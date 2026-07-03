import 'package:flutter/material.dart';

/// Spacing scale (4pt base) and elevation tokens.
/// Use these everywhere instead of literal paddings.
class AppSpacing {
  const AppSpacing._();

  // Base spacing unit
  static const double unit = 4;

  // Spacing values
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 56;

  // Page-level
  static const double pageHorizontal = 24;
  static const double pageTop = 12;
  static const double pageBottom = 24;
  static const double sectionGap = 24;
}

/// Shadow tokens (consistent elevation across the app).
/// Dark-mode aware: uses stronger shadows on dark surfaces so they remain
/// visible, following Material 3 guidance.
class AppShadows {
  const AppShadows._();

  static List<BoxShadow> cardSoftFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? const Color(0x66000000) : const Color(0x2814142D),
        blurRadius: 24,
        offset: const Offset(0, 8),
        spreadRadius: -16,
      ),
    ];
  }

  static List<BoxShadow> cardMediumFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? const Color(0x80000000) : const Color(0x3314142D),
        blurRadius: 32,
        offset: const Offset(0, 12),
        spreadRadius: -16,
      ),
    ];
  }

  static List<BoxShadow> cardStrongFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? const Color(0x99000000) : const Color(0x6614142D),
        blurRadius: 44,
        offset: const Offset(0, 20),
        spreadRadius: -22,
      ),
    ];
  }

  /// Light-only defaults. Prefer [cardSoftFor] inside widget trees.
  static List<BoxShadow> get cardSoft => const [
        BoxShadow(
          color: Color(0x2814142D),
          blurRadius: 24,
          offset: Offset(0, 8),
          spreadRadius: -16,
        ),
      ];

  static List<BoxShadow> get cardMedium => const [
        BoxShadow(
          color: Color(0x3314142D),
          blurRadius: 32,
          offset: Offset(0, 12),
          spreadRadius: -16,
        ),
      ];

  static List<BoxShadow> get cardStrong => const [
        BoxShadow(
          color: Color(0x6614142D),
          blurRadius: 44,
          offset: Offset(0, 20),
          spreadRadius: -22,
        ),
      ];

  static List<BoxShadow> get pill => [
        BoxShadow(
          color: const Color(0xFFFF6B35).withOpacity(0.28),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}
