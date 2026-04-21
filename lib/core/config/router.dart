import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_core/features/auth/presentation/pages/welcome_page.dart';
import 'package:flutter_core/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_core/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_core/features/home/presentation/pages/home_page.dart';
import 'package:flutter_core/features/pokemon/presentation/pages/pokemon_list_page.dart';
import 'package:flutter_core/features/auth/presentation/providers/auth_provider.dart';

/// Routes that only unauthenticated users should access.
const _authRoutes = {'/welcome', '/login', '/register'};

final routerProvider = Provider<GoRouter>((ref) {
  // ValueNotifier bridges Riverpod auth state → GoRouter refreshListenable.
  // GoRouter calls redirect() whenever this notifier fires.
  final refreshNotifier = ValueNotifier<bool>(false);

  ref.listen<AuthState>(authProvider, (previous, next) {
    if (previous?.status != next.status) {
      // Toggle value to trigger GoRouter refresh
      refreshNotifier.value = !refreshNotifier.value;
    }
  });

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, routerState) {
      final authState = ref.read(authProvider);

      // Still resolving auth (checking token / refreshing) — don't redirect yet
      if (authState.isUnknown) return null;

      final isAuthenticated = authState.isAuthenticated;
      final location = routerState.matchedLocation;
      final isOnAuthRoute = _authRoutes.contains(location);

      // Not authenticated and trying to access a protected route
      if (!isAuthenticated && !isOnAuthRoute) return '/welcome';

      // Authenticated and trying to access an auth-only route
      if (isAuthenticated && isOnAuthRoute) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => const CupertinoPage(
          child: HomePage(),
        ),
      ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => const CupertinoPage(
          child: WelcomePage(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const CupertinoPage(
          child: LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => const CupertinoPage(
          child: RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/pokemon',
        pageBuilder: (context, state) => const CupertinoPage(
          child: PokemonListPage(),
        ),
      ),
    ],
  );
});
