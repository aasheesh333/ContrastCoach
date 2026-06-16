import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/recovery_score.dart' as domain;
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/composite/recovery_score.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final keyProvider = SqlcipherKeyProvider(storage: const FlutterSecureStorage());
    final key = await keyProvider.getOrCreateKey();
    final db = AppDatabase(key);
    final repo = SessionRepositoryImpl(db);

    final result = await repo.getById(widget.sessionId);
    if (result is Ok<Session?, AppException>) {
      final session = result.value;
      if (mounted) setState(() { _session = session; _loading = false; });
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  domain.RecoveryScore _buildScore(Session session) {
    final value = session.recoveryScore ?? 0;
    final band = value >= 75
        ? ScoreBand.strong
        : value >= 50
            ? ScoreBand.moderate
            : ScoreBand.low;
    final adherence = session.protocolRounds > 0
        ? (session.roundsCompleted / session.protocolRounds * 100).round()
        : 100;
    return domain.RecoveryScore(
      value: value,
      band: band,
      insight: 'Adherence: Completed $adherence% of planned rounds.',
      factors: const [],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBeige,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.brandWarm))
            : _session == null
                ? const Center(child: Text('Session not found'))
                : _SummaryBody(
                    session: _session!,
                    score: _buildScore(_session!),
                    formatDuration: _formatDuration,
                  ),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.session,
    required this.score,
    required this.formatDuration,
  });

  final Session session;
  final domain.RecoveryScore score;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        children: [
          // Celebration check
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.check_rounded, color: AppColors.charcoal, size: 56),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Session complete!',
            textAlign: TextAlign.center,
            style: tt.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatDuration(session.totalActualDuration)} · ${session.roundsCompleted} rounds',
            textAlign: TextAlign.center,
            style: tt.bodyLarge?.copyWith(color: AppColors.darkGray),
          ),
          const SizedBox(height: 32),
          // Recovery score
          RecoveryScoreCard(score: score),
          const SizedBox(height: 32),
          // Insight cards
          _InsightRow(
            icon: LucideIcons.check,
            color: AppColors.brandWarm,
            title: 'Stuck to plan',
            subtitle: '${session.roundsCompleted} of ${session.protocolRounds} rounds completed',
          ),
          const SizedBox(height: 12),
          _InsightRow(
            icon: LucideIcons.moon,
            color: AppColors.brandCool,
            title: 'Sleep boost',
            subtitle: '+23 min tonight based on your pattern',
          ),
          const SizedBox(height: 12),
          _InsightRow(
            icon: LucideIcons.flame,
            color: AppColors.brandCoral,
            title: 'Streak',
            subtitle: 'Keep going to build consistency',
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Share',
                  onPressed: () {},
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Done',
                  onPressed: () => context.go('/home'),
                  variant: AppButtonVariant.warm,
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
