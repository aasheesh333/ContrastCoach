import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/utils/score_calculator.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';

class EndSession {
  EndSession({
    required SessionRepository sessions,
    required int Function() streakProvider,
    int? lastNightSleepMinutes,
    double? hrvRmssdTrend7Day,
  })  : _sessions = sessions,
        _streakProvider = streakProvider,
        _lastNightSleepMinutes = lastNightSleepMinutes,
        _hrvRmssdTrend7Day = hrvRmssdTrend7Day;

  final SessionRepository _sessions;
  final int Function() _streakProvider;
  final int? _lastNightSleepMinutes;
  final double? _hrvRmssdTrend7Day;

  Future<Result<Session, AppException>> call({
    required String sessionId,
    required DateTime endedAt,
    required Duration totalActualDuration,
    required int roundsCompleted,
  }) async {
    final getResult = await _sessions.getById(sessionId);
    if (getResult is Err) {
      return Err((getResult as Err).error);
    }
    final existing = (getResult as Ok<Session?, AppException>).value;
    if (existing == null) {
      return Err(ValidationException('Session not found: $sessionId'));
    }

    final updated = Session(
      id: existing.id,
      userId: existing.userId,
      protocolId: existing.protocolId,
      goal: existing.goal,
      startedAt: existing.startedAt,
      endedAt: endedAt,
      totalPlannedDuration: existing.totalPlannedDuration,
      totalActualDuration: totalActualDuration,
      roundsCompleted: roundsCompleted,
      protocolRounds: existing.protocolRounds,
      notes: existing.notes,
      healthDataSnapshot: existing.healthDataSnapshot,
      isSynced: existing.isSynced,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      phases: existing.phases,
    );

    final streak = _streakProvider();
    final score = calculateRecoveryScore(
      session: updated,
      currentStreakDays: streak,
      lastNightSleepMinutes: _lastNightSleepMinutes,
      hrvRmssdTrend7Day: _hrvRmssdTrend7Day,
    );

    final finalSession = Session(
      id: updated.id,
      userId: updated.userId,
      protocolId: updated.protocolId,
      goal: updated.goal,
      startedAt: updated.startedAt,
      endedAt: updated.endedAt,
      totalPlannedDuration: updated.totalPlannedDuration,
      totalActualDuration: updated.totalActualDuration,
      roundsCompleted: updated.roundsCompleted,
      protocolRounds: updated.protocolRounds,
      recoveryScore: score.value,
      notes: updated.notes,
      healthDataSnapshot: updated.healthDataSnapshot,
      isSynced: updated.isSynced,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
      phases: updated.phases,
    );

    final saveResult = await _sessions.save(finalSession);
    return saveResult;
  }
}
