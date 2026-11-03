import 'package:flutter/material.dart';

/// Palette: dark charcoal, white, light gray, green for totals.
class AppColors {
  AppColors._();

  static const Color charcoal = Color(0xFF2B2F33);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF2F3F5);
  static const Color border = Color(0xFFD9DCE0);
  static const Color mutedText = Color(0xFF6B7178);
  static const Color green = Color(0xFF1E8E3E);
  static const Color greenLight = Color(0xFFE3F2E7);
  static const Color warning = Color(0xFFB26A00);
  static const Color warningLight = Color(0xFFFFF3DC);
  static const Color danger = Color(0xFFC62828);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'AppFont',
    scaffoldBackgroundColor: AppColors.lightGray,
    colorScheme: const ColorScheme.light(
      primary: AppColors.charcoal,
      onPrimary: AppColors.white,
      secondary: AppColors.green,
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.charcoal,
      error: AppColors.danger,
    ),
  );
}
