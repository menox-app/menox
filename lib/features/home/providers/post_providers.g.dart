// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postDetailHash() => r'147c06d6e0e409f7c9135a113657fe5aa362223c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$PostDetail extends BuildlessAutoDisposeAsyncNotifier<Post> {
  late final String postId;

  FutureOr<Post> build(String postId);
}

/// See also [PostDetail].
@ProviderFor(PostDetail)
const postDetailProvider = PostDetailFamily();

/// See also [PostDetail].
class PostDetailFamily extends Family<AsyncValue<Post>> {
  /// See also [PostDetail].
  const PostDetailFamily();

  /// See also [PostDetail].
  PostDetailProvider call(String postId) {
    return PostDetailProvider(postId);
  }

  @override
  PostDetailProvider getProviderOverride(
    covariant PostDetailProvider provider,
  ) {
    return call(provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'postDetailProvider';
}

/// See also [PostDetail].
class PostDetailProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PostDetail, Post> {
  /// See also [PostDetail].
  PostDetailProvider(String postId)
    : this._internal(
        () => PostDetail()..postId = postId,
        from: postDetailProvider,
        name: r'postDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$postDetailHash,
        dependencies: PostDetailFamily._dependencies,
        allTransitiveDependencies: PostDetailFamily._allTransitiveDependencies,
        postId: postId,
      );

  PostDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final String postId;

  @override
  FutureOr<Post> runNotifierBuild(covariant PostDetail notifier) {
    return notifier.build(postId);
  }

  @override
  Override overrideWith(PostDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: PostDetailProvider._internal(
        () => create()..postId = postId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PostDetail, Post> createElement() {
    return _PostDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostDetailProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostDetailRef on AutoDisposeAsyncNotifierProviderRef<Post> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _PostDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PostDetail, Post>
    with PostDetailRef {
  _PostDetailProviderElement(super.provider);

  @override
  String get postId => (origin as PostDetailProvider).postId;
}

String _$feedPostsHash() => r'7e181a24b72f06bcb4aa81c2c05a30571f0d786d';

/// See also [FeedPosts].
@ProviderFor(FeedPosts)
final feedPostsProvider =
    AsyncNotifierProvider<FeedPosts, InfiniteList<Post>>.internal(
      FeedPosts.new,
      name: r'feedPostsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedPostsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FeedPosts = AsyncNotifier<InfiniteList<Post>>;
String _$commentsHash() => r'd38b9bfd29cffeba52d365b822fffe1bff376d6a';

abstract class _$Comments
    extends BuildlessAutoDisposeAsyncNotifier<InfiniteList<Comment>> {
  late final String postId;

  FutureOr<InfiniteList<Comment>> build(String postId);
}

/// See also [Comments].
@ProviderFor(Comments)
const commentsProvider = CommentsFamily();

/// See also [Comments].
class CommentsFamily extends Family<AsyncValue<InfiniteList<Comment>>> {
  /// See also [Comments].
  const CommentsFamily();

  /// See also [Comments].
  CommentsProvider call(String postId) {
    return CommentsProvider(postId);
  }

  @override
  CommentsProvider getProviderOverride(covariant CommentsProvider provider) {
    return call(provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'commentsProvider';
}

/// See also [Comments].
class CommentsProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<Comments, InfiniteList<Comment>> {
  /// See also [Comments].
  CommentsProvider(String postId)
    : this._internal(
        () => Comments()..postId = postId,
        from: commentsProvider,
        name: r'commentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$commentsHash,
        dependencies: CommentsFamily._dependencies,
        allTransitiveDependencies: CommentsFamily._allTransitiveDependencies,
        postId: postId,
      );

  CommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final String postId;

  @override
  FutureOr<InfiniteList<Comment>> runNotifierBuild(
    covariant Comments notifier,
  ) {
    return notifier.build(postId);
  }

  @override
  Override overrideWith(Comments Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentsProvider._internal(
        () => create()..postId = postId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<Comments, InfiniteList<Comment>>
  createElement() {
    return _CommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentsProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommentsRef
    on AutoDisposeAsyncNotifierProviderRef<InfiniteList<Comment>> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _CommentsProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<Comments, InfiniteList<Comment>>
    with CommentsRef {
  _CommentsProviderElement(super.provider);

  @override
  String get postId => (origin as CommentsProvider).postId;
}

String _$commentActionHash() => r'7d4c5535567fc658a2f6cad4436a3099afda6ee7';

/// See also [CommentAction].
@ProviderFor(CommentAction)
final commentActionProvider =
    AutoDisposeAsyncNotifierProvider<CommentAction, void>.internal(
      CommentAction.new,
      name: r'commentActionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$commentActionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommentAction = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
