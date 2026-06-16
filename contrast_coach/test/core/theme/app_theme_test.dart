import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses warm/cool brand colors', () {
      final theme = AppTheme.light();
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.surface, AppColors.lightBackground);
      expect(theme.colorScheme.onSurface, AppColors.lightTextPrimary);
      expect(theme.colorScheme.primary, AppColors.brandWarm);
    });

    test('dark theme uses dark background', () {
      final theme = AppTheme.dark();
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.surface, AppColors.darkBackground);
      expect(theme.colorScheme.onSurface, AppColors.darkTextPrimary);
    });

    test('Plus Jakarta Sans is the primary font', () {
      final theme = AppTheme.light();
      expect(theme.textTheme.displayLarge?.fontFamily, AppTypography.displayFont);
      expect(theme.textTheme.bodyLarge?.fontFamily, AppTypography.bodyFont);
    });
  });
}
