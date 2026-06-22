import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/session_stats.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:contrast_coach/presentation/widgets/atomic/identity.dart';
import 'package:contrast_coach/presentation/widgets/composite/streak_calendar.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StreakCalendarScreen extends StatefulWidget {
  const StreakCalendarScreen({super.key});
  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends State<StreakCalendarScreen> {
  Set<DateTime> _daysWithSessions = {};
  Map<DateTime, int> _intensity = {};
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

    final sessionsResult = await repo.getAll();
    if (sessionsResult is Ok<List<Session>, AppException>) {
      final sessions = sessionsResult.value;
      final dates = <DateTime>{};
      final counts = <DateTime, int>{};
      for (final s in sessions) {
        final d = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
        dates.add(d);
        counts[d] = (counts[d] ?? 0) + 1;
      }
      if (mounted) {
        setState(() {
          _daysWithSessions = dates;
          _intensity = counts;
          _stats = computeSessionStats(sessions);
          _loading = false;
        });
      }
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: const ContrastAppBar(title: 'Streak'),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.brandWarm),
              )
            : _stats.isEmpty
                ? AppEmptyState(
                    icon: LucideIcons.flame,
                    title: 'No streak yet',
                    message: 'Finish a session today to start a streak and build consistency over time.',
                    action: _StartSessionButton(
                      onPressed: () => context.push('/home'),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.lg,
                      AppSpacing.pageHorizontal,
                      AppSpacing.huge,
                    ),
                    children: [
                      _StreakHeader(stats: _stats),
                      const SizedBox(height: AppSpacing.lg),
                      StreakCalendar(
                        daysWithSessions: _daysWithSessions,
                        intensity: _intensity,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const _Legend(),
                      const SizedBox(height: AppSpacing.huge),
                      _StatsCard(stats: _stats),
                      const SizedBox(height: AppSpacing.lg),
                      if (_stats.bestScore != null)
                        _BestScoreCard(score: _stats.bestScore!),
                    ],
                  ),
      ),
    );
  }
}

class _StartSessionButton extends StatelessWidget {
  const _StartSessionButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandWarm,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: AppShadows.pill,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.play, color: AppColors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'Start a session',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakHeader extends StatelessWidget {
  const _StreakHeader({required this.stats});
  final SessionStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${stats.streakDays}',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: AppColors.brandWarm,
                height: 1.0,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              stats.streakDays == 1 ? 'day streak' : 'days streak',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          stats.streakDays > 0
              ? 'You are on a roll. Keep it going.'
              : 'Start one today to begin a new streak.',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            color: AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.brandWarm.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Last 12 weeks',
            style: TextStyle(
              fontFamily: Theme.of(context).textTheme.labelMedium?.fontFamily,
              fontSize: 11,
              color: AppColors.brandWarm,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});
  final SessionStats stats;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      radius: 20,
      elevation: AppCardElevation.soft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(label: 'At a glance'),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _InlineStat(
                  label: 'Total',
                  value: '${stats.totalSessions}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InlineStat(
                  label: 'Minutes',
                  value: '${stats.totalMinutes}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InlineStat(
                  label: 'This week',
                  value: '${stats.thisWeekCount}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
            height: 1.0,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            color: AppColors.midGray,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _BestScoreCard extends StatelessWidget {
  const _BestScoreCard({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      radius: 20,
      elevation: AppCardElevation.soft,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.brandWarm.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(LucideIcons.trophy, color: AppColors.brandWarm, size: 26),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal best',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: AppColors.midGray,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${score.round()} recovery score',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                    letterSpacing: -0.4,
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

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Less',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            color: AppColors.midGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        for (final c in const [
          AppColors.heatmap0,
          AppColors.heatmap1,
          AppColors.heatmap2,
          AppColors.heatmap3,
          AppColors.heatmap4,
        ])
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        const SizedBox(width: 8),
        const Text(
          'More',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            color: AppColors.midGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
