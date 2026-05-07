import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_core/core/apis/base/client/dio_factory.dart';
import 'package:flutter_core/core/storage/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    DioFactory.onAuthFailure = null;
  });

  test('refreshes token and resolves the original request retry', () async {
    final adapter = _AuthTestAdapter();
    final storage = await _storageWithTokens();

    DioFactory.initialize(
      apiBaseUrl: 'https://example.test/api/v1',
      localStorage: storage,
      httpClientAdapter: adapter,
    );

    final dio = DioFactory.instance.create('posts');
    final response = await dio
        .post<dynamic>('', data: {'content': 'hello'})
        .timeout(const Duration(seconds: 3));

    expect(response.data['data']['id'], 'post-1');
    expect(adapter.refreshCount, 1);
    expect(adapter.postAuthHeaders, ['Bearer old-token', 'Bearer new-token']);
    expect(storage.getToken(), 'new-token');
    expect(storage.getRefreshToken(), 'new-refresh-token');
  });

  test('clears tokens and reports auth failure when refresh fails', () async {
    final adapter = _AuthTestAdapter(refreshShouldFail: true);
    final storage = await _storageWithTokens();
    var authFailed = false;

    DioFactory.initialize(
      apiBaseUrl: 'https://example.test/api/v1',
      localStorage: storage,
      httpClientAdapter: adapter,
    );
    DioFactory.onAuthFailure = () => authFailed = true;

    final dio = DioFactory.instance.create('posts');

    await expectLater(
      dio
          .post<dynamic>('', data: {'content': 'hello'})
          .timeout(const Duration(seconds: 3)),
      throwsA(isA<DioException>()),
    );

    expect(adapter.refreshCount, 1);
    expect(authFailed, isTrue);
    expect(storage.getToken(), isNull);
    expect(storage.getRefreshToken(), isNull);
  });

  test(
    'does not refresh twice for queued requests after token changes',
    () async {
      final adapter = _AuthTestAdapter();
      final storage = await _storageWithTokens();

      DioFactory.initialize(
        apiBaseUrl: 'https://example.test/api/v1',
        localStorage: storage,
        httpClientAdapter: adapter,
      );

      final dio = DioFactory.instance.create('posts');

      final responses = await Future.wait([
        dio.post<dynamic>('', data: {'content': 'one'}),
        dio.post<dynamic>('', data: {'content': 'two'}),
      ]).timeout(const Duration(seconds: 3));

      expect(responses.map((response) => response.data['data']['id']), [
        'post-1',
        'post-1',
      ]);
      expect(adapter.refreshCount, 1);
      expect(adapter.postAuthHeaders, [
        'Bearer old-token',
        'Bearer old-token',
        'Bearer new-token',
        'Bearer new-token',
      ]);
    },
  );

  test('does not loop when retried request is still unauthorized', () async {
    final adapter = _AuthTestAdapter(postsAlwaysUnauthorized: true);
    final storage = await _storageWithTokens();
    var authFailed = false;

    DioFactory.initialize(
      apiBaseUrl: 'https://example.test/api/v1',
      localStorage: storage,
      httpClientAdapter: adapter,
    );
    DioFactory.onAuthFailure = () => authFailed = true;

    final dio = DioFactory.instance.create('posts');

    await expectLater(
      dio
          .post<dynamic>('', data: {'content': 'hello'})
          .timeout(const Duration(seconds: 3)),
      throwsA(isA<DioException>()),
    );

    expect(adapter.refreshCount, 1);
    expect(authFailed, isTrue);
    expect(adapter.postAuthHeaders, ['Bearer old-token', 'Bearer new-token']);
  });
}

Future<LocalStorage> _storageWithTokens() async {
  SharedPreferences.setMockInitialValues({
    'access_token': 'old-token',
    'refresh_token': 'refresh-token',
  });
  return LocalStorage(await SharedPreferences.getInstance());
}

class _AuthTestAdapter implements HttpClientAdapter {
  final bool refreshShouldFail;
  final bool postsAlwaysUnauthorized;
  final List<String?> postAuthHeaders = [];
  int refreshCount = 0;

  _AuthTestAdapter({
    this.refreshShouldFail = false,
    this.postsAlwaysUnauthorized = false,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await requestStream?.drain<void>();

    switch (options.uri.path) {
      case '/api/v1/posts':
        return _handlePost(options);
      case '/api/v1/auth/refresh':
        return _handleRefresh();
      default:
        return _json(404, {'message': 'not found'});
    }
  }

  @override
  void close({bool force = false}) {}

  ResponseBody _handlePost(RequestOptions options) {
    final auth = options.headers['Authorization'] as String?;
    postAuthHeaders.add(auth);

    if (!postsAlwaysUnauthorized && auth == 'Bearer new-token') {
      return _json(200, {
        'data': {'id': 'post-1', 'content': 'created'},
      });
    }

    return _json(401, {'message': 'expired'});
  }

  ResponseBody _handleRefresh() {
    refreshCount += 1;

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
