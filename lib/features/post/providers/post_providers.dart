import 'dart:async';

import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/apis/app/providers.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
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
  final Map<String, _PendingReactionJob> _jobs = {};

  PostReactionController(this._ref);

  void toggleReaction(Post post) {
    final nextIsLiked = !(post.isLiked ?? false);
    final job =
        _jobs[post.id] ??
        _PendingReactionJob(confirmedIsLiked: post.isLiked ?? false);

    job.desiredIsLiked = nextIsLiked;
    job.timer?.cancel();
    _jobs[post.id] = job;

    _applyReaction(post.id, nextIsLiked, fallbackPost: post);
    job.timer = Timer(_reactionDebounce, () => _flush(post.id));
  }

  void dispose() {
    for (final job in _jobs.values) {
      job.timer?.cancel();
    }
    _jobs.clear();
  }

  Future<void> _flush(String postId) async {
    final job = _jobs[postId];
    if (job == null || job.inFlight) return;

    if (job.desiredIsLiked == job.confirmedIsLiked) {
      job.timer = null;
      _jobs.remove(postId);
      return;
    }

    job.timer = null;
    job.inFlight = true;

    try {
      final response = await _ref.read(appApiProvider).posts.react(postId);
      final serverIsLiked = response.data;
      job.confirmedIsLiked = serverIsLiked;
      _applyReaction(postId, serverIsLiked);
    } catch (_) {
      job.desiredIsLiked = job.confirmedIsLiked;
      _applyReaction(postId, job.confirmedIsLiked);
    } finally {
      job.inFlight = false;
      final current = _jobs[postId];
      if (current != null) {
        if (current.desiredIsLiked != current.confirmedIsLiked) {
          current.timer?.cancel();
          current.timer = Timer(_reactionDebounce, () => _flush(postId));
        } else if (current.timer == null) {
          _jobs.remove(postId);
        }
      }
    }
  }

  void _applyReaction(String postId, bool isLiked, {Post? fallbackPost}) {
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
      } else if (fallbackPost != null) {
        postDetailNotifier.updatePost(_postWithReaction(fallbackPost, isLiked));
      }
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

class _PendingReactionJob {
  bool confirmedIsLiked;
  bool desiredIsLiked;
  bool inFlight;
  Timer? timer;

  _PendingReactionJob({required this.confirmedIsLiked})
    : desiredIsLiked = confirmedIsLiked,
      inFlight = false;
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
