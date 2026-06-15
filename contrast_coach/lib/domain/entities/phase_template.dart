import 'package:contrast_coach/domain/entities/phase_type.dart';

class PhaseTemplate {
  const PhaseTemplate({
    required this.type,
    required this.duration,
    this.targetTempC,
  });

  final PhaseType type;
  final Duration duration;
  final double? targetTempC;
}
