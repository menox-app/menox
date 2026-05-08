import 'dart:async';
import 'dart:io';

import 'package:flutter_core/core/apis/app/interfaces/comment.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/apis/app/interfaces/upload.dart';
import 'package:flutter_core/core/apis/app/providers.dart';
import 'package:flutter_core/core/state/async_action.dart';
import 'package:flutter_core/core/state/infinite_list.dart';
import 'package:flutter_core/features/post/providers/post_providers.dart';
import 'package:flutter_core/features/user/providers/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'comment_providers.g.dart';

const _pageLimit = 10;

class CommentMediaDraft {
  final File file;
  final String type;

  const CommentMediaDraft({required this.file, required this.type});
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

  void replaceComment(String id, Comment comment) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.replaceWhere((item) => item.id == id, comment));
  }

  void removeComment(String id) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.removeWhere((item) => item.id == id));
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
    await _createCommentOptimistically(body);
  });

  Future<void> createCommentWithMedia({
    required String postId,
    required String content,
    String? parentId,
    File? file,
  }) => execute(() async {
    await _createCommentWithMediaDrafts(
      postId: postId,
      content: content,
      parentId: parentId,
      mediaDrafts: file == null
          ? const []
          : [CommentMediaDraft(file: file, type: 'image')],
    );
  });

  Future<void> createCommentWithMediaDrafts({
    required String postId,
    required String content,
    String? parentId,
    required List<CommentMediaDraft> mediaDrafts,
  }) => execute(() async {
    await _createCommentWithMediaDrafts(
      postId: postId,
      content: content,
      parentId: parentId,
      mediaDrafts: mediaDrafts,
    );
  });

  Future<void> _createCommentWithMediaDrafts({
    required String postId,
    required String content,
    String? parentId,
    required List<CommentMediaDraft> mediaDrafts,
  }) async {
    final body = CreateCommentBody(
      postId: postId,
      content: content,
      parentId: parentId,
    );

    await _createCommentOptimistically(
      body,
      optimisticMedias: _optimisticMedias(postId, mediaDrafts),
      beforeCreate: () async {
        if (mediaDrafts.isEmpty) return body;

        final medias = await _uploadCommentMedias(mediaDrafts);

        return CreateCommentBody(
          postId: postId,
          content: content,
          parentId: parentId,
          medias: medias,
        );
      },
    );
  }

  List<Media> _optimisticMedias(
    String postId,
    List<CommentMediaDraft> mediaDrafts,
  ) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return mediaDrafts.indexed.map((entry) {
      final (index, draft) = entry;
      return Media(
        id: 'optimistic-media-$index-$timestamp',
        url: draft.file.path,
        type: draft.type,
        postId: postId,
      );
    }).toList();
  }

  Future<List<CreateCommentMediaBody>> _uploadCommentMedias(
    List<CommentMediaDraft> mediaDrafts,
  ) async {
    final files = mediaDrafts.map((draft) => draft.file).toList();
    final uploadApi = ref.read(appApiProvider).upload;
    final response = files.length == 1
        ? await uploadApi.single(
            IUploadSingleRequest(file: files.first, folder: 'comments'),
          )
        : await uploadApi.multiple(
            IUploadMultipleRequest(files: files, folder: 'comments'),
          );

    final uploads = response.data is List
        ? response.data as List
        : [response.data];

    return uploads.indexed.map((entry) {
      final (index, upload) = entry;
      final mediaId = upload.mediaId;
      if (mediaId == null || mediaId.isEmpty) {
        throw StateError('Upload response missing mediaId at index $index');
      }
      return CreateCommentMediaBody(mediaId: mediaId, order: index);
    }).toList();
  }

  Future<void> _createCommentOptimistically(
    CreateCommentBody body, {
    List<Media> optimisticMedias = const [],
    Future<CreateCommentBody> Function()? beforeCreate,
  }) async {
    final optimisticId =
        'optimistic-comment-${DateTime.now().microsecondsSinceEpoch}';
    final optimisticComment = _optimisticComment(
      body,
      optimisticId,
      optimisticMedias,
    );

    ref
        .read(commentsProvider(body.postId).notifier)
        .prependComment(optimisticComment);
    _adjustPostCommentCount(body.postId, 1);

    try {
      final createBody = beforeCreate == null ? body : await beforeCreate();
      final response = await ref
          .read(appApiProvider)
          .comments
          .create(ICreateCommentRequest(body: createBody));
      final comment = response.data;

      ref
          .read(commentsProvider(body.postId).notifier)
          .replaceComment(optimisticId, comment);

      unawaited(ref.read(commentsProvider(body.postId).notifier).refresh());
    } catch (_) {
      ref
          .read(commentsProvider(body.postId).notifier)
          .removeComment(optimisticId);
      _adjustPostCommentCount(body.postId, -1);
      rethrow;
    }
  }

  Comment _optimisticComment(
    CreateCommentBody body,
    String id,
    List<Media> medias,
  ) {
    final user = ref.read(currentUserProvider);
    return Comment(
      id: id,
      postId: body.postId,
      userId: user?.id,
      parentId: body.parentId,
      content: body.content,
      depth: body.parentId == null ? 0 : 1,
      type: 'comment',
      author: Author(
        id: user?.id,
        username: user?.username ?? '',
        displayName: user?.displayName,
        avatarUrl: user?.avatarUrl,
      ),
      likeCount: 0,
      replyCount: 0,
      medias: medias,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      extraData: const {'optimistic': true},
    );
  }

  void _adjustPostCommentCount(String postId, int delta) {
    final currentPosts = ref.read(feedPostsProvider).valueOrNull;
    if (currentPosts != null) {
      final index = currentPosts.items.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final postToUpdate = currentPosts.items[index];
        final updated = currentPosts.replaceWhere(
          (p) => p.id == postId,
          postToUpdate.copyWith(
            commentCount: ((postToUpdate.commentCount ?? 0) + delta).clamp(
              0,
              double.infinity,
            ),
          ),
        );
        ref.read(feedPostsProvider.notifier).state = AsyncData(updated);
      }
    }

    final postAsync = ref.read(postDetailProvider(postId));
    if (postAsync is AsyncData<Post>) {
      final currentPost = postAsync.value;
      ref
          .read(postDetailProvider(postId).notifier)
          .updatePost(
            currentPost.copyWith(
              commentCount: ((currentPost.commentCount ?? 0) + delta).clamp(
                0,
                double.infinity,
              ),
            ),
          );
    }
  }
}
