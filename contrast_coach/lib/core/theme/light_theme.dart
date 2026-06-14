import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const cs = ColorScheme.light(
    brightness: Brightness.light,
    primary: AppColors.lightOnSurfacePrimary,
    onPrimary: AppColors.lightSurface0,
    secondary: AppColors.lightOnSurfacePrimary,
    onSecondary: AppColors.lightSurface0,
    surface: AppColors.lightSurface0,
    onSurface: AppColors.lightOnSurfacePrimary,
    surfaceContainerLowest: AppColors.lightSurface0,
    surfaceContainerLow: AppColors.lightSurface1,
    surfaceContainer: AppColors.lightSurface2,
    surfaceContainerHigh: AppColors.lightSurface3,
    surfaceContainerHighest: AppColors.lightSurface3,
    onSurfaceVariant: AppColors.lightOnSurfaceSecondary,
    outline: AppColors.lightSurface2,
    outlineVariant: AppColors.lightSurface3,
    error: AppColors.lightOnSurfacePrimary,
    onError: AppColors.lightSurface0,
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
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
