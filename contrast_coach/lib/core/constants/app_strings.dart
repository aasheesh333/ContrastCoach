class AppStrings {
  const AppStrings._();

  static const String appName = 'ContrastCoach';
  static const String appTagline = 'Track heat. Track cold. See what works.';

  // Medical disclaimer (required in onboarding, settings, paywall, insights)
  static const String medicalDisclaimer =
      'This app is for informational and educational purposes only. '
      'It is not a medical device. Consult a healthcare professional '
      'before starting any new recovery routine.';

  // Onboarding
  static const String onboardingStep1Title = 'Track heat. Track cold. See what works.';
  static const String onboardingStep1Body =
      "Designed for the 95% of contrast therapy users who don't wear a watch into a 90C sauna.";
  static const String onboardingStep2Title = 'Built for your phone. Not your watch.';
  static const String onboardingStep2Body =
      'Apple warns against exposing watches above 35C. Voice commands work from inside the sauna.';
  static const String onboardingStep3Title = 'Your data stays on your device.';
  static const String onboardingStep3Body =
      "Health data is processed on-device. We don't see it. We don't store it. We don't sell it.";

  // Paywall
  static const String paywallMonthly = '\$5.99 / month';
  static const String paywallYearly = '\$39.99 / year';
  static const String paywallLifetime = '\$89.99 once';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection.';
}
