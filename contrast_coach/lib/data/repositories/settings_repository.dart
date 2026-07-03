import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:drift/drift.dart';

const String kAccentColorKey = 'accent_color';
const String kThemeModeKey = 'theme_mode';

class SettingsRepository {
  SettingsRepository(this._db);
  final AppDatabase _db;

  Future<String?> read(String key) async {
    final result = await (_db.select(_db.settings)
          ..where((t) => t.keyField.equals(key)))
        .getSingleOrNull();
    return result?.value;
  }

  Future<void> write(String key, String value) async {
    final now = DateTime.now();
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            keyField: key,
            value: value,
            updatedAt: now,
          ),
        );
  }

  Future<String> readAccentColor({String defaultValue = '#FF6B35'}) async {
    final v = await read(kAccentColorKey);
    return v ?? defaultValue;
  }

  Future<String> readThemeMode({String defaultValue = 'system'}) async {
    final v = await read(kThemeModeKey);
    return v ?? defaultValue;
  }

  Future<void> writeAccentColor(String hex) => write(kAccentColorKey, hex);
  Future<void> writeThemeMode(String mode) => write(kThemeModeKey, mode);
}
