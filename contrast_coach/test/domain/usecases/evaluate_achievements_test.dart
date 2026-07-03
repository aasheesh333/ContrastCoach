import 'package:contrast_coach/domain/entities/achievement.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/evaluate_achievements.dart';
import 'package:flutter_test/flutter_test.dart';

Session _session({required String id, required DateTime startedAt, double? recoveryScore}) {
  return Session(
    id: id,
    protocolId: 'recovery_standard',
    goal: Goal.recovery,
    startedAt: startedAt,
    totalPlannedDuration: const Duration(minutes: 15),
    totalActualDuration: const Duration(minutes: 15),
    roundsCompleted: 3,
    protocolRounds: 3,
    recoveryScore: recoveryScore,
    createdAt: startedAt,
    updatedAt: startedAt,
  );
}

void main() {
  test('returns the full catalog of 6 achievements when sessions is empty (all locked)', () {
    final out = evaluateAchievements(const []);
    expect(out, hasLength(6));
    expect(out.where((a) => a.isUnlocked), isEmpty);
  });

  test('one session today unlocks first_session only', () {
    final now = DateTime.now();
    final out = evaluateAchievements([_session(id: 's1', startedAt: now)]);
    final unlocked = out.where((a) => a.isUnlocked).map((a) => a.id).toSet();
    expect(unlocked, {'first_session'});
  });

  test('7 consecutive days unlocks first_session + streak_7', () {
    final today = DateTime.now();
    final sessions = [
      for (var i = 0; i < 7; i++)
        _session(id: 's$i', startedAt: today.subtract(Duration(days: i))),
    ];
    final out = evaluateAchievements(sessions);
    final unlocked = out.where((a) => a.isUnlocked).map((a) => a.id).toSet();
    expect(unlocked, containsAll(['first_session', 'streak_7']));
    expect(unlocked, isNot(contains('streak_30')));
  });

  test('recover score >= 85 unlocks score_85', () {
    final out = evaluateAchievements([
      _session(id: 's1', startedAt: DateTime.now(), recoveryScore: 88.0),
    ]);
    final unlocked = out.where((a) => a.isUnlocked).map((a) => a.id).toSet();
    expect(unlocked, contains('score_85'));
  });

  test('score_85 unlocks only with >= 85, not below', () {
    final out = evaluateAchievements([
      _session(id: 's1', startedAt: DateTime.now(), recoveryScore: 84.5),
    ]);
    final scoreAch = out.firstWhere((a) => a.id == 'score_85');
    expect(scoreAch.isUnlocked, isFalse);
  });

  test('catalog is deterministic and ordered', () {
    final out = evaluateAchievements(const []);
    expect(out.map((a) => a.id).toList(), [
      'first_session', 'streak_7', 'streak_30', 'sessions_50', 'sessions_100', 'score_85',
    ]);
  });

  test('sessions_50 unlocks when total >= 50', () {
    final today = DateTime.now();
    final sessions = [
      for (var i = 0; i < 50; i++)
        _session(id: 's$i', startedAt: today.subtract(Duration(days: i))),
    ];
    final out = evaluateAchievements(sessions);
    final unlocked = out.where((a) => a.isUnlocked).map((a) => a.id).toSet();
    expect(unlocked, containsAll(['first_session', 'sessions_50']));
  });
}
