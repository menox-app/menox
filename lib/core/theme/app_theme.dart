import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShadcnColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF09090B);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF09090B);
  static const Color popover = Color(0xFFFFFFFF);
  static const Color popoverForeground = Color(0xFF09090B);
  static const Color primary = Color(0xFF18181B);
  static const Color primaryForeground = Color(0xFFFAFAFA);
  static const Color secondary = Color(0xFFF4F4F5);
  static const Color secondaryForeground = Color(0xFF18181B);
  static const Color muted = Color(0xFFF4F4F5);
  static const Color mutedForeground = Color(0xFF71717A);
  static const Color accent = Color(0xFFF4F4F5);
  static const Color accentForeground = Color(0xFF18181B);
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFAFAFA);
  static const Color border = Color(0xFFE4E4E7);
  static const Color input = Color(0xFFE4E4E7);
  static const Color ring = Color(0xFF18181B);
}

class AppTheme {
  static CupertinoThemeData get cupertinoTheme {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: ShadcnColors.primary,
      scaffoldBackgroundColor: ShadcnColors.background,
      barBackgroundColor: ShadcnColors.background,
      textTheme: CupertinoTextThemeData(
        primaryColor: ShadcnColors.foreground,
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text', // Standard iOS font if available
          fontSize: 14,
          color: ShadcnColors.foreground,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: ShadcnColors.foreground,
          fontFamily: '.SF Pro Display',
        ),
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.foreground,
          fontFamily: '.SF Pro Text',
        ),
      ),
    );
  }

  // Temporary for backward compatibility if needed by any library
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: ShadcnColors.primary,
        onPrimary: ShadcnColors.primaryForeground,
        surface: ShadcnColors.background,
        onSurface: ShadcnColors.foreground,
      ),
      scaffoldBackgroundColor: ShadcnColors.background,
    );
  }
}
