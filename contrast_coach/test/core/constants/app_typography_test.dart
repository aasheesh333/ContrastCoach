import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTypography v4 type scale', () {
    test('titleHero spec', () {
      const style = AppTypography.titleHero;
      expect(style.fontFamily, AppTypography.bodyFont);
      expect(style.fontSize, 19);
      expect(style.height, 1.25);
      expect(style.fontWeight, FontWeight.w700);
    });

    test('bodyLargeV4 spec', () {
      const style = AppTypography.bodyLargeV4;
      expect(style.fontFamily, AppTypography.bodyFont);
      expect(style.fontSize, 15);
      expect(style.height, 1.45);
      expect(style.fontWeight, FontWeight.w400);
    });

    test('labelMediumV4 spec', () {
      const style = AppTypography.labelMediumV4;
      expect(style.fontFamily, AppTypography.bodyFont);
      expect(style.fontSize, 13);
      expect(style.height, 1.3);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.letterSpacing, 0.4);
    });

    test('captionV4 spec', () {
      const style = AppTypography.captionV4;
      expect(style.fontFamily, AppTypography.bodyFont);
      expect(style.fontSize, 11);
      expect(style.height, 1.3);
      expect(style.fontWeight, FontWeight.w500);
      expect(style.letterSpacing, 0.2);
    });

    test('monoLight uses JetBrainsMono w300 at 14', () {
      const style = AppTypography.monoLight;
      expect(style.fontFamily, AppTypography.monoFont);
      expect(style.fontSize, 14);
      expect(style.fontWeight, FontWeight.w300);
    });

    test('monoMedium uses JetBrainsMono w500 at 14', () {
      const style = AppTypography.monoMedium;
      expect(style.fontFamily, AppTypography.monoFont);
      expect(style.fontSize, 14);
      expect(style.fontWeight, FontWeight.w500);
    });

    test('no TextStyle references families other than PlusJakartaSans/JetBrainsMono', () {
      const allowed = {'PlusJakartaSans', 'JetBrainsMono'};
      const styles = <TextStyle>[
        AppTypography.displayHero,
        AppTypography.displayLarge,
        AppTypography.displayMedium,
        AppTypography.displaySmall,
        AppTypography.headlineLarge,
        AppTypography.headlineMedium,
        AppTypography.titleLarge,
        AppTypography.titleHero,
        AppTypography.titleMedium,
        AppTypography.titleSmall,
        AppTypography.bodyLarge,
        AppTypography.bodyLargeV4,
        AppTypography.bodyMedium,
        AppTypography.bodySmall,
        AppTypography.labelLarge,
        AppTypography.labelMedium,
        AppTypography.labelMediumV4,
        AppTypography.labelSmall,
        AppTypography.captionV4,
        AppTypography.timerHero,
        AppTypography.timerLarge,
        AppTypography.timerMono,
        AppTypography.monoSmall,
        AppTypography.monoLight,
        AppTypography.monoMedium,
      ];
      for (final s in styles) {
        expect(
          allowed.contains(s.fontFamily),
          isTrue,
          reason: '${s.fontFamily} is not in allowed families',
        );
      }
    });
  });
}
