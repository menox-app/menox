import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/apis/app/interfaces/comment.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_image.dart';
import 'package:flutter_core/features/home/screens/post_detail_screen.dart';
import 'package:flutter_core/features/home/widgets/media_carousel.dart';
import 'package:shimmer/shimmer.dart';

/// Threads-style post card:
class PostCard extends StatelessWidget {
  final Post post;
  final bool isDetail;

  const PostCard({super.key, required this.post, this.isDetail = false});

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

  @override
  Widget build(BuildContext context) {
    final author = post.author;
    final medias = post.medias ?? [];
    final highlightComments = (post.highlightComments ?? []).take(1).toList();
    final hasMedia = medias.isNotEmpty;
    final hasContent = post.content != null && post.content!.trim().isNotEmpty;
    final hasHighlights = highlightComments.isNotEmpty;

    if (isDetail) {
      return _buildDetailView(context, author, medias, hasContent, hasMedia);
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: ShadcnColors.background,
        child: Column(
          children: [
            Stack(
              children: [
                if (hasHighlights)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ThreadLinePainter(color: ShadcnColors.border),
                    ),
                  ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvatar(author),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(author),
                                if (hasContent) ...[
                                  const SizedBox(height: 4),
                                  _buildContent(),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (hasMedia) ...[
                      const SizedBox(height: 10),
                      MediaCarousel(
                        medias: medias,
                        likeCount: post.likeCount,
                        commentCount: post.commentCount,
                        repostCount: post.repostCount,
                        shareCount: post.shareCount,
                        padding: const EdgeInsets.only(left: 66, right: 16), // 16 (pad) + 38 (avatar) + 12 (gap) = 66
                      ),
                    ],

                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(66, 0, 16, 0),
                      child: _buildActionBar(),
                    ),

                    SizedBox(height: hasHighlights ? 6 : 10),
                  ],
                ),
              ],
            ),

            if (hasHighlights && !isDetail)
              _buildHighlightComments(highlightComments),

            Container(height: 0.5, color: ShadcnColors.border),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView(
    BuildContext context,
    Author? author,
    List<Media> medias,
    bool hasContent,
    bool hasMedia,
  ) {
    return Container(
      color: ShadcnColors.background,
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildAvatar(author),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          author?.displayName ?? author?.username ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: AppFontSizes.body,
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
                          fontSize: AppFontSizes.bodySmall,
                          color: ShadcnColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                // Threads Icon + Text
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ShadcnColors.foreground.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        FluentIcons.share_android_24_regular,
                        size: 10,
                        color: ShadcnColors.foreground,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Threads',
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        fontWeight: FontWeight.w600,
                        color: ShadcnColors.foreground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                const Icon(
                  FluentIcons.more_horizontal_24_regular,
                  color: ShadcnColors.foreground,
                  size: 20,
                ),
              ],
            ),
          ),
          if (hasContent) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.content!,
                style: const TextStyle(
                  fontSize: AppFontSizes.body,
                  height: 1.45,
                  color: ShadcnColors.foreground,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
          if (hasMedia) ...[
            const SizedBox(height: 12),
            MediaCarousel(
              medias: medias,
              likeCount: post.likeCount,
              commentCount: post.commentCount,
              repostCount: post.repostCount,
              shareCount: post.shareCount,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ],
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDetailActionBar(),
          ),
          const SizedBox(height: 12),
          Container(height: 0.5, color: ShadcnColors.border),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Liên quan nhất',
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        fontWeight: FontWeight.w600,
                        color: ShadcnColors.foreground,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      FluentIcons.chevron_down_20_regular,
                      size: 16,
                      color: ShadcnColors.mutedForeground,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Xem hoạt động',
                      style: TextStyle(
                        fontSize: AppFontSizes.bodySmall,
                        color: ShadcnColors.mutedForeground,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      FluentIcons.chevron_right_20_regular,
                      size: 14,
                      color: ShadcnColors.mutedForeground,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: ShadcnColors.border),
        ],
      ),
    );
  }

  Widget _buildHighlightComments(List<Comment> comments) {
    return Column(
      children: [
        for (var index = 0; index < comments.length; index++)
          _buildHighlightComment(
            comments[index],
            isLast: index == comments.length - 1,
          ),
      ],
    );
  }

  Widget _buildHighlightComment(Comment comment, {required bool isLast}) {
    final author = comment.author;
    final hasContent =
        comment.content != null && comment.content!.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, isLast ? 12 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 38,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _HighlightLinePainter(
                      color: ShadcnColors.border,
                      stopAtAvatar: isLast,
                    ),
                  ),
                ),
                _buildAvatar(author),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          author?.displayName ?? author?.username ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: AppFontSizes.bodySmall,
                            fontWeight: FontWeight.w600,
                            color: ShadcnColors.foreground,
                          ),
                        ),
                      ),
                      if (comment.createdAt != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          _timeAgo(comment.createdAt),
                          style: const TextStyle(
                            fontSize: AppFontSizes.meta,
                            color: ShadcnColors.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (hasContent)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        comment.content!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: AppFontSizes.bodySmall,
                          height: 1.4,
                          color: ShadcnColors.foreground,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  _buildCommentActionBar(comment),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Author? author) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ShadcnColors.secondary,
        border: Border.all(color: ShadcnColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: AppImage.avatar(
        url: author?.avatarUrl,
        size: 38,
        backgroundColor: ShadcnColors.secondary,
      ),
    );
  }

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
                    fontSize: AppFontSizes.bodySmall,
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
                  fontSize: AppFontSizes.meta,
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
              FluentIcons.more_horizontal_24_regular,
              color: ShadcnColors.mutedForeground,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      post.content!,
      style: const TextStyle(
        fontSize: AppFontSizes.bodySmall,
        height: 1.45,
        color: ShadcnColors.foreground,
        letterSpacing: -0.1,
      ),
      maxLines: 8,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionBar() {
    return Transform.translate(
      offset: const Offset(-8, 0),
      child: Row(
        spacing: 6,
        children: [
          _actionButton(
            icon: post.isLiked == true
                ? FluentIcons.heart_24_filled
                : FluentIcons.heart_24_regular,
            color: post.isLiked == true
                ? CupertinoColors.systemRed
                : ShadcnColors.foreground,
            count: post.likeCount,
            onTap: () {},
          ),
          _actionButton(
            icon: FluentIcons.chat_24_regular,
            color: ShadcnColors.foreground,
            count: post.commentCount,
            onTap: () {},
          ),
          _actionButton(
            icon: FluentIcons.arrow_sync_24_regular,
            color: ShadcnColors.foreground,
            count: post.repostCount,
            onTap: () {},
          ),
          _actionButton(
            icon: FluentIcons.send_24_regular,
            color: ShadcnColors.foreground,
            count: post.shareCount,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCommentActionBar(Comment comment) {
    return Transform.translate(
      offset: const Offset(-8, 0),
      child: Row(
        children: [
          _actionButton(
            icon: FluentIcons.heart_24_regular,
            color: ShadcnColors.foreground,
            count: comment.likeCount,
            onTap: () {},
          ),
          _actionButton(
            icon: FluentIcons.chat_24_regular,
            color: ShadcnColors.foreground,
            count: comment.replyCount,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDetailActionBar() {
    return Transform.translate(
      offset: const Offset(-8, 0),
      child: Row(
        spacing: 16,
        children: [
          _actionButton(
            icon: post.isLiked == true
                ? FluentIcons.heart_24_filled
                : FluentIcons.heart_24_regular,
            color: post.isLiked == true
                ? CupertinoColors.systemRed
                : ShadcnColors.foreground,
            count: post.likeCount,
            onTap: () {},
            large: true,
          ),
          _actionButton(
            icon: FluentIcons.chat_24_regular,
            color: ShadcnColors.foreground,
            count: post.commentCount,
            onTap: () {},
            large: true,
          ),
          _actionButton(
            icon: FluentIcons.arrow_sync_24_regular,
            color: ShadcnColors.foreground,
            count: post.repostCount,
            onTap: () {},
            large: true,
          ),
          _actionButton(
            icon: FluentIcons.send_24_regular,
            color: ShadcnColors.foreground,
            count: post.shareCount,
            onTap: () {},
            large: true,
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
    bool large = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: large ? 22 : 18, color: color),
            if (count != null && count > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(count),
                style: TextStyle(
                  fontSize: large ? AppFontSizes.body : AppFontSizes.caption,
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
}

class _ThreadLinePainter extends CustomPainter {
  final Color color;

  _ThreadLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const startY = 14.0 + 38.0 + 8.0; // top padding + avatar height + gap
    if (size.height <= startY) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const x = 16.0 + (38.0 / 2.0); // left padding + half avatar
    canvas.drawLine(const Offset(x, startY), Offset(x, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ThreadLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _HighlightLinePainter extends CustomPainter {
  final Color color;
  final bool stopAtAvatar;

  _HighlightLinePainter({required this.color, required this.stopAtAvatar});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final endY = stopAtAvatar ? 19.0 : size.height;
    canvas.drawLine(const Offset(19, 0), Offset(19, endY), paint);
  }

  @override
  bool shouldRepaint(covariant _HighlightLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.stopAtAvatar != stopAtAvatar;
  }
}

class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Shimmer.fromColors(
        baseColor: ShadcnColors.mutedForeground.withValues(alpha: 0.1),
        highlightColor: ShadcnColors.primary.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBox(
                width: 38,
                height: 38,
                borderRadius: BorderRadius.all(Radius.circular(19)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _SkeletonBox(width: 112, height: 14),
                        SizedBox(width: 8),
                        _SkeletonBox(width: 28, height: 12),
                      ],
                    ),
                    SizedBox(height: 12),
                    _SkeletonBox(width: double.infinity, height: 13),
                    SizedBox(height: 8),
                    FractionallySizedBox(
                      widthFactor: 0.72,
                      child: _SkeletonBox(height: 13),
                    ),
                    SizedBox(height: 12),
                    _SkeletonBox(
                      width: double.infinity,
                      height: 250,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _SkeletonBox(width: 46, height: 18),
                        SizedBox(width: 18),
                        _SkeletonBox(width: 46, height: 18),
                        SizedBox(width: 18),
                        _SkeletonBox(width: 46, height: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const _SkeletonBox({this.width, required this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: ShadcnColors.mutedForeground,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}
