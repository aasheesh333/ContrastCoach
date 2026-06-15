enum PhaseType {
  sauna,
  cold,
  rest,
  custom;

  static PhaseType fromString(String s) {
    return PhaseType.values.firstWhere(
      (e) => e.name == s,
      orElse: () => PhaseType.custom,
    );
  }
}
