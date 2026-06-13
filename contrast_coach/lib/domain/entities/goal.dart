enum Goal {
  recovery,
  energy,
  sleep,
  immunity;

  static Goal fromString(String s) {
    return Goal.values.firstWhere(
      (e) => e.name == s,
      orElse: () => Goal.recovery,
    );
  }
}
