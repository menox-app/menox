import 'dart:async';

import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/apis/app/providers.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'package:flutter_core/core/state/infinite_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_providers.g.dart';

const _pageLimit = 10;

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
