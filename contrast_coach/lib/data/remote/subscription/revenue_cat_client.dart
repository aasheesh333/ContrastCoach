import 'package:contrast_coach/core/env/env_config.dart';  
import 'package:contrast_coach/presentation/screens/home/firebase_auth_proxy.dart';  
import 'package:firebase_auth/firebase_auth.dart';  
import 'package:purchases_flutter/purchases_flutter.dart';  

class RevenueCatBootstrap {  
  static bool _initialized = false;  

  static bool get isConfigured {  
    if (_initialized) return true;  
    final apiKey = EnvConfig.revenuecatApiKey;  
    return apiKey != null && apiKey.isNotEmpty;  
  }  

  static Future<void> init() async {  
    if (_initialized) return;  

    final apiKey = EnvConfig.revenuecatApiKey;  
    if (apiKey == null || apiKey.isEmpty) {  
      throw MissingConfigurationException(  
        'RevenueCat API key is missing. '
        'Ensure REVENUECAT_API_KEY is set via --dart-define '
        'or a platform-specific key (REVENUECAT_API_KEY_ANDROID / REVENUECAT_API_KEY_IOS).',  
      );  
    }  

    // Allow offline/initialization to proceed even if Firebase Auth is not yet ready  
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
      // Firebase Auth not yet initialized, proceed with anonymous RevenueCat ID  
    }  

    final config = PurchasesConfiguration(apiKey);  
    if (appUserID != null && appUserID.isNotEmpty) {  
      config.appUserID = appUserID;  
    }  
    await Purchases.configure(config);  
    _initialized = true;  
  }  

  static void reset() {  
    _initialized = false;  
  }  
}  

class MissingConfigurationException implements Exception {  
  final String message;  
  MissingConfigurationException(this.message);  

  @override  
  String toString() => 'MissingConfigurationException: $message';  
}  
