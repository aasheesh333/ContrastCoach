import 'package:flutter/material.dart';

/// Plus Jakarta Sans single-typeface system.
/// One family, weights from 100 (timer) to 800 (display).
class AppTypography {
  const AppTypography._();

  static const String displayFont = 'PlusJakartaSans';
  static const String bodyFont = 'PlusJakartaSans';
  static const String monoFont = 'JetBrainsMono';

  // Display (headline impact)
  static const TextStyle displayHero = TextStyle(
    fontFamily: displayFont,
    fontSize: 56,
    height: 1.05,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
  );

  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFont,
    fontSize: 40,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFont,
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: displayFont,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: displayFont,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: displayFont,
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  // Titles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  // Labels (uppercase, letter-spaced)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  // Timer (ultra-thin, huge)
  static const TextStyle timerHero = TextStyle(
    fontFamily: monoFont,
    fontSize: 200,
    height: 1.0,
    fontWeight: FontWeight.w100,
    letterSpacing: -4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle timerLarge = TextStyle(
    fontFamily: monoFont,
    fontSize: 96,
    fontWeight: FontWeight.w200,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle timerMono = timerLarge;

  static const TextStyle monoSmall = TextStyle(
    fontFamily: monoFont,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // TextTheme
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineMedium,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
