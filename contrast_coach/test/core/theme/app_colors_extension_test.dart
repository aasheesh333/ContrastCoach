import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColorsExtension', () {
    test('light.warmAccent == coral', () {
      expect(AppColorsExtension.light.warmAccent, const Color(0xFFFF8A65));
    });

    test('dark.lineColor == 0xFF24252C', () {
      expect(AppColorsExtension.dark.lineColor, const Color(0xFF24252C));
    });

    test('light theme installs AppColorsExtension.light', () {
      final theme = AppTheme.light();
      final ext = theme.extension<AppColorsExtension>();
      expect(ext, isNotNull);
      expect(ext, AppColorsExtension.light);
    });

    test('dark theme installs AppColorsExtension.dark', () {
      final theme = AppTheme.dark();
      final ext = theme.extension<AppColorsExtension>();
      expect(ext, isNotNull);
      expect(ext, AppColorsExtension.dark);
    });

    test('copyWith preserves unspecified fields', () {
      final updated = AppColorsExtension.light.copyWith(
        purple: const Color(0xFF000000),
      );
      expect(updated.purple, const Color(0xFF000000));
      expect(updated.warmAccent, AppColorsExtension.light.warmAccent);
      expect(updated.coldAccent2, AppColorsExtension.light.coldAccent2);
      expect(updated.textMuted, AppColorsExtension.light.textMuted);
      expect(updated.textFaint, AppColorsExtension.light.textFaint);
      expect(updated.success, AppColorsExtension.light.success);
      expect(updated.lineColor, AppColorsExtension.light.lineColor);
    });

    test('lerp at t=0.5 produces midway values', () {
      const t = 0.5;
      final mid = AppColorsExtension.light.lerp(AppColorsExtension.dark, t);
      final expectedMuted = Color.lerp(
        AppColorsExtension.light.textMuted,
        AppColorsExtension.dark.textMuted,
        t,
      );
      final expectedLine = Color.lerp(
        AppColorsExtension.light.lineColor,
        AppColorsExtension.dark.lineColor,
        t,
      );
      expect(mid.textMuted, expectedMuted);
      expect(mid.lineColor, expectedLine);
      expect(mid.warmAccent, AppColorsExtension.light.warmAccent);
      expect(mid.success, AppColorsExtension.light.success);
    });
  });
}
