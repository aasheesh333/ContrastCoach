import 'package:contrast_coach/core/animations/animation_utils.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const cs = ColorScheme.light(
    brightness: Brightness.light,
    primary: AppColors.heat,
    onPrimary: AppColors.lightCard,
    secondary: AppColors.cold,
    onSecondary: AppColors.lightCard,
    surface: AppColors.lightBg,
    onSurface: AppColors.lightInk,
    surfaceContainerLowest: AppColors.lightCard,
    surfaceContainerLow: AppColors.lightCard,
    surfaceContainer: AppColors.lightBg,
    surfaceContainerHigh: AppColors.lightLine,
    surfaceContainerHighest: AppColors.lightLine,
    onSurfaceVariant: AppColors.lightInk2,
    outline: AppColors.lightLine,
    outlineVariant: AppColors.lightLine,
    error: AppColors.error,
    onError: AppColors.lightCard,
    tertiary: AppColors.cold,
    onTertiary: AppColors.lightCard,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    extensions: const [AppColorsExtension.light],
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.lightInk,
      displayColor: AppColors.lightInk,
    ),
    scaffoldBackgroundColor: cs.surface,
    splashFactory: InkSplash.splashFactory,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBg,
      foregroundColor: AppColors.lightInk,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.titleLarge,
      centerTitle: false,
    ),
    cardColor: AppColors.lightCard,
    dividerColor: AppColors.lightLine,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: AnimationUtils.pageTransition,
        TargetPlatform.iOS: AnimationUtils.pageTransition,
      },
    ),
  );
}
