import 'package:contrast_coach/data/local/database/tables/sessions_table.dart';
import 'package:drift/drift.dart';

@DataClassName('PhaseRow')
class Phases extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  IntColumn get orderIndex => integer()();
  IntColumn get plannedDurationSec => integer()();
  IntColumn get actualDurationSec => integer()();
  RealColumn get targetTempC => real().nullable()();
  RealColumn get actualTempC => real().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
  TextColumn get voiceLog => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
