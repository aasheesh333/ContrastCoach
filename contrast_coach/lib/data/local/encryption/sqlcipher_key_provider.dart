import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SqlcipherKeyProvider {
  const SqlcipherKeyProvider({required this.storage});
  final FlutterSecureStorage storage;

  static const String _keyName = 'drift_db_key_v1';

  Future<String> getOrCreateKey() async {
    final existing = await storage.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) return existing;
    final newKey = _generateRandomKey();
    await storage.write(key: _keyName, value: newKey);
    return newKey;
  }

  String _generateRandomKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
