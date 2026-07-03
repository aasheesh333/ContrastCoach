import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/repositories/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SettingsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('readAccentColor returns default when no row exists', () async {
    expect(await repo.readAccentColor(), '#FF6B35');
  });

  test('writeAccentColor then readAccentColor round-trip', () async {
    await repo.writeAccentColor('#2D7CF1');
    expect(await repo.readAccentColor(), '#2D7CF1');
  });

  test('readThemeMode returns default system when no row exists', () async {
    expect(await repo.readThemeMode(), 'system');
  });

  test('writeThemeMode then readThemeMode round-trip', () async {
    await repo.writeThemeMode('dark');
    expect(await repo.readThemeMode(), 'dark');
  });

  test('writeAccentColor overwrites prior value (insertOnConflictUpdate)', () async {
    await repo.writeAccentColor('#2D7CF1');
    await repo.writeAccentColor('#FF6B35');
    expect(await repo.readAccentColor(), '#FF6B35');
  });

  test('read returns null for unknown key', () async {
    expect(await repo.read('nonexistent'), isNull);
  });
}
