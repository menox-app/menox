import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';

class AppSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final double lineWidth;

  const AppSpinner({
    super.key,
    this.size = 20,
    this.color,
    this.lineWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final spinnerColor = color ?? ShadcnColors.mutedForeground;

    return SizedBox(
      width: size,
      height: size,
      child: CupertinoActivityIndicator(
        color: spinnerColor,
        radius: size / 2,
      ),
    );
  }
}
