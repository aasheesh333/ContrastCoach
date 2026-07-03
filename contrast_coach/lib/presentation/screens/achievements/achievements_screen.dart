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
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

/// v4 Achievements screen.
///
/// Loads all sessions from the local drift store, runs the pure-Dart
/// [evaluateAchievements] evaluator, and renders a 2-column grid of badge
/// tiles with v4 styling (radius 20, surfaceContainerHigh, PlusJakartaSans).
///
/// Subscription tier gate: [FeatureGating.canUseFullAchievementsHistory].
/// Free users see unlocked badges within a 7-day window plus all locked
/// badges; Pro users see the full history. The live tier read is deferred
/// (would require Firestore/RevenueCat) — see "Tier wiring" in the task
/// report. Until wired, the screen defaults to showing all badges.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late Future<List<Achievement>> _load;

  /// Deferred: read live tier from RevenueCat/Firestore via
  /// [SharedSubscriptionState] (see insights/streak screens). Until then
  /// we default to [SubscriptionTier.free] only to expose the gate flag —
  /// the consumer behavior is "show all badges" so the screen is not
  /// degraded for Free users during the v4 port.
  static const SubscriptionTier _tier = SubscriptionTier.free;

  @override
  void initState() {
    super.initState();
    _load = _loadAchievements();
  }

  Future<List<Achievement>> _loadAchievements() async {
    final db = await DatabaseProvider.instance();
    final repo = SessionRepositoryImpl(db);
    final result = await repo.getAll();
    final sessions = result is Ok<List<Session>, AppException>
        ? result.value
        : <Session>[];
    final all = evaluateAchievements(sessions);
    return _applyTierGate(all);
  }

  /// Apply the Pro/Free achievements-history gate.
  ///
  /// Free: drop unlocked badges whose `unlockedAt` is older than 7 days,
  /// keep locked badges and recently-unlocked ones.
  /// Pro (or any `isPro` tier): keep all badges.
  List<Achievement> _applyTierGate(List<Achievement> all) {
    final fullHistory = FeatureGating.canUseFullAchievementsHistory(_tier);
    if (fullHistory) return all;
    final cutoff = DateTime.now().subtract(
      Duration(days: FeatureGating.freeStreakHistoryDays),
    );
    return all
        .where(
          (a) => !a.isUnlocked || (a.unlockedAt?.isAfter(cutoff) ?? false),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const ContrastAppBar(title: 'Achievements'),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<Achievement>>(
          future: _load,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _emptyState(context);
            }
            final items = snapshot.data ?? const <Achievement>[];
            if (items.isEmpty) return _emptyState(context);
            return _AchievementsGrid(items: items);
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
          children: [
            const Text(
              '🏆',
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No achievements yet — start a session to unlock',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid({required this.items});
  final List<Achievement> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        AppSpacing.sectionGap,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _AchievementTile(achievement: items[i]),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});
  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    // Spec said AppColors.ink3 — that token does not exist in AppColors
    // (only lightInk3/darkInk3 do). Use colorScheme.outline so the locked
    // state is theme-aware and consistent with other v4 screens.
    final mutedColor = Theme.of(context).colorScheme.outline;
    final emojiColor = unlocked ? AppColors.heat : mutedColor;
    final nameColor = unlocked
        ? Theme.of(context).colorScheme.onSurface
        : mutedColor;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            achievement.emoji,
            style: TextStyle(fontSize: 36, color: emojiColor, height: 1.0),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            achievement.title,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: nameColor,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            achievement.description,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.outline,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            unlocked
                ? 'Unlocked ${_formatDate(achievement.unlockedAt!)}'
                : 'Locked',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: unlocked ? AppColors.heat : mutedColor,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.month}/${d.day}/${d.year}';
  }
}
