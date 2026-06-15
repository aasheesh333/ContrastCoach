import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:contrast_coach/domain/entities/score_factor.dart';

class RecoveryScore {
  const RecoveryScore({
    required this.value,
    required this.band,
    required this.insight,
    required this.factors,
  });

  final double value;
  final ScoreBand band;
  final String insight;
  final List<ScoreFactor> factors;
}
