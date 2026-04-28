import 'package:flutter_core/core/apis/base/client/dio_factory.dart';
import 'package:flutter_core/core/storage/local_storage.dart';
import 'package:flutter_core/main.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// ---------------------------------------------------------------------------
// Auth State
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Auth Notifier — Instant Auth Pattern
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  final LocalStorage _storage;
  final QueryClient _queryClient;

  AuthNotifier(this._storage, this._queryClient)
      : super(AuthState(
          status: _storage.getToken() != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
        )) {
    // Đăng ký callback — khi DioFactory refresh fail → tự logout
    DioFactory.onAuthFailure = _handleAuthFailure;

    if (state.isAuthenticated) {
      _verifyInBackground();
    }
  }

  /// Gọi bởi DioFactory khi refresh token thất bại
  void _handleAuthFailure() {
    _storage.clearAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
    _queryClient.removeQueries(queryKey: ['auth', 'me'], exact: true);
  }

  /// Background verification — user đã thấy Home với cached data.
  /// Nếu token hết hạn, interceptor tự refresh.
  /// Nếu refresh cũng fail → kick về Login.
  Future<void> _verifyInBackground() async {
    try {
      _queryClient.invalidateQueries(
        queryKey: ['auth', 'me'],
        exact: true,
        refetchType: RefetchType.active,
      );
    } catch (_) {
      // Token + refresh đều fail → clear & redirect login
      await _storage.clearAll();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Called after successful login.
  Future<void> login(String accessToken, String refreshToken) async {
    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    state = const AuthState(status: AuthStatus.authenticated);
    
    // Invalidate profile query to trigger fresh fetch
    _queryClient.invalidateQueries(
      queryKey: ['auth', 'me'],
      refetchType: RefetchType.active,
    );
  }

  /// Called on logout — clears all tokens + cached user.
  Future<void> logout() async {
    await _storage.clearAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
    
    // Clear the user cache on logout
    _queryClient.removeQueries(
      queryKey: ['auth', 'me'],
      exact: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(localStorageProvider),
    ref.read(queryClientProvider),
  );
});
