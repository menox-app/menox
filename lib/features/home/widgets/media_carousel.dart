import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/features/home/widgets/media_viewer.dart';
import 'package:video_player/video_player.dart';

/// Renders media for a post (Threads-style):
/// - Single image → full-width rounded image
/// - Multiple images → horizontal scroll of rounded cards (peek next image)
/// - Video → video player with play/pause overlay
class MediaCarousel extends StatefulWidget {
  final List<Media> medias;
  final num? likeCount;
  final num? commentCount;
  final num? repostCount;
  final num? shareCount;

  const MediaCarousel({
    super.key,
    required this.medias,
    this.likeCount,
    this.commentCount,
    this.repostCount,
    this.shareCount,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  static const double _mediaHeight = 280;

  @override
  void initState() {
    super.initState();
    final firstMedia = widget.medias.first;
    if (firstMedia.type == 'video') {
      _initVideo(firstMedia.url);
    }
  }

  void _initVideo(String url) {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) setState(() => _isVideoInitialized = true);
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medias = widget.medias;
    if (medias.isEmpty) return const SizedBox.shrink();

    final images = medias.where((m) => m.type == 'image').toList();
    final videos = medias.where((m) => m.type == 'video').toList();

    if (images.isEmpty && videos.isNotEmpty) return _buildVideoPlayer();
    if (images.length == 1 && videos.isEmpty) {
      return _buildSingleImage(images.first, medias);
    }
    return _buildHorizontalScroll(images, medias);
  }

  // ── Single image ──
  Widget _buildSingleImage(Media media, List<Media> allMedias) {
    return GestureDetector(
      onTap: () => MediaViewer.open(
        context,
        allMedias,
        initialIndex: 0,
        likeCount: widget.likeCount,
        commentCount: widget.commentCount,
        repostCount: widget.repostCount,
        shareCount: widget.shareCount,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: double.infinity,
          height: _mediaHeight,
          child: CachedNetworkImage(
            imageUrl: media.url,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: ShadcnColors.secondary,
              child: const Center(child: CupertinoActivityIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              color: ShadcnColors.secondary,
              child: const Center(
                child: Icon(CupertinoIcons.photo,
                    color: ShadcnColors.mutedForeground, size: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Horizontal scroll of image cards (Threads style) ──
  Widget _buildHorizontalScroll(List<Media> images, List<Media> allMedias) {
    // Card width = ~70% of available width so next card peeks
    // Available width = screen width - 16(left pad) - 38(avatar) - 12(gap) - 16(right pad) = width - 82
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 82) * 0.75;

    return SizedBox(
      height: _mediaHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          return GestureDetector(
                onTap: () => MediaViewer.open(
                  context,
                  allMedias,
                  initialIndex: i,
                  likeCount: widget.likeCount,
                  commentCount: widget.commentCount,
                  repostCount: widget.repostCount,
                  shareCount: widget.shareCount,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: cardWidth,
                    height: _mediaHeight,
                    child: CachedNetworkImage(
                      imageUrl: images[i].url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: ShadcnColors.secondary,
                        child: const Center(
                            child: CupertinoActivityIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: ShadcnColors.secondary,
                        child: const Center(
                          child: Icon(CupertinoIcons.photo,
                              color: ShadcnColors.mutedForeground, size: 28),
                        ),
                      ),
                    ),
                  ),
                ),
          );
        },
      ),
    );
  }

  // ── Video player ──
  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _videoController == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: _mediaHeight,
          color: ShadcnColors.secondary,
          child: const Center(child: CupertinoActivityIndicator()),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: _mediaHeight),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _videoController!.value.isPlaying
                  ? _videoController!.pause()
                  : _videoController!.play();
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              if (!_videoController!.value.isPlaying)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF000000).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.play_fill,
                    color: Color(0xFFFFFFFF),
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
