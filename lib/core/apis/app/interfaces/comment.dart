import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/apis/base/interfaces/record.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
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
