import 'package:contrast_coach/core/animations/animation_utils.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_accents.dart';
import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  // v4 rule (§2.4): dark mode does NOT change --heat / --coral / --cold /
  // --cold2 / --purple / --ok. Only ink / bg / card / line flip.
  const cs = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: AppColors.brandWarm,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.brandCoral,
    onPrimaryContainer: AppColors.white,
    secondary: AppColors.brandCool,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.brandCool2,
    onSecondaryContainer: AppColors.white,
    tertiary: AppColors.brandPurple,
    onTertiary: AppColors.white,
    surface: AppColors.darkBackground,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerLowest: AppColors.darkBackground,
    surfaceContainerLow: AppColors.darkSurface,
    surfaceContainer: AppColors.darkSurfaceVariant,
    surfaceContainerHigh: AppColors.darkSurfaceVariant,
    surfaceContainerHighest: Color(0xFF23252B),
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: AppColors.darkOutline,
    outlineVariant: Color(0xFF1F2026),
    error: AppColors.error,
    onError: AppColors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    extensions: const <ThemeExtension<dynamic>>[AppAccents.dark],
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.darkTextPrimary,
      displayColor: AppColors.darkTextPrimary,
    ),
    scaffoldBackgroundColor: cs.surface,
    splashFactory: InkSplash.splashFactory,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.titleLarge,
      centerTitle: false,
    ),
    cardColor: AppColors.darkSurface,
    dividerColor: AppColors.darkOutline,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: AnimationUtils.pageTransition,
        TargetPlatform.iOS: AnimationUtils.pageTransition,
      },
    ),
  );
}
