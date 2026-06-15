import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroStartCard extends StatelessWidget {
  const HeroStartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AppCard(
      elevation: AppCardElevation.high,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('READY', style: tt.labelSmall),
          const SizedBox(height: 8),
          Text('Choose your session', style: tt.displayMedium),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _GoalCard(
                title: 'Refresh',
                subtitle: 'Recovery standard',
                onTap: () => context.push('/session/recovery_standard'),
              ),
              _GoalCard(
                title: 'Focus',
                subtitle: 'Morning energy',
                onTap: () => context.push('/session/energy_morning'),
              ),
              _GoalCard(
                title: 'Sleep',
                subtitle: 'Evening wind-down',
                onTap: () => context.push('/session/sleep_evening'),
              ),
              _GoalCard(
                title: 'Immunity',
                subtitle: 'Weekly boost',
                onTap: () => context.push('/session/immunity_weekly'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Build custom protocol',
            onPressed: () => context.push('/protocol/custom'),
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: tt.titleMedium?.copyWith(color: cs.onSurface)),
              const SizedBox(height: 4),
              Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
