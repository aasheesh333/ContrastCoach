import 'package:contrast_coach/core/env/env_config.dart';
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatBootstrap {
  static bool _initialized = false;
  static String? _initError;

  static bool get isConfigured {
    if (_initialized) return true;
    if (_initError != null) return false;
    final apiKey = EnvConfig.revenuecatApiKey;
    return apiKey != null && apiKey.isNotEmpty;
  }

  static String? get initError => _initError;

  static Future<void> init() async {
    if (_initialized) return;

    final apiKey = EnvConfig.revenuecatApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      _initError = 'RevenueCat API key is missing. '
          'Ensure REVENUECAT_API_KEY is set via --dart-define '
          'or a platform-specific key.';
      throw MissingConfigurationException(_initError!);
    }

    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    }

    String? appUserID;
    try {
      final auth = FirebaseAuthNullableProxy.tryGet();
      if (auth != null) {
        final user = auth.currentUser;
        if (user != null) {
          appUserID = user.uid;
        }
      }
    } catch (_) {
    }

    final config = PurchasesConfiguration(apiKey);
    if (appUserID != null && appUserID.isNotEmpty) {
      config.appUserID = appUserID;
    }
    try {
      await Purchases.configure(config);
      _initialized = true;
    } catch (e) {
      _initError = 'RevenueCat configuration failed: $e';
      throw MissingConfigurationException(_initError!);
    }
  }

  static void reset() {
    _initialized = false;
    _initError = null;
  }
}

class MissingConfigurationException implements Exception {
  final String message;
  MissingConfigurationException(this.message);

  @override
  String toString() => 'MissingConfigurationException: $message';
}
