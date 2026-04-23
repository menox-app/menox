import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/hooks/use_auth.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/features/auth/presentation/providers/auth_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = CupertinoTheme.of(context);
    final auth = useAuth(ref);
    final user = auth.user;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        border: null,
        backgroundColor: ShadcnColors.background,
        middle: const Text(
          'Menox',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => ref.read(authProvider.notifier).logout(),
          child: const Icon(
            CupertinoIcons.square_arrow_right,
            color: ShadcnColors.destructive,
            size: 22,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Greeting row linked to the cached user profile
              Row(
                children: [
                  // Avatar with cached URL
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: ShadcnColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ShadcnColors.border,
                        width: 1.5,
                      ),
                      image: user?.avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(user!.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user?.avatarUrl == null
                        ? const Icon(
                            CupertinoIcons.person_fill,
                            color: ShadcnColors.mutedForeground,
                            size: 26,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning 👋',
                        style: theme.textTheme.textStyle.copyWith(
                          fontSize: 13,
                          color: ShadcnColors.mutedForeground,
                        ),
                      ),
                      Text(
                        user != null ? 'Welcome back, ${user.displayName.split(' ')[0]}!' : 'Welcome back!',
                        style: theme.textTheme.textStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Divider
              Container(height: 1, color: ShadcnColors.border),

              const SizedBox(height: 32),

              // Placeholder content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: ShadcnColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          CupertinoIcons.photo_on_rectangle,
                          size: 32,
                          color: ShadcnColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your feed is empty',
                        style: theme.textTheme.textStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Follow friends to see their memes here.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.textStyle.copyWith(
                          fontSize: 13,
                          color: ShadcnColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
