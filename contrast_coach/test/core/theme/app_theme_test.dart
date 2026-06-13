import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses monochrome colors only', () {
      final theme = AppTheme.light();
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.surface, AppColors.lightSurface0);
      expect(theme.colorScheme.onSurface, AppColors.lightOnSurfacePrimary);
      expect(theme.textTheme.displayLarge?.fontSize, AppTypography.displayLarge.fontSize);
      expect(theme.textTheme.displayLarge?.fontFamily, AppTypography.displayLarge.fontFamily);
      expect(theme.textTheme.displayLarge?.fontWeight, AppTypography.displayLarge.fontWeight);
    });

    test('dark theme uses monochrome colors only', () {
      final theme = AppTheme.dark();
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.surface, AppColors.darkSurface0);
      expect(theme.colorScheme.onSurface, AppColors.darkOnSurfacePrimary);
    });

    test('no chromatic primary color (grayscale only)', () {
      expect(AppTheme.light().colorScheme.primary, AppColors.lightOnSurfacePrimary);
      expect(AppTheme.dark().colorScheme.primary, AppColors.darkOnSurfacePrimary);
    });
  });
}
