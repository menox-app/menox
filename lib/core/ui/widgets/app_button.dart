import 'package:flutter/material.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_spinner.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, link, destructive }

enum AppButtonSize { xs, sm, md, lg, icon }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final double? iconSize;
  final bool fullWidth;
  final double? width;
  final double? height;
  final bool disabled;
  final AlignmentGeometry alignment;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.iconSize,
    this.fullWidth = false,
    this.height,
    this.width,
    this.disabled = false,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final button = TextButton(
      onPressed: disabled || isLoading ? null : onPressed,
      style: _buttonStyle(),
      child: _buildContent(),
    );

    final sizedButton = SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height ?? _getHeight(),
      child: button,
    );

    if (fullWidth || width != null) return sizedButton;

    return Align(
      alignment: alignment,
      widthFactor: 1,
      heightFactor: 1,
      child: sizedButton,
    );
  }

  ButtonStyle _buttonStyle() {
    final buttonHeight = height ?? _getHeight();

    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, buttonHeight)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      padding: WidgetStatePropertyAll(_getPadding()),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(_resolveBackgroundColor),
      foregroundColor: WidgetStateProperty.resolveWith(_resolveForegroundColor),
      overlayColor: WidgetStateProperty.resolveWith(_resolveOverlayColor),
      side: WidgetStateProperty.resolveWith(_resolveBorder),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
          height: 1.2,
          leadingDistribution: TextLeadingDistribution.even,
          letterSpacing: 0,
          decoration: variant == AppButtonVariant.link
              ? TextDecoration.underline
              : null,
        ),
      ),
    );
  }

  Color? _resolveBackgroundColor(Set<WidgetState> states) {
    final isDisabled = states.contains(WidgetState.disabled);

    switch (variant) {
      case AppButtonVariant.primary:
        return isDisabled
            ? ShadcnColors.primary.withValues(alpha: 0.6)
            : ShadcnColors.primary;
      case AppButtonVariant.secondary:
        return isDisabled
            ? ShadcnColors.secondary.withValues(alpha: 0.5)
            : ShadcnColors.secondary;
      case AppButtonVariant.destructive:
        return isDisabled
            ? ShadcnColors.destructive.withValues(alpha: 0.5)
            : ShadcnColors.destructive;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
      case AppButtonVariant.link:
        return Colors.transparent;
    }
  }

  Color _resolveForegroundColor(Set<WidgetState> states) {
    final baseColor = _getTextColor();
    if (states.contains(WidgetState.disabled)) {
      return baseColor.withValues(alpha: 0.65);
    }
    return baseColor;
  }

  Color? _resolveOverlayColor(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) return Colors.transparent;
    if (states.contains(WidgetState.pressed)) {
      return _getTextColor().withValues(alpha: 0.12);
    }
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused)) {
      return _getTextColor().withValues(alpha: 0.08);
    }
    return Colors.transparent;
  }

  BorderSide? _resolveBorder(Set<WidgetState> states) {
    if (variant != AppButtonVariant.outline) return null;

    return BorderSide(
      color: states.contains(WidgetState.disabled)
          ? ShadcnColors.border.withValues(alpha: 0.5)
          : ShadcnColors.border,
      width: 1,
    );
  }

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.xs:
        return AppFontSizes.meta;
      case AppButtonSize.sm:
        return AppFontSizes.bodySmall;
      case AppButtonSize.md:
      case AppButtonSize.icon:
        return AppFontSizes.body;
      case AppButtonSize.lg:
        return AppFontSizes.input;
    }
  }

  double _getIconSize() {
    if (iconSize != null) return iconSize!;

    switch (size) {
      case AppButtonSize.xs:
        return 16;
      case AppButtonSize.sm:
        return 18;
      case AppButtonSize.md:
        return 20;
      case AppButtonSize.lg:
        return 22;
      case AppButtonSize.icon:
        return 20;
    }
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.xs:
        return 32;
      case AppButtonSize.sm:
        return 36;
      case AppButtonSize.md:
        return 44;
      case AppButtonSize.lg:
        return 52;
      case AppButtonSize.icon:
        return 44;
    }
  }

  EdgeInsets _getPadding() {
    if (size == AppButtonSize.icon) return EdgeInsets.zero;

    if (variant == AppButtonVariant.ghost || variant == AppButtonVariant.link) {
      switch (size) {
        case AppButtonSize.xs:
          return const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge);
        case AppButtonSize.sm:
          return const EdgeInsets.symmetric(horizontal: 10);
        case AppButtonSize.md:
          return const EdgeInsets.symmetric(horizontal: 12);
        case AppButtonSize.lg:
          return const EdgeInsets.symmetric(horizontal: 16);
        case AppButtonSize.icon:
          return EdgeInsets.zero;
      }
    }

    switch (size) {
      case AppButtonSize.xs:
        return const EdgeInsets.symmetric(horizontal: 12);
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 14);
      case AppButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 18);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 22);
      case AppButtonSize.icon:
        return EdgeInsets.zero;
    }
  }

  double _getIconGap() {
    if (size == AppButtonSize.xs) return 4;
    return 6;
  }

  Color _getTextColor() {
    switch (variant) {
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

    if (isLoading) {
      return AppSpinner(size: _getIconSize(), color: textColor);
    }

    final iconSize = _getIconSize();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          SizedBox.square(
            dimension: iconSize,
            child: Icon(icon, size: iconSize),
          ),
          if (size != AppButtonSize.icon) SizedBox(width: _getIconGap()),
        ],
        if (size != AppButtonSize.icon)
          Text(
            text,
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
              height: 1.2,
              leadingDistribution: TextLeadingDistribution.even,
              letterSpacing: 0,
              decoration: variant == AppButtonVariant.link
                  ? TextDecoration.underline
                  : null,
            ),
          ),
      ],
    );
  }
}
