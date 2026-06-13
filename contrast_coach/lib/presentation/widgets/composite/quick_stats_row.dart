import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:flutter/material.dart';

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
        Expanded(child: _Stat(label: 'Streak', value: '$streakDays')),
        const SizedBox(width: 8),
        Expanded(child: _Stat(label: 'Avg', value: '${avgDurationMin}m')),
        const SizedBox(width: 8),
        Expanded(child: _Stat(label: 'Last', value: lastScore == null ? '-' : lastScore!.round().toString())),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AppCard(
      elevation: AppCardElevation.medium,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: tt.labelSmall),
          const SizedBox(height: 8),
          Text(value, style: tt.headlineMedium),
        ],
      ),
    );
  }
}
