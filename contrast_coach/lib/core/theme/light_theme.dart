import 'package:contrast_coach/core/animations/animation_utils.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_accents.dart';
import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const cs = ColorScheme.light(
    brightness: Brightness.light,
    primary: AppColors.brandWarm,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.brandCoral,
    onPrimaryContainer: AppColors.white,
    secondary: AppColors.brandCool,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.brandCool2,
    onSecondaryContainer: AppColors.white,
    // v4 purple accent (sleep protocol tile) exposed via tertiary slot.
    tertiary: AppColors.brandPurple,
    onTertiary: AppColors.white,
    surface: AppColors.offWhite,
    onSurface: AppColors.charcoal,
    surfaceContainerLowest: AppColors.white,
    surfaceContainerLow: AppColors.white,
    surfaceContainer: AppColors.warmBeige,
    surfaceContainerHigh: AppColors.lightGray,
    surfaceContainerHighest: AppColors.lightGray,
    onSurfaceVariant: AppColors.darkGray,
    outline: AppColors.outline,
    outlineVariant: Color(0xFFE5E5E0),
    error: AppColors.error,
    onError: AppColors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    extensions: const <ThemeExtension<dynamic>>[AppAccents.light],
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.charcoal,
      displayColor: AppColors.charcoal,
    ),
    scaffoldBackgroundColor: cs.surface,
    splashFactory: InkSplash.splashFactory,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.offWhite,
      foregroundColor: AppColors.charcoal,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.titleLarge,
      centerTitle: false,
    ),
    cardColor: AppColors.white,
    dividerColor: AppColors.outline,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: AnimationUtils.pageTransition,
        TargetPlatform.iOS: AnimationUtils.pageTransition,
      },
    ),
  );
}
