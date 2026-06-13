import 'package:contrast_coach/domain/entities/recovery_score.dart' as domain;
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:flutter/material.dart';

class RecoveryScoreCard extends StatelessWidget {
  const RecoveryScoreCard({super.key, required this.score});
  final domain.RecoveryScore score;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          score.value.round().toString(),
          style: tt.displayLarge?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 4),
        Text(score.band.label.toUpperCase(), style: tt.labelLarge),
        const SizedBox(height: 16),
        Text(score.insight, style: tt.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}
