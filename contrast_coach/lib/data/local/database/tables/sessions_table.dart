import 'package:drift/drift.dart';

@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get protocolId => text()();
  TextColumn get goal => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get totalPlannedDurationSec => integer()();
  IntColumn get totalActualDurationSec => integer()();
  IntColumn get roundsCompleted => integer()();
  IntColumn get protocolRounds => integer()();
  RealColumn get recoveryScore => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get healthDataSnapshot => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
