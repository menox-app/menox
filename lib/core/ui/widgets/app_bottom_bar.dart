import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';

class AppBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onCreatePressed;

  const AppBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    const double barWidth = 280; // Stable width for 5 items
    const double barHeight = 56;
    const double itemWidth = barWidth / 5;
    const double pillPadding = 6; // Padding inside the item slot for the pill

    return Center(
      child: Container(
        width: barWidth,
        height: barHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: ShadcnColors.primary.withValues(alpha: 0.1),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: ShadcnColors.primary.withValues(alpha: 0.25),
              child: Stack(
                children: [
                  // Selection Pill - Perfect alignment with Expanded slots
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuart,
                    left: selectedIndex * itemWidth + pillPadding,
                    top: pillPadding,
                    child: Container(
                      width: itemWidth - (pillPadding * 2),
                      height: barHeight - (pillPadding * 2),
                      decoration: BoxDecoration(
                        color: ShadcnColors.primary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                  // Icons Row - Using Expanded to ensure exact centering
                  Row(
                    children: [
                      Expanded(
                        child: _NavBarItem(
                          icon: CupertinoIcons.square_grid_2x2_fill,
                          isSelected: selectedIndex == 0,
                          onTap: () => onItemSelected(0),
                          height: barHeight,
                        ),
                      ),
                      Expanded(
                        child: _NavBarItem(
                          icon: CupertinoIcons.chat_bubble_fill,
                          isSelected: selectedIndex == 1,
                          onTap: () => onItemSelected(1),
                          height: barHeight,
                        ),
                      ),
                      Expanded(
                        child: _CreateButton(
                          onTap: onCreatePressed,
                          height: barHeight,
                        ),
                      ),
                      Expanded(
                        child: _NavBarItem(
                          icon: CupertinoIcons.heart_fill,
                          isSelected: selectedIndex == 3,
                          onTap: () => onItemSelected(3),
                          height: barHeight,
                        ),
                      ),
                      Expanded(
                        child: _NavBarItem(
                          icon: CupertinoIcons.person_fill,
                          isSelected: selectedIndex == 4,
                          onTap: () => onItemSelected(4),
                          height: barHeight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double height;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: height,
        child: Center(
          child: Icon(
            icon,
            color: isSelected
                ? ShadcnColors.primaryForeground
                : ShadcnColors.mutedForeground.withValues(alpha: 0.5),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;
  final double height;

  const _CreateButton({required this.onTap, required this.height});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: ShadcnColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.add,
              color: ShadcnColors.primaryForeground,
              size: 20, // Slightly smaller for mini
            ),
          ),
        ),
      ),
    );
  }
}
