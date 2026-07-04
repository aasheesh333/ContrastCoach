import 'package:contrast_coach/core/animations/animation_utils.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_motion.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
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
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_chip.dart';
import 'package:contrast_coach/presentation/widgets/composite/recovery_score.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (m < 60) return '$m:$s';
    final h = m ~/ 60;
    final mm = (m % 60).toString().padLeft(2, '0');
    return '$h:$mm:$s';
  }

  String _formatStreakBanner(int streak) {
    if (streak <= 0) return 'No streak yet';
    return '$streak day${streak == 1 ? '' : 's'} in a row';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppMotion.defaultDuration,
          child: _loading
              ? const Center(
                  key: ValueKey('loading'),
                  child: CircularProgressIndicator(color: AppColors.heat),
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
  String? _selectedMood;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;

    final duration = widget.formatDuration(widget.session.totalActualDuration);
    final rounds = widget.session.roundsCompleted;
    final completionLine = '🎉 Complete · $duration · $rounds round${rounds == 1 ? '' : 's'}';

    final hrvDelta = _hrvTrendValue(widget.stats);
    final bestTime = _bestTimeOfDay(widget.stats);
    final newRecord = _newRecordLine(widget.session, widget.stats);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.huge,
        AppSpacing.pageHorizontal,
        AppSpacing.huge,
      ),
      children: [
        Text(
          completionLine,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.bodyFont,
            fontSize: 13,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        RecoveryScoreCard(score: widget.score),
        const SizedBox(height: AppSpacing.lg),
        _InsightListCard(
          rows: [
            _ListRow('📈', '7-day HRV trend', hrvDelta, boldValue: true),
            _ListRow('⏰', 'Best time', bestTime, boldValue: true),
            _ListRow('🌡️', 'Heat target hit this week', '', boldValue: false),
            _ListRow('🏅', 'New record', newRecord, boldValue: true),
          ],
          lineColor: ext.lineColor,
          surfaceColor: cs.surface,
          onSurfaceColor: cs.onSurface,
        ),
        const SizedBox(height: AppSpacing.sm),
        _MoodJournalCard(
          selectedMood: _selectedMood,
          onMoodTap: (m) => setState(() => _selectedMood = m),
          surfaceColor: cs.surface,
          onSurfaceColor: cs.onSurface,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Save session',
          onPressed: () => context.go('/home'),
          variant: AppButtonVariant.primary,
          fullWidth: true,
          marginTop: 0,
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Share card 📤',
                onPressed: () => context.push('/share/${widget.session.id}'),
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                marginTop: 0,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: 'Start another',
                onPressed: () => context.go('/home'),
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                marginTop: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// HRV trend display. The prior implementation fabricated a "+N%" from
  /// average duration (not real HRV data) — misleading for users making
  /// recovery decisions. Now returns "—" until a real HRV trend is
  /// available from health-data snapshots.
  String _hrvTrendValue(SessionStats s) {
    return '—';
  }

  /// Best time-of-day heuristic from `timeOfDayFractions`.
  String _bestTimeOfDay(SessionStats s) {
    if (s.totalSessions == 0) return '—';
    final f = s.timeOfDayFractions();
    if (f.morning >= f.afternoon && f.morning >= f.evening) return 'mornings';
    if (f.afternoon >= f.evening) return 'afternoons';
    return 'evenings';
  }

  /// New-record caption. Mockup: 'longest sauna phase'.
  String _newRecordLine(Session s, SessionStats stats) {
    final longest = s.totalActualDuration;
    if (stats.totalSessions <= 1) return 'longest single session';
    return 'longest single session: ${longest.inMinutes} min';
  }
}

/// v4 `.card.list` — flat list card with 4 emoji-prefixed rows, 1px line
/// border between rows (last row has no border).
class _InsightListCard extends StatelessWidget {
  const _InsightListCard({
    required this.rows,
    required this.lineColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
  });

  final List<_ListRow> rows;
  final Color lineColor;
  final Color surfaceColor;
  final Color onSurfaceColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lineColor, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i].render(
              lineColor: lineColor,
              showDivider: i < rows.length - 1,
              onSurfaceColor: onSurfaceColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _ListRow {
  const _ListRow(this.emoji, this.label, this.value, {required this.boldValue});
  final String emoji;
  final String label;
  final String value;
  final bool boldValue;

  Widget render({
    required Color lineColor,
    required bool showDivider,
    required Color onSurfaceColor,
  }) {
    return _ListRowWidget(
      emoji: emoji,
      label: label,
      value: value,
      boldValue: boldValue,
      lineColor: lineColor,
      showDivider: showDivider,
      onSurfaceColor: onSurfaceColor,
    );
  }
}

class _ListRowWidget extends StatelessWidget {
  const _ListRowWidget({
    required this.emoji,
    required this.label,
    required this.value,
    required this.boldValue,
    required this.lineColor,
    required this.showDivider,
    required this.onSurfaceColor,
  });

  final String emoji;
  final String label;
  final String value;
  final bool boldValue;
  final Color lineColor;
  final bool showDivider;
  final Color onSurfaceColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: lineColor, width: 1),
              ),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16, height: 1.2)),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: onSurfaceColor,
                ),
                children: [
                  TextSpan(text: '$label '),
                  if (value.isNotEmpty)
                    TextSpan(
                      text: value,
                      style: TextStyle(
                          fontWeight:
                              boldValue ? FontWeight.bold : FontWeight.w500),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// v4 `.card` (margin-top:12) with "📝 How did it feel?" + 3 mood chips.
class _MoodJournalCard extends StatelessWidget {
  const _MoodJournalCard({
    required this.selectedMood,
    required this.onMoodTap,
    required this.surfaceColor,
    required this.onSurfaceColor,
  });

  final String? selectedMood;
  final ValueChanged<String> onMoodTap;
  final Color surfaceColor;
  final Color onSurfaceColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📝 How did it feel?',
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: onSurfaceColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChip(
                label: '😩 Tough',
                selected: selectedMood == 'tough',
                onTap: () => onMoodTap('tough'),
              ),
              AppChip(
                label: '🙌 Great',
                selected: selectedMood == 'great',
                onTap: () => onMoodTap('great'),
              ),
              AppChip(
                label: '😌 Calm',
                selected: selectedMood == 'calm',
                onTap: () => onMoodTap('calm'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
