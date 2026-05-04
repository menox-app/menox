import 'package:flutter/material.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_spinner.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, link, destructive }

enum AppButtonSize { xs, sm, md, lg, icon }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool fullWidth;
  final double? width;
  final double? height;
  final bool disabled;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.fullWidth = false,
    this.height,
    this.width,
    this.disabled = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: Container(
        height: widget.height ?? _getHeight(),
        width: widget.width ?? (widget.fullWidth ? double.infinity : null),
        decoration: _getDecoration(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTapDown: widget.disabled ? null : (_) => _controller.forward(),
            onTapUp: widget.disabled ? null : (_) => _controller.reverse(),
            onTapCancel: widget.disabled ? null : () => _controller.reverse(),
            onTap: (widget.isLoading || widget.disabled)
                ? null
                : widget.onPressed,
            splashColor: _getSplashColor(),
            highlightColor: Colors.transparent,
            child: Padding(padding: _getPadding(), child: _buildContent()),
          ),
        ),
      ),
    );
  }

  BoxDecoration? _getDecoration() {
    if (widget.variant == AppButtonVariant.link) return null;

    final bool isDisabled = widget.disabled || widget.isLoading;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          color: isDisabled
              ? ShadcnColors.primary.withValues(alpha: 0.6)
              : ShadcnColors.primary,
          borderRadius: BorderRadius.circular(50),
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: isDisabled
              ? ShadcnColors.secondary.withValues(alpha: 0.5)
              : ShadcnColors.secondary,
          borderRadius: BorderRadius.circular(50),
        );
      case AppButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isDisabled
                ? ShadcnColors.border.withValues(alpha: 0.5)
                : ShadcnColors.border,
            width: 1,
          ),
        );
      case AppButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        );
      case AppButtonVariant.destructive:
        return BoxDecoration(
          color: isDisabled
              ? ShadcnColors.destructive.withValues(alpha: 0.5)
              : ShadcnColors.destructive,
          borderRadius: BorderRadius.circular(50),
        );
      default:
        return null;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case AppButtonSize.xs:
        return 32;
      case AppButtonSize.sm:
        return 36;
      case AppButtonSize.md:
        return 44; // Mobile Standard
      case AppButtonSize.lg:
        return 52; // CTA Standard
      case AppButtonSize.icon:
        return 44;
    }
  }

  Color _getSplashColor() {
    final textColor = _getTextColor();
    return textColor.withValues(alpha: 0.1);
  }

  EdgeInsets _getPadding() {
    if (widget.size == AppButtonSize.icon) return EdgeInsets.zero;

    switch (widget.size) {
      case AppButtonSize.xs:
        return const EdgeInsets.symmetric(horizontal: 12);
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 16);
      case AppButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 20);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 24);
      default:
        return const EdgeInsets.symmetric(horizontal: 20);
    }
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
      return Center(child: AppSpinner(size: 20, color: textColor));
    }

    double fontSize;
    double iconSize;

    switch (widget.size) {
      case AppButtonSize.xs:
        fontSize = AppFontSizes.meta;
        iconSize = 14;
        break;
      case AppButtonSize.sm:
        fontSize = AppFontSizes.bodySmall;
        iconSize = 16;
        break;
      case AppButtonSize.md:
        fontSize = AppFontSizes.body;
        iconSize = 18;
        break;
      case AppButtonSize.lg:
        fontSize = AppFontSizes.input;
        iconSize = 20;
        break;
      case AppButtonSize.icon:
        fontSize = AppFontSizes.body;
        iconSize = 20;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: iconSize, color: textColor),
          if (widget.size != AppButtonSize.icon) const SizedBox(width: 8),
        ],
        if (widget.size != AppButtonSize.icon)
          Text(
            widget.text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              decoration: widget.variant == AppButtonVariant.link
                  ? TextDecoration.underline
                  : null,
            ),
          ),
      ],
    );
  }
}
