import 'package:flutter/widgets.dart';
import 'package:flutter_core/core/theme/app_theme.dart';

class SafeContentArea extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool left;
  final bool top;
  final bool right;
  final bool bottom;
  final bool maintainBottomViewPadding;

  const SafeContentArea({
    super.key,
    required this.child,
    this.padding = AppSpacing.contentHorizontal,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.maintainBottomViewPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: Padding(padding: padding, child: child),
    );
  }
}
