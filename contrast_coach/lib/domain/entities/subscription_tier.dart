enum SubscriptionTier { free, proMonthly, proYearly, lifetime }

extension SubscriptionTierLabel on SubscriptionTier {
  String get label => switch (this) {
        SubscriptionTier.free => 'Free',
        SubscriptionTier.proMonthly => 'Pro Monthly',
        SubscriptionTier.proYearly => 'Pro Yearly',
        SubscriptionTier.lifetime => 'Lifetime',
      };

  bool get isPro => this != SubscriptionTier.free;
}
