import 'package:contrast_coach/domain/entities/phase_type.dart';

class Phase {
  const Phase({
    required this.id,
    required this.type,
    required this.orderIndex,
    required this.plannedDuration,
    this.actualDuration,
    this.targetTempC,
    this.actualTempC,
    required this.startedAt,
    this.endedAt,
    this.skipped = false,
    this.voiceLog,
  });

  final String id;
  final PhaseType type;
  final int orderIndex;
  final Duration plannedDuration;
  final Duration? actualDuration;
  final double? targetTempC;
  final double? actualTempC;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool skipped;
  final String? voiceLog;
}
