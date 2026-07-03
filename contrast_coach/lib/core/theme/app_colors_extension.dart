import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.warmAccent,
    required this.coldAccent2,
    required this.textMuted,
    required this.textFaint,
    required this.success,
    required this.purple,
    required this.lineColor,
  });

  final Color warmAccent;
  final Color coldAccent2;
  final Color textMuted;
  final Color textFaint;
  final Color success;
  final Color purple;
  final Color lineColor;

  static const AppColorsExtension light = AppColorsExtension(
    warmAccent: Color(0xFFFF8A65),
    coldAccent2: Color(0xFF5B9CFF),
    textMuted: Color(0xFF6B6E76),
    textFaint: Color(0xFF9AA0A8),
    success: Color(0xFF33C27F),
    purple: Color(0xFF7A5BFF),
    lineColor: Color(0xFFECEEF2),
  );

  static const AppColorsExtension dark = AppColorsExtension(
    warmAccent: Color(0xFFFF8A65),
    coldAccent2: Color(0xFF5B9CFF),
    textMuted: Color(0xFFAEB2BC),
    textFaint: Color(0xFF7B7F8A),
    success: Color(0xFF33C27F),
    purple: Color(0xFF7A5BFF),
    lineColor: Color(0xFF24252C),
  );

  @override
  AppColorsExtension copyWith({
    Color? warmAccent,
    Color? coldAccent2,
    Color? textMuted,
    Color? textFaint,
    Color? success,
    Color? purple,
    Color? lineColor,
  }) {
    return AppColorsExtension(
      warmAccent: warmAccent ?? this.warmAccent,
      coldAccent2: coldAccent2 ?? this.coldAccent2,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      success: success ?? this.success,
      purple: purple ?? this.purple,
      lineColor: lineColor ?? this.lineColor,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      warmAccent: Color.lerp(warmAccent, other.warmAccent, t)!,
      coldAccent2: Color.lerp(coldAccent2, other.coldAccent2, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      success: Color.lerp(success, other.success, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      lineColor: Color.lerp(lineColor, other.lineColor, t)!,
    );
  }
}
