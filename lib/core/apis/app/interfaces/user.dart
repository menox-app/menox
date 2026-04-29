import 'package:flutter_core/core/apis/base/interfaces/record.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User extends BaseRecord<String> {
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? bio;
  final String? bioQuote;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final String activityLevel;
  final List<String> tags;

  User({
    super.id = 'unknown',
    this.email = '',
    this.username = '',
    this.displayName = '',
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
    return _$UserFromJson({
      ...json,
      'id': json['id'] ?? json['_id'] ?? 'unknown',
    });
  }

  @override
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
