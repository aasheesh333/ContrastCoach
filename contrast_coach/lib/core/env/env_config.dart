import 'package:contrast_coach/core/env/env_keys.dart';

class EnvConfig {
  const EnvConfig._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
  }

  static String? _read(String key) {
    final fromDefine = String.fromEnvironment(key, defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return null;
  }

  static String? get env {
    final v = _read(EnvKeys.env);
    if (v == null || v.isEmpty) return 'dev';
    return v;
  }

  static bool get isDev => env == 'dev' || env == null;
  static bool get isProd => env == 'prod';

  static String? get firebaseApiKey => _read(EnvKeys.firebaseApiKey);
  static String? get firebaseProjectId => _read(EnvKeys.firebaseProjectId);
  static String? get firebaseAppId => _read(EnvKeys.firebaseAppId);
  static String? get firebaseMessagingSenderId => _read(EnvKeys.firebaseMessagingSenderId);
  static String? get firebaseStorageBucket => _read(EnvKeys.firebaseStorageBucket);
  static String? get revenuecatApiKey => _read(EnvKeys.revenuecatApiKey);
}
