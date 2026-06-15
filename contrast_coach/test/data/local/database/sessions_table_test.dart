import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('insert and read a session', () async {
    final now = DateTime.now();
    final id = 's1';
    await db.into(db.sessions).insert(
          SessionsCompanion.insert(
            id: id,
            protocolId: 'recovery_standard',
            goal: 'recovery',
            startedAt: now,
            totalPlannedDurationSec: 1800,
            totalActualDurationSec: 1800,
            roundsCompleted: 3,
            protocolRounds: 3,
            createdAt: now,
            updatedAt: now,
          ),
        );
    final all = await db.select(db.sessions).get();
    expect(all, hasLength(1));
    expect(all.first.id, id);
    expect(all.first.protocolId, 'recovery_standard');
  });

  test('cascade delete phases when session deleted', () async {
    final now = DateTime.now();
    await db.into(db.sessions).insert(
          SessionsCompanion.insert(
            id: 's1',
            protocolId: 'p1',
            goal: 'recovery',
            startedAt: now,
            totalPlannedDurationSec: 100,
            totalActualDurationSec: 100,
            roundsCompleted: 1,
            protocolRounds: 1,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.into(db.phases).insert(
          PhasesCompanion.insert(
            id: 'ph1',
            sessionId: 's1',
            type: 'sauna',
            orderIndex: 0,
            plannedDurationSec: 60,
            actualDurationSec: 60,
            startedAt: now,
          ),
        );
    await (db.delete(db.sessions)..where((t) => t.id.equals('s1'))).go();
    final phases = await db.select(db.phases).get();
    expect(phases, isEmpty);
  });
}
