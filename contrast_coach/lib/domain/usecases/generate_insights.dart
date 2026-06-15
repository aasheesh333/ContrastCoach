import 'package:contrast_coach/domain/entities/insight.dart';
import 'package:contrast_coach/domain/entities/session.dart';

List<Insight> generateInsights({
  required List<Session> sessions,
  required DateTime periodEnd,
  Duration period = const Duration(days: 30),
}) {
  if (sessions.isEmpty) return const [];

  final periodStart = periodEnd.subtract(period);
  final inPeriod = sessions.where((s) => s.startedAt.isAfter(periodStart)).toList();
  if (inPeriod.isEmpty) return const [];

  final insights = <Insight>[];

  // 1. Total sessions
  insights.add(Insight(
    id: 'total-sessions',
    category: InsightCategory.totalSessions,
    heroMetric: inPeriod.length.toString(),
    title: 'Total sessions',
    body: 'You did ${inPeriod.length} sessions in the last ${period.inDays} days.',
    periodStart: periodStart,
    periodEnd: periodEnd,
  ));

  // 2. Avg duration
  final totalSec = inPeriod.fold<int>(0, (a, s) => a + s.totalActualDuration.inSeconds);
  final avgMin = (totalSec / inPeriod.length / 60).round();
  insights.add(Insight(
    id: 'avg-duration',
    category: InsightCategory.avgDuration,
    heroMetric: '${avgMin}m',
    title: 'Avg duration',
    body: 'Average session length over the period.',
    periodStart: periodStart,
    periodEnd: periodEnd,
  ));

  // 3. Best protocol
  final byProtocol = <String, List<Session>>{};
  for (final s in inPeriod) {
    byProtocol.putIfAbsent(s.protocolId, () => []).add(s);
  }
  String? bestProtocol;
  double bestScore = -1;
  byProtocol.forEach((id, list) {
    final scores = list.where((s) => s.recoveryScore != null).map((s) => s.recoveryScore!);
    if (scores.isEmpty) return;
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    if (avg > bestScore) {
      bestScore = avg;
      bestProtocol = id;
    }
  });
  if (bestProtocol != null) {
    insights.add(Insight(
      id: 'best-protocol',
      category: InsightCategory.bestProtocol,
      heroMetric: bestScore.round().toString(),
      title: 'Best protocol',
      body: '$bestProtocol averages $bestScore.',
      periodStart: periodStart,
      periodEnd: periodEnd,
    ));
  }

  // 4. Sleep correlation (uses healthDataSnapshot)
  final withSleep = inPeriod.where((s) => s.healthDataSnapshot?['sleepMinutes'] != null).toList();
  if (withSleep.isNotEmpty) {
    final avgSleep = withSleep
            .map((s) => (s.healthDataSnapshot!['sleepMinutes']! as num).toInt())
            .reduce((a, b) => a + b) /
        withSleep.length;
    insights.add(Insight(
      id: 'sleep-correlation',
      category: InsightCategory.sleepCorrelation,
      heroMetric: '${(avgSleep / 60).toStringAsFixed(1)}h',
      title: 'Sleep correlation',
      body: 'Average sleep on session days.',
      periodStart: periodStart,
      periodEnd: periodEnd,
    ));
  }

  // 5. Recovery trend
  final withScores = inPeriod.where((s) => s.recoveryScore != null).toList()
    ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  if (withScores.length >= 2) {
    final first = withScores.first.recoveryScore!;
    final last = withScores.last.recoveryScore!;
    final delta = last - first;
    insights.add(Insight(
      id: 'recovery-trend',
      category: InsightCategory.recoveryTrend,
      heroMetric: delta >= 0 ? '+${delta.round()}' : '${delta.round()}',
      title: 'Recovery trend',
      body: 'Score change from first to last session.',
      periodStart: periodStart,
      periodEnd: periodEnd,
    ));
  }

  return insights;
}
