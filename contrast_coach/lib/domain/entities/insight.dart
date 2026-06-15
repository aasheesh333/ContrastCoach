enum InsightCategory {
  totalSessions,
  avgDuration,
  bestProtocol,
  sleepCorrelation,
  recoveryTrend,
  recommendations,
  streakMilestone,
}

class Insight {
  const Insight({
    required this.id,
    required this.category,
    required this.heroMetric,
    required this.title,
    required this.body,
    required this.periodStart,
    required this.periodEnd,
  });
  final String id;
  final InsightCategory category;
  final String heroMetric;
  final String title;
  final String body;
  final DateTime periodStart;
  final DateTime periodEnd;
}
