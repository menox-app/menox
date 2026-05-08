import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/apis/app/interfaces/comment.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/media/app_image.dart';
import 'package:flutter_core/core/utils/date_time_utils.dart';
import 'package:flutter_core/core/utils/number_format_utils.dart';
import 'package:flutter_core/features/comment/widgets/comment_card.dart';
import 'package:flutter_core/features/comment/widgets/create_comment_sheet.dart';
import 'package:flutter_core/features/post/widgets/media_carousel.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

/// Threads-style post card:
class PostCard extends StatelessWidget {
  static const double _horizontalInset = AppSpacing.screenEdge;
  static const double _avatarSize = 38;
  static const double _avatarGap = 12;
  static const double _contentInset =
      _horizontalInset + _avatarSize + _avatarGap;

  final Post post;
  final bool isDetail;

  const PostCard({super.key, required this.post, this.isDetail = false});

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
      onTap: () => context.push('/post/${post.id.trim()}', extra: post),
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
                      padding: const EdgeInsets.fromLTRB(
                        _horizontalInset,
                        14,
                        _horizontalInset,
                        0,
                      ),
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
                        padding: const EdgeInsets.only(
                          left: _contentInset,
                          right: _horizontalInset,
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        _contentInset,
                        0,
                        _horizontalInset,
                        0,
                      ),
                      child: _buildActionBar(context),
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
            padding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
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
                          painter: _ThreadLinePainter(
                            color: ShadcnColors.border,
                            startFromAvatar: true,
                            paddingLeft: 0,
                          ),
                        ),
                      ),
                      _buildAvatar(author),
                    ],
                  ),
                ),
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
                        DateTimeUtils.relativeShort(post.createdAt),
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
              padding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
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
              padding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
            ),
          ],
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
            child: _buildDetailActionBar(context),
          ),
          const SizedBox(height: 12),
          Container(height: 0.5, color: ShadcnColors.border),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _horizontalInset,
              vertical: 14,
            ),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _horizontalInset,
        8,
        _horizontalInset,
        isLast ? 12 : 8,
      ),
      child: CommentCard(
        post: post,
        comment: comment,
        isLast: isLast,
        showHorizontalPadding: false,
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
                DateTimeUtils.relativeShort(post.createdAt),
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

  Widget _buildActionBar(BuildContext context) {
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
            onTap: () {
              if (isDetail) {
                // If already in detail, focus or show sheet
                showCreateCommentSheet(context, post);
              } else {
                context.push('/post/${post.id.trim()}', extra: post);
              }
            },
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

  Widget _buildDetailActionBar(BuildContext context) {
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
            onTap: () => showCreateCommentSheet(context, post),
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenEdge,
          vertical: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: large ? 22 : 18, color: color),
            if (count != null && count > 0) ...[
              const SizedBox(width: 4),
              Text(
                NumberFormatUtils.compactCount(count),
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
  final bool startFromAvatar;
  final double paddingLeft;

  _ThreadLinePainter({
    required this.color,
    this.startFromAvatar = false,
    this.paddingLeft = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startY = startFromAvatar ? (38.0 + 8.0) : (14.0 + 38.0 + 8.0);
    if (size.height <= startY) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final x = paddingLeft + (38.0 / 2.0);
    canvas.drawLine(Offset(x, startY), Offset(x, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ThreadLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.startFromAvatar != startFromAvatar ||
        oldDelegate.paddingLeft != paddingLeft;
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            14,
            AppSpacing.screenEdge,
            14,
          ),
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
