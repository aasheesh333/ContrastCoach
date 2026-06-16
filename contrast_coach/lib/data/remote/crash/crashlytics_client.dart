import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsClient {
  static final CrashlyticsClient _instance = CrashlyticsClient._();
  factory CrashlyticsClient() => _instance;
  CrashlyticsClient._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      await FirebaseCrashlytics.instance.setUserIdentifier('');
      FlutterError.onError = (details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      _initialized = true;
    } catch (e) {
      debugPrint('Crashlytics init failed: $e');
    }
  }

  void recordError(
    dynamic error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    if (!_initialized) return;
    FirebaseCrashlytics.instance.recordError(error, stack, reason: reason, fatal: fatal);
  }

  void log(String message) {
    if (!_initialized) return;
    FirebaseCrashlytics.instance.log(message);
  }
}
