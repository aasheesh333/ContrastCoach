import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._();

  static const _onboardingKey = 'onboarding_complete';
  static const _analyticsEnabledKey = 'analytics_enabled';
  static const _voiceEnabledKey = 'voice_enabled';
  static const _notificationsEnabledKey = 'notifications_enabled';

  static SharedPreferences? _prefs;
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static bool get isInitialized => _prefs != null;

  static bool get isOnboardingComplete => _prefs?.getBool(_onboardingKey) ?? false;

  static Future<void> setOnboardingComplete(bool value) async {
    await init();
    await _prefs!.setBool(_onboardingKey, value);
    changes.value++;
  }

  static bool get analyticsEnabled => _prefs?.getBool(_analyticsEnabledKey) ?? true;

  static Future<void> setAnalyticsEnabled(bool value) async {
    await init();
    await _prefs!.setBool(_analyticsEnabledKey, value);
    changes.value++;
  }

  static bool get voiceEnabled => _prefs?.getBool(_voiceEnabledKey) ?? true;

  static Future<void> setVoiceEnabled(bool value) async {
    await init();
    await _prefs!.setBool(_voiceEnabledKey, value);
    changes.value++;
  }

  static bool get notificationsEnabled => _prefs?.getBool(_notificationsEnabledKey) ?? true;

  static Future<void> setNotificationsEnabled(bool value) async {
    await init();
    await _prefs!.setBool(_notificationsEnabledKey, value);
    changes.value++;
  }
}
