// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: json['id'] as String? ?? '',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  postId: json['post_id'] as String?,
  userId: json['user_id'] as String?,
  parentId: json['parent_id'] as String?,
  content: json['content'] as String?,
  depth: _numFromJson(json['depth']),
  type: json['type'] as String?,
  mediaUrl: json['media_url'] as String?,
  mediaMetadata: json['media_metadata'] as Map<String, dynamic>?,
  author: json['author'] == null
      ? null
      : Author.fromJson(json['author'] as Map<String, dynamic>),
  replyToUsername: json['reply_to_username'] as String?,
  likeCount: _numFromJson(json['like_count']),
  replyCount: _numFromJson(json['reply_count']),
  replies: (json['replies'] as List<dynamic>?)
      ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'post_id': instance.postId,
  'user_id': instance.userId,
  'parent_id': instance.parentId,
  'content': instance.content,
  'depth': instance.depth,
  'type': instance.type,
  'media_url': instance.mediaUrl,
  'media_metadata': instance.mediaMetadata,
  'author': instance.author?.toJson(),
  'reply_to_username': instance.replyToUsername,
  'like_count': instance.likeCount,
  'reply_count': instance.replyCount,
  'replies': instance.replies?.map((e) => e.toJson()).toList(),
};
