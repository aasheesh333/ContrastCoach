import 'package:drift/drift.dart';

@DataClassName('HealthSnapshotRow')
class HealthSnapshots extends Table {
  TextColumn get id => text()();
  DateTimeColumn get capturedAt => dateTime()();
  IntColumn get sleepMinutes => integer().nullable()();
  RealColumn get hrvRmssd7DayAvg => real().nullable()();
  RealColumn get hrvRmssdTrend7Day => real().nullable()();
  RealColumn get restingHr7DayAvg => real().nullable()();
  RealColumn get restingHrTrend7Day => real().nullable()();
  IntColumn get stepsYesterday => integer().nullable()();
  DateTimeColumn get lastWorkoutAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
