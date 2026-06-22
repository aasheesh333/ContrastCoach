import 'package:flutter/material.dart';

/// Responsive scaling utility based on screen width.
///
/// Uses 375px (iPhone SE) as the baseline. Clamps between 0.85 and 1.3
/// to prevent extreme scaling on very small or very large screens.
class AppScale {
  const AppScale._();

  /// Returns a scale factor based on screen width.
  static double textScale(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / 375).clamp(0.85, 1.3);
  }

  /// Returns scaled font size.
  static double font(BuildContext context, double base) {
    return base * textScale(context);
  }

  /// Returns scaled spacing.
  static double space(BuildContext context, double base) {
    return base * textScale(context);
  }

  /// Returns a scaled TextStyle with the given base font size.
  static TextStyle style(BuildContext context, TextStyle base) {
    final scale = textScale(context);
    return base.copyWith(fontSize: (base.fontSize ?? 14) * scale);
  }
}
