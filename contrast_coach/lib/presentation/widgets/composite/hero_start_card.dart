import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HeroStartCard extends StatelessWidget {
  const HeroStartCard({super.key, required this.recommendedProtocol, required this.sessionCount, this.onStart});
  final Protocol? recommendedProtocol;
  final int sessionCount;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = recommendedProtocol;
    final name = p?.name ?? 'Standard Recovery';
    final duration = p?.totalDuration ?? const Duration(minutes: 25);
    final rounds = p?.rounds ?? 3;
    final mins = duration.inMinutes;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(gradient: AppGradients.contrast, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(999)), child: Text("TODAY'S SESSION", style: cs.textTheme.labelSmall?.copyWith(color: Colors.white))),
          if (sessionCount > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(999)), child: Text('$sessionCount done', style: cs.textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: AppSpacing.xl),
        Text(name, style: cs.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        Text('$rounds rounds · $mins min', style: cs.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8))),
        const SizedBox(height: AppSpacing.xxl),
        Container(height: 6, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(3))),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(width: double.infinity, child: Material(color: Colors.white, borderRadius: BorderRadius.circular(999), child: InkWell(onTap: onStart, borderRadius: BorderRadius.circular(999), child: Container(height: 64, alignment: Alignment.center, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(LucideIcons.play, color: AppColors.brandWarm, size: 22),
          const SizedBox(width: 10),
          Text('Start session', style: cs.textTheme.titleMedium?.copyWith(color: AppColors.brandWarm, fontWeight: FontWeight.w700)),
        ]))))),
      ]),
    );
  }
}
