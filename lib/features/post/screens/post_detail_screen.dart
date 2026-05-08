import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/controls/app_button.dart';
import 'package:flutter_core/core/ui/controls/app_icon_button.dart';
import 'package:flutter_core/features/comment/providers/comment_providers.dart';
import 'package:flutter_core/features/post/providers/post_providers.dart';
import 'package:flutter_core/core/ui/layout/app_scaffold.dart';
import 'package:flutter_core/features/comment/widgets/comment_input_bar.dart';
import 'package:flutter_core/features/comment/widgets/comment_card.dart';
import 'package:flutter_core/features/post/widgets/post_card.dart';
import 'package:flutter_core/core/ui/feedback/app_error_state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostDetailScreen extends HookConsumerWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(post.id));
    final currentPost = postAsync.valueOrNull ?? post;
    final theme = CupertinoTheme.of(context);
    final scrollController = useScrollController();
    final commentsAsync = ref.watch(commentsProvider(post.id));
    final commentsNotifier = ref.read(commentsProvider(post.id).notifier);
    final commentsState = commentsAsync.valueOrNull;

    useEffect(
      () {
        void onScroll() {
          if (scrollController.position.pixels >=
                  scrollController.position.maxScrollExtent - 200 &&
              commentsState?.hasNextPage == true &&
              commentsState?.isFetchingNextPage != true) {
            commentsNotifier.fetchNextPage();
          }
        }

        scrollController.addListener(onScroll);
        return () => scrollController.removeListener(onScroll);
      },
      [
        scrollController,
        commentsState?.hasNextPage,
        commentsState?.isFetchingNextPage,
      ],
    );

    return AppScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: AppSpacing.navigationBarPadding,
        backgroundColor: ShadcnColors.background,
        border: const Border(
          bottom: BorderSide(color: ShadcnColors.border, width: 0.5),
        ),
        leading: AppButton(
          icon: FluentIcons.chevron_left_24_filled,
          variant: AppButtonVariant.ghost,
          text: "Back",
          size: AppButtonSize.xs,
          iconSize: 18,
          alignment: Alignment.centerLeft,
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Thread',
              style: theme.textTheme.navTitleTextStyle.copyWith(
                color: ShadcnColors.foreground,
                fontSize: AppFontSizes.body,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Chi tiết bài viết',
              style: theme.textTheme.navTitleTextStyle.copyWith(
                color: ShadcnColors.mutedForeground,
                fontSize: AppFontSizes.meta,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIconButton(
              icon: FluentIcons.alert_24_regular,
              size: AppButtonSize.xs,
              iconSize: 22,
              variant: AppButtonVariant.ghost,
              onPressed: () {},
            ),
          ],
        ),
      ),
      child: ColoredBox(
        color: ShadcnColors.background,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // Post Detail
                  SliverToBoxAdapter(
                    child: PostCard(post: currentPost, isDetail: true),
                  ),

                  // Pull to refresh
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      await commentsNotifier.refresh();
                    },
                  ),

                  ...commentsAsync.when(
                    skipLoadingOnRefresh: true,
                    data: (commentsState) {
                      final comments = commentsState.items;
                      return [
                        if (comments.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Center(
                                child: Text(
                                  'No comments yet.',
                                  style: theme.textTheme.textStyle.copyWith(
                                    fontSize: AppFontSizes.bodySmall,
                                    color: ShadcnColors.mutedForeground,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return CommentCard(
                                post: currentPost,
                                comment: comments[index],
                                isLast: index == comments.length - 1,
                              );
                            }, childCount: comments.length),
                          ),
                        if (commentsState.isFetchingNextPage)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => const CommentCardSkeleton(),
                              childCount: 2,
                            ),
                          ),
                      ];
                    },
                    loading: () => [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const CommentCardSkeleton(),
                          childCount: 5,
                        ),
                      ),
                    ],
                    error: (error, stackTrace) => [
                      SliverToBoxAdapter(
                        child: AppErrorState(
                          error: error,
                          onRetry: () => commentsNotifier.refresh(),
                          showHomeButton: false,
                        ),
                      ),
                    ],
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                ],
              ),
            ),
            CommentInputBar(post: currentPost),
          ],
        ),
      ),
    );
  }
}
