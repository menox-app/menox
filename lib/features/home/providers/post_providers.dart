import 'dart:async';

import 'package:flutter_core/core/apis/app/interfaces/comment.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/apis/app/providers.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'package:flutter_core/core/state/async_action.dart';
import 'package:flutter_core/core/state/infinite_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_providers.g.dart';

const _pageLimit = 10;

@riverpod
class PostDetail extends _$PostDetail {
  @override
  Future<Post> build(String postId) async {
    final response = await ref.read(appApiProvider).posts.getById(BaseGetByIdRequest(id: postId));
    return response.data;
  }

  void updatePost(Post post) {
    state = AsyncData(post);
  }
}

@Riverpod(keepAlive: true)
class FeedPosts extends _$FeedPosts {
  @override
  Future<InfiniteList<Post>> build() async {
    final items = await _fetchPage(1, _pageLimit);
    return InfiniteList<Post>.empty(
      limit: _pageLimit,
    ).replaceWithFirstPage(items);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<InfiniteList<Post>>().copyWithPrevious(state);
    state = await AsyncValue.guard(build);
  }

  Future<void> fetchNextPage() async {
    final current = state.valueOrNull;
    if (current == null || current.isFetchingNextPage || !current.hasNextPage) {
      return;
    }

    state = AsyncData(current.copyWith(isFetchingNextPage: true));

    try {
      final items = await _fetchPage(current.page + 1, current.limit);
      state = AsyncData(current.appendPage(items));
    } catch (error, stackTrace) {
      state = AsyncError<InfiniteList<Post>>(error, stackTrace)
          .copyWithPrevious(
            AsyncData(current.copyWith(isFetchingNextPage: false)),
          );
    }
  }

  void prependPost(Post post) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.prependUnique(
        post,
        matches: (existing, incoming) => existing.id == incoming.id,
      ),
    );
  }

  Future<List<Post>> _fetchPage(int page, int limit) async {
    final response = await ref
        .read(appApiProvider)
        .posts
        .getAll(BasePaginationRequest(page: page, limit: limit));
    return response.data;
  }
}

@riverpod
class Comments extends _$Comments {
  @override
  Future<InfiniteList<Comment>> build(String postId) async {
    final items = await _fetchPage(1, _pageLimit);
    return InfiniteList<Comment>.empty(
      limit: _pageLimit,
    ).replaceWithFirstPage(items);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<InfiniteList<Comment>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => build(postId));
  }

  Future<void> fetchNextPage() async {
    final current = state.valueOrNull;
    if (current == null || current.isFetchingNextPage || !current.hasNextPage) {
      return;
    }

    state = AsyncData(current.copyWith(isFetchingNextPage: true));

    try {
      final items = await _fetchPage(current.page + 1, current.limit);
      state = AsyncData(current.appendPage(items));
    } catch (error, stackTrace) {
      state = AsyncError<InfiniteList<Comment>>(error, stackTrace)
          .copyWithPrevious(
            AsyncData(current.copyWith(isFetchingNextPage: false)),
          );
    }
  }

  void prependComment(Comment comment) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.prependUnique(
        comment,
        matches: (existing, incoming) => existing.id == incoming.id,
      ),
    );
  }

  Future<List<Comment>> _fetchPage(int page, int limit) async {
    final response = await ref
        .read(appApiProvider)
        .posts
        .getComments(IGetCommentsRequest(id: postId, page: page, limit: limit));
    return response.data;
  }
}

@riverpod
class CommentAction extends _$CommentAction with AsyncAction<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createComment(CreateCommentBody body) => execute(() async {
    final response = await ref.read(appApiProvider).comments.create(
          ICreateCommentRequest(body: body),
        );
    final comment = response.data;

    // Update the local list if it's already loaded
    ref.read(commentsProvider(body.postId).notifier).prependComment(comment);

    // Optimistic Update: Increment comment count in FeedPosts
    final currentPosts = ref.read(feedPostsProvider).valueOrNull;
    if (currentPosts != null) {
      final postToUpdate = currentPosts.items.firstWhere((p) => p.id == body.postId);
      final updated = currentPosts.replaceWhere(
        (p) => p.id == body.postId,
        postToUpdate.copyWith(
          commentCount: (postToUpdate.commentCount ?? 0) + 1,
        ),
      );
      ref.read(feedPostsProvider.notifier).state = AsyncData(updated);
    }
    
    // Optimistic Update: Increment comment count in postDetailProvider
    final postAsync = ref.read(postDetailProvider(body.postId));
    if (postAsync is AsyncData<Post>) {
      final currentPost = postAsync.value;
      ref.read(postDetailProvider(body.postId).notifier).updatePost(
        currentPost.copyWith(commentCount: (currentPost.commentCount ?? 0) + 1),
      );
    }

    // Optional: refresh to get the latest counts/state from server
    unawaited(ref.read(commentsProvider(body.postId).notifier).refresh());
  });
}
