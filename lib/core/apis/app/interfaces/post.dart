import 'package:flutter_core/core/apis/base/interfaces/record.dart';

class Author {
  final String? id;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  Author({
    this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      username: json['username'] ?? '',
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
    };
  }
}

class Media {
  final String id;
  final String? publicId;
  final String url;
  final String type;
  final String postId;

  Media({
    required this.id,
    this.publicId,
    required this.url,
    required this.type,
    required this.postId,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      publicId: json['public_id'],
      url: json['url'],
      type: json['type'],
      postId: json['post_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'public_id': publicId,
      'url': url,
      'type': type,
      'post_id': postId,
    };
  }
}

class Post extends BaseRecord {
  final String? authorId;
  final String? content;
  final String? visibility;
  final Author? author;
  final List<Media>? medias;
  final num? likeCount;
  final bool? isLiked;
  final bool? isFollowingAuthor;

  Post({
    required super.id,
    super.createdAt,
    super.updatedAt,
    super.extraData,
    this.authorId,
    this.content,
    this.visibility,
    this.author,
    this.medias,
    this.likeCount,
    this.isLiked,
    this.isFollowingAuthor,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Parse like_count — API returns it as a String ("0")
    num? parsedLikeCount;
    if (json['like_count'] != null) {
      parsedLikeCount = json['like_count'] is num
          ? json['like_count']
          : num.tryParse(json['like_count'].toString());
    }

    // Parse is_liked — API returns 0/1 (int) instead of bool
    bool? parsedIsLiked;
    if (json['is_liked'] != null) {
      parsedIsLiked = json['is_liked'] is bool
          ? json['is_liked']
          : json['is_liked'] == 1;
    }

    return Post(
      id: json['id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      authorId: json['author_id'],
      content: json['content'],
      visibility: json['visibility'],
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
      medias: json['medias'] != null
          ? (json['medias'] as List).map((e) => Media.fromJson(e)).toList()
          : null,
      likeCount: parsedLikeCount,
      isLiked: parsedIsLiked,
      isFollowingAuthor: json['is_following_author'],
      extraData: json,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      ...extraData,
    };
  }
}