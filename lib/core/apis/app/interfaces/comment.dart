import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/apis/base/interfaces/record.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'package:flutter_core/core/apis/base/interfaces/serializable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Comment extends BaseRecord<String> {
  final String? postId;
  final String? userId;
  final String? parentId;
  final String? content;
  @JsonKey(fromJson: _numFromJson)
  final num? depth;
  final String? type;
  final String? mediaUrl;
  final Map<String, dynamic>? mediaMetadata;
  final Author? author;
  final String? replyToUsername;
  @JsonKey(fromJson: _numFromJson)
  final num? likeCount;
  @JsonKey(fromJson: _numFromJson)
  final num? replyCount;
  final List<Comment>? replies;
  final List<Media>? medias;

  Comment({
    super.id = '',
    super.createdAt,
    super.updatedAt,
    super.extraData,
    this.postId,
    this.userId,
    this.parentId,
    this.content,
    this.depth,
    this.type,
    this.mediaUrl,
    this.mediaMetadata,
    this.author,
    this.replyToUsername,
    this.likeCount,
    this.replyCount,
    this.replies,
    this.medias,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

num? _numFromJson(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}

class IGetCommentsRequest extends BasePaginationRequest<Map<String, dynamic>> {
  IGetCommentsRequest({
    required String id,
    super.page,
    super.limit,
    String? parentId,
  }) : super(
         pathParams: {'id': id},
         extraParams: {if (parentId != null) 'parent_id': parentId},
       );
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class CreateCommentBody implements BaseSerializable {
  final String postId;
  final String content;
  final String? parentId;
  final List<CreateCommentMediaBody>? medias;

  CreateCommentBody({
    required this.postId,
    required this.content,
    this.parentId,
    this.medias,
  });

  factory CreateCommentBody.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentBodyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CreateCommentBodyToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateCommentMediaBody {
  final String mediaId;
  final int order;

  CreateCommentMediaBody({required this.mediaId, required this.order});

  factory CreateCommentMediaBody.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentMediaBodyFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCommentMediaBodyToJson(this);
}

class ICreateCommentRequest extends BaseCreateRequest<Comment> {
  ICreateCommentRequest({
    required super.body,
    super.params,
  });
}
