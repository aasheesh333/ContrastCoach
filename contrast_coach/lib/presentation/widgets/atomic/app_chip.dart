import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

/// v4 design-system chip. Matches the mockup `.chip` token:
///   radius 20, padding 8/13, font 12 / weight 700,
///   var(--card) bg + 1px var(--line) border, var(--ink) text.
///   When selected (.on): var(--heat) bg + heat border + white text.
///
///   For the unselected-state variant on a dark hero (e.g. mockup pills on
///   `.hero` card) use [AppPill]. [AppChip] is the bordered light-surface chip.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onSelected,
    this.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onSelected;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lineColor = Theme.of(context).extension<AppColorsExtension>()!.lineColor;
    final accentColor = accent ?? AppColors.heat;
    final bg = selected ? accentColor : cs.surface;
    final fg = selected ? AppColors.white : cs.onSurface;
    final borderColor = selected ? accentColor : lineColor;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap ?? onSelected,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Text(
            label,
            style: AppTypography.labelMediumV4.copyWith(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
