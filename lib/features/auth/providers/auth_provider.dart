import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_core/core/apis/app/interfaces/auth.dart';
import 'package:flutter_core/core/apis/app/interfaces/user.dart';
import 'package:flutter_core/core/apis/app/providers.dart';
import 'package:flutter_core/core/apis/base/client/dio_factory.dart';
import 'package:flutter_core/core/state/async_action.dart';
import 'package:flutter_core/core/storage/local_storage.dart';
import 'package:flutter_core/features/user/providers/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;

  const AuthState({this.status = AuthStatus.unknown});

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnknown => status == AuthStatus.unknown;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AuthState && other.status == status);

  @override
  int get hashCode => status.hashCode;
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final LocalStorage _storage;

  @override
  AuthState build() {
    _storage = ref.read(localStorageProvider);
    DioFactory.onAuthFailure = _handleAuthFailure;

    final token = _storage.getToken();
    final authState = AuthState(
      status: token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );

    if (authState.isAuthenticated) {
      // Background sync to validate token and refresh profile
      Future<void>.delayed(Duration.zero, _syncUserInBackground);
    }

    return authState;
  }

  void _handleAuthFailure() {
    unawaited(_storage.clearAll());
    state = const AuthState(status: AuthStatus.unauthenticated);
    ref.read(currentUserProvider.notifier).clear();
  }

  Future<void> _syncUserInBackground() async {
    await _loadCachedUser();
    await _fetchFreshUser();
  }

  Future<void> _loadCachedUser() async {
    try {
      final cached = _storage.getCachedUserJson();
      if (cached != null) {
        ref.read(currentUserProvider.notifier).setUser(User.fromJson(cached));
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Cached user parse failed: $error');
      }
      await _storage.clearCachedUser();
    }
  }

  Future<void> _fetchFreshUser() async {
    if (_storage.getToken() == null) return;

    try {
      final response = await ref.read(appApiProvider).auth.getMe();
      final user = response.data;
      await _storage.saveUserProfile(user.toJson());
      ref.read(currentUserProvider.notifier).setUser(user);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        _handleAuthFailure();
      } else if (kDebugMode) {
        debugPrint('/auth/me failed: ${error.message}');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('/auth/me failed: $error');
      }
    }
  }

  Future<void> login(String accessToken, String refreshToken) async {
    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    state = const AuthState(status: AuthStatus.authenticated);
    unawaited(_syncUserInBackground());
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
    ref.read(currentUserProvider.notifier).clear();
  }
}

@riverpod
class AuthAction extends _$AuthAction with AsyncAction<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(ISignInRequest request) => execute(() async {
    final response = await ref.read(appApiProvider).auth.signIn(request);
    await ref
        .read(authProvider.notifier)
        .login(response.data.token, response.data.refreshToken);
  });

  Future<void> signUp(ISignUpRequest request) => execute(() async {
    final response = await ref.read(appApiProvider).auth.signUp(request);
    await ref
        .read(authProvider.notifier)
        .login(response.data.token, response.data.refreshToken);
  });
}
