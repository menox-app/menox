import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/apis/app/interfaces/comment.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_image.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/utils/date_time_utils.dart';
import 'package:flutter_core/core/utils/number_format_utils.dart';
import 'package:flutter_core/features/home/widgets/create_comment_sheet.dart';
import 'package:shimmer/shimmer.dart';

class CommentCard extends StatelessWidget {
  final Post post;
  final Comment comment;
  final bool isLast;
  final bool showHorizontalPadding;

  const CommentCard({
    super.key,
    required this.post,
    required this.comment,
    this.isLast = false,
    this.showHorizontalPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final author = comment.author;
    final hasContent =
        comment.content != null && comment.content!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHorizontalPadding) const SizedBox(width: 16),
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
              padding: EdgeInsets.only(top: 2, right: showHorizontalPadding ? 16 : 0),
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
                          DateTimeUtils.relativeShort(comment.createdAt),
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
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: AppFontSizes.bodySmall,
                          height: 1.4,
                          color: ShadcnColors.foreground,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  _buildCommentActionBar(context, comment),
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

  Widget _buildCommentActionBar(BuildContext context, Comment comment) {
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
            onTap: () =>
                showCreateCommentSheet(context, post, parentComment: comment),
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
            Icon(icon, size: 18, color: color),
            if (count != null && count > 0) ...[
              const SizedBox(width: 4),
              Text(
                NumberFormatUtils.compactCount(count),
                style: TextStyle(
                  fontSize: AppFontSizes.caption,
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

class CommentCardSkeleton extends StatelessWidget {
  const CommentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Shimmer.fromColors(
        baseColor: ShadcnColors.mutedForeground.withValues(alpha: 0.1),
        highlightColor: ShadcnColors.primary.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                        _SkeletonBox(width: 80, height: 14),
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
