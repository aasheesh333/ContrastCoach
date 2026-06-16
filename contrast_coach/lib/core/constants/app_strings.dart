class AppStrings {
  const AppStrings._();

  static const String appName = 'ContrastCoach';
  static const String appTagline = 'Track heat. Track cold. See what works.';

  // Medical disclaimer (required in onboarding, settings, paywall, insights)
  static const String medicalDisclaimer =
      'This app is for informational and educational purposes only. '
      'It is not a medical device. Consult a healthcare professional '
      'before starting any new recovery routine.';

  // Onboarding (3 steps)
  static const String onboardingStep1Title = 'HEAT.\nCOLD.\nREPEAT.';
  static const String onboardingStep1Body =
      'The science of contrast therapy, simplified.';
  static const String onboardingStep1Tagline = 'NO ACCOUNT • NO CLOUD • NO BS';
  static const String onboardingStep2Title =
      'Your sauna. Your plunge. Your data.';
  static const String onboardingStep2Body =
      'No wearable needed. Phone stays safe in your locker.';
  static const String onboardingStep3Title = 'Private by default.';
  static const String onboardingStep3Body =
      'Health data is processed on-device. We don\'t see it. We don\'t store it. We don\'t sell it.';

  // Paywall
  static const String paywallMonthly = '\$5.99 / month';
  static const String paywallYearly = '\$39.99 / year';
  static const String paywallLifetime = '\$89.99 lifetime';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection.';
}
