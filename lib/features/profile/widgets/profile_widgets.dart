import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_image.dart';

class ProfileStatItem extends StatelessWidget {
  final String label;
  final String value;

  const ProfileStatItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: AppFontSizes.title,
            fontWeight: FontWeight.w800,
            color: ShadcnColors.foreground,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.caption,
            fontWeight: FontWeight.w500,
            color: ShadcnColors.mutedForeground.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class ProfileTagChip extends StatelessWidget {
  final String label;

  const ProfileTagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ShadcnColors.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ShadcnColors.border.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: AppFontSizes.meta,
          fontWeight: FontWeight.w500,
          color: ShadcnColors.mutedForeground,
        ),
      ),
    );
  }
}

class PremiumGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const PremiumGradientButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3B448F), // Deep Blue/Purple
              Color(0xFFE89E5B), // Golden/Orange
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B448F).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: AppFontSizes.input,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String? bannerUrl;
  final String? avatarUrl;
  final double expandedHeight;

  ProfileHeaderDelegate({
    this.bannerUrl,
    this.avatarUrl,
    required this.expandedHeight,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double opacity = (1 - shrinkOffset / expandedHeight).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Avatar Image acting as Banner (filling the space)
        if (avatarUrl != null)
          Opacity(
            opacity: opacity,
            child: AppImage(
              url: avatarUrl,
              fit: BoxFit.cover,
              backgroundColor: ShadcnColors.secondary,
            ),
          )
        else
          Container(color: ShadcnColors.secondary),

        // Gradient Overlay for readability
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CupertinoColors.black.withValues(alpha: 0.1),
                CupertinoColors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant ProfileHeaderDelegate oldDelegate) => true;
}
