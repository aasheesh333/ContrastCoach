import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/gradients.dart';
import 'package:contrast_coach/domain/entities/recovery_score.dart' as domain;
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:flutter/material.dart';

/// v4 recovery score card. Mockup `.score`:
///   - number 70 w800 heat→cold horizontal gradient text-clip
///   - band label 14 w800 ls.5 var(--ok) (#33C27F)
class RecoveryScoreCard extends StatelessWidget {
  const RecoveryScoreCard({super.key, required this.score});
  final domain.RecoveryScore score;

  String get _bandLabel => switch (score.band) {
        ScoreBand.low => 'LOW RECOVERY',
        ScoreBand.moderate => 'MODERATE RECOVERY',
        ScoreBand.strong => 'STRONG RECOVERY',
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppGradients.scoreText.createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            score.value.round().toString(),
            style: const TextStyle(
              fontFamily: AppTypography.displayFont,
              fontWeight: FontWeight.w800,
              fontSize: 70,
              color: AppColors.white,
              height: 1.0,
              letterSpacing: -1.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _bandLabel,
          style: const TextStyle(
            fontFamily: AppTypography.bodyFont,
            color: AppColors.ok,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
