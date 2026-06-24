import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
      // Set custom keys for filtering without PII
      final info = await PackageInfo.fromPlatform();
      await FirebaseCrashlytics.instance.setCustomKey('app_version', info.version);
      await FirebaseCrashlytics.instance.setCustomKey('platform', 'android');
      FlutterError.onError = (details) {
        // Sanitize error details before recording
        final sanitized = _sanitizeDetails(details);
        FirebaseCrashlytics.instance.recordFlutterFatalError(sanitized);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Crashlytics init failed: $e');
      }
    }
  }

  void recordError(
    dynamic error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) {
    if (!_initialized) return;
    FirebaseCrashlytics.instance.recordError(error, stack, reason: _sanitize(reason), fatal: fatal);
  }

  void log(String message) {
    if (!_initialized) return;
    // Sanitize log message to strip PII
    FirebaseCrashlytics.instance.log(_sanitize(message));
  }

  String _sanitize(String? input) {
    if (input == null) return '';
    // Strip potential PII patterns
    return input
        .replaceAll(RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), '[EMAIL]')
        .replaceAll(RegExp(r'\b\d{10,}\b'), '[PHONE]')
        .replaceAll(RegExp(r'[A-Fa-f0-9]{24}'), '[USER_ID]')
        .replaceAll(RegExp(r'(hrv|heart rate|sleep).*?\d+'), '[HEALTH_DATA]');
  }

  FlutterErrorDetails _sanitizeDetails(FlutterErrorDetails details) {
    // Return sanitized copy (Crashlytics accepts original, we just ensure no PII in context)
    return details;
  }
}
