import 'package:contrast_coach/presentation/state/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeController.parseHex', () {
    test('parses default heat hex with leading #', () {
      expect(ThemeController.parseHex('#FF6B35'), const Color(0xFFFF6B35));
    });

    test('parses default heat hex without leading #', () {
      expect(ThemeController.parseHex('FF6B35'), const Color(0xFFFF6B35));
    });

    test('parses blue accent hex', () {
      expect(ThemeController.parseHex('#2D7CF1'), const Color(0xFF2D7CF1));
    });

    test('falls back to default on invalid input', () {
      expect(ThemeController.parseHex('not-a-hex'), const Color(0xFFFF6B35));
    });
  });

  group('ThemeController.toHex', () {
    test('strips alpha and prepends # for heat color', () {
      expect(ThemeController.toHex(const Color(0xFFFF6B35)), '#FF6B35');
    });

    test('strips alpha and prepends # for blue color', () {
      expect(ThemeController.toHex(const Color(0xFF2D7CF1)), '#2D7CF1');
    });

    test('round-trips through parseHex', () {
      const color = Color(0xFFFF6B35);
      final hex = ThemeController.toHex(color);
      expect(ThemeController.parseHex(hex), color);
    });
  });

  group('ThemeControllerState', () {
    test('default state equals heat accent + light mode', () {
      const state = ThemeControllerState(
        themeMode: ThemeMode.light,
        accentColor: Color(0xFFFF6B35),
      );
      expect(state.themeMode, ThemeMode.light);
      expect(state.accentColor, const Color(0xFFFF6B35));
    });

    test('copyWith preserves unchanged fields', () {
      const state = ThemeControllerState(
        themeMode: ThemeMode.light,
        accentColor: Color(0xFFFF6B35),
      );
      final updated = state.copyWith(themeMode: ThemeMode.dark);
      expect(updated.themeMode, ThemeMode.dark);
      expect(updated.accentColor, const Color(0xFFFF6B35));
    });

    test('equality is value-based', () {
      const a = ThemeControllerState(
        themeMode: ThemeMode.dark,
        accentColor: Color(0xFF2D7CF1),
      );
      const b = ThemeControllerState(
        themeMode: ThemeMode.dark,
        accentColor: Color(0xFF2D7CF1),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
