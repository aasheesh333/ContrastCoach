import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:flutter/material.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';

/// Quick stats row: 4 metrics, all derived from real data.
class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({
    super.key,
    required this.streakDays,
    required this.avgDurationMin,
    required this.lastScore,
    required this.bestScore,
    required this.totalMinutes,
    required this.weekDelta,
  });

  final int streakDays;
  final int avgDurationMin;
  final double? lastScore;
  final double? bestScore;
  final int totalMinutes;
  final int weekDelta;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Stat(
            label: 'STREAK',
            value: '$streakDays',
            suffix: streakDays == 1 ? 'day' : 'days',
            icon: Icons.local_fire_department,
            accent: AppColors.brandWarm,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _Stat(
            label: 'AVG',
            value: avgDurationMin.toString(),
            suffix: 'min',
            icon: Icons.timer_outlined,
            accent: AppColors.brandCool,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _Stat(
            label: 'LAST',
            value: lastScore == null ? '—' : lastScore!.round().toString(),
            suffix: lastScore == null ? 'no data' : 'score',
            icon: Icons.bolt_outlined,
            accent: AppColors.brandWarm,
            trend: weekDelta,
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
    required this.icon,
    required this.accent,
    this.trend,
  });
  final String label;
  final String value;
  final String suffix;
  final IconData icon;
  final Color accent;
  final int? trend;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: AppShadows.cardSoft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(icon, size: 13, color: accent),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.midGray,
                        letterSpacing: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    suffix,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      color: AppColors.midGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (trend != null && trend! != 0) ...[
                    const SizedBox(width: 6),
                    _TrendChip(delta: trend!),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.delta});
  final int delta;

  @override
  Widget build(BuildContext context) {
    final positive = delta > 0;
    return Text(
      '${positive ? '+' : ''}$delta wk',
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 10,
        color: positive ? AppColors.success : AppColors.error,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

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
            decoration: const BoxDecoration(gradient: AppGradients.contrastHorizontal),
          ),
        ),
      ),
    );
  }
}
