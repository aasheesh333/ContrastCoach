/// v4-exact corner radii (runbook §2.3).
///
/// Distinct from the legacy [AppShapes] scale which pre-dates the v4 spec.
/// New surfaces should prefer [AppRadii]; existing widgets migrate opportunistically.
class AppRadii {
  const AppRadii._();

  /// Small controls (chips, small tiles).
  static const double small = 14;

  /// Default card / tile radius.
  static const double card = 20;

  /// Large hero surfaces (readiness card, paywall hero).
  static const double large = 26;

  /// Bottom sheet top corners (v4 sheets).
  static const double sheetTop = 28;
}
