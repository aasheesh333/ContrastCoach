import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:flutter/material.dart';

/// v4 PRO lock badge. Matches the mockup `.lock` token:
///   position absolute top:11 right:11, font 10/w800, white text,
///   `linear-gradient(120deg,var(--heat),var(--coral))` bg, radius 7, padding 2/6.
///   Rendered atop protocol cards to mark Pro-only content.
class AppProLockBadge extends StatelessWidget {
  const AppProLockBadge({super.key, this.label = 'PRO'});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: AppGradients.btnPrimary,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTypography.bodyFont,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
          letterSpacing: 0.2,
          height: 1.1,
        ),
      ),
    );
  }
}
