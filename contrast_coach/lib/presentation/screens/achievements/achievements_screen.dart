import 'dart:ui' as ui;

import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/feature_gating.dart';
import 'package:contrast_coach/data/local/database/database_provider.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/achievement.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/usecases/evaluate_achievements.dart';
import 'package:contrast_coach/domain/usecases/session_stats.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:flutter/material.dart';

const _kLevelNames = [
  'Novice',
  'Apprentice',
  'Steady',
  'Frostwalker',
  'Coldforge',
  'Heatsworn',
  'Ironliver',
  'Aurora',
  'Icemaster',
  'Legend',
];

String _levelName(int level) {
  if (level < 0) return _kLevelNames.first;
  final idx = (level - 1).clamp(0, _kLevelNames.length - 1);
  return _kLevelNames[idx];
}

int _levelForSessions(int sessions) =>
    (sessions ~/ 12).clamp(0, _kLevelNames.length - 1) + 1;

int _xpForMinutes(int minutes) => minutes * 10;

const _grayscale = ui.ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late Future<({List<Achievement> badges, int level, int xp, double pct})> _load;

  static const SubscriptionTier _tier = SubscriptionTier.free;

  @override
  void initState() {
    super.initState();
    _load = _loadAchievements();
  }

  Future<({List<Achievement> badges, int level, int xp, double pct})>
      _loadAchievements() async {
    final db = await DatabaseProvider.instance();
    final repo = SessionRepositoryImpl(db);
    final result = await repo.getAll();
    final sessions = result is Ok<List<Session>, AppException>
        ? result.value
        : <Session>[];
    final stats = computeSessionStats(sessions);
    final level = _levelForSessions(stats.totalSessions);
    final xp = _xpForMinutes(stats.totalMinutes);
    final nextThreshold = (level + 1) * 1200;
    final curThreshold = level * 1200;
    final pct = nextThreshold == curThreshold
        ? 1.0
        : ((xp - curThreshold) / (nextThreshold - curThreshold)).clamp(0.0, 1.0);
    final all = evaluateAchievements(sessions);
    final gated = _applyTierGate(all);
    return (badges: gated, level: level, xp: xp, pct: pct);
  }

  List<Achievement> _applyTierGate(List<Achievement> all) {
    final fullHistory = FeatureGating.canUseFullAchievementsHistory(_tier);
    if (fullHistory) return all;
    final cutoff = DateTime.now().subtract(
      Duration(days: FeatureGating.freeStreakHistoryDays),
    );
    return all
        .where((a) => !a.isUnlocked || (a.unlockedAt?.isAfter(cutoff) ?? false))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const ContrastAppBar(title: 'Achievements', showBackButton: true),
      body: SafeArea(
        top: false,
        child: FutureBuilder<
            ({List<Achievement> badges, int level, int xp, double pct})>(
          future: _load,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return _emptyState(context);
            final data = snapshot.data;
            if (data == null || data.badges.isEmpty) return _emptyState(context);
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.lg,
                AppSpacing.pageHorizontal,
                AppSpacing.sectionGap,
              ),
              children: [
                _LevelCard(level: data.level, xp: data.xp, pct: data.pct),
                const SizedBox(height: 14),
                _BadgesGrid(badges: data.badges),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('🏆', style: TextStyle(fontSize: 40)),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No achievements yet — start a session to unlock',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Level + XP card. Mockup `.card` margin-bottom 14:
///   Row "Level 4 · Frostwalker" + "720 XP" — 13 w700.
///   `.bar-p` 8 tall, heat→coral inner at 72%.
class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level, required this.xp, required this.pct});
  final int level;
  final int xp;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final name = _levelName(level).trim();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ext.lineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A14142D),
            blurRadius: 24,
            offset: Offset(0, 8),
            spreadRadius: -16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level · $name',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$xp XP',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: ext.lineColor),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(gradient: AppGradients.btnPrimary),
                    ),
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

/// 3-column badge grid. Mockup `.badges` `grid-template-columns: 1fr 1fr 1fr`
/// gap 12. `.badge` radius 16, padding 14/6, emoji 26px centered, small label
/// 10 w700. `.badge.locked` opacity .4 + filter grayscale(1).
class _BadgesGrid extends StatelessWidget {
  const _BadgesGrid({required this.badges});
  final List<Achievement> badges;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, i) => _BadgeTile(achievement: badges[i]),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.achievement});
  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorsExtension>()!;
    final unlocked = achievement.isUnlocked;
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ext.lineColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A14142D),
            blurRadius: 24,
            offset: Offset(0, 8),
            spreadRadius: -16,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            achievement.emoji,
            style: const TextStyle(fontSize: 26, height: 1.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    if (unlocked) return tile;
    return Opacity(
      opacity: 0.4,
      child: ColorFiltered(
        colorFilter: _grayscale,
        child: tile,
      ),
    );
  }
}
