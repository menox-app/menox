import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/apis/app/interfaces/comment.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/media/app_image.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/utils/date_time_utils.dart';
import 'package:flutter_core/core/utils/number_format_utils.dart';
import 'package:flutter_core/features/comment/widgets/create_comment_sheet.dart';
import 'package:shimmer/shimmer.dart';

class CommentCard extends StatelessWidget {
  static const double _horizontalInset = AppSpacing.screenEdge;

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
    final hasMedia = comment.medias != null && comment.medias!.isNotEmpty;
    final isOptimistic = comment.extraData['optimistic'] == true;

    return Container(
      padding: EdgeInsets.only(top: showHorizontalPadding ? 8 : 0),
      child: _PendingPulse(
        isPending: isOptimistic,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHorizontalPadding) const SizedBox(width: _horizontalInset),
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
                padding: EdgeInsets.only(
                  top: 2,
                  right: showHorizontalPadding ? _horizontalInset : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            author?.displayName ??
                                author?.username ??
                                'Unknown',
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
                    if (hasMedia)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: comment.medias!
                                .map((media) => _buildMediaPreview(media.url))
                                .toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    _buildCommentActionBar(context, comment, isOptimistic),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildMediaPreview(String url) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: ShadcnColors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ShadcnColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: AppImage(
        url: url,
        fit: BoxFit.cover,
        backgroundColor: ShadcnColors.secondary,
      ),
    );
  }

  Widget _buildCommentActionBar(
    BuildContext context,
    Comment comment,
    bool isOptimistic,
  ) {
    return Transform.translate(
      offset: const Offset(-8, 0),
      child: Row(
        children: [
          _actionButton(
            icon: FluentIcons.heart_24_regular,
            color: ShadcnColors.foreground,
            count: comment.likeCount,
            onTap: isOptimistic ? null : () {},
          ),
          _actionButton(
            icon: FluentIcons.chat_24_regular,
            color: ShadcnColors.foreground,
            count: comment.replyCount,
            onTap: isOptimistic
                ? null
                : () => showCreateCommentSheet(
                    context,
                    post,
                    parentComment: comment,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    num? count,
    required VoidCallback? onTap,
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

class _PendingPulse extends StatefulWidget {
  final bool isPending;
  final Widget child;

  const _PendingPulse({required this.isPending, required this.child});

  @override
  State<_PendingPulse> createState() => _PendingPulseState();
}

class _PendingPulseState extends State<_PendingPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = Tween<double>(
      begin: 0.55,
      end: 0.72,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.isPending) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PendingPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPending == oldWidget.isPending) return;
    if (widget.isPending) {
      _controller.repeat(reverse: true);
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPending) return widget.child;

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(opacity: _opacity.value, child: child);
      },
      child: widget.child,
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
          padding: const EdgeInsets.all(AppSpacing.screenEdge),
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
