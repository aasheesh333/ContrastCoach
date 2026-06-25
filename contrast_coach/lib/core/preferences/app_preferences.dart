import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppPreferences {
  AppPreferences._();
  static const _onboardingKey = 'onboarding_complete';
  static const _analyticsEnabledKey = 'analytics_enabled';
  static const _voiceEnabledKey = 'voice_enabled';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _notifsStreakKey = 'notif_streak';
  static const _notifsTimingKey = 'notif_timing';
  static const _notifsInsightKey = 'notif_insight';
  static const _notifsSubscriptionKey = 'notif_subscription';
  static const _notifsHealthKey = 'notif_health';
  static const _storage = FlutterSecureStorage();
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static bool _isOnboardingComplete = false;
  static bool _analyticsEnabled = true;
  static bool _voiceEnabled = true;
  static bool _notificationsEnabled = true;
  static bool _notifsStreak = true;
  static bool _notifsTiming = true;
  static bool _notifsInsight = true;
  static bool _notifsSubscription = true;
  static bool _notifsHealth = true;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _isOnboardingComplete = await _getBoolSafe(_onboardingKey, false);
    _analyticsEnabled = await _getBoolSafe(_analyticsEnabledKey, true);
    _voiceEnabled = await _getBoolSafe(_voiceEnabledKey, true);
    _notificationsEnabled = await _getBoolSafe(_notificationsEnabledKey, true);
    _notifsStreak = await _getBoolSafe(_notifsStreakKey, true);
    _notifsTiming = await _getBoolSafe(_notifsTimingKey, true);
    _notifsInsight = await _getBoolSafe(_notifsInsightKey, true);
    _notifsSubscription = await _getBoolSafe(_notifsSubscriptionKey, true);
    _notifsHealth = await _getBoolSafe(_notifsHealthKey, true);
    _themeMode = await _getStrSafe(_themeModeKey, 'light');
    _initialized = true;
  }

  static Future<String> _getStr(String key, String d) async {
    final v = await _storage.read(key: key);
    return v ?? d;
  }

  static bool get isInitialized => _initialized;

  static Future<bool> _getBool(String key, bool d) async {
    final v = await _storage.read(key: key);
    return v == null ? d : v == 'true';
  }

  static Future<bool> _getBoolSafe(String key, bool d) async {
    try {
      return await _getBool(key, d);
    } catch (_) {
      return d;
    }
  }

  static Future<String> _getStrSafe(String key, String d) async {
    try {
      return await _getStr(key, d);
    } catch (_) {
      return d;
    }
  }

  static Future<bool> _setBool(String key, bool v) async {
    try {
      await _storage.write(key: key, value: v.toString());
    } catch (_) {
      return false;
    }
    if (key == _onboardingKey) _isOnboardingComplete = v;
    else if (key == _analyticsEnabledKey) _analyticsEnabled = v;
    else if (key == _voiceEnabledKey) _voiceEnabled = v;
    else if (key == _notificationsEnabledKey) _notificationsEnabled = v;
    else if (key == _notifsStreakKey) _notifsStreak = v;
    else if (key == _notifsTimingKey) _notifsTiming = v;
    else if (key == _notifsInsightKey) _notifsInsight = v;
    else if (key == _notifsSubscriptionKey) _notifsSubscription = v;
    else if (key == _notifsHealthKey) _notifsHealth = v;
    changes.value++;
    return true;
  }

  static bool get isOnboardingComplete => _isOnboardingComplete;
  static Future<bool> setOnboardingComplete(bool v) async => _setBool(_onboardingKey, v);
  static bool get analyticsEnabled => _analyticsEnabled;
  static Future<bool> setAnalyticsEnabled(bool v) async => _setBool(_analyticsEnabledKey, v);
  static bool get voiceEnabled => _voiceEnabled;
  static Future<bool> setVoiceEnabled(bool v) async => _setBool(_voiceEnabledKey, v);
  static bool get notificationsEnabled => _notificationsEnabled;
  static Future<bool> setNotificationsEnabled(bool v) async => _setBool(_notificationsEnabledKey, v);

  static bool get notifsStreak => _notifsStreak;
  static Future<bool> setNotifsStreak(bool v) async => _setBool(_notifsStreakKey, v);
  static bool get notifsTiming => _notifsTiming;
  static Future<bool> setNotifsTiming(bool v) async => _setBool(_notifsTimingKey, v);
  static bool get notifsInsight => _notifsInsight;
  static Future<bool> setNotifsInsight(bool v) async => _setBool(_notifsInsightKey, v);
  static bool get notifsSubscription => _notifsSubscription;
  static Future<bool> setNotifsSubscription(bool v) async => _setBool(_notifsSubscriptionKey, v);
  static bool get notifsHealth => _notifsHealth;
  static Future<bool> setNotifsHealth(bool v) async => _setBool(_notifsHealthKey, v);

  static const _themeModeKey = 'theme_mode';
  static String _themeMode = 'light';

  static String get themeMode => _themeMode;
  static ThemeMode get themeModeValue => switch (_themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
  static Future<bool> setThemeMode(String v) async => _setStrSafe(_themeModeKey, v);

  static Future<bool> _setStrSafe(String key, String v) async {
    try {
      await _storage.write(key: key, value: v);
    } catch (_) {
      return false;
    }
    if (key == _themeModeKey) _themeMode = v;
    changes.value++;
    return true;
  }

  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
    _isOnboardingComplete = false;
    _analyticsEnabled = true;
    _voiceEnabled = true;
    _notificationsEnabled = true;
    _notifsStreak = true;
    _notifsTiming = true;
    _notifsInsight = true;
    _notifsSubscription = true;
    _notifsHealth = true;
    _themeMode = 'light';
    changes.value++;
  }
}
