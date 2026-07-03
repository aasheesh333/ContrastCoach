import 'package:contrast_coach/core/animations/animation_utils.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  const cs = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: AppColors.heat,
    onPrimary: AppColors.darkInk,
    secondary: AppColors.cold,
    onSecondary: AppColors.darkInk,
    surface: AppColors.darkBg,
    onSurface: AppColors.darkInk,
    surfaceContainerLowest: AppColors.darkBg,
    surfaceContainerLow: AppColors.darkCard,
    surfaceContainer: AppColors.darkSurfaceVariant,
    surfaceContainerHigh: AppColors.darkSurfaceVariant,
    surfaceContainerHighest: AppColors.darkLine,
    onSurfaceVariant: AppColors.darkInk2,
    outline: AppColors.darkLine,
    outlineVariant: AppColors.darkLine,
    error: AppColors.error,
    onError: AppColors.darkInk,
    tertiary: AppColors.cold,
    onTertiary: AppColors.darkInk,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    extensions: const [AppColorsExtension.dark],
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.darkInk,
      displayColor: AppColors.darkInk,
    ),
    scaffoldBackgroundColor: cs.surface,
    splashFactory: InkSplash.splashFactory,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: AppColors.darkInk,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.titleLarge,
      centerTitle: false,
    ),
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkLine,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: AnimationUtils.pageTransition,
        TargetPlatform.iOS: AnimationUtils.pageTransition,
      },
    ),
  );
}
