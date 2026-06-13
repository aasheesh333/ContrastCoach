import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/phase.dart';

class Session {
  const Session({
    required this.id,
    this.userId,
    required this.protocolId,
    required this.goal,
    required this.startedAt,
    this.endedAt,
    required this.totalPlannedDuration,
    required this.totalActualDuration,
    required this.roundsCompleted,
    required this.protocolRounds,
    this.recoveryScore,
    this.notes,
    this.healthDataSnapshot,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
    this.phases = const [],
  });

  final String id;
  final String? userId;
  final String protocolId;
  final Goal goal;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Duration totalPlannedDuration;
  final Duration totalActualDuration;
  final int roundsCompleted;
  final int protocolRounds;
  final double? recoveryScore;
  final String? notes;
  final Map<String, dynamic>? healthDataSnapshot;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Phase> phases;

  bool get isComplete => endedAt != null;
}
