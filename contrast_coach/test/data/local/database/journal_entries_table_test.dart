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

  test('insert and read a journal entry', () async {
    final now = DateTime.now();
    await db.into(db.journalEntries).insert(
          JournalEntriesCompanion.insert(
            id: 'je1',
            createdAt: now,
            mood: 'recovered',
            note: 'Felt great after cold shower',
          ),
        );
    final all = await db.select(db.journalEntries).get();
    expect(all, hasLength(1));
    expect(all.first.id, 'je1');
    expect(all.first.mood, 'recovered');
    expect(all.first.note, 'Felt great after cold shower');
  });

  test('journal entry insert with nullable mood and note works', () async {
    final now = DateTime.now();
    await db.into(db.journalEntries).insert(
          JournalEntriesCompanion.insert(
            id: 'je2',
            createdAt: now,
          ),
        );
    final all = await db.select(db.journalEntries).get();
    expect(all, hasLength(1));
    expect(all.first.id, 'je2');
    expect(all.first.mood, isNull);
    expect(all.first.note, isNull);
  });

  test('schema version is 3', () async {
    expect(db.schemaVersion, 3);
  });
}
