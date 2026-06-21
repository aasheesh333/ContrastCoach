import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/insight.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InsightsScreen extends StatefulWidget { const InsightsScreen({super.key}); @override State<InsightsScreen> createState() => _InsightsScreenState(); }

class _InsightsScreenState extends State<InsightsScreen> {
  List<Session> _sessions = [];
  bool _loading = true;
  String? _error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final key = await SqlcipherKeyProvider(storage: const FlutterSecureStorage()).getKey();
      if (key == null) { setState(() { _loading = false; _error = 'Database not available'; }); return; }
      final repo = SessionRepository(db: AppDatabase(key));
      final r = await repo.getAllSessions();
      if (!mounted) return;
      r.fold((err) => setState(() { _loading = false; _error = err.message; }), (sessions) => setState(() { _sessions = sessions; _loading = false; }));
    } catch (e) { if (mounted) setState(() { _loading = false; _error = e.toString(); }); }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pad = AppSpacing.adaptivePage(context);
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(LucideIcons.alertTriangle, size: 48, color: cs.error), const SizedBox(height: 16), Text(_error!, style: cs.textTheme.bodyLarge)])));
    if (_sessions.isEmpty) return Scaffold(backgroundColor: cs.surface, body: AppEmptyState(icon: LucideIcons.barChart3, title: 'Not enough data', message: 'Complete sessions to unlock insights.',
      action: AppButton(label: 'Start session', onPressed: () => context.push('/session/active'), variant: AppButtonVariant.warm)));

    final totalMins = _sessions.fold<int>(0, (sum, s) => sum + s.totalDuration.inMinutes);
    final avgScore = _sessions.map((s) => s.recoveryScore ?? 75.0).reduce((a, b) => a + b) / _sessions.length;
    final currentStreak = computeSessionStreak(_sessions);

    return Scaffold(backgroundColor: cs.surface, body: SafeArea(child: SingleChildScrollView(padding: pad, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Insights', style: cs.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: AppSpacing.sm),
      Text('Trends from your ${_sessions.length} sessions', style: cs.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: AppSpacing.xxl),
      Row(children: [
        Expanded(child: AppCard.section(child: _StatCard(label: 'Sessions', value: '${_sessions.length}', icon: LucideIcons.flame, color: cs.primary))),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: AppCard.section(child: _StatCard(label: 'Avg Score', value: '${(avgScore).round()}', icon: LucideIcons.activity, color: cs.tertiary))),
      ]),
      const SizedBox(height: AppSpacing.md),
      Row(children: [
        Expanded(child: AppCard.section(child: _StatCard(label: 'Minutes', value: '$totalMins', icon: LucideIcons.timer, color: cs.secondary))),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: AppCard.section(child: _StatCard(label: 'Streak', value: '${currentStreak}d', icon: LucideIcons.award, color: AppColors.success))),
      ]),
      SizedBox(height: AppSpacing.adaptiveBottom(context)),
    ]))));
  }
}

int computeSessionStreak(List<Session> sessions) {
  if (sessions.isEmpty) return 0;
  final dates = sessions.map((s) => DateTime(s.date.year, s.date.month, s.date.day)).toSet().toList()..sort((a, b) => b.compareTo(a));
  int streak = 1;
  for (int i = 1; i < dates.length; i++) {
    if (dates[i - 1].difference(dates[i]).inDays == 1) { streak++; } else { break; }
  }
  return streak;
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
