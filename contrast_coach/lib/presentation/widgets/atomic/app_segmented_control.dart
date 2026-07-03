import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

/// v4 segmented control. Matches the mockup `.seg` token:
///   outer: var(--line) bg, radius 14, padding 4
///   each child: flex 1, padding 9, radius 11, font 12/w700, var(--ink2)
///   active child: var(--card) bg, var(--ink) text,
///   box-shadow `0 3px 8px -3px rgba(0,0,0,.2)`
///
///   Used in Insights (Week/Month/Year), Edit Profile (°C / °F), etc.
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  final List<AppSegment<T>> segments;
  final T value;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ext.lineColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final s in segments)
            Expanded(
              child: _Segment(
                label: s.label,
                selected: s.value == value,
                onTap: onChanged == null
                    ? null
                    : () => onChanged!(s.value),
                cardColor: cs.surface,
                inkColor: cs.onSurface,
                ink2Color: cs.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class AppSegment<T> {
  const AppSegment({required this.value, required this.label});
  final T value;
  final String label;
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.cardColor,
    required this.inkColor,
    required this.ink2Color,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color cardColor;
  final Color inkColor;
  final Color ink2Color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: selected ? cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                    spreadRadius: -3,
                  ),
                ]
              : const [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.labelMediumV4.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? inkColor : ink2Color,
            letterSpacing: 0,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
