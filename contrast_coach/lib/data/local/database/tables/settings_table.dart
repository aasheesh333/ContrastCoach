import 'package:drift/drift.dart';

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get keyField => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {keyField};
}
