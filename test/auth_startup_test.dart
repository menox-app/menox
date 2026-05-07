import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_core/core/apis/app/index.dart';
import 'package:flutter_core/core/apis/base/client/dio_factory.dart';
import 'package:flutter_core/core/storage/local_storage.dart';
import 'package:flutter_core/features/auth/providers/auth_provider.dart';
import 'package:flutter_core/features/user/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    DioFactory.onAuthFailure = null;
  });

  test(
    'shows cached user immediately then refreshes profile from /me',
    () async {
      final adapter = _AuthStartupAdapter();
      final storage = await _storageWithAuth(
        cachedUser: _userJson(id: 'cached', username: 'cached_user'),
      );
      AppApi.initialize(
        baseUrl: 'https://example.test',
        localStorage: storage,
        httpClientAdapter: adapter,
      );

      final container = ProviderContainer(
        overrides: [localStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      expect(container.read(authProvider).isAuthenticated, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(currentUserProvider)?.username, 'cached_user');

      await adapter.meRequested.future.timeout(const Duration(seconds: 3));
      await _waitUntil(
        () => container.read(currentUserProvider)?.username == 'fresh_user',
      );

      expect(adapter.meCount, 1);
      expect(container.read(currentUserProvider)?.username, 'fresh_user');
      expect(storage.getCachedUserJson()?['username'], 'fresh_user');
    },
  );

  test('malformed cached user does not block /me', () async {
    final adapter = _AuthStartupAdapter();
    final storage = await _storageWithAuth(
      cachedUser: {
        ..._userJson(id: 'cached', username: 'cached_user'),
        'tags': [1],
      },
    );
    AppApi.initialize(
      baseUrl: 'https://example.test',
      localStorage: storage,
      httpClientAdapter: adapter,
    );

    final container = ProviderContainer(
      overrides: [localStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    expect(container.read(authProvider).isAuthenticated, isTrue);
    await Future<void>.delayed(Duration.zero);

    await adapter.meRequested.future.timeout(const Duration(seconds: 3));
    await _waitUntil(
      () => container.read(currentUserProvider)?.username == 'fresh_user',
    );

    expect(adapter.meCount, 1);
    expect(container.read(currentUserProvider)?.username, 'fresh_user');
    expect(storage.getCachedUserJson()?['username'], 'fresh_user');
  });

  test('401 from /me with failed refresh signs the user out', () async {
    final adapter = _AuthStartupAdapter(
      meShouldUnauthorized: true,
      refreshShouldFail: true,
    );
    final storage = await _storageWithAuth(
      cachedUser: _userJson(id: 'cached', username: 'cached_user'),
    );
    AppApi.initialize(
      baseUrl: 'https://example.test',
      localStorage: storage,
      httpClientAdapter: adapter,
    );

    final container = ProviderContainer(
      overrides: [localStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    expect(container.read(authProvider).isAuthenticated, isTrue);
    await Future<void>.delayed(Duration.zero);

    await adapter.refreshRequested.future.timeout(const Duration(seconds: 3));
    await _waitUntil(
      () => container.read(authProvider).status == AuthStatus.unauthenticated,
    );

    expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    expect(container.read(currentUserProvider), isNull);
    expect(storage.getToken(), isNull);
  });

  test('non-auth /me failure keeps cached authenticated session', () async {
    final adapter = _AuthStartupAdapter(meStatusCode: 500);
    final storage = await _storageWithAuth(
      cachedUser: _userJson(id: 'cached', username: 'cached_user'),
    );
    AppApi.initialize(
      baseUrl: 'https://example.test',
      localStorage: storage,
      httpClientAdapter: adapter,
    );

    final container = ProviderContainer(
      overrides: [localStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    expect(container.read(authProvider).isAuthenticated, isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(currentUserProvider)?.username, 'cached_user');

    await adapter.meRequested.future.timeout(const Duration(seconds: 3));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(container.read(authProvider).isAuthenticated, isTrue);
    expect(container.read(currentUserProvider)?.username, 'cached_user');
    expect(storage.getToken(), 'old-token');
  });
}

Future<void> _waitUntil(bool Function() predicate) async {
  for (var i = 0; i < 50; i += 1) {
    if (predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  if (!predicate()) {
    throw StateError('Timed out waiting for auth startup state');
  }
}

Future<LocalStorage> _storageWithAuth({
  Map<String, dynamic>? cachedUser,
}) async {
  SharedPreferences.setMockInitialValues({
    'access_token': 'old-token',
    'refresh_token': 'refresh-token',
    if (cachedUser != null) 'cached_user': jsonEncode(cachedUser),
  });
  return LocalStorage(await SharedPreferences.getInstance());
}

Map<String, dynamic> _userJson({required String id, required String username}) {
  return {
    'id': id,
    'email': '$username@example.test',
    'username': username,
    'display_name': username,
    'followers_count': 0,
    'following_count': 0,
    'posts_count': 0,
    'activity_level': 'Normal',
    'tags': <String>[],
  };
}

class _AuthStartupAdapter implements HttpClientAdapter {
  final bool meShouldUnauthorized;
  final bool refreshShouldFail;
  final int meStatusCode;
  final Completer<void> meRequested = Completer<void>();
  final Completer<void> refreshRequested = Completer<void>();
  int meCount = 0;

  _AuthStartupAdapter({
    this.meShouldUnauthorized = false,
    this.refreshShouldFail = false,
    this.meStatusCode = 200,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await requestStream?.drain<void>();

    switch (options.uri.path) {
      case '/api/v1/auth/me':
        return _handleMe();
      case '/api/v1/auth/refresh':
        return _handleRefresh();
      default:
        return _json(404, {'message': 'not found'});
    }
  }

  @override
  void close({bool force = false}) {}

  ResponseBody _handleMe() {
    meCount += 1;
    if (!meRequested.isCompleted) meRequested.complete();

    if (meShouldUnauthorized) {
      return _json(401, {'message': 'expired'});
    }

    if (meStatusCode != 200) {
      return _json(meStatusCode, {'message': 'server error'});
    }

    return _json(200, {'data': _userJson(id: 'fresh', username: 'fresh_user')});
  }

  ResponseBody _handleRefresh() {
    if (!refreshRequested.isCompleted) refreshRequested.complete();

    if (refreshShouldFail) {
      return _json(401, {'message': 'refresh expired'});
    }

    return _json(200, {
      'data': {
        'access_token': 'new-token',
        'refresh_token': 'new-refresh-token',
      },
    });
  }

  ResponseBody _json(int statusCode, Map<String, dynamic> body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
