import 'package:flutter_core/core/apis/base/interfaces/record.dart';

class User extends BaseRecord<String> {
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? bio;
  final String? bioQuote;
  
  // Stats
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final String activityLevel;
  
  // Tags
  final List<String> tags;

  User({
    required super.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bannerUrl,
    this.bio,
    this.bioQuote,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.activityLevel = 'Normal',
    this.tags = const [],
    super.createdAt,
    super.updatedAt,
    super.extraData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? json['_id'] as String? ?? 'unknown',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      bio: json['bio'] as String?,
      bioQuote: json['bioQuote'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      activityLevel: json['activityLevel'] as String? ?? 'Normal',
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      extraData: json,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'bannerUrl': bannerUrl,
    'bio': bio,
    'bioQuote': bioQuote,
    'followersCount': followersCount,
    'followingCount': followingCount,
    'postsCount': postsCount,
    'activityLevel': activityLevel,
    'tags': tags,
  };
}
