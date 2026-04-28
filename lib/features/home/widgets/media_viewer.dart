import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/theme/app_theme.dart';

/// Fullscreen Threads-style media viewer:
/// - Swipe left/right between images
/// - Pinch-to-zoom
/// - Close (X) button top-left, more (···) button top-right
/// - Action bar at bottom: ♡ 💬 🔄 ▷ with counts
class MediaViewer extends StatefulWidget {
  final List<Media> medias;
  final int initialIndex;
  final num? likeCount;
  final num? commentCount;
  final num? repostCount;
  final num? shareCount;

  const MediaViewer({
    super.key,
    required this.medias,
    this.initialIndex = 0,
    this.likeCount,
    this.commentCount,
    this.repostCount,
    this.shareCount,
  });

  /// Push the viewer as a fullscreen route.
  static void open(
    BuildContext context,
    List<Media> medias, {
    int initialIndex = 0,
    num? likeCount,
    num? commentCount,
    num? repostCount,
    num? shareCount,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => MediaViewer(
          medias: medias,
          initialIndex: initialIndex,
          likeCount: likeCount,
          commentCount: commentCount,
          repostCount: repostCount,
          shareCount: shareCount,
        ),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 150),
      ),
    );
  }

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatCount(num? count) {
    if (count == null || count == 0) return '';
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.medias.where((m) => m.type == 'image').toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Swipeable fullscreen images ──
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) {
              return Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: images[i].url,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CupertinoActivityIndicator(color: Colors.white),
                    ),
                    errorWidget: (_, __, ___) => const Center(
                      child: Icon(CupertinoIcons.photo,
                          color: Colors.white38, size: 48),
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Top bar: close + more ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close
                    _circleButton(
                      icon: CupertinoIcons.xmark,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    // More
                    _circleButton(
                      icon: CupertinoIcons.ellipsis,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom action bar ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _actionItem(
                      icon: CupertinoIcons.heart,
                      count: widget.likeCount,
                    ),
                    _actionItem(
                      icon: CupertinoIcons.chat_bubble,
                      count: widget.commentCount,
                    ),
                    _actionItem(
                      icon: CupertinoIcons.arrow_2_squarepath,
                      count: widget.repostCount,
                    ),
                    _actionItem(
                      icon: CupertinoIcons.paperplane,
                      count: widget.shareCount,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _actionItem({required IconData icon, num? count}) {
    final label = _formatCount(count);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 22),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
