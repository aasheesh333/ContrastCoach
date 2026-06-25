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
        color: isDark ? Colors.black.withOpacity(0.25) : const Color(0x0A000000),
        blurRadius: 16,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> cardMediumFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.30) : const Color(0x0F000000),
        blurRadius: 24,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static List<BoxShadow> cardStrongFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.35) : const Color(0x14000000),
        blurRadius: 32,
        offset: const Offset(0, 12),
      ),
    ];
  }

  /// Light-only defaults. Prefer [cardSoftFor] inside widget trees.
  static List<BoxShadow> get cardSoft => const [
        BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 2)),
      ];

  static List<BoxShadow> get cardMedium => const [
        BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 6)),
      ];

  static List<BoxShadow> get cardStrong => const [
        BoxShadow(color: Color(0x14000000), blurRadius: 32, offset: Offset(0, 12)),
      ];

  static List<BoxShadow> get pill => [
        BoxShadow(
          color: const Color(0xFFFF6B35).withOpacity(0.28),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}
