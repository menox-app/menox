import 'package:flutter/cupertino.dart';
import 'package:flutter_core/features/auth/screens/login_screen.dart';
import 'package:flutter_core/features/auth/screens/register_screen.dart';
import 'package:flutter_core/features/auth/screens/welcome_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/features/messages/screens/messages_screen.dart';
import 'package:flutter_core/features/activity/screens/activity_screen.dart';
import 'package:flutter_core/features/profile/screens/profile_screen.dart';
import 'package:flutter_core/features/home/screens/main_screen.dart';
import 'package:flutter_core/features/home/screens/home_screen.dart';
import 'package:flutter_core/features/post/screens/post_detail_screen.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/features/auth/providers/auth_provider.dart';
import 'package:flutter_core/core/ui/layout/app_scaffold.dart';

/// Routes that only unauthenticated users should access.
const _authRoutes = {'/welcome', '/login', '/register'};

final rootNavigatorKey = GlobalKey<NavigatorState>();
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
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, routerState) {
      final authState = ref.read(authProvider);
      if (authState.isUnknown) return null;
      if (authState.isSessionExpired) return null;

      final isAuthenticated = authState.isAuthenticated;
      final location = routerState.matchedLocation;
      final isOnAuthRoute = _authRoutes.contains(location);

      if (!isAuthenticated && !isOnAuthRoute) return '/welcome';
      if (isAuthenticated && isOnAuthRoute) return '/';

      return null;
    },
    errorBuilder: (context, state) => AppScaffold(
      navigationBar: const CupertinoNavigationBar(
        padding: AppSpacing.navigationBarPadding,
        middle: Text('Not Found'),
        border: null,
      ),
      error: state.error ?? 'The page you are looking for does not exist.',
    ),
    routes: [
      // Auth Routes
      GoRoute(
        path: '/welcome',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: WelcomeScreen()),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            const CupertinoPage(child: RegisterScreen()),
      ),
      GoRoute(
        path: '/post/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final post = state.extra as Post;
          return CupertinoPage(child: PostDetailScreen(post: post));
        },
      ),

      // Main Shell Route
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
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
                    const CupertinoPage(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _messagesNavigatorKey,
            routes: [
              GoRoute(
                path: '/messages',
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: MessagesScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _activityNavigatorKey,
            routes: [
              GoRoute(
                path: '/activity',
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: ActivityScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    const CupertinoPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
