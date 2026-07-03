import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:drift/drift.dart';

typedef JournalEntry = JournalEntryRow;

class JournalRepositoryImpl {
  JournalRepositoryImpl(this._db);
  final AppDatabase _db;

  Future<Result<List<JournalEntry>, AppException>> getAll() async {
    try {
      final q = _db.select(_db.journalEntries)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
      final rows = await q.get();
      return Ok(rows);
    } catch (e) {
      return Err(DatabaseException('Failed to load journal entries', cause: e));
    }
  }

  Future<Result<JournalEntry, AppException>> insert({
    String? mood,
    String? note,
  }) async {
    try {
      final id = '${DateTime.now().millisecondsSinceEpoch}-${mood.hashCode.abs()}';
      final now = DateTime.now();
      final companion = JournalEntriesCompanion.insert(
        id: id,
        createdAt: now,
        mood: Value(mood),
        note: Value(note),
      );
      await _db.into(_db.journalEntries).insert(companion);
      final saved = await (_db.select(_db.journalEntries)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      return Ok(saved);
    } catch (e) {
      return Err(DatabaseException('Failed to insert journal entry', cause: e));
    }
  }

  Future<Result<void, AppException>> delete(String id) async {
    try {
      await (_db.delete(_db.journalEntries)..where((t) => t.id.equals(id))).go();
      return const Ok(null);
    } catch (e) {
      return Err(DatabaseException('Failed to delete journal entry', cause: e));
    }
  }
}
