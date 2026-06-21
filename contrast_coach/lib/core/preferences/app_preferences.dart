import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppPreferences {
  AppPreferences._();
  static const _onboardingKey = 'onboarding_complete';
  static const _analyticsEnabledKey = 'analytics_enabled';
  static const _voiceEnabledKey = 'voice_enabled';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _storage = FlutterSecureStorage();
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  // Cached values — set defaults, loaded from FSS on init()
  static bool _isOnboardingComplete = false;
  static bool _analyticsEnabled = true;
  static bool _voiceEnabled = true;
  static bool _notificationsEnabled = true;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _isOnboardingComplete = await _getBool(_onboardingKey, false);
    _analyticsEnabled = await _getBool(_analyticsEnabledKey, true);
    _voiceEnabled = await _getBool(_voiceEnabledKey, true);
    _notificationsEnabled = await _getBool(_notificationsEnabledKey, true);
    _initialized = true;
  }

  static bool get isInitialized => _initialized;

  static Future<bool> _getBool(String key, bool d) async {
    final v = await _storage.read(key: key);
    return v == null ? d : v == 'true';
  }

  static Future<void> _setBool(String key, bool v) async {
    await _storage.write(key: key, value: v.toString());
    if (key == _onboardingKey) _isOnboardingComplete = v;
    else if (key == _analyticsEnabledKey) _analyticsEnabled = v;
    else if (key == _voiceEnabledKey) _voiceEnabled = v;
    else if (key == _notificationsEnabledKey) _notificationsEnabled = v;
    changes.value++;
  }

  static bool get isOnboardingComplete => _isOnboardingComplete;
  static Future<void> setOnboardingComplete(bool v) async => _setBool(_onboardingKey, v);
  static bool get analyticsEnabled => _analyticsEnabled;
  static Future<void> setAnalyticsEnabled(bool v) async => _setBool(_analyticsEnabledKey, v);
  static bool get voiceEnabled => _voiceEnabled;
  static Future<void> setVoiceEnabled(bool v) async => _setBool(_voiceEnabledKey, v);
  static bool get notificationsEnabled => _notificationsEnabled;
  static Future<void> setNotificationsEnabled(bool v) async => _setBool(_notificationsEnabledKey, v);

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    _isOnboardingComplete = false;
    _analyticsEnabled = true;
    _voiceEnabled = true;
    _notificationsEnabled = true;
    changes.value++;
  }
}
