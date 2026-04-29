// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String? ?? 'unknown',
  email: json['email'] as String? ?? '',
  username: json['username'] as String? ?? '',
  displayName: json['display_name'] as String? ?? '',
  avatarUrl: json['avatar_url'] as String?,
  bannerUrl: json['banner_url'] as String?,
  bio: json['bio'] as String?,
  bioQuote: json['bio_quote'] as String?,
  followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
  followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
  postsCount: (json['posts_count'] as num?)?.toInt() ?? 0,
  activityLevel: json['activity_level'] as String? ?? 'Normal',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'email': instance.email,
  'username': instance.username,
  'display_name': instance.displayName,
  'avatar_url': instance.avatarUrl,
  'banner_url': instance.bannerUrl,
  'bio': instance.bio,
  'bio_quote': instance.bioQuote,
  'followers_count': instance.followersCount,
  'following_count': instance.followingCount,
  'posts_count': instance.postsCount,
  'activity_level': instance.activityLevel,
  'tags': instance.tags,
};
