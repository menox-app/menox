import 'package:flutter/cupertino.dart';
import 'package:flutter_core/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_core/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_core/features/auth/presentation/pages/welcome_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_core/features/messages/presentation/pages/messages_page.dart';
import 'package:flutter_core/features/activity/presentation/pages/activity_page.dart';
import 'package:flutter_core/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_core/features/home/presentation/pages/main_screen.dart';
import 'package:flutter_core/features/home/presentation/pages/home_page.dart';
import 'package:flutter_core/features/auth/presentation/providers/auth_provider.dart';

/// Routes that only unauthenticated users should access.
const _authRoutes = {'/welcome', '/login', '/register'};

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _messagesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'messages');
final _activityNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'activity');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<bool>(false);

  ref.listen<AuthState>(authProvider, (previous, next) {
    if (previous?.status != next.status) {
      refreshNotifier.value = !refreshNotifier.value;
    }
  });

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, routerState) {
      final authState = ref.read(authProvider);
      if (authState.isUnknown) return null;

      final isAuthenticated = authState.isAuthenticated;
      final location = routerState.matchedLocation;
      final isOnAuthRoute = _authRoutes.contains(location);

      if (!isAuthenticated && !isOnAuthRoute) return '/welcome';
      if (isAuthenticated && isOnAuthRoute) return '/';

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/welcome',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: WelcomePage()),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: LoginPage()),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: RegisterPage()),
      ),

      // Main Shell Route
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: HomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _messagesNavigatorKey,
            routes: [
              GoRoute(
                path: '/messages',
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: MessagesPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _activityNavigatorKey,
            routes: [
              GoRoute(
                path: '/activity',
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: ActivityPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: ProfilePage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
