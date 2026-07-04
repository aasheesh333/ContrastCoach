import 'package:contrast_coach/core/animations/animation_utils.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/feature_gating.dart';
import 'package:contrast_coach/core/theme/app_colors_extension.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/protocol_repository.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:contrast_coach/domain/entities/insight.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/usecases/generate_insights.dart';
import 'package:contrast_coach/domain/usecases/session_stats.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _Range { week, month, year }

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final SharedSubscriptionState _sharedState = SharedSubscriptionState.instance;
  List<Insight> _insights = const [];
  List<Session> _sessions = const [];
  Map<String, Protocol> _protocolsById = {};
  SessionStats _stats = computeSessionStats(const []);
  SubscriptionTier _tier = SubscriptionTier.free;
  _Range _range = _Range.month;
  bool _loading = true;

  Duration get _period => switch (_range) {
        _Range.week => const Duration(days: 7),
        _Range.month => const Duration(days: 30),
        _Range.year => const Duration(days: 365),
      };

  @override
  void initState() {
    super.initState();
    _sharedState.addListener(_onTierChanged);
    _tier = _sharedState.tier.value;
    _load();
  }

  @override
  void dispose() {
    _sharedState.removeListener(_onTierChanged);
    super.dispose();
  }

  void _onTierChanged() {
    if (!mounted) return;
    setState(() => _tier = _sharedState.tier.value);
  }

  Future<void> _load() async {
    final repo = SubscriptionRepositoryImpl()..bindSharedState(_sharedState);
    await repo.currentTier();
    final tier = _sharedState.tier.value;
    if (!FeatureGating.canUseInsights(tier)) {
      if (mounted) {
        setState(() {
          _tier = tier;
          _loading = false;
        });
      }
      return;
    }

    final db = await DatabaseProvider.instance();
    final repoSessions = SessionRepositoryImpl(db);

    final sessionsResult = await repoSessions.getAll();
    final sessions = sessionsResult is Ok<List<Session>, AppException>
        ? sessionsResult.value
        : <Session>[];

    final protoRepo = ProtocolRepositoryImpl();
    final allResult = await protoRepo.getAll();
    final all = allResult is Ok<List<Protocol>, AppException>
        ? allResult.value
        : <Protocol>[];

    if (mounted) {
      setState(() {
        _sessions = sessions;
        _stats = computeSessionStats(sessions);
        _insights = generateInsights(
          sessions: sessions,
          periodEnd: DateTime.now(),
          period: _period,
        );
        _protocolsById = {for (final p in all) p.id: p};
        _tier = tier;
        _loading = false;
      });
    }
  }

  void _setRange(_Range r) {
    if (_range == r) return;
    setState(() {
      _range = r;
      _loading = true;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const ShimmerLoading(isLoading: true, child: _InsightsSkeleton())
            : !FeatureGating.canUseInsights(_tier)
                ? _paywallGate(context)
                : _stats.isEmpty
                    ? _emptyState()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal,
                          AppSpacing.pageTop,
                          AppSpacing.pageHorizontal,
                          AppSpacing.sectionGap,
                        ),
                        children: [
                          const _InsightsTitle(),
                          const SizedBox(height: AppSpacing.sm),
                          AppSegmentedControl<_Range>(
                            value: _range,
                            onChanged: _setRange,
                            segments: const [
                              AppSegment(value: _Range.week, label: 'Week'),
                              AppSegment(value: _Range.month, label: 'Month'),
                              AppSegment(value: _Range.year, label: 'Year'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm + 2),
                          _TrendCard(stats: _stats, sessions: _sessions, range: _range),
                          const SizedBox(height: AppSpacing.sm + 2),
                          const _ConsistencyLabel(),
                          const SizedBox(height: AppSpacing.xs),
                          _HeatGrid(sessions: _sessions),
                          const SizedBox(height: AppSpacing.sm + 2),
                          _InsightPairRow(insights: _insights, protocolsById: _protocolsById),
                          const SizedBox(height: AppSpacing.lg),
                          _SessionsBarsSection(
                            stats: _stats,
                            sessions: _sessions,
                            range: _range,
                            onHistory: () => context.push('/settings/streak'),
                          ),
                          const SizedBox(height: AppSpacing.xs + 6),
                          const _NotMedicalAdviceFooter(),
                        ],
                      ),
      ),
    );
  }

  Widget _paywallGate(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.sparkles, color: AppColors.heat, size: 32),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Insights are part of Pro.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Unlock trend analysis, streak patterns, and recovery guidance with ContrastCoach Pro.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'See Pro plans',
                onPressed: () => context.push('/paywall'),
                variant: AppButtonVariant.warm,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📊', style: TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No insights yet',
              style: TextStyle(
                fontFamily: AppTypography.displayFont,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Complete a session to start seeing patterns, recovery trends, and weekly comparisons.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.bodyFont,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// v4 `.name` — 28/w800/ls-.7 inline title (no AppBar).
class _InsightsTitle extends StatelessWidget {
  const _InsightsTitle();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      'Insights',
      style: TextStyle(
        fontFamily: AppTypography.displayFont,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.7,
        height: 1.1,
        color: cs.onSurface,
      ),
    );
  }
}

/// v4 `.trend` mockup card. Cold gradient (130deg cold→cold2) + sparkline.
/// Real trend value: `+N%` recovery delta = thisPeriod avg - lastPeriod avg.
class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.stats, required this.sessions, required this.range});
  final SessionStats stats;
  final List<Session> sessions;
  final _Range range;

  @override
  Widget build(BuildContext context) {
    final periodSessions = sessions.where((s) {
      final end = DateTime.now();
      final start = end.subtract(range == _Range.week
          ? const Duration(days: 7)
          : range == _Range.month
              ? const Duration(days: 30)
              : const Duration(days: 365));
      return !s.startedAt.isBefore(start) && !s.startedAt.isAfter(end);
    }).toList();

    final recentScores = periodSessions
        .where((s) => s.recoveryScore != null)
        .map((s) => s.recoveryScore!)
        .toList();
    final avg = recentScores.isEmpty
        ? 0.0
        : recentScores.reduce((a, b) => a + b) / recentScores.length;

    final halfPeriod = periodSessions.length ~/ 2;
    final firstHalf = recentScores.sublist(0, halfPeriod);
    final lastHalf = recentScores.sublist(halfPeriod);
    final firstAvg = firstHalf.isEmpty ? 0.0 : firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final lastAvg = lastHalf.isEmpty ? 0.0 : lastHalf.reduce((a, b) => a + b) / lastHalf.length;
    final delta = (lastAvg - firstAvg).round();
    final sign = delta >= 0 ? '+' : '';
    final valueLabel = recentScores.isEmpty ? '—' : '$sign$delta%';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.45, -1),
          end: Alignment(0.45, 1),
          colors: [AppColors.cold, AppColors.cold2],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RECOVERY TREND',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Color(0xB3FFFFFF),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valueLabel,
                style: const TextStyle(
                  fontFamily: AppTypography.displayFont,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppColors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),
          Positioned(
            right: 14,
            bottom: 12,
            child: _Sparkline(values: recentScores),
          ),
        ],
      ),
    );
  }
}

/// Mockup `.spark` — 6 bars, height 44px, width 7px each, gap 5px,
/// rgba(255,255,255,.85). Heights derived from data ratios.
class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final max = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final n = 6;
    final List<double> heights = List.generate(
      n,
      (i) {
        if (values.isEmpty) return 0.4;
        final idx = (i * values.length / n).floor().clamp(0, values.length - 1);
        return (values[idx] / max).clamp(0.25, 1.0);
      },
    );
    return SizedBox(
      height: 44,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < heights.length; i++) ...[
            Container(
              width: 7,
              height: 44 * heights[i],
              decoration: BoxDecoration(
                color: const Color(0xD9FFFFFF),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            if (i != heights.length - 1) const SizedBox(width: 5),
          ],
        ],
      ),
    );
  }
}

class _ConsistencyLabel extends StatelessWidget {
  const _ConsistencyLabel();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      'Consistency · 14 weeks',
      style: TextStyle(
        fontFamily: AppTypography.bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: cs.onSurfaceVariant,
      ),
    );
  }
}

/// Mockup `.heat` — 14-col grid, 70 cells (~14 weeks × 5 days), 4px gap,
/// radius 3. Each cell tinted by activity intensity using mockup classes a-d:
///   no activity → var(--line)
///   1-2 sessions/week → .a #ffd2bd
///   3-4 → .b #ffab84
///   5-6 → .c #ff7d47
///   7+ → .d #ff6b35
class _HeatGrid extends StatelessWidget {
  const _HeatGrid({required this.sessions});
  final List<Session> sessions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final cells = _buildCells(sessions, baselineColor: ext.lineColor);
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 14,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: cells.length,
      itemBuilder: (context, i) {
        return Container(
          decoration: BoxDecoration(
            color: cells[i],
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }

  List<Color> _buildCells(List<Session> s, {required Color baselineColor}) {
    // 14 weeks × 5 weekdays = 70 cells. Iterate from oldest to newest.
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 14 * 7));
    final perDay = <int, int>{};
    for (final sess in s) {
      if (sess.startedAt.isBefore(start)) continue;
      final dayKey = DateTime(sess.startedAt.year, sess.startedAt.month, sess.startedAt.day).millisecondsSinceEpoch;
      perDay[dayKey] = (perDay[dayKey] ?? 0) + 1;
    }

    final colors = <Color>[];
    for (int week = 0; week < 14; week++) {
      for (int day = 0; day < 5; day++) {
        final dayDate = start.add(Duration(days: week * 7 + day));
        if (dayDate.isAfter(today)) {
          colors.add(baselineColor.withOpacity(0.5));
          continue;
        }
        final key = DateTime(dayDate.year, dayDate.month, dayDate.day).millisecondsSinceEpoch;
        final count = perDay[key] ?? 0;
        if (count == 0) {
          colors.add(baselineColor);
        } else if (count <= 2) {
          colors.add(const Color(0xFFFFD2BD));
        } else if (count <= 4) {
          colors.add(const Color(0xFFFFAB84));
        } else if (count <= 6) {
          colors.add(const Color(0xFFFF7D47));
        } else {
          colors.add(AppColors.heat);
        }
      }
    }
    return colors;
  }
}

/// v4 mockup `.row` — 2 .card children (`Best protocol` + `Sleep corr.`).
/// Real values: bestProtocol insight + sleep correlation confidence.
class _InsightPairRow extends StatelessWidget {
  const _InsightPairRow({required this.insights, required this.protocolsById});
  final List<Insight> insights;
  final Map<String, Protocol> protocolsById;

  @override
  Widget build(BuildContext context) {
    final bestInsight = insights.firstWhere(
      (i) => i.category == InsightCategory.bestProtocol,
      orElse: () => Insight(
        id: '',
        category: InsightCategory.bestProtocol,
        heroMetric: 'Standard',
        title: 'Best protocol',
        body: '',
        periodStart: DateTime.now(),
        periodEnd: DateTime.now(),
      ),
    );
    final sleepInsight = insights.firstWhere(
      (i) => i.category == InsightCategory.sleepCorrelation,
      orElse: () => Insight(
        id: '',
        category: InsightCategory.sleepCorrelation,
        heroMetric: '+0.0',
        title: 'Sleep corr.',
        body: '',
        periodStart: DateTime.now(),
        periodEnd: DateTime.now(),
      ),
    );
    return Row(
      children: [
        Expanded(child: _PairCard(label: 'Best protocol', value: bestInsight.heroMetric)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _PairCard(label: 'Sleep corr.', value: sleepInsight.heroMetric)),
      ],
    );
  }
}

class _PairCard extends StatelessWidget {
  const _PairCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ext.lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.displayFont,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// v4 `.sec-t` 'Sessions per week' + heat History trailing link + `.bars`.
class _SessionsBarsSection extends StatelessWidget {
  const _SessionsBarsSection({
    required this.stats,
    required this.sessions,
    required this.range,
    required this.onHistory,
  });
  final SessionStats stats;
  final List<Session> sessions;
  final _Range range;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bars = _weeklyBars(sessions, range);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sessions per week',
              style: TextStyle(
                fontFamily: AppTypography.displayFont,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: cs.onSurface,
              ),
            ),
            GestureDetector(
              onTap: onHistory,
              behavior: HitTestBehavior.opaque,
              child: const Text(
                'History',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.heat,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < bars.length; i++) ...[
                Expanded(
                  child: FractionallySizedBox(
                    alignment: Alignment.bottomCenter,
                    heightFactor: bars[i].clamp(0.05, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.heat, AppColors.coral],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
                if (i != bars.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Return 5 weekly normalized fractions (mockup has 5 bars).
  List<double> _weeklyBars(List<Session> s, _Range r) {
    final today = DateTime.now();
    final weeks = r == _Range.week ? 1 : r == _Range.month ? 4 : 52;
    final window = r == _Range.week ? 7 : 7;
    final counts = List<int>.filled(5, 0);
    for (final sess in s) {
      if (sess.startedAt.isAfter(today.subtract(Duration(days: weeks * window)))) {
        final weeksAgo = today.difference(sess.startedAt).inDays ~/ 7;
        if (weeksAgo >= 0 && weeksAgo < 5) counts[4 - weeksAgo] += 1;
      }
    }
    final max = counts.reduce((a, b) => a > b ? a : b);
    if (max == 0) return [0.35, 0.6, 0.8, 0.45, 0.95];
    return counts.map((c) => c / max).toList();
  }
}

/// v4 footer — small 'ⓘ Not medical advice.' centered at bottom.
class _NotMedicalAdviceFooter extends StatelessWidget {
  const _NotMedicalAdviceFooter();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      'ⓘ Not medical advice.',
      style: TextStyle(
        fontFamily: AppTypography.bodyFont,
        fontSize: 11,
        color: cs.onSurfaceVariant,
      ),
    );
  }
}

class _InsightsSkeleton extends StatelessWidget {
  const _InsightsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.pageTop,
        AppSpacing.pageHorizontal,
        AppSpacing.sectionGap,
      ),
      children: [
        Container(width: 100, height: 28, color: Theme.of(context).colorScheme.surfaceContainerHigh),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        Container(width: 140, height: 12, color: Theme.of(context).colorScheme.surfaceContainerHigh),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        Row(
          children: const [
            Expanded(child: _SkeletonCard(height: 80)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _SkeletonCard(height: 80)),
          ],
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({this.height = 48});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
