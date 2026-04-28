import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/apis/app/index.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'package:flutter_core/core/hooks/use_auth.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/assets/app_icons.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';
import 'package:flutter_core/core/ui/widgets/app_icon_button.dart';
import 'package:flutter_core/features/home/widgets/post_card.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiClient = AppApi.instance;
    final user = useAuth(ref).user;
    final theme = CupertinoTheme.of(context);
    // ── Infinite Query — page-based pagination ──
    final postsQuery = useInfiniteQuery<List<Post>, dynamic, int>(
      ['posts', 'feed'],
      (context) async {
        final page = context.pageParam;
        final response = await apiClient.posts.getAll(
          BasePaginationRequest(page: page, limit: 10),
        );
        return response.data;
      },
      initialPageParam: 1,
      nextPageParamBuilder: (data) {
        // Nếu page cuối trả về ít hơn limit → hết data
        final lastPage = data.pages.last;
        if (lastPage.isEmpty || lastPage.length < 10) return null;
        return data.pages.length + 1;
      },
    );

    // Flatten all pages into single list
    final allPosts =
        postsQuery.data?.pages.expand((page) => page).toList() ?? [];

    // ── Scroll Controller for infinite load ──
    final scrollController = useScrollController();

    useEffect(
      () {
        void onScroll() {
          if (scrollController.position.pixels >=
                  scrollController.position.maxScrollExtent - 200 &&
              postsQuery.hasNextPage &&
              !postsQuery.isFetchingNextPage) {
            postsQuery.fetchNextPage();
          }
        }

        scrollController.addListener(onScroll);
        return () => scrollController.removeListener(onScroll);
      },
      [scrollController, postsQuery.hasNextPage, postsQuery.isFetchingNextPage],
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        border: null,
        backgroundColor: ShadcnColors.background,
        leading: AppIconButton(
          icon: CupertinoIcons.equal,
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
          icon: CupertinoIcons.at,
          sizeOverride: 32,
          variant: AppButtonVariant.ghost,
          onPressed: () =>{},
        
        ),
      ),
      child: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ── Create Post ──
          SliverToBoxAdapter(
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
                      image: user?.avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(user!.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: ShadcnColors.accent,
                    ),
                    child: user?.avatarUrl == null
                        ? const Icon(
                            CupertinoIcons.person,
                            size: 20,
                            color: ShadcnColors.accentForeground,
                          )
                        : null,
                  ),
                  // Username
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2.5,
                    children: [
                    Text(user?.username ?? 'No username', style: theme.textTheme.textStyle.copyWith(color: ShadcnColors.foreground, fontWeight: FontWeight.w500, fontSize: 15),),
                    Text("What's happening on your mind?", style: theme.textTheme.textStyle.copyWith(fontSize: 13, color: ShadcnColors.mutedForeground),),
                  ],
                  )
                ],
              ),
            ),
          ),

          // Divider
          const SliverToBoxAdapter(
            child: Divider(
              height: 1,
              color: ShadcnColors.border,
            ),
          ),  

          // ── Pull to Refresh ──
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              await postsQuery.refetch();
            },
          ),
          // ── Posts List ──
          if (postsQuery.isLoading && allPosts.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            )
          else if (allPosts.isEmpty)
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
                        CupertinoIcons.photo_on_rectangle,
                        size: 28,
                        color: ShadcnColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Your feed is empty',
                      style: theme.textTheme.textStyle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Follow friends to see their memes here.',
                      style: theme.textTheme.textStyle.copyWith(
                        fontSize: 13,
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
                if (index < allPosts.length) {
                  return PostCard(post: allPosts[index]);
                }
                return null;
              }, childCount: allPosts.length),
            ),

          // ── Loading more indicator ──
          if (postsQuery.isFetchingNextPage)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CupertinoActivityIndicator()),
              ),
            ),

          // ── End of feed ──
          if (!postsQuery.hasNextPage && allPosts.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    "You're all caught up 🎉",
                    style: theme.textTheme.textStyle.copyWith(
                      fontSize: 13,
                      color: ShadcnColors.mutedForeground,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom padding for the floating nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
