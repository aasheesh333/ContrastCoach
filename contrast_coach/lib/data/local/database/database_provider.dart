import 'dart:async';

import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Singleton provider for [AppDatabase].
///
/// Previously every screen created its own [AppDatabase] instance via
/// `SqlcipherKeyProvider` + `AppDatabase(key)`, which leaked file handles
/// and caused potential lock contention on low-end devices. Even the
/// "singleton" pattern at one point was racy: two concurrent
/// `instance()` calls could each see `_instance == null` and create
/// separate database instances before either assignment landed.
///
/// Use [DatabaseProvider.instance] everywhere instead of constructing
/// `AppDatabase` directly.
class DatabaseProvider {
  DatabaseProvider._();

  static Future<AppDatabase>? _inflight;
  static AppDatabase? _instance;

  /// Returns the shared [AppDatabase], creating it on first access.
  ///
  /// Concurrent callers share the same future, so only one database
  /// instance is ever opened.
  static Future<AppDatabase> instance() {
    final existing = _instance;
    if (existing != null) return Future.value(existing);
    return _inflight ??= _open();
  }

  static Future<AppDatabase> _open() async {
    try {
      final keyProvider =
          SqlcipherKeyProvider(storage: const FlutterSecureStorage());
      final key = await keyProvider.getOrCreateKey();
      final db = AppDatabase(key);
      _instance = db;
      return db;
    } finally {
      _inflight = null;
    }
  }

  /// Closes and nulls the singleton (useful for tests / account deletion).
  static Future<void> dispose() async {
    final db = _instance;
    _instance = null;
    if (db != null) {
      await db.close();
    }
  }

  /// Override the singleton with a test instance (injected in-memory DB).
  static void setTestInstance(AppDatabase db) {
    _instance = db;
  }
}
