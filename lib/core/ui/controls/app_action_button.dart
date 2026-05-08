import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/utils/number_format_utils.dart';

class AppActionButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final Color color;
  final Color? activeColor;
  final num? count;
  final VoidCallback? onTap;
  final bool large;
  final bool isActive;

  const AppActionButton({
    super.key,
    required this.icon,
    this.activeIcon,
    required this.color,
    this.activeColor,
    this.count,
    required this.onTap,
    this.large = false,
    this.isActive = false,
  });

  @override
  State<AppActionButton> createState() => _AppActionButtonState();
}

class _AppActionButtonState extends State<AppActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late Color _fromColor;
  late Color _toColor;

  @override
  void initState() {
    super.initState();
    final initialColor = _resolvedColor(widget.isActive);
    _fromColor = initialColor;
    _toColor = initialColor;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: widget.isActive ? 1.08 : 1.04,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 52,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.isActive ? 1.08 : 1.04,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 48,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant AppActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _fromColor = _resolvedColor(oldWidget.isActive);
      _toColor = _resolvedColor(widget.isActive);
      _controller
        ..stop()
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.isActive
        ? (widget.activeIcon ?? widget.icon)
        : widget.icon;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenEdge,
          vertical: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final color =
                    ColorTween(
                      begin: _fromColor,
                      end: _toColor,
                    ).transform(_controller.value) ??
                    _toColor;

                return Transform.scale(
                  scale: _scale.value,
                  child: IconTheme(
                    data: IconThemeData(color: color),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: color),
                      child: child!,
                    ),
                  ),
                );
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final offset =
                      Tween<Offset>(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: Icon(
                  icon,
                  key: ValueKey('${icon.codePoint}-${widget.isActive}'),
                  size: widget.large ? 22 : 18,
                ),
              ),
            ),
            if (widget.count != null && widget.count! > 0) ...[
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final color =
                      ColorTween(
                        begin: _fromColor,
                        end: _toColor,
                      ).transform(_controller.value) ??
                      _toColor;
                  return DefaultTextStyle.merge(
                    style: TextStyle(color: color),
                    child: child!,
                  );
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final offset =
                        Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        );
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: offset, child: child),
                    );
                  },
                  child: Text(
                    NumberFormatUtils.compactCount(widget.count),
                    key: ValueKey('${widget.count}-${widget.isActive}'),
                    style: TextStyle(
                      fontSize: widget.large
                          ? AppFontSizes.body
                          : AppFontSizes.caption,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _resolvedColor(bool isActive) {
    if (isActive) {
      return widget.activeColor ?? widget.color;
    }
    return widget.color;
  }
}
