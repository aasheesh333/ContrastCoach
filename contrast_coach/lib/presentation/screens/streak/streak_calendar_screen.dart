import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

class StreakCalendarScreen extends StatefulWidget { const StreakCalendarScreen({super.key}); @override State<StreakCalendarScreen> createState() => _StreakCalendarScreenState(); }

class _StreakCalendarScreenState extends State<StreakCalendarScreen> {
  Map<DateTime, int> _heatmap = {};
  int _currentStreak = 0, _longestStreak = 0, _totalSessions = 0;
  bool _loading = true; String? _error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final key = await SqlcipherKeyProvider(storage: const FlutterSecureStorage()).getKey();
      if (key == null) { if (mounted) setState(() { _loading = false; _error = 'DB not available'; }); return; }
      final sessions = (await SessionRepository(db: AppDatabase(key)).getAllSessions()).getOrElse(<Session>[]);
      final now = DateTime.now();
      final map = <DateTime, int>{};
      for (final s in sessions) { final d = DateTime(s.date.year, s.date.month, s.date.day); map[d] = (map[d] ?? 0) + 1; }
      final dates = map.keys.where((d) => (map[d] ?? 0) > 0).toList()..sort();
      int streak = 0, longest = 0, curr = 0;
      DateTime? prev;
      for (final d in dates) {
        if (prev != null && d.difference(prev).inDays == 1) { curr++; } else { curr = 1; }
        if (curr > longest) longest = curr;
        prev = d;
      }
      final last = dates.isEmpty ? null : dates.last;
      if (last != null && now.difference(last).inDays <= 1) streak = curr;
      else if (map[DateTime(now.year, now.month, now.day)] != null) streak = 1;
      if (!mounted) return;
      setState(() { _heatmap = map; _currentStreak = streak; _longestStreak = longest; _totalSessions = sessions.length; _loading = false; });
    } catch (e) { if (mounted) setState(() { _loading = false; _error = e.toString(); }); }
  }

  Color _heatColor(int score) => switch (score) { 0 => AppColors.heatmap0, 1 => AppColors.heatmap1, 2 => AppColors.heatmap2, 3 => AppColors.heatmap3, _ => AppColors.heatmap4 };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pad = AppSpacing.adaptivePage(context);
    final w = MediaQuery.of(context).size.width - pad.left - pad.right;
    final cellSize = ((w - 13 * 2) / 13).clamp(20.0, 32.0);

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(backgroundColor: cs.surface, body: SafeArea(child: SingleChildScrollView(padding: pad, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Streak', style: cs.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: AppSpacing.sm),
      Text('$_currentStreak day${_currentStreak == 1 ? '' : 's'} counting', style: cs.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: AppSpacing.xxl),
      Row(children: [
        Expanded(child: AppCard.section(child: _StatCard(label: 'Current', value: '$_currentStreak d', icon: LucideIcons.flame, color: cs.primary))),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: AppCard.section(child: _StatCard(label: 'Best', value: '$_longestStreak d', icon: LucideIcons.award, color: cs.tertiary))),
      ]),
      const SizedBox(height: AppSpacing.xxl),
      const SectionHeader(label: 'Activity'),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(DateFormat('MMM yyyy').format(DateTime.now()), style: cs.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        Text('$_totalSessions sessions', style: cs.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ]),
      const SizedBox(height: AppSpacing.md),
      Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: cs.outline.withOpacity(0.15))), child: Wrap(spacing: 2, runSpacing: 2, children: List.generate(365, (i) {
        final day = DateTime.now().subtract(Duration(days: 364 - i));
        final count = _heatmap[DateTime(day.year, day.month, day.day)] ?? 0;
        return Container(width: cellSize, height: cellSize, decoration: BoxDecoration(color: _heatColor(count.clamp(0, 4)), borderRadius: BorderRadius.circular(4)));
      }))),
      const SizedBox(height: AppSpacing.md),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Less', style: cs.textTheme.bodySmall?.copyWith(color: cs.outline)), const SizedBox(width: AppSpacing.xs), ...List.generate(5, (i) => Container(width: 12, height: 12, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: _heatColor(i), borderRadius: BorderRadius.circular(3)))), const SizedBox(width: AppSpacing.xs), Text('More', style: cs.textTheme.bodySmall?.copyWith(color: cs.outline))]),
      SizedBox(height: AppSpacing.adaptiveBottom(context)),
    ]))));
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label; final String value; final IconData icon; final Color color;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 16)),
      const SizedBox(height: AppSpacing.sm),
      Text(value, style: cs.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(label, style: cs.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
    ]);
  }
}
