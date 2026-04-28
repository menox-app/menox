import 'package:flutter_core/core/apis/app/index.dart' show AppApi;
import 'package:flutter_core/core/apis/app/client/auth.dart';
import 'package:flutter_core/core/apis/app/interfaces/auth.dart';
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
// Auth Notifier
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  final LocalStorage _storage;
  final AuthApiClient _authClient;
  final QueryClient _queryClient;

  AuthNotifier(this._storage, this._authClient, this._queryClient) : super(const AuthState()) {
    _checkAuth();
  }

  /// Called on app startup — determines if user is authenticated.
  Future<void> _checkAuth() async {
    final accessToken = _storage.getToken();

    // 1. Access token exists → authenticated
    if (accessToken != null) {
      state = const AuthState(status: AuthStatus.authenticated);
      _queryClient.invalidateQueries(
        queryKey: ['auth', 'me'],
        exact: true,
        refetchType: RefetchType.active,
      );
      return;
    }

    // 2. No access token → try refresh
    final refreshToken = _storage.getRefreshToken();
    if (refreshToken == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final response = await _authClient.refreshToken(
        RefreshTokenBody(refreshToken: refreshToken),
      );
      await _storage.saveTokens(
        accessToken: response.data.token,
        refreshToken: response.data.refreshToken,
      );
      state = const AuthState(status: AuthStatus.authenticated);
      _queryClient.invalidateQueries(queryKey: ['auth', 'me']);
    } catch (_) {
      // Refresh token expired — clear everything, force re-login
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

  /// Called on logout — clears all tokens.
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
    AppApi.instance.auth,
    ref.read(queryClientProvider),
  );
});
