import 'dart:async';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/apis/app/providers.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'package:flutter_core/core/state/debounced_bool_action.dart';
import 'package:flutter_core/core/state/infinite_list.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_providers.g.dart';

const _pageLimit = 10;
const _reactionDebounce = Duration(milliseconds: 350);

final postReactionControllerProvider = Provider<PostReactionController>((ref) {
  final controller = PostReactionController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

class PostReactionController {
  final Ref _ref;
  late final DebouncedBoolActionController<String> _controller;

  PostReactionController(this._ref) {
    _controller = DebouncedBoolActionController<String>(
      debounce: _reactionDebounce,
      apply: _applyReaction,
      perform: _performReaction,
      onSettled: (postId) => _cacheSeed.remove(postId),
    );
  }

  void toggleReaction(Post post) {
    _cacheSeed[post.id] = post;
    _controller.toggle(post.id, currentValue: post.isLiked ?? false);
  }

  final Map<String, Post> _cacheSeed = {};

  void dispose() => _controller.dispose();

  Future<bool> _performReaction(String postId) async {
    final response = await _ref.read(appApiProvider).posts.react(postId);
    return response.data;
  }

  void _applyReaction(String postId, bool isLiked) {
    final feedState = _ref.read(feedPostsProvider).valueOrNull;
    if (feedState != null) {
      final existing = feedState.items.any((post) => post.id == postId);
      if (existing) {
        final currentPost = feedState.items.firstWhere(
          (post) => post.id == postId,
        );
        _ref
            .read(feedPostsProvider.notifier)
            .applyReaction(_postWithReaction(currentPost, isLiked));
      }
    }

    final detailProvider = postDetailProvider(postId);
    if (_ref.exists(detailProvider)) {
      final postDetailNotifier = _ref.read(detailProvider.notifier);
      final postDetail = _ref.read(detailProvider);
      if (postDetail is AsyncData<Post>) {
        postDetailNotifier.updatePost(
          _postWithReaction(postDetail.value, isLiked),
        );
      } else if (_cacheSeed[postId] case final fallbackPost?) {
        postDetailNotifier.updatePost(_postWithReaction(fallbackPost, isLiked));
      }
    }

    final seeded = _cacheSeed[postId];
    if (seeded != null) {
      _cacheSeed[postId] = _postWithReaction(seeded, isLiked);
    }
  }

  Post _postWithReaction(Post post, bool isLiked) {
    final wasLiked = post.isLiked ?? false;
    if (wasLiked == isLiked) return post;

    final baseCount = post.likeCount ?? 0;
    final nextCount = (baseCount + (isLiked ? 1 : -1)).clamp(
      0,
      double.infinity,
    );

    return post.copyWith(isLiked: isLiked, likeCount: nextCount);
  }
}

@riverpod
class PostDetail extends _$PostDetail {
  @override
  Future<Post> build(String postId) async {
    final response = await ref
        .read(appApiProvider)
        .posts
        .getById(BaseGetByIdRequest(id: postId));
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

  void replacePost(String id, Post post) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.replaceWhere((item) => item.id == id, post));
  }

  void applyReaction(Post post) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.replaceWhere((item) => item.id == post.id, post));
  }

  void removePost(String id) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.removeWhere((item) => item.id == id));
  }

  Future<List<Post>> _fetchPage(int page, int limit) async {
    final response = await ref
        .read(appApiProvider)
        .posts
        .getAll(BasePaginationRequest(page: page, limit: limit));
    return response.data;
  }
}
