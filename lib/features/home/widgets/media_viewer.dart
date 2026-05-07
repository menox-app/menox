import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_spinner.dart';
import 'package:flutter_core/core/utils/number_format_utils.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Fullscreen media viewer.
/// - Swipe left/right between images
/// - Pinch-to-zoom
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

  @override
  Widget build(BuildContext context) {
    // Show all medias (both images and videos)
    final items = widget.medias;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                final media = items[index];
                if (media.type == 'video') {
                  return PhotoViewGalleryPageOptions.customChild(
                    child: _VideoViewerPage(media: media),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 4.0,
                    heroAttributes: PhotoViewHeroAttributes(tag: media.url),
                  );
                }
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(media.url),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 4.0,
                  heroAttributes: PhotoViewHeroAttributes(tag: media.url),
                );
              },
              itemCount: items.length,
              pageController: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close
                    _circleButton(
                      icon: FluentIcons.dismiss_24_regular,
                      onTap: () => Navigator.of(context).pop(),
                    ),

                    // Page Indicator (e.g., 1 / 3)
                    if (items.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentPage + 1} / ${items.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppFontSizes.bodySmall,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                    // More
                    _circleButton(
                      icon: FluentIcons.more_horizontal_24_regular,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _actionItem(
                      icon: FluentIcons.heart_24_regular,
                      count: widget.likeCount,
                    ),
                    _actionItem(
                      icon: FluentIcons.chat_24_regular,
                      count: widget.commentCount,
                    ),
                    _actionItem(
                      icon: FluentIcons.arrow_repeat_all_24_regular,
                      count: widget.repostCount,
                    ),
                    _actionItem(
                      icon: FluentIcons.send_24_regular,
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

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _actionItem({required IconData icon, num? count}) {
    final label = NumberFormatUtils.compactCount(count);
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
              fontSize: AppFontSizes.meta,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _VideoViewerPage extends StatefulWidget {
  final Media media;

  const _VideoViewerPage({required this.media});

  @override
  State<_VideoViewerPage> createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<_VideoViewerPage> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  String? _error;

  bool _showControls = true;
  bool _isScrubbing = false;
  bool _showCenterIcon = false;
  bool _isFullscreen = false;
  IconData _centerIcon = FluentIcons.play_24_filled;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.media.url))
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() => _initialized = true);
              _controller.play();
              _startHideTimer();
            }
          })
          .catchError((e) {
            if (mounted) setState(() => _error = e.toString());
          });

    // Listen to controller to keep slider updated smoothly
    _controller.addListener(() {
      if (mounted && _controller.value.isPlaying && !_isScrubbing) {
        setState(() {}); // trigger rebuild for progress
      }
    });
  }

  void _startHideTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isScrubbing && _controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showControls = true;
        _centerIcon = FluentIcons.pause_24_filled;
      } else {
        _controller.play();
        _startHideTimer();
        _centerIcon = FluentIcons.play_24_filled;
      }

      // Briefly show center icon
      _showCenterIcon = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showCenterIcon = false);
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (!_initialized) {
      return const Center(child: AppSpinner(color: Colors.white));
    }

    final duration = _controller.value.duration.inMilliseconds.toDouble();
    final position = _controller.value.position.inMilliseconds.toDouble();
    double progress = duration > 0
        ? (position / duration).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _showControls = true;
        _togglePlay();
      },
      child: Stack(
        children: [
          Center(
            child: SizedBox.expand(
              child: FittedBox(
                fit: _isFullscreen ? BoxFit.contain : BoxFit.contain,
                child: SizedBox(
                  width: _controller.value.size.width == 0
                      ? 100
                      : _controller.value.size.width,
                  height: _controller.value.size.height == 0
                      ? 100
                      : _controller.value.size.height,
                  child: IgnorePointer(child: VideoPlayer(_controller)),
                ),
              ),
            ),
          ),

          if (_controller.value.size.width > _controller.value.size.height)
            Positioned(
              bottom: 150, // Floating above the bottom controls
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showControls ? 1.0 : 0.0,
                  child: GestureDetector(
                    onTap: () {
                      _toggleFullscreen();
                      _startHideTimer();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isFullscreen
                                ? FluentIcons.full_screen_minimize_24_regular
                                : FluentIcons.full_screen_maximize_24_regular,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isFullscreen ? 'Exit full screen' : 'Full screen',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppFontSizes.meta,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showCenterIcon ? 0.7 : 0.0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(_centerIcon, color: Colors.white, size: 48),
              ),
            ),
          ),

          Positioned(
            bottom: 80, // Above engagement bar
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showControls || _isScrubbing ? 1.0 : 0.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Action Row (Volume)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Volume Mute/Unmute
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _controller.setVolume(
                                _controller.value.volume == 0 ? 1.0 : 0.0,
                              );
                              _startHideTimer();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _controller.value.volume == 0
                                  ? FluentIcons.speaker_mute_24_filled
                                  : FluentIcons.speaker_2_24_filled,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Time Duration Label (shown when scrubbing or controls visible)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppFontSizes.caption,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 2),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Smooth Scrubber Bar
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: _isScrubbing ? 6.0 : 2.0,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: _isScrubbing
                            ? 6.0
                            : 0.0, // Hide thumb when not scrubbing
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14.0,
                      ),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: (val) {
                        setState(() => _isScrubbing = true);
                        final newPosition = Duration(
                          milliseconds: (duration * val).toInt(),
                        );
                        _controller.seekTo(newPosition);
                      },
                      onChangeEnd: (val) {
                        setState(() {
                          _isScrubbing = false;
                          _startHideTimer();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
