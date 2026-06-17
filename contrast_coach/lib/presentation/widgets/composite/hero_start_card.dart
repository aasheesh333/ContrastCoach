import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Hero card on Home: "TODAY'S SESSION" + protocol summary + gradient progress
/// + giant "Start session" pill button. Tap to start the recommended session.
class HeroStartCard extends StatelessWidget {
  const HeroStartCard({
    super.key,
    required this.recommendedProtocol,
    required this.sessionCount,
    this.onStart,
  });

  final Protocol? recommendedProtocol;
  final int sessionCount;
  final VoidCallback? onStart;

  IconData _iconForCategory(ProtocolCategory c) => switch (c) {
        ProtocolCategory.recovery => LucideIcons.snowflake,
        ProtocolCategory.energy => LucideIcons.sun,
        ProtocolCategory.sleep => LucideIcons.moon,
        ProtocolCategory.immunity => LucideIcons.shield,
        ProtocolCategory.custom => LucideIcons.sparkles,
      };

  Color _accentForCategory(ProtocolCategory c) => switch (c) {
        ProtocolCategory.energy => AppColors.brandWarm,
        ProtocolCategory.immunity => AppColors.brandCool,
        _ => AppColors.brandWarm,
      };

  @override
  Widget build(BuildContext context) {
    final p = recommendedProtocol;
    final name = p?.name ?? 'Standard Recovery';
    final duration = p?.totalDuration ?? const Duration(minutes: 25);
    final rounds = p?.rounds ?? 3;
    final category = p?.category ?? ProtocolCategory.recovery;
    final accent = _accentForCategory(category);
    final mins = duration.inMinutes;
    final secs = duration.inSeconds.remainder(60);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      radius: 28,
      elevation: AppCardElevation.medium,
      onTap: onStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconForCategory(category), size: 18, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                "TODAY'S SESSION",
                style: TextStyle(
                  fontFamily: Theme.of(context).textTheme.labelSmall?.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: accent,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$mins min${secs > 0 ? ' ${secs}s' : ''} · $rounds rounds',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              color: AppColors.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Gradient progress bar (visual: total session time)
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              decoration: const BoxDecoration(
                gradient: AppGradients.contrastHorizontal,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _StartSessionPill(
            onPressed: onStart ?? () => _defaultStart(context),
            label: sessionCount == 0
                ? 'Start first session'
                : 'Start session',
          ),
        ],
      ),
    );
  }

  void _defaultStart(BuildContext context) {
    final p = recommendedProtocol;
    final id = p?.id ?? 'recovery_standard';
    context.push('/session/$id');
  }
}

class _StartSessionPill extends StatelessWidget {
  const _StartSessionPill({required this.onPressed, required this.label});
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandWarm,
      borderRadius: BorderRadius.circular(999),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 60,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: AppShadows.pill,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: AppColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(LucideIcons.arrowRight, color: AppColors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal row of goal cards. Tapping a goal starts that protocol.
class GoalCardsRow extends StatelessWidget {
  const GoalCardsRow({super.key, required this.onGoalTap});

  /// Called with the goal enum when user taps a goal card.
  final void Function(Goal goal) onGoalTap;

  @override
  Widget build(BuildContext context) {
    final entries = <_GoalEntry>[
      const _GoalEntry(Goal.recovery, 'Recovery', 'Standard', ProtocolCategory.recovery, AppColors.brandWarm, LucideIcons.snowflake),
      const _GoalEntry(Goal.energy, 'Energy', 'Morning', ProtocolCategory.energy, AppColors.brandCoral, LucideIcons.sun),
      const _GoalEntry(Goal.sleep, 'Sleep', 'Evening', ProtocolCategory.sleep, AppColors.brandCool, LucideIcons.moon),
      const _GoalEntry(Goal.immunity, 'Immunity', 'Weekly', ProtocolCategory.immunity, AppColors.brandCool, LucideIcons.shield),
    ];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, i) => _GoalTile(entry: entries[i], onTap: () => onGoalTap(entries[i].goal)),
      ),
    );
  }
}

class _GoalEntry {
  const _GoalEntry(this.goal, this.title, this.subtitle, this.category, this.color, this.icon);
  final Goal goal;
  final String title;
  final String subtitle;
  final ProtocolCategory category;
  final Color color;
  final IconData icon;
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.entry, required this.onTap});
  final _GoalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: AppCard(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        elevation: AppCardElevation.soft,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: entry.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(entry.icon, color: entry.color, size: 18),
            ),
            const SizedBox(height: 4),
            Text(
              entry.title,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
                height: 1.2,
              ),
            ),
            Text(
              entry.subtitle,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
