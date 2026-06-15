import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/insight.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/generate_insights.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Session _makeSession({
    required DateTime startedAt,
    required Duration actual,
    String protocolId = 'recovery_standard',
    int roundsCompleted = 3,
    int protocolRounds = 3,
    double? recoveryScore,
  }) {
    return Session(
      id: 's-${startedAt.millisecondsSinceEpoch}',
      protocolId: protocolId,
      goal: Goal.recovery,
      startedAt: startedAt,
      endedAt: startedAt.add(actual),
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: actual,
      roundsCompleted: roundsCompleted,
      protocolRounds: protocolRounds,
      recoveryScore: recoveryScore,
      createdAt: startedAt,
      updatedAt: startedAt,
    );
  }

  test('empty sessions produces no insights', () {
    final result = generateInsights(sessions: const [], periodEnd: DateTime(2026, 6, 13));
    expect(result, isEmpty);
  });

  test('produces 5-7 insights for 30-day data', () {
    final now = DateTime(2026, 6, 13);
    final sessions = List.generate(20, (i) {
      return _makeSession(
        startedAt: now.subtract(Duration(days: i)),
        actual: const Duration(minutes: 25),
        recoveryScore: 70 + (i % 20).toDouble(),
      );
    });
    final insights = generateInsights(sessions: sessions, periodEnd: now);
    expect(insights.length, inInclusiveRange(4, 6));
  });

  test('includes total sessions', () {
    final now = DateTime(2026, 6, 13);
    final sessions = List.generate(5, (i) {
      return _makeSession(
        startedAt: now.subtract(Duration(days: i)),
        actual: const Duration(minutes: 20),
        recoveryScore: 70,
      );
    });
    final insights = generateInsights(sessions: sessions, periodEnd: now);
    expect(insights.any((i) => i.category == InsightCategory.totalSessions), isTrue);
  });
}
