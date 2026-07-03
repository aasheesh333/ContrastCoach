import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color heat = Color(0xFFFF6B35);
  static const Color coral = Color(0xFFFF8A65);
  static const Color cold = Color(0xFF2D7CF1);
  static const Color cold2 = Color(0xFF5B9CFF);
  static const Color purple = Color(0xFF7A5BFF);
  static const Color ok = Color(0xFF33C27F);
  static const Color error = Color(0xFFE53935);

  static const Color lightInk = Color(0xFF0C0C0E);
  static const Color lightInk2 = Color(0xFF6B6E76);
  static const Color lightInk3 = Color(0xFF9AA0A8);
  static const Color lightBg = Color(0xFFEEF0F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightLine = Color(0xFFECEEF2);

  static const Color darkInk = Color(0xFFF4F5F7);
  static const Color darkInk2 = Color(0xFFAEB2BC);
  static const Color darkInk3 = Color(0xFF7B7F8A);
  static const Color darkBg = Color(0xFF0A0B0F);
  static const Color darkCard = Color(0xFF15161B);
  static const Color darkLine = Color(0xFF24252C);

  @Deprecated('Use heat')
  static const Color brandWarm = heat;
  @Deprecated('Use cold')
  static const Color brandCool = cold;
  @Deprecated('Use coral')
  static const Color brandCoral = coral;
  @Deprecated('Use v4 tokens')
  static const Color brandCoralPop = Color(0xFFFF6B9D);

  static const Color charcoal = lightInk;
  static const Color darkGray = lightInk2;
  static const Color midGray = lightInk3;
  static const Color outline = lightLine;
  static const Color lightGray = Color(0xFFECEEF2);
  static const Color offWhite = lightBg;
  @Deprecated('Use lightBg')
  static const Color warmBeige = lightBg;
  static const Color white = lightCard;

  static const Color success = ok;
  @Deprecated('Use v4 tokens')
  static const Color successSoft = Color(0xFFD7F2E3);
  static const Color errorSoft = Color(0xFFFFCDD2);

  @Deprecated('Use v4 tokens')
  static const Color heatmap0 = Color(0xFFECEEF2);
  @Deprecated('Use v4 tokens')
  static const Color heatmap1 = Color(0xFFFFE0CC);
  @Deprecated('Use v4 tokens')
  static const Color heatmap2 = Color(0xFFFFAB7E);
  @Deprecated('Use v4 tokens')
  static const Color heatmap3 = Color(0xFFFF8050);
  @Deprecated('Use v4 tokens')
  static const Color heatmap4 = heat;

  static const Color lightBackground = lightBg;
  @Deprecated('Use lightBg')
  static const Color lightHomeBackground = lightBg;
  static const Color lightSurface = lightCard;
  static const Color lightSurfaceVariant = lightLine;
  static const Color lightTextPrimary = lightInk;
  static const Color lightTextSecondary = lightInk2;
  static const Color lightTextTertiary = lightInk3;

  static const Color darkBackground = darkBg;
  static const Color darkSurface = darkCard;
  static const Color darkSurfaceVariant = Color(0xFF24252C);
  static const Color darkTextPrimary = darkInk;
  static const Color darkTextSecondary = darkInk2;
  static const Color darkTextTertiary = darkInk3;
  static const Color darkOutline = darkLine;
}
