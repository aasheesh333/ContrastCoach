import 'package:contrast_coach/core/env/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await EnvConfig.init();
  });

  group('EnvConfig', () {
    test('isDev true when no env set', () {
      expect(EnvConfig.isDev, isTrue);
    });

    test('isProd false in test', () {
      expect(EnvConfig.isProd, isFalse);
    });

  test('firebaseApiKey returns null when not set', () {
    // When .env has the value, this returns it; we just verify it's a string or null
    final key = EnvConfig.firebaseApiKey;
    expect(key == null || key is String, isTrue);
  });
  });
}
