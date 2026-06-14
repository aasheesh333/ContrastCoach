import 'dart:convert';

import 'package:contrast_coach/domain/entities/session.dart';

String exportUserDataAsJson({
  required List<Session> sessions,
  required DateTime exportedAt,
}) {
  final data = {
    'exportedAt': exportedAt.toIso8601String(),
    'version': 1,
    'sessions': sessions
        .map(
          (s) => {
            'id': s.id,
            'protocolId': s.protocolId,
            'goal': s.goal.name,
            'startedAt': s.startedAt.toIso8601String(),
            'endedAt': s.endedAt?.toIso8601String(),
            'totalPlannedDurationSec': s.totalPlannedDuration.inSeconds,
            'totalActualDurationSec': s.totalActualDuration.inSeconds,
            'roundsCompleted': s.roundsCompleted,
            'protocolRounds': s.protocolRounds,
            'recoveryScore': s.recoveryScore,
            'healthDataSnapshot': s.healthDataSnapshot,
            'phases': s.phases
                .map(
                  (p) => {
                    'type': p.type.name,
                    'orderIndex': p.orderIndex,
                    'plannedDurationSec': p.plannedDuration.inSeconds,
                    'actualDurationSec': p.actualDuration?.inSeconds,
                    'targetTempC': p.targetTempC,
                    'actualTempC': p.actualTempC,
                    'skipped': p.skipped,
                  },
                )
                .toList(),
          },
        )
        .toList(),
  };
  return const JsonEncoder.withIndent('  ').convert(data);
}
