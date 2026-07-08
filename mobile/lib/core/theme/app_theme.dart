import 'package:flutter/material.dart';

/// Design tokens for the "PUR Beatmaker" art direction: dark, clean,
/// urban/premium, with sparing neon accents reserved for active
/// playback state, tags and key actions. Full design system comes
/// in the UX/UI step — this is the minimal palette needed to start
/// building screens consistently.
abstract class AppColors {
  static const deepBlack = Color(0xFF0B0B0D);
  static const anthracite = Color(0xFF1A1B1F);
  static const offWhite = Color(0xFFF2F1ED);
  static const electricPurple = Color(0xFF8B5CF6);
  static const nightBlue = Color(0xFF1E3A8A);
  static const audioGreen = Color(0xFF34D399);
  static const warmOrange = Color(0xFFF97316);
  static const neonPink = Color(0xFFEC4899);
}

class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.electricPurple,
      brightness: Brightness.dark,
      surface: AppColors.anthracite,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepBlack,
      colorScheme: scheme,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400, height: 1.4),
      ),
    );
  }
}
