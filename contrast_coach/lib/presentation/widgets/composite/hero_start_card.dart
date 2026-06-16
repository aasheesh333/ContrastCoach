import 'package:contrast_coach/core/constants/app_colors.dart';
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
    this.onStart,
  });

  final Protocol? recommendedProtocol;
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
    final tt = Theme.of(context).textTheme;
    final p = recommendedProtocol;
    final name = p?.name ?? 'Standard Recovery';
    final duration = p?.totalDuration ?? const Duration(minutes: 25);
    final rounds = p?.rounds ?? 3;
    final category = p?.category ?? ProtocolCategory.recovery;
    final accent = _accentForCategory(category);

    return AppSurface(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      radius: 28,
      elevation: 4,
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
              const SizedBox(width: 12),
              Text(
                "TODAY'S SESSION",
                style: tt.labelSmall?.copyWith(
                  color: accent,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: tt.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${duration.inMinutes} min · $rounds rounds · 78% effort',
            style: tt.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          // Gradient progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              decoration: const BoxDecoration(
                gradient: AppGradients.contrastHorizontal,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 20),
          _StartSessionPill(
            onPressed: onStart ?? () => _defaultStart(context),
            label: 'Start session',
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 60,
          width: double.infinity,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
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
      _GoalEntry(Goal.recovery, 'Recovery', 'Standard', 'recovery_standard', AppColors.brandWarm, LucideIcons.snowflake),
      _GoalEntry(Goal.energy, 'Energy', 'Morning', 'energy_morning', AppColors.brandCoral, LucideIcons.sun),
      _GoalEntry(Goal.sleep, 'Sleep', 'Evening', 'sleep_evening', AppColors.brandCool, LucideIcons.moon),
      _GoalEntry(Goal.immunity, 'Immunity', 'Weekly', 'immunity_weekly', AppColors.brandCool, LucideIcons.shield),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _GoalTile(entry: entries[i], onTap: () => onGoalTap(entries[i].goal)),
      ),
    );
  }
}

class _GoalEntry {
  const _GoalEntry(this.goal, this.title, this.subtitle, this.protocolId, this.color, this.icon);
  final Goal goal;
  final String title;
  final String subtitle;
  final String protocolId;
  final Color color;
  final IconData icon;
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.entry, required this.onTap});
  final _GoalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SizedBox(
      width: 130,
      child: AppSurface(
        radius: 20,
        padding: const EdgeInsets.all(14),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: tt.titleMedium),
                const SizedBox(height: 2),
                Text(
                  entry.subtitle,
                  style: tt.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
