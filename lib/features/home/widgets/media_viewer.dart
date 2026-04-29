import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

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
    // Show all medias (both images and videos)
    final items = widget.medias;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Swipeable fullscreen items ──
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) {
                final media = items[i];
                if (media.type == 'video') {
                  return _VideoViewerPage(media: media);
                }
                return Center(child: _ZoomableImage(url: media.url));
              },
            ),
          ),

          // ── Top bar: close + more ──
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
                      icon: CupertinoIcons.xmark,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    // More
                    _circleButton(icon: CupertinoIcons.ellipsis, onTap: () {}),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
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
  IconData _centerIcon = CupertinoIcons.play_fill;

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
        _centerIcon = CupertinoIcons.pause_fill;
      } else {
        _controller.play();
        _startHideTimer();
        _centerIcon = CupertinoIcons.play_fill;
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
      return const Center(
        child: CupertinoActivityIndicator(color: Colors.white),
      );
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
          // ── Video ──
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

          // ── Center Bottom Fullscreen Pill (Only for Landscape Videos) ──
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
                                ? CupertinoIcons.arrow_down_right_arrow_up_left
                                : CupertinoIcons.viewfinder,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isFullscreen ? 'Thu nhỏ' : 'Toàn màn hình',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
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

          // ── Fading Center Icon ──
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

          // ── TikTok Style Bottom Controls ──
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
                                  ? CupertinoIcons.speaker_slash_fill
                                  : CupertinoIcons.speaker_2_fill,
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
                            fontSize: 12,
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

class _ZoomableImage extends StatefulWidget {
  final String url;
  const _ZoomableImage({required this.url});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final TransformationController _transformationController =
      TransformationController();
  bool _isZoomed = false;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(() {
      final isZoomed =
          _transformationController.value.getMaxScaleOnAxis() > 1.01;
      if (isZoomed != _isZoomed) {
        setState(() => _isZoomed = isZoomed);
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: widget.url,
      fit: BoxFit.contain,
      placeholder: (_, __) =>
          const Center(child: CupertinoActivityIndicator(color: Colors.white)),
      errorWidget: (_, __, ___) => const Center(
        child: Icon(CupertinoIcons.photo, color: Colors.white38, size: 48),
      ),
    );

    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          if (pointerSignal.scrollDelta.dy < 0 && !_isZoomed) {
            // Scroll Up -> Zoom In
            setState(() => _isZoomed = true);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final pos = pointerSignal.localPosition;
              _transformationController.value = Matrix4.identity()
                ..translate(-pos.dx, -pos.dy)
                ..scale(2.0);
            });
          } else if (pointerSignal.scrollDelta.dy > 0 && _isZoomed) {
            // Scroll Down -> Zoom Out
            final currentScale = _transformationController.value
                .getMaxScaleOnAxis();
            if (currentScale <= 1.2) {
              _transformationController.value = Matrix4.identity();
              setState(() => _isZoomed = false);
            } else {
              _transformationController.value.scale(0.8);
            }
          }
        }
      },
      child: GestureDetector(
        onDoubleTapDown: (details) => _tapPosition = details.localPosition,
        onDoubleTap: () {
          if (_isZoomed) {
            setState(() => _isZoomed = false);
          } else {
            setState(() => _isZoomed = true);
            // Must wait until InteractiveViewer is fully mounted in the tree
            // before applying the matrix transform, otherwise it overrides it!
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final pos = _tapPosition ?? const Offset(0, 0);
              // Scale by 2.0 and center on the tap position
              _transformationController.value = Matrix4.identity()
                ..translate(-pos.dx, -pos.dy)
                ..scale(2.0);
            });
          }
        },
        child: _isZoomed
            ? InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 4.0,
                panEnabled: true,
                scaleEnabled: true,
                child: image,
              )
            : image,
      ),
    );
  }
}
