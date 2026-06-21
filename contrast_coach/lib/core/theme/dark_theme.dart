import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  const cs = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: AppColors.brandWarm,
    onPrimary: AppColors.white,
    secondary: AppColors.brandCool,
    onSecondary: AppColors.white,
    surface: AppColors.darkBackground,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerLowest: AppColors.darkBackground,
    surfaceContainerLow: AppColors.darkSurface,
    surfaceContainer: AppColors.darkSurfaceVariant,
    surfaceContainerHigh: Color(0xFF2A2A2A),
    surfaceContainerHighest: Color(0xFF333333),
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: Color(0xFF2A2A2A),
    outlineVariant: Color(0xFF1F1F1F),
    error: AppColors.error,
    onError: AppColors.white,
    tertiary: AppColors.brandCool,
    onTertiary: AppColors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.darkTextPrimary,
      displayColor: AppColors.darkTextPrimary,
    ),
    scaffoldBackgroundColor: cs.surface,
    splashFactory: NoSplash.splashFactory,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.titleLarge,
    ),
  );
}
