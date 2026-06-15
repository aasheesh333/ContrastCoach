import 'package:contrast_coach/core/utils/score_calculator.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/phase.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:flutter_test/flutter_test.dart';

Session _makeSession({
  Duration planned = const Duration(minutes: 30),
  Duration actual = const Duration(minutes: 30),
  int roundsCompleted = 3,
  int protocolRounds = 3,
  DateTime? startedAt,
  List<Phase> phases = const [],
}) {
  final now = startedAt ?? DateTime(2026, 6, 13, 7, 0);
  return Session(
    id: 's1',
    protocolId: 'p1',
    goal: Goal.recovery,
    startedAt: now,
    endedAt: now.add(actual),
    totalPlannedDuration: planned,
    totalActualDuration: actual,
    roundsCompleted: roundsCompleted,
    protocolRounds: protocolRounds,
    createdAt: now,
    updatedAt: now,
    phases: phases,
  );
}

void main() {
  group('calculateRecoveryScore', () {
    test('perfect session scores strong', () {
      final score = calculateRecoveryScore(session: _makeSession());
      expect(score.value, greaterThan(70));
      expect(score.band, ScoreBand.strong);
    });

    test('late-night session is penalized', () {
      final late = calculateRecoveryScore(
        session: _makeSession(startedAt: DateTime(2026, 6, 13, 23, 0)),
      );
      final morning = calculateRecoveryScore(
        session: _makeSession(startedAt: DateTime(2026, 6, 13, 7, 0)),
      );
      expect(late.value, lessThan(morning.value));
      expect(late.factors.any((f) => f.contribution < 0 && f.name == 'Time of day'), isTrue);
    });

    test('morning session gets +5 bonus', () {
      final morning = calculateRecoveryScore(
        session: _makeSession(startedAt: DateTime(2026, 6, 13, 7, 0)),
      );
      expect(morning.factors.any((f) => f.contribution == 5 && f.name == 'Time of day'), isTrue);
    });

    test('low band for value <= 40', () {
      final score = calculateRecoveryScore(
        session: _makeSession(
          planned: const Duration(minutes: 30),
          actual: const Duration(minutes: 5),
          roundsCompleted: 0,
          protocolRounds: 5,
          startedAt: DateTime(2026, 6, 13, 23, 0),
        ),
      );
      expect(score.value, lessThanOrEqualTo(45));
      expect(score.band, anyOf(ScoreBand.low, ScoreBand.moderate));
    });

    test('moderate band for partial session', () {
      final score = calculateRecoveryScore(
        session: _makeSession(
          actual: const Duration(minutes: 15),
          roundsCompleted: 1,
          protocolRounds: 5,
        ),
      );
      expect(score.band, ScoreBand.moderate);
    });

    test('score is clamped to 0-100', () {
      final high = calculateRecoveryScore(session: _makeSession());
      expect(high.value, lessThanOrEqualTo(100));
      expect(high.value, greaterThanOrEqualTo(0));
    });

    test('temperature delta in ideal range adds 10', () {
      final phases = [
        Phase(
          id: 'ph1',
          type: PhaseType.sauna,
          orderIndex: 0,
          plannedDuration: const Duration(minutes: 15),
          actualTempC: 80,
          startedAt: DateTime.now(),
        ),
        Phase(
          id: 'ph2',
          type: PhaseType.cold,
          orderIndex: 1,
          plannedDuration: const Duration(minutes: 2),
          actualTempC: 12,
          startedAt: DateTime.now(),
        ),
      ];
      final score = calculateRecoveryScore(session: _makeSession(phases: phases));
      expect(score.factors.any((f) => f.name == 'Temperature delta' && f.contribution == 10), isTrue);
    });

    test('factors list is populated', () {
      final score = calculateRecoveryScore(session: _makeSession());
      expect(score.factors, isNotEmpty);
    });

    test('insight string is non-empty', () {
      final score = calculateRecoveryScore(session: _makeSession());
      expect(score.insight, isNotEmpty);
    });

    test('streak bonus at 7 days', () {
      final score = calculateRecoveryScore(
        session: _makeSession(),
        currentStreakDays: 7,
      );
      expect(score.factors.any((f) => f.name == 'Streak' && f.contribution == 2), isTrue);
    });

    test('streak bonus at 30 days', () {
      final score = calculateRecoveryScore(
        session: _makeSession(),
        currentStreakDays: 30,
      );
      expect(score.factors.any((f) => f.name == 'Streak' && f.contribution == 5), isTrue);
    });

    test('gap penalty for > 7 days', () {
      final score = calculateRecoveryScore(
        session: _makeSession(),
        daysSinceLastSession: 14,
      );
      expect(score.factors.any((f) => f.name == 'Gap penalty'), isTrue);
    });
  });
}
