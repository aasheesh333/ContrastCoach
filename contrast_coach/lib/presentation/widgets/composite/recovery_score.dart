import 'package:contrast_coach/domain/entities/recovery_score.dart' as domain;
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:flutter/material.dart';
import 'package:contrast_coach/core/constants/app_colors.dart';

class RecoveryScoreCard extends StatelessWidget {
  const RecoveryScoreCard({super.key, required this.score});
  final domain.RecoveryScore score;

  String get _bandLabel => switch (score.band) {
        ScoreBand.low => 'LOW',
        ScoreBand.moderate => 'MODERATE',
        ScoreBand.strong => 'STRONG',
      };

  Color get _bandColor => switch (score.band) {
        ScoreBand.low => AppColors.error,
        ScoreBand.moderate => AppColors.brandWarm,
        ScoreBand.strong => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          score.value.round().toString(),
          style: tt.displayLarge?.copyWith(
            fontWeight: FontWeight.w200,
            fontSize: 96,
            height: 1.0,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 48,
          height: 2,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 12),
        Text(
          _bandLabel,
          style: tt.labelLarge?.copyWith(
            color: _bandColor,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          score.insight,
          style: tt.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
