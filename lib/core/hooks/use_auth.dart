import 'package:flutter_core/core/apis/app/interfaces/user.dart';
import 'package:flutter_core/features/auth/hooks/auth_provider.dart';
import 'package:flutter_core/features/user/hooks/user_provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A "Web-style" custom hook to access and manage authentication state and user data.
/// This hook is a pure Getter/Setter for the global [currentUserProvider].
class AuthContext {
  final User? user;
  final Function(User? user) setUser;
  final Future<void> Function() logout;

  AuthContext({
    required this.user,
    required this.setUser,
    required this.logout,
  });
}

AuthContext useAuth(WidgetRef ref) {
  final user = ref.watch(currentUserProvider);

  return useMemoized(() {
    return AuthContext(
      user: user,
      setUser: (User? u) {
        ref.read(currentUserProvider.notifier).state = u;
      },
      logout: () async {
        await ref.read(authProvider.notifier).logout();
        // The authProvider.logout() should already handle clearing,
        // but we ensure store is reset here too.
        ref.read(currentUserProvider.notifier).state = null;
      },
    );
  }, [user]);
}
