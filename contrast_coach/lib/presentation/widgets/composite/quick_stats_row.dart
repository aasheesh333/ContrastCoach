import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/domain/usecases/session_stats.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({super.key, required this.stats});
  final SessionStats stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      (LucideIcons.flame, '${stats.currentStreak}', 'Streak', cs.primary),
      (LucideIcons.activity, '${(stats.averageScore * 100).round()}%', 'Avg', cs.tertiary),
      (LucideIcons.timer, '${stats.totalMinutes}', 'Min', cs.secondary),
    ];
    return Row(children: items.map((item) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs), child: Column(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: item.$4.withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: Icon(item.$1, color: item.$4, size: 18)),
      const SizedBox(height: AppSpacing.xs),
      Text(item.$2, style: cs.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      Text(item.$3, style: cs.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
    ])))).toList());
  }
}
