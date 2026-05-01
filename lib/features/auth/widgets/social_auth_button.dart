import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';

class SocialAuthButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const SocialAuthButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ShadcnColors.border, width: 1),
          color: ShadcnColors.background,
        ),
        child: SizedBox(height: 24, width: 24, child: Center(child: icon)),
      ),
    );
  }
}
