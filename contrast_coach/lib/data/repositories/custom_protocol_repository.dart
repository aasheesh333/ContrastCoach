import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/tables/custom_protocols_table.dart';
import 'package:drift/drift.dart';

class CustomProtocolRepository {
  CustomProtocolRepository(this._db);
  final AppDatabase _db;

  Future<Result<void, AppException>> save({
    required String id,
    required String name,
    required String description,
    required int rounds,
    required String phasesJson,
  }) async {
    try {
      final now = DateTime.now();
      await _db.into(_db.customProtocols).insertOnConflictUpdate(
            CustomProtocolsCompanion.insert(
              id: id,
              name: name,
              description: description,
              rounds: rounds,
              phasesJson: phasesJson,
              createdAt: now,
              updatedAt: now,
            ),
          );
      return const Ok(null);
    } catch (e) {
      return Err(DatabaseException('Failed to save custom protocol', cause: e));
    }
  }

  Future<Result<List<CustomProtocolRow>, AppException>> getAll() async {
    try {
      final rows = await _db.select(_db.customProtocols).get();
      return Ok(rows);
    } catch (e) {
      return Err(DatabaseException('Failed to read custom protocols', cause: e));
    }
  }
}
