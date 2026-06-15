import 'package:contrast_coach/core/theme/dark_theme.dart';
import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => buildLightTheme();
  static ThemeData dark() => buildDarkTheme();
}
