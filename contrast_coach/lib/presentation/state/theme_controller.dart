import 'package:contrast_coach/core/preferences/app_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeControllerState {
  const ThemeControllerState({
    required this.themeMode,
    required this.accentColor,
  });
  final ThemeMode themeMode;
  final Color accentColor;

  ThemeControllerState copyWith({ThemeMode? themeMode, Color? accentColor}) =>
      ThemeControllerState(
        themeMode: themeMode ?? this.themeMode,
        accentColor: accentColor ?? this.accentColor,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThemeControllerState &&
          other.themeMode == themeMode &&
          other.accentColor == accentColor);

  @override
  int get hashCode => Object.hash(themeMode, accentColor);
}

class ThemeController extends StateNotifier<ThemeControllerState> {
  ThemeController()
      : super(ThemeControllerState(
          themeMode: AppPreferences.themeModeValue,
          accentColor: _parseHex(AppPreferences.accentColor),
        )) {
    AppPreferences.changes.addListener(_onPrefsChanged);
  }

  void _onPrefsChanged() {
    state = ThemeControllerState(
      themeMode: AppPreferences.themeModeValue,
      accentColor: _parseHex(AppPreferences.accentColor),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final name = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await AppPreferences.setThemeMode(name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setAccentColor(Color color) async {
    final hex = _toHex(color);
    await AppPreferences.setAccentColor(hex);
    state = state.copyWith(accentColor: color);
  }

  @override
  void dispose() {
    AppPreferences.changes.removeListener(_onPrefsChanged);
    super.dispose();
  }

  static Color _parseHex(String raw) {
    var s = raw.startsWith('#') ? raw.substring(1) : raw;
    if (s.length == 6) s = 'FF$s';
    final v = int.tryParse(s, radix: 16) ?? 0xFFFF6B35;
    return Color(v);
  }

  static String _toHex(Color c) {
    final hex = c.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${hex.substring(2)}';
  }

  @visibleForTesting
  static Color parseHex(String s) => _parseHex(s);

  @visibleForTesting
  static String toHex(Color c) => _toHex(c);
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeControllerState>(
  (ref) => ThemeController(),
);
