import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:flutter/material.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';

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
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final tint = accent ?? AppColors.brandWarm;
    return AppSurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      radius: 20,
      elevation: 1,
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
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heroMetric,
                  style: tt.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: tt.titleMedium?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
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

/// Hero stat card with gradient background (used on Insights screen)
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          Text(
            delta,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: AppColors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple horizontal bar with rounded corners.
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
