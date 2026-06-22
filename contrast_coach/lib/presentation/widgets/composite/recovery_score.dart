import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/domain/entities/recovery_score.dart' as domain;
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:flutter/material.dart';

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
    return Column(
      children: [
        Text(
          score.value.round().toString(),
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w200,
            fontSize: 96,
            color: Theme.of(context).colorScheme.onSurface,
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
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: _bandColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          score.insight,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
