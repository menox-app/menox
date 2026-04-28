import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/hooks/use_auth.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/features/auth/hooks/auth_provider.dart';
import 'package:flutter_core/features/profile/widgets/profile_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = useAuth(ref);
    final user = auth.user;

    // Removal of forced dark mode override
    return CupertinoPageScaffold(
      backgroundColor: ShadcnColors.background,
      child: user == null
          ? const Center(child: CupertinoActivityIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Collapsing Banner Header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ProfileHeaderDelegate(
                    expandedHeight: 280,
                    bannerUrl: user.bannerUrl,
                    avatarUrl: user.avatarUrl,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Handle Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.displayName,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      height: 1.1,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '@${user.username}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: ShadcnColors.mutedForeground
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: ShadcnColors.primary.withValues(
                                  alpha: 0.3,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.infinite,
                                size: 20,
                                color: ShadcnColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Stats Row
                        Row(
                          children: [
                            ProfileStatItem(
                              label: 'Followers',
                              value:
                                  '${(user.followersCount / 1000).toStringAsFixed(1)}K',
                            ),
                            _divider(),
                            ProfileStatItem(
                              label: 'Following',
                              value: '${user.followingCount}',
                            ),
                            _divider(),
                            ProfileStatItem(
                              label: 'Posts',
                              value: '${user.postsCount}',
                            ),
                            _divider(),
                            ProfileStatItem(
                              label: 'Activity',
                              value: user.activityLevel,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        if (user.bioQuote != null) ...[
                          Text(
                            '"${user.bioQuote}"',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (user.bio != null)
                          Text(
                            user.bio!,
                            style: TextStyle(
                              fontSize: 15,
                              color: ShadcnColors.mutedForeground.withValues(
                                alpha: 0.9,
                              ),
                              height: 1.5,
                            ),
                          ),

                        const SizedBox(height: 24),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.tags
                              .map((tag) => ProfileTagChip(label: tag))
                              .toList(),
                        ),

                        const SizedBox(height: 40),

                        PremiumGradientButton(
                          text: 'Logout',
                          onTap: () => ref.read(authProvider.notifier).logout(),
                        ),

                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _divider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: ShadcnColors.border.withValues(alpha: 0.2),
    );
  }
}
