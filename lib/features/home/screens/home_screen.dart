import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/assets/app_icons.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';
import 'package:flutter_core/core/ui/widgets/app_icon_button.dart';
import 'package:flutter_core/core/ui/widgets/app_image.dart';
import 'package:flutter_core/features/home/providers/post_providers.dart';
import 'package:flutter_core/features/home/widgets/create_post_sheet.dart';
import 'package:flutter_core/features/home/widgets/post_card.dart';
import 'package:flutter_core/features/user/providers/user_provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_core/core/ui/widgets/app_error_state.dart';
import 'package:flutter_core/core/ui/widgets/app_scaffold.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = CupertinoTheme.of(context);
    final postsAsync = ref.watch(feedPostsProvider);
    final postsNotifier = ref.read(feedPostsProvider.notifier);
    final postsState = postsAsync.valueOrNull;

    final scrollController = useScrollController();

    useEffect(
      () {
        void onScroll() {
          if (scrollController.position.pixels >=
                  scrollController.position.maxScrollExtent - 200 &&
              postsState?.hasNextPage == true &&
              postsState?.isFetchingNextPage != true) {
            postsNotifier.fetchNextPage();
          }
        }

        scrollController.addListener(onScroll);
        return () => scrollController.removeListener(onScroll);
      },
      [
        scrollController,
        postsState?.hasNextPage,
        postsState?.isFetchingNextPage,
      ],
    );

    return AppScaffold(
      controller: scrollController,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        border: null,
        backgroundColor: ShadcnColors.background,
        leading: AppIconButton(
          icon: FluentIcons.navigation_24_regular,
          sizeOverride: 32,
          variant: AppButtonVariant.ghost,
          onPressed: () => {},
        ),
        middle: SizedBox(
          width: 28,
          height: 28,
          child: SvgPicture.asset(AppIcons.appLogo, fit: BoxFit.contain),
        ),
        trailing: AppIconButton(
          icon: FluentIcons.mention_24_regular,
          sizeOverride: 32,
          variant: AppButtonVariant.ghost,
          onPressed: () => {},
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () => showCreatePostSheet(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                spacing: 8,
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ShadcnColors.border,
                        width: 0.5,
                      ),
                      color: ShadcnColors.accent,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AppImage.avatar(
                      url: user?.avatarUrl,
                      size: 40,
                      backgroundColor: ShadcnColors.accent,
                      errorIcon: FluentIcons.person_24_regular,
                      errorIconSize: 20,
                    ),
                  ),
                  // Username
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2.5,
                    children: [
                      Text(
                        user?.username ?? 'No username',
                        style: theme.textTheme.textStyle.copyWith(
                          color: ShadcnColors.foreground,
                          fontWeight: FontWeight.w500,
                          fontSize: AppFontSizes.body,
                        ),
                      ),
                      Text(
                        "What's happening on your mind?",
                        style: theme.textTheme.textStyle.copyWith(
                          fontSize: AppFontSizes.meta,
                          color: ShadcnColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Divider
        const SliverToBoxAdapter(
          child: Divider(height: 1, color: ShadcnColors.border),
        ),

        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await postsNotifier.refresh();
          },
        ),

        ...postsAsync.when(
          skipLoadingOnRefresh: true,
          data: (postsState) {
            final posts = postsState.items;
            return [
              if (posts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: ShadcnColors.secondary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            FluentIcons.image_24_regular,
                            size: 28,
                            color: ShadcnColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Your feed is empty',
                          style: theme.textTheme.textStyle.copyWith(
                            fontSize: AppFontSizes.body,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Follow friends to see their memes here.',
                          style: theme.textTheme.textStyle.copyWith(
                            fontSize: AppFontSizes.meta,
                            color: ShadcnColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return PostCard(post: posts[index]);
                  }, childCount: posts.length),
                ),
              if (postsState.isFetchingNextPage)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const PostCardSkeleton(),
                    childCount: 2,
                  ),
                ),
              if (!postsState.hasNextPage && posts.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        "You're all caught up",
                        style: theme.textTheme.textStyle.copyWith(
                          fontSize: AppFontSizes.meta,
                          color: ShadcnColors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                ),
            ];
          },
          loading: () => [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const PostCardSkeleton(),
                childCount: 5,
              ),
            ),
          ],
          error: (error, stackTrace) => [
            SliverFillRemaining(
              child: AppErrorState(
                error: error,
                onRetry: () => postsNotifier.refresh(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
