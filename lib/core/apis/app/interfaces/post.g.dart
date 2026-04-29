// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
  id: json['id'] as String?,
  username: json['username'] as String? ?? '',
  displayName: json['display_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'display_name': instance.displayName,
  'avatar_url': instance.avatarUrl,
};

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
  id: json['id'] as String? ?? '',
  publicId: json['public_id'] as String?,
  url: json['url'] as String? ?? '',
  type: json['type'] as String? ?? '',
  postId: json['post_id'] as String? ?? '',
);

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
  'id': instance.id,
  'public_id': instance.publicId,
  'url': instance.url,
  'type': instance.type,
  'post_id': instance.postId,
};

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: json['id'] as String? ?? '',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  authorId: json['author_id'] as String?,
  content: json['content'] as String?,
  visibility: json['visibility'] as String?,
  author: json['author'] == null
      ? null
      : Author.fromJson(json['author'] as Map<String, dynamic>),
  medias: (json['medias'] as List<dynamic>?)
      ?.map((e) => Media.fromJson(e as Map<String, dynamic>))
      .toList(),
  likeCount: _numFromJson(json['like_count']),
  isLiked: _boolFromJson(json['is_liked']),
  isFollowingAuthor: json['is_following_author'] as bool?,
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'author_id': instance.authorId,
  'content': instance.content,
  'visibility': instance.visibility,
  'author': instance.author?.toJson(),
  'medias': instance.medias?.map((e) => e.toJson()).toList(),
  'like_count': instance.likeCount,
  'is_liked': instance.isLiked,
  'is_following_author': instance.isFollowingAuthor,
};
