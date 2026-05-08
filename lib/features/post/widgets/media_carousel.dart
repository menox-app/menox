import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/media/app_image.dart';
import 'package:flutter_core/core/ui/feedback/app_spinner.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_core/features/post/widgets/media_viewer.dart';

/// Renders media for a post.
class MediaCarousel extends StatefulWidget {
  final List<Media> medias;
  final num? likeCount;
  final num? commentCount;
  final num? repostCount;
  final num? shareCount;
  final EdgeInsetsGeometry padding;

  const MediaCarousel({
    super.key,
    required this.medias,
    this.likeCount,
    this.commentCount,
    this.repostCount,
    this.shareCount,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  String? _videoError;

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
      ..initialize()
          .then((_) {
            // Auto-play videos are usually muted by default
            _videoController!.setVolume(0.0);
            _videoController!.setLooping(true);
            if (mounted) setState(() => _isVideoInitialized = true);
          })
          .catchError((error) {
            debugPrint("Video init error: \$error");
            if (mounted) setState(() => _videoError = error.toString());
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

  Widget _buildSingleImage(Media media, List<Media> allMedias) {
    return Padding(
      padding: widget.padding,
      child: GestureDetector(
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
            child: AppImage(url: media.url, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalScroll(List<Media> images, List<Media> allMedias) {
    // Card width = ~70% of available width so next card peeks
    // Available width = screen width - 16(left pad) - 38(avatar) - 12(gap) - 16(right pad) = width - 82
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 82) * 0.75;

    return SizedBox(
      height: _mediaHeight,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: widget.padding,
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
                  child: AppImage(url: images[i].url, fit: BoxFit.cover),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoError != null) {
      return Padding(
        padding: widget.padding,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: _mediaHeight,
            color: ShadcnColors.secondary,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Video Error:\n${_videoError ?? ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ShadcnColors.destructive,
                    fontSize: AppFontSizes.meta,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!_isVideoInitialized || _videoController == null) {
      return Padding(
        padding: widget.padding,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: _mediaHeight,
            color: ShadcnColors.secondary,
            child: const Center(child: AppSpinner()),
          ),
        ),
      );
    }

    return Padding(
      padding: widget.padding,
      child: VisibilityDetector(
        key: Key('video_${widget.medias.first.id}'),
        onVisibilityChanged: (info) {
          if (!mounted || _videoController == null || !_isVideoInitialized) {
            return;
          }
          if (info.visibleFraction >= 0.5) {
            if (!_videoController!.value.isPlaying) {
              _videoController!.play();
            }
          } else {
            if (_videoController!.value.isPlaying) {
              _videoController!.pause();
            }
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Open MediaViewer instead of toggling play inline
              MediaViewer.open(
                context,
                widget.medias,
                initialIndex: 0,
                likeCount: widget.likeCount,
                commentCount: widget.commentCount,
                repostCount: widget.repostCount,
                shareCount: widget.shareCount,
              );
            },
            child: SizedBox(
              width: double.infinity,
              height: _mediaHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                      child: Center(
                        child: _videoController!.value.aspectRatio > 0
                            ? AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: IgnorePointer(
                                  child: VideoPlayer(_videoController!),
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_videoController!.value.volume == 0) {
                            _videoController!.setVolume(1.0);
                          } else {
                            _videoController!.setVolume(0.0);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF000000).withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _videoController!.value.volume == 0
                              ? FluentIcons.speaker_mute_24_filled
                              : FluentIcons.speaker_2_24_filled,
                          color: const Color(0xFFFFFFFF),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
