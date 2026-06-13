import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  const cs = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: AppColors.darkOnSurfacePrimary,
    onPrimary: AppColors.darkSurface0,
    secondary: AppColors.darkOnSurfacePrimary,
    onSecondary: AppColors.darkSurface0,
    surface: AppColors.darkSurface0,
    onSurface: AppColors.darkOnSurfacePrimary,
    surfaceContainerLowest: AppColors.darkSurface0,
    surfaceContainerLow: AppColors.darkSurface1,
    surfaceContainer: AppColors.darkSurface2,
    surfaceContainerHigh: AppColors.darkSurface3,
    surfaceContainerHighest: AppColors.darkSurface3,
    onSurfaceVariant: AppColors.darkOnSurfaceSecondary,
    outline: AppColors.darkSurface2,
    outlineVariant: AppColors.darkSurface3,
    error: AppColors.darkOnSurfacePrimary,
    onError: AppColors.darkSurface0,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: cs.surface,
    splashFactory: NoSplash.splashFactory,
    visualDensity: VisualDensity.standard,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
