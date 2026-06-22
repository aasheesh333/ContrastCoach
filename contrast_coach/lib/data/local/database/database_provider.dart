import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Singleton provider for [AppDatabase].
///
/// Previously every screen created its own [AppDatabase] instance via
/// `SqlcipherKeyProvider` + `AppDatabase(key)`, which leaked file handles
/// and caused potential lock contention on low-end devices.
///
/// Use [DatabaseProvider.instance] everywhere instead of constructing
/// `AppDatabase` directly.
class DatabaseProvider {
  DatabaseProvider._();
  static AppDatabase? _instance;

  /// Returns the shared [AppDatabase], creating it on first access.
  static Future<AppDatabase> instance() async {
    if (_instance != null) return _instance!;
    final keyProvider =
        SqlcipherKeyProvider(storage: const FlutterSecureStorage());
    final key = await keyProvider.getOrCreateKey();
    _instance = AppDatabase(key);
    return _instance!;
  }

  /// Closes and nulls the singleton (useful for tests / account deletion).
  static Future<void> dispose() async {
    final db = _instance;
    _instance = null;
    if (db != null) {
      await db.close();
    }
  }
}
