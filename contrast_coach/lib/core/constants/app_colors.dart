import 'package:flutter/material.dart';

/// Warm & Cool design palette for ContrastCoach.
/// Orange = heat/recovery. Blue = cold/focus.
class AppColors {
  const AppColors._();

  // Brand
  static const Color brandWarm = Color(0xFFFF6B35);
  static const Color brandCool = Color(0xFF2D7CF1);
  static const Color brandCoral = Color(0xFFFF8A65);
  static const Color brandCoralPop = Color(0xFFFF6B9D);

  // Neutrals (light)
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color darkGray = Color(0xFF4A4A4A);
  static const Color midGray = Color(0xFF6B6B6B);
  static const Color outline = Color(0xFFE0E0DC);
  static const Color lightGray = Color(0xFFF0F0F0);
  static const Color offWhite = Color(0xFFFAFAF7);
  static const Color warmBeige = Color(0xFFF5F0E8);
  static const Color white = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color successSoft = Color(0xFFD7E8D7);
  static const Color error = Color(0xFFE53935);

  // Heatmap intensity (4 levels, light to deep orange)
  static const Color heatmap0 = Color(0xFFF0F0F0);
  static const Color heatmap1 = Color(0xFFFFE0CC);
  static const Color heatmap2 = Color(0xFFFFAB7E);
  static const Color heatmap3 = Color(0xFFFF8050);
  static const Color heatmap4 = Color(0xFFFF6B35);

  // Theme surfaces (light)
  static const Color lightBackground = offWhite;
  static const Color lightHomeBackground = warmBeige;
  static const Color lightSurface = white;
  static const Color lightSurfaceVariant = lightGray;
  static const Color lightTextPrimary = charcoal;
  static const Color lightTextSecondary = darkGray;
  static const Color lightTextTertiary = midGray;

  // Theme surfaces (dark)
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkSurfaceVariant = Color(0xFF1F1F1F);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFA8A8A8);
  static const Color darkTextTertiary = Color(0xFF6E6E6E);
}
