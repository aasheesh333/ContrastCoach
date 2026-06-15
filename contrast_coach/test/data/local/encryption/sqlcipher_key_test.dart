import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final storageState = <String, String>{};

  setUp(() {
    storageState.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'read') {
        final key = call.arguments['key'] as String?;
        return key == null ? null : storageState[key];
      }
      if (call.method == 'write') {
        final key = call.arguments['key'] as String;
        final value = call.arguments['value'] as String?;
        if (value == null) {
          storageState.remove(key);
        } else {
          storageState[key] = value;
        }
        return null;
      }
      if (call.method == 'delete') {
        final key = call.arguments['key'] as String;
        storageState.remove(key);
        return null;
      }
      if (call.method == 'deleteAll') {
        storageState.clear();
        return null;
      }
      if (call.method == 'containsKey') {
        final key = call.arguments['key'] as String;
        return storageState.containsKey(key);
      }
      if (call.method == 'readAll') {
        return Map<String, String>.from(storageState);
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('SqlcipherKeyProvider', () {
    test('getOrCreateKey returns a key when storage is empty', () async {
      final storage = FlutterSecureStorage();
      final provider = SqlcipherKeyProvider(storage: storage);
      final key = await provider.getOrCreateKey();
      expect(key, isNotEmpty);
      expect(key.length, greaterThanOrEqualTo(40));
    });

    test('getOrCreateKey returns the same key on second call', () async {
      final storage = FlutterSecureStorage();
      final provider = SqlcipherKeyProvider(storage: storage);
      final k1 = await provider.getOrCreateKey();
      final k2 = await provider.getOrCreateKey();
      expect(k1, k2);
    });
  });
}
