import 'package:contrast_coach/core/feature_gating.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeatureGating', () {
    test('free tier can access only free protocols', () {
      expect(
        FeatureGating.canAccessProtocol('recovery_standard', SubscriptionTier.free),
        isTrue,
      );
      expect(
        FeatureGating.canAccessProtocol('sleep_evening', SubscriptionTier.free),
        isFalse,
      );
    });

    test('pro tier unlocks protocol and feature access', () {
      expect(
        FeatureGating.canAccessProtocol('sleep_evening', SubscriptionTier.proYearly),
        isTrue,
      );
      expect(FeatureGating.canUseInsights(SubscriptionTier.proYearly), isTrue);
      expect(FeatureGating.canUseCustomProtocols(SubscriptionTier.proYearly), isTrue);
      expect(FeatureGating.canUseVoiceControl(SubscriptionTier.proYearly), isTrue);
    });
  });
}
