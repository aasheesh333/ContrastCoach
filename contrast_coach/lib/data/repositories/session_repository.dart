import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/phase.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';
import 'package:drift/drift.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._db);
  final AppDatabase _db;

  @override
  Future<Result<Session, AppException>> save(Session session) async {
    try {
      await _db.into(_db.sessions).insertOnConflictUpdate(
            SessionsCompanion.insert(
              id: session.id,
              userId: Value(session.userId),
              protocolId: session.protocolId,
              goal: session.goal.name,
              startedAt: session.startedAt,
              endedAt: Value(session.endedAt),
              totalPlannedDurationSec: session.totalPlannedDuration.inSeconds,
              totalActualDurationSec: session.totalActualDuration.inSeconds,
              roundsCompleted: session.roundsCompleted,
              protocolRounds: session.protocolRounds,
              recoveryScore: Value(session.recoveryScore),
              notes: Value(session.notes),
              healthDataSnapshot: Value(session.healthDataSnapshot?.toString()),
              isSynced: Value(session.isSynced),
              isDeleted: const Value(false),
              createdAt: session.createdAt,
              updatedAt: session.updatedAt,
            ),
          );

      for (final phase in session.phases) {
        await _db.into(_db.phases).insertOnConflictUpdate(
              PhasesCompanion.insert(
                id: phase.id,
                sessionId: session.id,
                type: phase.type.name,
                orderIndex: phase.orderIndex,
                plannedDurationSec: phase.plannedDuration.inSeconds,
                actualDurationSec: phase.actualDuration?.inSeconds ?? phase.plannedDuration.inSeconds,
                targetTempC: Value(phase.targetTempC),
                actualTempC: Value(phase.actualTempC),
                startedAt: phase.startedAt,
                endedAt: Value(phase.endedAt),
                skipped: Value(phase.skipped),
                voiceLog: Value(phase.voiceLog),
              ),
            );
      }
      return Ok(session);
    } catch (e) {
      return Err(DatabaseException('Failed to save session', cause: e));
    }
  }

  @override
  Future<Result<Session?, AppException>> getById(String id) async {
    try {
      final row = await (_db.select(_db.sessions)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) return const Ok(null);
      return Ok(await _hydrate(row));
    } catch (e) {
      return Err(DatabaseException('Failed to read session', cause: e));
    }
  }

  @override
  Future<Result<List<Session>, AppException>> getAll({int? limit, DateTime? since}) async {
    try {
      final query = _db.select(_db.sessions)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
      if (limit != null) query.limit(limit);
      if (since != null) query.where((t) => t.startedAt.isBiggerOrEqualValue(since));
      final rows = await query.get();
      final sessions = <Session>[];
      for (final row in rows) {
        sessions.add(await _hydrate(row));
      }
      return Ok(sessions);
    } catch (e) {
      return Err(DatabaseException('Failed to read sessions', cause: e));
    }
  }

  @override
  Future<Result<void, AppException>> delete(String id) async {
    try {
      await (_db.delete(_db.sessions)..where((t) => t.id.equals(id))).go();
      return const Ok(null);
    } catch (e) {
      return Err(DatabaseException('Failed to delete session', cause: e));
    }
  }

  @override
  Stream<List<Session>> watchAll() {
    return _db.select(_db.sessions).watch().map((rows) {
      return rows.map((r) => _rowToSession(r, phases: const [])).toList();
    });
  }

  @override
  Future<int> getStreakDays() async {
    final all = await (_db.select(_db.sessions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    if (all.isEmpty) return 0;
    final daysWithSessions = all
        .map((r) => DateTime(r.startedAt.year, r.startedAt.month, r.startedAt.day))
        .toSet();
    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    while (daysWithSessions.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<Session> _hydrate(SessionRow row) async {
    final phaseRows = await (_db.select(_db.phases)
          ..where((t) => t.sessionId.equals(row.id))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
    final phases = phaseRows
        .map((p) => Phase(
              id: p.id,
              type: PhaseType.fromString(p.type),
              orderIndex: p.orderIndex,
              plannedDuration: Duration(seconds: p.plannedDurationSec),
              actualDuration: Duration(seconds: p.actualDurationSec),
              targetTempC: p.targetTempC,
              actualTempC: p.actualTempC,
              startedAt: p.startedAt,
              endedAt: p.endedAt,
              skipped: p.skipped,
              voiceLog: p.voiceLog,
            ))
        .toList();
    return _rowToSession(row, phases: phases);
  }

  Session _rowToSession(SessionRow row, {required List<Phase> phases}) {
    return Session(
      id: row.id,
      userId: row.userId,
      protocolId: row.protocolId,
      goal: Goal.fromString(row.goal),
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      totalPlannedDuration: Duration(seconds: row.totalPlannedDurationSec),
      totalActualDuration: Duration(seconds: row.totalActualDurationSec),
      roundsCompleted: row.roundsCompleted,
      protocolRounds: row.protocolRounds,
      recoveryScore: row.recoveryScore,
      notes: row.notes,
      healthDataSnapshot: null,
      isSynced: row.isSynced,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      phases: phases,
    );
  }
}
