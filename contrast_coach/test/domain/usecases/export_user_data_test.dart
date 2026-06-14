import 'dart:convert';

import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/export_user_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('export produces valid JSON', () {
    final session = Session(
      id: 's1',
      protocolId: 'recovery_standard',
      goal: Goal.recovery,
      startedAt: DateTime(2026, 6, 13, 7),
      endedAt: DateTime(2026, 6, 13, 7, 30),
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: const Duration(minutes: 30),
      roundsCompleted: 3,
      protocolRounds: 3,
      recoveryScore: 78,
      createdAt: DateTime(2026, 6, 13, 7),
      updatedAt: DateTime(2026, 6, 13, 7, 30),
    );
    final json = exportUserDataAsJson(
      sessions: [session],
      exportedAt: DateTime(2026, 6, 13, 8),
    );
    final parsed = jsonDecode(json) as Map<String, dynamic>;
    expect(parsed['version'], 1);
    expect((parsed['sessions'] as List), hasLength(1));
    expect(
      (parsed['sessions'] as List).first['protocolId'],
      'recovery_standard',
    );
  });
}
