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

class AppFontSizes {
  static const double caption = 12;
  static const double meta = 13;
  static const double bodySmall = 15;
  static const double body = 16;
  static const double input = 16;
  static const double title = 20;
  static const double largeTitle = 26;
  static const double display = 30;
}

class AppSpacing {
  static const double screenEdge = 8;

  static const EdgeInsetsDirectional navigationBarPadding =
      EdgeInsetsDirectional.only(start: screenEdge, end: screenEdge);

  static const EdgeInsets contentHorizontal = EdgeInsets.symmetric(
    horizontal: screenEdge,
  );

  static const EdgeInsets contentPadding = EdgeInsets.all(screenEdge);
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
          fontSize: AppFontSizes.body,
          color: ShadcnColors.foreground,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: AppFontSizes.display,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: ShadcnColors.foreground,
          fontFamily: '.SF Pro Display',
        ),
        navTitleTextStyle: TextStyle(
          fontSize: AppFontSizes.input,
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
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: AppFontSizes.body,
          height: 1.35,
          color: ShadcnColors.foreground,
        ),
        bodyMedium: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: AppFontSizes.bodySmall,
          height: 1.35,
          color: ShadcnColors.foreground,
        ),
        bodySmall: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: AppFontSizes.meta,
          height: 1.3,
          color: ShadcnColors.mutedForeground,
        ),
        labelLarge: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.foreground,
        ),
        labelMedium: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: AppFontSizes.bodySmall,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.foreground,
        ),
        labelSmall: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: AppFontSizes.caption,
          fontWeight: FontWeight.w500,
          color: ShadcnColors.mutedForeground,
        ),
        titleLarge: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: AppFontSizes.largeTitle,
          fontWeight: FontWeight.w700,
          color: ShadcnColors.foreground,
        ),
        titleMedium: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: AppFontSizes.title,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.foreground,
        ),
        titleSmall: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: AppFontSizes.input,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.foreground,
        ),
      ),
    );
  }
}
