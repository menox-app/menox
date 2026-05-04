import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/apis/app/index.dart';
import 'package:flutter_core/core/apis/app/interfaces/comment.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';
import 'package:flutter_core/core/ui/widgets/app_icon_button.dart';
import 'package:flutter_core/features/home/widgets/comment_card.dart';
import 'package:flutter_core/features/home/widgets/post_card.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostDetailScreen extends HookConsumerWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiClient = AppApi.instance;
    final theme = CupertinoTheme.of(context);
    final scrollController = useScrollController();

    final commentsQuery = useInfiniteQuery<List<Comment>, dynamic, int>(
      ['comments', post.id],
      (context) async {
        final page = context.pageParam;
        final response = await apiClient.posts.getComments(
          IGetCommentsRequest(id: post.id, page: page, limit: 10),
        );
        return response.data;
      },
      initialPageParam: 1,
      nextPageParamBuilder: (data) {
        final lastPage = data.pages.last;
        if (lastPage.isEmpty || lastPage.length < 10) return null;
        return data.pages.length + 1;
      },
    );

    final allComments =
        commentsQuery.data?.pages.expand((page) => page).toList() ?? [];

    final isInitialLoading = commentsQuery.isLoading && allComments.isEmpty;

    useEffect(
      () {
        void onScroll() {
          if (scrollController.position.pixels >=
                  scrollController.position.maxScrollExtent - 200 &&
              commentsQuery.hasNextPage &&
              !commentsQuery.isFetchingNextPage) {
            commentsQuery.fetchNextPage();
          }
        }

        scrollController.addListener(onScroll);
        return () => scrollController.removeListener(onScroll);
      },
      [
        scrollController,
        commentsQuery.hasNextPage,
        commentsQuery.isFetchingNextPage,
      ],
    );

    return CupertinoPageScaffold(
      backgroundColor: ShadcnColors.background,
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
      child: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Post Detail
          SliverToBoxAdapter(
            child: PostCard(post: post, isDetail: true),
          ),

          // Pull to refresh
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              await commentsQuery.refetch();
            },
          ),

          if (isInitialLoading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const CommentCardSkeleton(),
                childCount: 5,
              ),
            )
          else if (allComments.isEmpty)
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
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return CommentCard(
                    comment: allComments[index],
                    isLast: index == allComments.length - 1,
                  );
                },
                childCount: allComments.length,
              ),
            ),

          if (commentsQuery.isFetchingNextPage)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const CommentCardSkeleton(),
                childCount: 2,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }
}
