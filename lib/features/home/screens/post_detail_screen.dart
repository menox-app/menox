import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';
import 'package:flutter_core/core/ui/widgets/app_icon_button.dart';
import 'package:flutter_core/features/home/providers/post_providers.dart';
import 'package:flutter_core/features/home/widgets/comment_card.dart';
import 'package:flutter_core/features/home/widgets/post_card.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_core/core/ui/widgets/app_scaffold.dart';

class PostDetailScreen extends HookConsumerWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        backgroundColor: ShadcnColors.background,
        border: const Border(
          bottom: BorderSide(color: ShadcnColors.border, width: 0.5),
        ),
        leading: AppIconButton(
          icon: FluentIcons.ios_arrow_ltr_24_filled,
          sizeOverride: 28,
          variant: AppButtonVariant.ghost,
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
              '598K lượt xem',
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
              sizeOverride: 28,
              variant: AppButtonVariant.ghost,
              onPressed: () {},
            ),
            AppIconButton(
              icon: FluentIcons.more_horizontal_24_regular,
              sizeOverride: 28,
              variant: AppButtonVariant.ghost,
              onPressed: () {},
            ),
          ],
        ),
      ),     
      controller: scrollController,
      slivers: [
        // Post Detail
        SliverToBoxAdapter(child: PostCard(post: post, isDetail: true)),

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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return CommentCard(
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
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.textStyle.copyWith(
                      fontSize: AppFontSizes.bodySmall,
                      color: ShadcnColors.mutedForeground,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
