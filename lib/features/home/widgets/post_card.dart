import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/features/home/widgets/media_carousel.dart';

/// Threads-style post card:
/// ┌──────────────────────────────────────┐
/// │ [Avatar]  username · 6h          ··· │
/// │    │      Content text ...            │
/// │    │      ┌────────────────────┐      │
/// │    │      │   Media carousel   │      │
/// │    │      └────────────────────┘      │
/// │    │      ♡  💬  🔄  ▷              │
/// │    │      57.1K · 646 · 2.1K · 3.1K  │
/// │ ───┼──────────────────────────────── │
/// └──────────────────────────────────────┘
class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    return '${(diff.inDays / 30).floor()}mo';
  }

  String _formatCount(num? count) {
    if (count == null || count == 0) return '';
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }



  num? _parseCount(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    final author = post.author;
    final medias = post.medias ?? [];
    final hasMedia = medias.isNotEmpty;
    final hasContent = post.content != null && post.content!.trim().isNotEmpty;

    return Container(
      color: ShadcnColors.background,
      child: Column(
        children: [
          // ── Main content row: Stack for thread line + Row for content ──
          Stack(
            children: [
              // ── Thread line (positioned absolutely to span the whole height) ──
              Positioned(
                left: 16 + (38 / 2) - 0.5, // padding + half avatar - half line
                top: 14 + 38 + 8, // padding + avatar + gap
                bottom: 0, // stretch to bottom
                width: 1.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: ShadcnColors.border,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

              // ── Content ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Left column: Avatar ──
                    Column(
                      children: [
                        _buildAvatar(author),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // ── Right column: Header + Content + Media + Actions ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header: username · time · more ──
                          _buildHeader(author),

                          // ── Content ──
                          if (hasContent) ...[
                            const SizedBox(height: 4),
                            _buildContent(),
                          ],

                          // ── Media ──
                          if (hasMedia) ...[
                            const SizedBox(height: 10),
                            MediaCarousel(
                              medias: medias,
                              likeCount: post.likeCount,
                              commentCount: _parseCount(post.extraData['comment_count']),
                              repostCount: _parseCount(post.extraData['repost_count']),
                              shareCount: _parseCount(post.extraData['share_count']),
                            ),
                          ],

                          // ── Action bar ──
                          const SizedBox(height: 6),
                          _buildActionBar(),

                          // ── Engagement counts ──
                          if (post.likeCount != null && post.likeCount! > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 2, bottom: 4),
                              child: Text(
                                _buildEngagementText(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: ShadcnColors.mutedForeground,
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Bottom divider ──
          Container(height: 0.5, color: ShadcnColors.border),
        ],
      ),
    );
  }

  // ── Avatar ──
  Widget _buildAvatar(Author? author) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ShadcnColors.secondary,
        border: Border.all(color: ShadcnColors.border, width: 0.5),
        image: author?.avatarUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(author!.avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: author?.avatarUrl == null
          ? const Icon(
              CupertinoIcons.person_fill,
              color: ShadcnColors.mutedForeground,
              size: 18,
            )
          : null,
    );
  }

  // ── Header row ──
  Widget _buildHeader(Author? author) {
    return Row(
      children: [
        // Username
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  author?.displayName ?? author?.username ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ShadcnColors.foreground,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _timeAgo(post.createdAt),
                style: const TextStyle(
                  fontSize: 13,
                  color: ShadcnColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        // More button
        GestureDetector(
          onTap: () {},
          child: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(
              CupertinoIcons.ellipsis,
              color: ShadcnColors.mutedForeground,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ── Content text ──
  Widget _buildContent() {
    return Text(
      post.content!,
      style: const TextStyle(
        fontSize: 14,
        height: 1.45,
        color: ShadcnColors.foreground,
        letterSpacing: -0.1,
      ),
      maxLines: 8,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ── Action bar ──
  Widget _buildActionBar() {
    return Transform.translate(
      offset: const Offset(-8, 0),
      child: Row(
        children: [
          _actionButton(
            icon: post.isLiked == true
                ? CupertinoIcons.heart_fill
                : CupertinoIcons.heart,
            color: post.isLiked == true
                ? CupertinoColors.systemRed
                : ShadcnColors.foreground,
            count: post.likeCount,
            onTap: () {},
          ),
          _actionButton(
            icon: CupertinoIcons.chat_bubble,
            color: ShadcnColors.foreground,
            onTap: () {},
          ),
          _actionButton(
            icon: CupertinoIcons.arrow_2_squarepath,
            color: ShadcnColors.foreground,
            onTap: () {},
          ),
          _actionButton(
            icon: CupertinoIcons.paperplane,
            color: ShadcnColors.foreground,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    num? count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: color),
            if (count != null && count > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(count),
                style: TextStyle(
                  fontSize: 12.5,
                  color: color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _buildEngagementText() {
    final parts = <String>[];
    if (post.likeCount != null && post.likeCount! > 0) {
      parts.add('${_formatCount(post.likeCount)} likes');
    }
    return parts.join(' · ');
  }
}
