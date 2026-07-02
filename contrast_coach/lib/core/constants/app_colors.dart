import 'package:flutter/material.dart';

/// Warm & Cool design palette for ContrastCoach.
///
/// Values here are the exact v4 prototype tokens (see runbook §2.4).
/// Do not "round" or re-tune them; downstream widgets assume these hexes.
///
/// Orange = heat/recovery. Blue = cold/focus. Purple = sleep protocol accent.
class AppColors {
  const AppColors._();

  // Brand (v4 exact)
  static const Color brandWarm = Color(0xFFFF6B35);     // --heat
  static const Color brandCoral = Color(0xFFFF8A65);    // --coral
  static const Color brandCool = Color(0xFF2D7CF1);     // --cold
  static const Color brandCool2 = Color(0xFF5B9CFF);    // --cold2
  static const Color brandPurple = Color(0xFF7A5BFF);   // --purple (sleep tile)
  static const Color brandCoralPop = Color(0xFFFF6B9D); // premium coral pop

  // Neutrals (light) — v4 --ink / --ink2 / --ink3
  static const Color charcoal = Color(0xFF0C0C0E);   // --ink
  static const Color darkGray = Color(0xFF6B6E76);   // --ink2
  static const Color midGray = Color(0xFF9AA0A8);    // --ink3
  static const Color outline = Color(0xFFE0E0DC);
  static const Color lightGray = Color(0xFFF0F0F0);
  static const Color offWhite = Color(0xFFFAFAF7);
  static const Color warmBeige = Color(0xFFF5F0E8);
  static const Color white = Color(0xFFFFFFFF);

  // Status (v4 exact: --ok #33C27F)
  static const Color success = Color(0xFF33C27F);
  static const Color successSoft = Color(0xFFD7F0E0);
  static const Color error = Color(0xFFE53935);
  static const Color errorSoft = Color(0xFFFFCDD2);

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

  // Theme surfaces (dark) — v4 exact: --bg #0A0B0F, --card #15161B, --line #24252C
  static const Color darkBackground = Color(0xFF0A0B0F);
  static const Color darkSurface = Color(0xFF15161B);
  static const Color darkSurfaceVariant = Color(0xFF1B1D22);
  static const Color darkTextPrimary = Color(0xFFF4F5F7);
  static const Color darkTextSecondary = Color(0xFFAEB2BC);
  static const Color darkTextTertiary = Color(0xFF7B7F8A);
  static const Color darkOutline = Color(0xFF24252C);
  static const Color darkCard = darkSurface;
}
