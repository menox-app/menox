import 'package:flutter/material.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';
import 'package:flutter_core/core/ui/widgets/app_spinner.dart';

class AppIconButton extends StatefulWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final double? sizeOverride;

  const AppIconButton({
    super.key,
    this.icon,
    this.child,
    required this.onPressed,
    this.variant = AppButtonVariant.ghost,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.sizeOverride,
  }) : assert(icon != null || child != null, 'Either icon or child must be provided');

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getSize() {
    if (widget.sizeOverride != null) return widget.sizeOverride!;
    switch (widget.size) {
      case AppButtonSize.xs:
        return 32;
      case AppButtonSize.sm:
        return 36;
      case AppButtonSize.md:
        return 44;
      case AppButtonSize.lg:
        return 52;
      default:
        return 44;
    }
  }

  @override
  Widget build(BuildContext context) {
    final side = _getSize();
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Container(
        width: side,
        height: side,
        decoration: _getDecoration(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            onTap: widget.isLoading ? null : widget.onPressed,
            splashColor: _getSplashColor(),
            highlightColor: Colors.transparent,
            child: Center(
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration? _getDecoration() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          color: ShadcnColors.primary,
          borderRadius: BorderRadius.circular(50),
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: ShadcnColors.secondary,
          borderRadius: BorderRadius.circular(50),
        );
      case AppButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: ShadcnColors.border, width: 1),
        );
      case AppButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        );
      case AppButtonVariant.destructive:
        return BoxDecoration(
          color: ShadcnColors.destructive,
          borderRadius: BorderRadius.circular(50),
        );
      default:
        return null;
    }
  }

  Color _getSplashColor() {
    final textColor = _getTextColor();
    return textColor.withValues(alpha: 0.1);
  }

  Color _getTextColor() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return ShadcnColors.primaryForeground;
      case AppButtonVariant.secondary:
        return ShadcnColors.secondaryForeground;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
      case AppButtonVariant.link:
        return ShadcnColors.foreground;
      case AppButtonVariant.destructive:
        return ShadcnColors.destructiveForeground;
    }
  }

  Widget _buildContent() {
    final textColor = _getTextColor();

    if (widget.isLoading) {
      return AppSpinner(size: 20, color: textColor);
    }

    if (widget.child != null) return widget.child!;

    double iconSize;
    switch (widget.size) {
      case AppButtonSize.xs:
        iconSize = 16;
        break;
      case AppButtonSize.sm:
        iconSize = 18;
        break;
      case AppButtonSize.md:
        iconSize = 20;
        break;
      case AppButtonSize.lg:
        iconSize = 24;
        break;
      default:
        iconSize = 20;
    }

    return Icon(widget.icon, size: iconSize, color: textColor);
  }
}
