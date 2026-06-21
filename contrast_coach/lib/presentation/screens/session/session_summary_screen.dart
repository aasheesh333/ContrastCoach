import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/utils/score_calculator.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/recovery_score.dart' as domain;
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/session_stats.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:contrast_coach/presentation/widgets/composite/recovery_score.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({super.key, required this.sessionId});
  final String sessionId;
  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  Session? _session;
  SessionStats _stats = computeSessionStats(const []);
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final keyProvider = SqlcipherKeyProvider(storage: const FlutterSecureStorage());
    final key = await keyProvider.getKey();
    if (key == null) { setState(() => _loading = false); return; }
    final repo = SessionRepository(db: AppDatabase(key));
    final r = await repo.getSession(widget.sessionId);
    if (!mounted) return;
    r.fold((_) => setState(() => _loading = false), (session) async {
      final r2 = await repo.getAllSessions();
      final sessions = r2.isOk ? (r2 as Ok<List<Session>>).value : <Session>[];
      setState(() { _session = session; _stats = computeSessionStats(sessions); _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pad = AppSpacing.adaptivePage(context);
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final s = _session;
    if (s == null) return Scaffold(body: Center(child: Text('Session not found', style: cs.textTheme.bodyLarge)));
    final score = s.recoveryScore ?? 75.0;
    final band = bandForScore(score);

    return Scaffold(backgroundColor: cs.surface, body: SafeArea(child: SingleChildScrollView(padding: pad, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(padding: const EdgeInsets.all(AppSpacing.xxxl), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.brandWarm, AppColors.brandCoral], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24)), child: Column(children: [
        Text('Session complete!', textAlign: TextAlign.center, style: cs.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.lg),
        RecoveryScoreWidget(score: score, size: 96),
        const SizedBox(height: AppSpacing.md),
        Text(band.label, style: cs.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
        Text(band.subtitle, style: cs.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.7))),
      ])),
      const SizedBox(height: AppSpacing.xxxl),
      Row(children: [
        Expanded(child: AppCard.section(child: _StatTile(icon: LucideIcons.timer, label: 'Duration', value: '${s.totalDuration.inMinutes}m', color: cs.primary))),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: AppCard.section(child: _StatTile(icon: LucideIcons.flame, label: 'Streak', value: '${_stats.currentStreak}d', color: cs.tertiary))),
      ]),
      const SizedBox(height: AppSpacing.md),
      Row(children: [
        Expanded(child: AppCard.section(child: _StatTile(icon: LucideIcons.repeat, label: 'Rounds', value: '${s.roundsCompleted}/${s.protocolRounds}', color: cs.secondary))),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: AppCard.section(child: _StatTile(icon: LucideIcons.activity, label: 'Score', value: '${score.round()}', color: AppColors.success))),
      ]),
      const SizedBox(height: AppSpacing.xxxl),
      AppButton(label: 'Done', onPressed: () => context.go('/home'), variant: AppButtonVariant.warm, fullWidth: true, size: AppButtonSize.large),
      const SizedBox(height: AppSpacing.md),
      AppButton(label: 'Share progress', onPressed: () {}, variant: AppButtonVariant.secondary, fullWidth: true, leadingIcon: LucideIcons.share2),
      SizedBox(height: AppSpacing.adaptiveBottom(context)),
    ]))));
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon; final String label; final String value; final Color color;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
      const SizedBox(height: AppSpacing.sm),
      Text(value, style: cs.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(label, style: cs.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
    ]);
  }
}
