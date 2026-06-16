import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const cs = ColorScheme.light(
    brightness: Brightness.light,
    primary: AppColors.brandWarm,
    onPrimary: AppColors.white,
    secondary: AppColors.brandCool,
    onSecondary: AppColors.white,
    surface: AppColors.lightBackground,
    onSurface: AppColors.lightTextPrimary,
    surfaceContainerLowest: AppColors.white,
    surfaceContainerLow: AppColors.offWhite,
    surfaceContainer: AppColors.warmBeige,
    surfaceContainerHigh: AppColors.lightGray,
    surfaceContainerHighest: AppColors.lightGray,
    onSurfaceVariant: AppColors.lightTextSecondary,
    outline: AppColors.lightGray,
    outlineVariant: Color(0xFFE5E5E0),
    error: AppColors.error,
    onError: AppColors.white,
    tertiary: AppColors.brandCool,
    onTertiary: AppColors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.lightTextPrimary,
      displayColor: AppColors.lightTextPrimary,
    ),
    scaffoldBackgroundColor: cs.surface,
    splashFactory: NoSplash.splashFactory,
    visualDensity: VisualDensity.standard,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.charcoal,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.titleLarge,
    ),
  );
}
