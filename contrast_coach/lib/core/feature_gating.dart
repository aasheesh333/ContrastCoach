import 'package:contrast_coach/domain/entities/subscription_tier.dart';

class FeatureGating {
  const FeatureGating._();

  static const Set<String> _freeProtocolIds = {
    'recovery_standard',
    'energy_morning',
    'cold_only_deep',
  };

  static bool canAccessProtocol(String protocolId, SubscriptionTier tier) {
    if (tier.isPro) return true;
    return _freeProtocolIds.contains(protocolId);
  }

  static bool canUseHealthConnect(SubscriptionTier tier) => tier.isPro;

  static bool canUseVoiceControl(SubscriptionTier tier) => tier.isPro;

  static bool canUseCloudSync(SubscriptionTier tier) => tier.isPro;

  static bool canUseInsights(SubscriptionTier tier) => tier.isPro;

  static bool canUseCustomProtocols(SubscriptionTier tier) => tier.isPro;

  static bool canUseFullStreakHistory(SubscriptionTier tier) => tier.isPro;

  static int freeStreakHistoryDays = 7;

  static bool canUseFullRecoveryScore(SubscriptionTier tier) => tier.isPro;

  static bool canUseCoach(SubscriptionTier tier) => tier.isPro;

  static bool canUseFullAchievementsHistory(SubscriptionTier tier) => tier.isPro;
}
