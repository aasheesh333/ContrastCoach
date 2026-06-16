import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:flutter/material.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';

class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({
    super.key,
    required this.streakDays,
    required this.avgDurationMin,
    required this.lastScore,
  });

  final int streakDays;
  final int avgDurationMin;
  final double? lastScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Stat(
            label: 'STREAK',
            value: '$streakDays',
            suffix: streakDays == 1 ? 'day' : 'days',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Stat(
            label: 'AVG',
            value: '${avgDurationMin}',
            suffix: 'min',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Stat(
            label: 'LAST',
            value: lastScore == null ? '-' : lastScore!.round().toString(),
            suffix: 'score',
            accent: true,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.suffix,
    this.accent = false,
  });

  final String label;
  final String value;
  final String suffix;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return AppSurface(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: accent ? AppColors.brandWarm : cs.onSurfaceVariant,
              letterSpacing: 1.2,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: tt.displaySmall),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  suffix,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A small progress bar with gradient fill.
class GradientProgressBar extends StatelessWidget {
  const GradientProgressBar({super.key, required this.fraction, this.height = 8});
  final double fraction;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: AppColors.lightGray,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction.clamp(0.0, 1.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.contrastHorizontal,
            ),
          ),
        ),
      ),
    );
  }
}
