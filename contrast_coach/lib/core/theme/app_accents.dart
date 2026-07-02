import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Custom [ThemeExtension] carrying v4 accent + text tokens that don't fit
/// Material's [ColorScheme] slots (runbook §2.1).
///
/// Access via `Theme.of(context).extension<AppAccents>()!`.
///
/// Per §2.4 rule: dark mode does NOT re-tint accent colors (heat, coral,
/// cold, cold2, purple, ok). Only ink / bg / card / line flip. So the same
/// accent values are used in both light and dark themes — only the text
/// muted/faint tokens differ.
@immutable
class AppAccents extends ThemeExtension<AppAccents> {
  const AppAccents({
    required this.warmAccent,
    required this.coldAccent2,
    required this.purpleAccent,
    required this.success,
    required this.textMuted,
    required this.textFaint,
  });

  /// Warm coral pop (--coral). Same in both themes.
  final Color warmAccent;

  /// Cool secondary blue (--cold2). Same in both themes.
  final Color coldAccent2;

  /// Sleep-protocol purple (--purple). Same in both themes.
  final Color purpleAccent;

  /// Positive/success state (--ok). Same in both themes.
  final Color success;

  /// Secondary text (--ink2 in light, dark text secondary in dark).
  final Color textMuted;

  /// Tertiary text (--ink3 in light, dark text tertiary in dark).
  final Color textFaint;

  static const AppAccents light = AppAccents(
    warmAccent: AppColors.brandCoral,
    coldAccent2: AppColors.brandCool2,
    purpleAccent: AppColors.brandPurple,
    success: AppColors.success,
    textMuted: AppColors.darkGray,
    textFaint: AppColors.midGray,
  );

  static const AppAccents dark = AppAccents(
    warmAccent: AppColors.brandCoral,
    coldAccent2: AppColors.brandCool2,
    purpleAccent: AppColors.brandPurple,
    success: AppColors.success,
    textMuted: AppColors.darkTextSecondary,
    textFaint: AppColors.darkTextTertiary,
  );

  @override
  AppAccents copyWith({
    Color? warmAccent,
    Color? coldAccent2,
    Color? purpleAccent,
    Color? success,
    Color? textMuted,
    Color? textFaint,
  }) {
    return AppAccents(
      warmAccent: warmAccent ?? this.warmAccent,
      coldAccent2: coldAccent2 ?? this.coldAccent2,
      purpleAccent: purpleAccent ?? this.purpleAccent,
      success: success ?? this.success,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
    );
  }

  @override
  AppAccents lerp(ThemeExtension<AppAccents>? other, double t) {
    if (other is! AppAccents) return this;
    return AppAccents(
      warmAccent: Color.lerp(warmAccent, other.warmAccent, t)!,
      coldAccent2: Color.lerp(coldAccent2, other.coldAccent2, t)!,
      purpleAccent: Color.lerp(purpleAccent, other.purpleAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
    );
  }
}
