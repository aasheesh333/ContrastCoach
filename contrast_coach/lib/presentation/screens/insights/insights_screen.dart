import 'package:contrast_coach/core/animations/animation_utils.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/feature_gating.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/protocol_repository.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/data/repositories/subscription_repository.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/insight.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/usecases/generate_insights.dart';
import 'package:contrast_coach/domain/usecases/session_stats.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_chip.dart';
import 'package:contrast_coach/presentation/widgets/composite/insight_block.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
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
  SessionStats _stats = computeSessionStats(const []);
  Map<String, Protocol> _protocolsById = {};
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
    // Refresh the tier from RevenueCat each load; the listener keeps the UI
    // in sync for subsequent changes (e.g. after returning from the paywall).
    final repo = SubscriptionRepositoryImpl()
      ..bindSharedState(_sharedState);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const ContrastAppBar(title: 'Insights'),
      body: SafeArea(
        top: false,
        child: _loading
            ? const ShimmerLoading(isLoading: true, child: _InsightsSkeleton())
            : !FeatureGating.canUseInsights(_tier)
                ? _paywallGate(context)
            : _stats.isEmpty
                ? _emptyState()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.lg,
                      AppSpacing.pageHorizontal,
                      AppSpacing.sectionGap,
                    ),
                    children: [
                      Text(
                        _rangeLabel(_range),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _headlineForRange(_range, _stats),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.2,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          AppChip(
                            label: 'Week',
                            selected: _range == _Range.week,
                            onTap: () => _setRange(_Range.week),
                          ),
                          const SizedBox(width: 8),
                          AppChip(
                            label: 'Month',
                            selected: _range == _Range.month,
                            onTap: () => _setRange(_Range.month),
                          ),
                          const SizedBox(width: 8),
                          AppChip(
                            label: 'Year',
                            selected: _range == _Range.year,
                            onTap: () => _setRange(_Range.year),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      GradientHeroStat(
                        label: _range == _Range.week
                            ? 'SESSIONS THIS WEEK'
                            : _range == _Range.month
                                ? 'SESSIONS THIS MONTH'
                                : 'SESSIONS THIS YEAR',
                        value: _periodSessions().toString(),
                        delta: _stats.streakDays > 0
                            ? '${_stats.streakDays} day streak · ${_stats.avgDurationMin}m avg'
                            : 'No streak yet · start one today',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _StatGrid(stats: _stats),
                      const SizedBox(height: AppSpacing.lg),
                      _PatternSection(stats: _stats, range: _range),
                      const SizedBox(height: AppSpacing.lg),
                      if (_insights.isNotEmpty) ...[
                        const SectionHeader(label: 'Insights for you'),
                        const SizedBox(height: AppSpacing.xs),
                        for (final i in _insights.where((i) =>
                            i.category != InsightCategory.totalSessions &&
                            i.category != InsightCategory.avgDuration)) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: InsightBlock(
                              heroMetric: i.heroMetric,
                              title: i.title,
                              body: _decorateInsight(i),
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Not medical advice. For informational purposes only.',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
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
              const Icon(LucideIcons.sparkles, color: AppColors.brandWarm, size: 32),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Insights are part of Pro.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
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
                  fontFamily: 'PlusJakartaSans',
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

  int _periodSessions() {
    final total = _insights.firstWhere(
      (i) => i.category == InsightCategory.totalSessions,
      orElse: () => Insight(
        id: 'none',
        category: InsightCategory.totalSessions,
        heroMetric: '0',
        title: 'Sessions',
        body: '',
        periodStart: DateTime.now(),
        periodEnd: DateTime.now(),
      ),
    );
    return int.tryParse(total.heroMetric) ?? 0;
  }

  String _decorateInsight(Insight i) {
    if (i.category == InsightCategory.bestProtocol && _protocolsById[i.id] == null) {
      // bestProtocol insight uses id == 'best-protocol' but the protocolId
      // is buried in body; return as-is to avoid hardcoding names.
      return i.body;
    }
    return i.body;
  }

  void _setRange(_Range r) {
    if (_range == r) return;
    setState(() {
      _range = r;
      _loading = true;
    });
    _load();
  }

  String _rangeLabel(_Range r) => switch (r) {
        _Range.week => 'This week',
        _Range.month => 'This month',
        _Range.year => 'This year',
      };

  String _headlineForRange(_Range r, SessionStats s) {
    final sessions = r == _Range.week
        ? s.thisWeekCount
        : r == _Range.month
            ? s.totalSessions
            : s.totalSessions;
    if (sessions == 0) {
      return 'No sessions yet';
    }
    return '$sessions session${sessions == 1 ? '' : 's'} tracked';
  }

  Widget _emptyState() {
    return AppEmptyState(
      icon: LucideIcons.barChart3,
      title: 'No insights yet',
      message: 'Complete a session to start seeing patterns, recovery trends, and weekly comparisons.',
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});
  final SessionStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _GridStat(
                label: 'TOTAL SESSIONS',
                value: '${stats.totalSessions}',
                icon: LucideIcons.activity,
                color: AppColors.brandWarm,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _GridStat(
                label: 'AVG DURATION',
                value: '${stats.avgDurationMin}',
                suffix: 'min',
                icon: LucideIcons.timer,
                color: AppColors.brandCool,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _GridStat(
                label: 'BEST SCORE',
                value: stats.bestScore != null
                    ? '${stats.bestScore!.round()}'
                    : '—',
                icon: LucideIcons.trophy,
                color: AppColors.brandWarm,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _GridStat(
                label: 'TOTAL MINUTES',
                value: '${stats.totalMinutes}',
                suffix: 'min',
                icon: LucideIcons.flame,
                color: AppColors.brandCool,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GridStat extends StatelessWidget {
  const _GridStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: 20,
      elevation: AppCardElevation.soft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(
                  suffix!,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PatternSection extends StatelessWidget {
  const _PatternSection({required this.stats, required this.range});
  final SessionStats stats;
  final _Range range;

  @override
  Widget build(BuildContext context) {
    final f = stats.timeOfDayFractions();
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      radius: 20,
      elevation: AppCardElevation.soft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(label: 'Time-of-day pattern'),
          const SizedBox(height: AppSpacing.xs),
          _BarRow(
            label: 'Morning (5–11)',
            value: '${(f.morning * 100).round()}%',
            fraction: f.morning,
            color: AppColors.brandWarm,
            count: stats.morningCount,
          ),
          const SizedBox(height: 10),
          _BarRow(
            label: 'Afternoon (12–17)',
            value: '${(f.afternoon * 100).round()}%',
            fraction: f.afternoon,
            color: AppColors.brandCoral,
            count: stats.afternoonCount,
          ),
          const SizedBox(height: 10),
          _BarRow(
            label: 'Evening (18–4)',
            value: '${(f.evening * 100).round()}%',
            fraction: f.evening,
            color: AppColors.brandCool,
            count: stats.eveningCount,
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
    required this.count,
  });
  final String label;
  final String value;
  final double fraction;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$value · $count',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ContrastBar(fraction: fraction, color: color),
      ],
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
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        AppSpacing.sectionGap,
      ),
      children: [
        Container(width: 80, height: 14, color: Theme.of(context).colorScheme.surfaceContainerHigh),
        const SizedBox(height: 4),
        Container(width: 180, height: 24, color: Theme.of(context).colorScheme.surfaceContainerHigh),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(right: 8), child: _SkeletonChip())),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 120,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(20)),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: const [
            Expanded(child: _SkeletonCard(height: 100)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _SkeletonCard(height: 100)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: const [
            Expanded(child: _SkeletonCard(height: 100)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _SkeletonCard(height: 100)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SkeletonCard(height: 160),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 60,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
        ),
      ],
    );
  }
}

class _SkeletonChip extends StatelessWidget {
  const _SkeletonChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
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
