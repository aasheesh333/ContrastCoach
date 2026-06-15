import 'package:contrast_coach/data/local/database/tables/sessions_table.dart';
import 'package:drift/drift.dart';

@DataClassName('StreakRow')
class Streaks extends Table {
  TextColumn get date => text()();
  TextColumn get sessionId => text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get count => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {date};
}
