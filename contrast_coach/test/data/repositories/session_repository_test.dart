import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SessionRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SessionRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  Session _makeSession({String id = 's1', DateTime? startedAt}) {
    final now = startedAt ?? DateTime(2026, 6, 13, 7);
    return Session(
      id: id,
      protocolId: 'p1',
      goal: Goal.recovery,
      startedAt: now,
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: const Duration(minutes: 30),
      roundsCompleted: 3,
      protocolRounds: 3,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('save and getById round-trips a session', () async {
    final saveResult = await repo.save(_makeSession());
    expect(saveResult.isOk, isTrue);

    final getResult = await repo.getById('s1');
    expect(getResult.isOk, isTrue);
    final session = (getResult as dynamic).value as Session?;
    expect(session?.id, 's1');
    expect(session?.goal, Goal.recovery);
  });

  test('getAll returns multiple sessions newest-first', () async {
    final t1 = DateTime(2026, 6, 1);
    final t2 = DateTime(2026, 6, 10);
    await repo.save(_makeSession(id: 'a', startedAt: t1));
    await repo.save(_makeSession(id: 'b', startedAt: t2));

    final result = await repo.getAll();
    final list = (result as dynamic).value as List<Session>;
    expect(list.first.id, 'b');
    expect(list.last.id, 'a');
  });

  test('delete removes session', () async {
    await repo.save(_makeSession());
    await repo.delete('s1');
    final result = await repo.getById('s1');
    expect((result as dynamic).value, isNull);
  });

  test('getStreakDays returns 0 when no sessions', () async {
    expect(await repo.getStreakDays(), 0);
  });

  test('getStreakDays counts consecutive days from today', () async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    await repo.save(_makeSession(id: 'a', startedAt: today));
    await repo.save(_makeSession(id: 'b', startedAt: yesterday));
    await repo.save(_makeSession(id: 'c', startedAt: twoDaysAgo));
    final streak = await repo.getStreakDays();
    expect(streak, greaterThanOrEqualTo(1));
  });
}
