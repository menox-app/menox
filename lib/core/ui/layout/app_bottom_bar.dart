import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
    const double barWidth = 280;
    const double barHeight = 56;
    const double itemWidth = barWidth / 5;
    const double pillPadding = 6;

    return Center(
      child: Container(
        width: barWidth,
        height: barHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          // CSS: box-shadow: 0px 0px 21px -8px rgba(255,255,255,0.3)
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.08),
              blurRadius: 21,
              spreadRadius: -4,
            ),
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFFFFF).withValues(alpha: 0.08),
                    const Color(0xFFFFFFFF).withValues(alpha: 0.03),
                    const Color(0xFFFFFFFF).withValues(alpha: 0.06),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFFFFF).withValues(alpha: 0.0),
                            const Color(0xFFFFFFFF).withValues(alpha: 0.4),
                            const Color(0xFFFFFFFF).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuart,
                    left: selectedIndex * itemWidth + pillPadding,
                    top: pillPadding,
                    child: Container(
                      width: itemWidth - (pillPadding * 2),
                      height: barHeight - (pillPadding * 2),
                      decoration: BoxDecoration(
                        // CSS button: rgba(255,255,255,0.1)
                        color: const Color(0xFFFFFFFF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(
                            0xFFFFFFFF,
                          ).withValues(alpha: 0.12),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _NavBarItem(
                          icon: FluentIcons.grid_20_regular,
                          activeIcon: FluentIcons.grid_20_filled,
                          isSelected: selectedIndex == 0,
                          onTap: () => onItemSelected(0),
                          height: barHeight,
                        ),
                      ),
                      Expanded(
                        child: _NavBarItem(
                          icon: FluentIcons.chat_32_regular,
                          activeIcon: FluentIcons.chat_32_filled,
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
                          icon: FluentIcons.heart_32_regular,
                          activeIcon: FluentIcons.heart_32_filled,
                          isSelected: selectedIndex == 3,
                          onTap: () => onItemSelected(3),
                          height: barHeight,
                        ),
                      ),
                      Expanded(
                        child: _NavBarItem(
                          icon: FluentIcons.person_32_regular,
                          activeIcon: FluentIcons.person_32_filled,
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
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final double height;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
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
            isSelected ? activeIcon : icon,
            color: isSelected
                ? ShadcnColors.primary
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
            decoration: BoxDecoration(
              color: ShadcnColors.primary,
              shape: BoxShape.circle,
              // Glass shadow cho create button
              boxShadow: [
                BoxShadow(
                  color: ShadcnColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              FluentIcons.add_24_filled,
              color: ShadcnColors.primaryForeground,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
