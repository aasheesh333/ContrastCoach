import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_spacing.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:flutter/material.dart';
class InsightBlock extends StatelessWidget {
  const InsightBlock({
    super.key,
    required this.heroMetric,
    required this.title,
    required this.body,
    this.accent,
    this.icon,
  });

  final String heroMetric;
  final String title;
  final String body;
  final Color? accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tint = accent ?? AppColors.brandWarm;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      radius: 20,
      elevation: AppCardElevation.soft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: tint, size: 20),
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heroMetric,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: AppColors.darkGray,
                    height: 1.4,
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

class GradientHeroStat extends StatelessWidget {
  const GradientHeroStat({
    super.key,
    required this.label,
    required this.value,
    required this.delta,
    this.gradient,
  });

  final String label;
  final String value;
  final String delta;
  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl + 4,
      ),
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.contrast,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: AppColors.white,
              fontSize: 64,
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            delta,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: AppColors.white.withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ContrastBar extends StatelessWidget {
  const ContrastBar({
    super.key,
    required this.fraction,
    this.color = AppColors.brandWarm,
    this.height = 8,
  });

  final double fraction;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: color.withOpacity(0.12),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction.clamp(0.0, 1.0),
          child: Container(color: color),
        ),
      ),
    );
  }
}
