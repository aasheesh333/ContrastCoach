import 'package:contrast_coach/core/env/env_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatBootstrap {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    final apiKey = EnvConfig.revenuecatApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      return;
    }
    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);
    _initialized = true;
  }
}
