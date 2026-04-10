import 'package:flutter/cupertino.dart';
import 'package:flutter_core/features/auth/presentation/pages/welcome_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_core/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_core/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_core/features/pokemon/presentation/pages/pokemon_list_page.dart';

final router = GoRouter(
  initialLocation: '/welcome',
  routes: [
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
