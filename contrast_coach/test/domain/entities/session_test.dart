import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Session isComplete false when endedAt is null', () {
    final s = Session(
      id: '1',
      protocolId: 'p1',
      goal: Goal.recovery,
      startedAt: DateTime.now(),
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: const Duration(minutes: 30),
      roundsCompleted: 3,
      protocolRounds: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    expect(s.isComplete, isFalse);
  });

  test('Session isComplete true when endedAt set', () {
    final now = DateTime.now();
    final s = Session(
      id: '1',
      protocolId: 'p1',
      goal: Goal.recovery,
      startedAt: now,
      endedAt: now.add(const Duration(minutes: 30)),
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: const Duration(minutes: 30),
      roundsCompleted: 3,
      protocolRounds: 3,
      createdAt: now,
      updatedAt: now,
    );
    expect(s.isComplete, isTrue);
  });
}
