/// HealthSnapshot entity — represents a point-in-time snapshot of health metrics
/// read from Health Connect. All fields are nullable because not every user
/// has every metric connected.
class HealthSnapshot {
  const HealthSnapshot({
    required this.capturedAt,
    this.lastNightSleepMinutes,
    this.hrvRmssd7DayAvg,
    this.hrvRmssdTrend7Day,
    this.restingHr7DayAvg,
    this.restingHrTrend7Day,
    this.stepsYesterday,
    this.lastWorkoutAt,
  });

  final DateTime capturedAt;
  final int? lastNightSleepMinutes;
  final double? hrvRmssd7DayAvg;
  final double? hrvRmssdTrend7Day;
  final double? restingHr7DayAvg;
  final double? restingHrTrend7Day;
  final int? stepsYesterday;
  final DateTime? lastWorkoutAt;
}
