import 'package:contrast_coach/core/constants/app_motion.dart';
import 'package:contrast_coach/core/constants/app_shapes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppShapes v4 tokens', () {
    test('small == 14', () {
      expect(AppShapes.small, 14);
    });

    test('large == 26', () {
      expect(AppShapes.large, 26);
    });

    test('card == 20 (alias of cardLarge)', () {
      expect(AppShapes.card, 20);
      expect(AppShapes.card, AppShapes.cardLarge);
    });

    test('cardSmall == 14 (deprecated alias retargeted)', () {
      // ignore: deprecated_member_use_from_same_package
      expect(AppShapes.cardSmall, 14);
    });

    test('cardXL == 26 (deprecated alias retargeted)', () {
      // ignore: deprecated_member_use_from_same_package
      expect(AppShapes.cardXL, 26);
    });
  });

  group('AppMotion v4 tokens', () {
    test('defaultDuration == 260ms', () {
      expect(AppMotion.defaultDuration, const Duration(milliseconds: 260));
    });
  });

  group('AppCurves v4 tokens', () {
    test('spring == Cubic(0.22, 1, 0.36, 1)', () {
      expect(AppCurves.spring, const Cubic(0.22, 1, 0.36, 1));
    });
  });
}
