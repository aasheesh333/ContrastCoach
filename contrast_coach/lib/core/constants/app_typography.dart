import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static const String displayFont = 'InterTight';
  static const String bodyFont = 'Inter';
  static const String monoFont = 'JetBrainsMono';

  static const TextStyle displayLarge =
      TextStyle(fontFamily: displayFont, fontSize: 57, height: 64 / 57, fontWeight: FontWeight.w300);
  static const TextStyle displayMedium =
      TextStyle(fontFamily: displayFont, fontSize: 45, height: 52 / 45, fontWeight: FontWeight.w300);
  static const TextStyle headlineLarge =
      TextStyle(fontFamily: displayFont, fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w500);
  static const TextStyle headlineMedium =
      TextStyle(fontFamily: displayFont, fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w500);
  static const TextStyle titleLarge =
      TextStyle(fontFamily: bodyFont, fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600);
  static const TextStyle titleMedium = TextStyle(
    fontFamily: bodyFont, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600, letterSpacing: 0.15,
  );
  static const TextStyle bodyLarge =
      TextStyle(fontFamily: bodyFont, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400);
  static const TextStyle bodyMedium =
      TextStyle(fontFamily: bodyFont, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400);
  static const TextStyle bodySmall =
      TextStyle(fontFamily: bodyFont, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400);
  static const TextStyle labelLarge = TextStyle(
    fontFamily: bodyFont, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: bodyFont, fontSize: 11, height: 16 / 11, fontWeight: FontWeight.w500, letterSpacing: 0.5,
  );

  static const TextStyle timerMono = TextStyle(
    fontFamily: monoFont,
    fontSize: 96,
    fontWeight: FontWeight.w200,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelSmall: labelSmall,
  );
}
