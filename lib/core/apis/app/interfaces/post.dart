import 'package:flutter_core/core/apis/app/interfaces/comment.dart';
import 'package:flutter_core/core/apis/base/interfaces/record.dart';
import 'package:flutter_core/core/apis/base/interfaces/serializable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Author {
  final String? id;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  Author({this.id, this.username = '', this.displayName, this.avatarUrl});

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Media {
  final String id;
  final String? publicId;
  final String url;
  final String type;
  final String postId;

  Media({
    this.id = '',
    this.publicId,
    this.url = '',
    this.type = '',
    this.postId = '',
  });

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);

  Map<String, dynamic> toJson() => _$MediaToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Post extends BaseRecord<String> {
  final String? authorId;
  final String? content;
  final String? visibility;
  final Author? author;
  final List<Media>? medias;
  @JsonKey(fromJson: _numFromJson)
  final num? likeCount;
  @JsonKey(fromJson: _numFromJson)
  final num? commentCount;
  @JsonKey(fromJson: _numFromJson)
  final num? repostCount;
  @JsonKey(fromJson: _numFromJson)
  final num? shareCount;
  @JsonKey(fromJson: _boolFromJson)
  final bool? isLiked;
  final bool? isFollowingAuthor;
  final List<Comment>? highlightComments;

  Post({
    super.id = '',
    super.createdAt,
    super.updatedAt,
    super.extraData,
    this.authorId,
    this.content,
    this.visibility,
    this.author,
    this.medias,
    this.likeCount,
    this.commentCount,
    this.repostCount,
    this.shareCount,
    this.isLiked,
    this.isFollowingAuthor,
    this.highlightComments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final post = _$PostFromJson(json);
    return post._withExtraData(json);
  }

  @override
  Map<String, dynamic> toJson() => _$PostToJson(this);

  Post _withExtraData(Map<String, dynamic> extraData) {
    return Post(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      extraData: extraData,
      authorId: authorId,
      content: content,
      visibility: visibility,
      author: author,
      medias: medias,
      likeCount: likeCount,
      commentCount: commentCount,
      repostCount: repostCount,
      shareCount: shareCount,
      isLiked: isLiked,
      isFollowingAuthor: isFollowingAuthor,
      highlightComments: highlightComments,
    );
  }
}

num? _numFromJson(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}

bool? _boolFromJson(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value.toString() == 'true' || value.toString() == '1';
}

// CREATE POST
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CreatePostBody implements BaseSerializable {
  final String content;
  final String visibility;
  final List<CreatePostMediaBody> medias;

  CreatePostBody({
    required this.content,
    this.visibility = 'public',
    this.medias = const [],
  });

  factory CreatePostBody.fromJson(Map<String, dynamic> json) =>
      _$CreatePostBodyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CreatePostBodyToJson(this);
}

@JsonSerializable()
class CreatePostMediaBody {
  final String mediaId;
  final int order;

  CreatePostMediaBody({required this.mediaId, required this.order});

  factory CreatePostMediaBody.fromJson(Map<String, dynamic> json) =>
      _$CreatePostMediaBodyFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostMediaBodyToJson(this);
}
