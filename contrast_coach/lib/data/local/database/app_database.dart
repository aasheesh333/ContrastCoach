import 'dart:io';

import 'package:contrast_coach/data/local/database/tables/custom_protocols_table.dart';
import 'package:contrast_coach/data/local/database/tables/health_snapshots_table.dart';
import 'package:contrast_coach/data/local/database/tables/phases_table.dart';
import 'package:contrast_coach/data/local/database/tables/sessions_table.dart';
import 'package:contrast_coach/data/local/database/tables/settings_table.dart';
import 'package:contrast_coach/data/local/database/tables/streaks_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Sessions, Phases, Streaks, Settings, HealthSnapshots, CustomProtocols])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String encryptionKey) : super(_openConnection(encryptionKey));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(sessions, sessions.healthDataSnapshot);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static LazyDatabase _openConnection(String key) {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'contrast_coach.db'));
      return NativeDatabase.createInBackground(
        file,
        setup: (raw) {
          raw.execute("PRAGMA key = '$key';");
          raw.execute('PRAGMA foreign_keys = ON;');
        },
      );
    });
  }
}
