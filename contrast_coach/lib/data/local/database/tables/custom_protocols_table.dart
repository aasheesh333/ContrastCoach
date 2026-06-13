import 'package:drift/drift.dart';

@DataClassName('CustomProtocolRow')
class CustomProtocols extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get rounds => integer()();
  TextColumn get phasesJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
