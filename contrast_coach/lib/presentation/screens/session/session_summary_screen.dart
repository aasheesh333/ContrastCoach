import 'package:contrast_coach/core/animations/animation_utils.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/utils/score_calculator.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
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
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DatabaseProvider.instance();
    final repo = SessionRepositoryImpl(db);

    final result = await repo.getById(widget.sessionId);
    final allResult = await repo.getAll();
    final sessions = allResult is Ok<List<Session>, AppException>
        ? allResult.value
        : <Session>[];

    if (mounted) {
      setState(() {
        if (result is Ok<Session?, AppException>) _session = result.value;
        _stats = computeSessionStats(sessions);
        _loading = false;
      });
    }
  }

  domain.RecoveryScore _buildScore(Session session) {
    final value = session.recoveryScore ?? 0;
    final band = value <= 40
        ? ScoreBand.low
        : value <= 70
            ? ScoreBand.moderate
            : ScoreBand.strong;
    final adherence = session.protocolRounds > 0
        ? (session.roundsCompleted / session.protocolRounds).clamp(0.0, 1.0)
        : 1.0;
    final insight = _insightFor(session, adherence, band);
    return domain.RecoveryScore(
      value: value,
      band: band,
      insight: insight,
      factors: const [],
    );
  }

  String _insightFor(Session session, double adherence, ScoreBand band) {
    if (session.recoveryScore == null) {
      return 'Session saved. Insights will appear after the recovery score is calculated.';
    }
    if (adherence < 0.6) {
      return '${band.label} session. Stick closer to your plan to lift your score.';
    }
    if (session.roundsCompleted >= session.protocolRounds) {
      return '${band.label} session. You finished every round — keep that streak going.';
    }
    return '${band.label} session. ${(adherence * 100).round()}% of rounds completed.';
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  String _formatStreakBanner(int streak) {
    if (streak <= 0) return 'No streak yet';
    return '$streak day${streak == 1 ? '' : 's'} in a row';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBeige,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _loading
              ? const Center(
                  key: ValueKey('loading'),
                  child: CircularProgressIndicator(color: AppColors.brandWarm),
                )
              : _session == null
                  ? const Center(
                      key: ValueKey('not-found'),
                      child: Text('Session not found'),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('content'),
                      child: _SummaryBody(
                        session: _session!,
                        score: _buildScore(_session!),
                        formatDuration: _formatDuration,
                        stats: _stats,
                      ),
                    ),
        ),
      ),
    );
  }
}

class _SummaryBody extends StatefulWidget {
  const _SummaryBody({
    required this.session,
    required this.score,
    required this.formatDuration,
    required this.stats,
  });

  final Session session;
  final domain.RecoveryScore score;
  final String Function(Duration) formatDuration;
  final SessionStats stats;

  @override
  State<_SummaryBody> createState() => _SummaryBodyState();
}

class _SummaryBodyState extends State<_SummaryBody> {
  bool _showCelebration = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.huge,
            AppSpacing.pageHorizontal,
            AppSpacing.huge,
          ),
          children: [
            _Celebration(),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Session complete.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.formatDuration(widget.session.totalActualDuration)} · ${widget.session.roundsCompleted}/${widget.session.protocolRounds} rounds',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.huge),
            RecoveryScoreCard(score: widget.score),
            const SizedBox(height: AppSpacing.huge),
            _InsightRow(
              icon: LucideIcons.check,
              color: AppColors.brandWarm,
              title: 'Plan adherence',
              subtitle: _adherenceLine(widget.session),
            ),
            const SizedBox(height: AppSpacing.md),
            _InsightRow(
              icon: LucideIcons.flame,
              color: AppColors.brandCoral,
              title: _formatStreakBanner(widget.stats.streakDays),
              subtitle: widget.stats.streakDays > 0
                  ? 'You are ${widget.stats.streakDays} day${widget.stats.streakDays == 1 ? '' : 's'} into a new streak.'
                  : 'Finish one tomorrow to start a streak.',
            ),
            const SizedBox(height: AppSpacing.md),
            _InsightRow(
              icon: LucideIcons.timer,
              color: AppColors.brandCool,
              title: 'Total time tracked',
              subtitle: '${widget.stats.totalMinutes} minutes across ${widget.stats.totalSessions} sessions',
            ),
            const SizedBox(height: AppSpacing.huge),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Share',
                    onPressed: () => _shareProgress(context),
                    variant: AppButtonVariant.secondary,
                    leadingIcon: LucideIcons.share2,
                    fullWidth: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
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
        if (_showCelebration)
          CelebrationOverlay(
            duration: const Duration(seconds: 3),
            onComplete: () => setState(() => _showCelebration = false),
          ),
      ],
    );
  }

  String _formatStreakBanner(int streak) {
    if (streak <= 0) return 'No streak yet';
    return '$streak day${streak == 1 ? '' : 's'} in a row';
  }

  String _adherenceLine(Session s) {
    if (s.protocolRounds == 0) return 'Custom session';
    final pct = (s.roundsCompleted / s.protocolRounds * 100).round();
    return '$pct% of planned rounds completed';
  }

  void _shareProgress(BuildContext context) {
    final score = widget.session.recoveryScore;
    final scoreText = score != null ? score.round().toString() : 'N/A';
    final minutes = widget.session.totalActualDuration?.inMinutes ?? 0;
    Share.share(
      'I just completed a contrast therapy session on ContrastCoach! '
      'Recovery score: $scoreText/100, $minutes minutes. '
      'Track heat. Track cold. See what works.',
      subject: 'My ContrastCoach recovery score',
    );
  }
}

class _Celebration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          shape: BoxShape.circle,
          boxShadow: AppShadows.cardSoft,
        ),
        child: const Center(
          child: Icon(LucideIcons.check, color: AppColors.charcoal, size: 40),
        ),
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
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: 20,
      elevation: AppCardElevation.soft,
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
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
                    fontWeight: FontWeight.w500,
                    height: 1.35,
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
