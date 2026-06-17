import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';

/// Aggregated stats computed from real session data.
/// All numbers here are derived — no placeholders.
class SessionStats {
  const SessionStats({
    required this.totalSessions,
    required this.streakDays,
    required this.avgDurationMin,
    required this.lastScore,
    required this.bestScore,
    required this.totalMinutes,
    required this.morningCount,
    required this.afternoonCount,
    required this.eveningCount,
    required this.lastSession,
    required this.thisWeekCount,
    required this.lastWeekCount,
  });

  final int totalSessions;
  final int streakDays;
  final int avgDurationMin;
  final double? lastScore;
  final double? bestScore;
  final int totalMinutes;
  final int morningCount; // 5-11
  final int afternoonCount; // 12-17
  final int eveningCount; // 18-4
  final Session? lastSession;
  final int thisWeekCount;
  final int lastWeekCount;

  bool get isEmpty => totalSessions == 0;

  /// Sessions by goal in the past `period`.
  Map<Goal, int> goalDistribution(List<Session> sessions, Duration period) {
    final cutoff = DateTime.now().subtract(period);
    final inPeriod = sessions.where((s) => s.startedAt.isAfter(cutoff)).toList();
    final dist = <Goal, int>{};
    for (final s in inPeriod) {
      dist[s.goal] = (dist[s.goal] ?? 0) + 1;
    }
    return dist;
  }

  /// Time-of-day distribution (morning/afternoon/evening) as fractions [0,1].
  ({double morning, double afternoon, double evening}) timeOfDayFractions() {
    final total = morningCount + afternoonCount + eveningCount;
    if (total == 0) return (morning: 0, afternoon: 0, evening: 0);
    return (
      morning: morningCount / total,
      afternoon: afternoonCount / total,
      evening: eveningCount / total,
    );
  }

  /// Week-over-week delta in sessions.
  int get weekDelta => thisWeekCount - lastWeekCount;
}

SessionStats computeSessionStats(List<Session> sessions) {
  if (sessions.isEmpty) {
    return const SessionStats(
      totalSessions: 0,
      streakDays: 0,
      avgDurationMin: 0,
      lastScore: null,
      bestScore: null,
      totalMinutes: 0,
      morningCount: 0,
      afternoonCount: 0,
      eveningCount: 0,
      lastSession: null,
      thisWeekCount: 0,
      lastWeekCount: 0,
    );
  }

  final total = sessions.length;
  final totalSec = sessions.fold<int>(0, (a, s) => a + s.totalActualDuration.inSeconds);
  final avgMin = (totalSec / total / 60).round();
  final lastScore = sessions.first.recoveryScore;
  final scores = sessions
      .map((s) => s.recoveryScore)
      .whereType<double>()
      .toList(growable: false);
  final bestScore = scores.isEmpty ? null : (scores..sort()).last;

  // Streak
  final days = sessions
      .map((s) => DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day))
      .toSet();
  var streak = 0;
  var cursor = DateTime.now();
  cursor = DateTime(cursor.year, cursor.month, cursor.day);
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  // Time of day buckets
  var morning = 0, afternoon = 0, evening = 0;
  for (final s in sessions) {
    final h = s.startedAt.hour;
    if (h >= 5 && h < 12) {
      morning++;
    } else if (h >= 12 && h < 18) {
      afternoon++;
    } else {
      evening++;
    }
  }

  // Week comparison
  final now = DateTime.now();
  final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
  final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
  final thisWeek = sessions.where((s) => s.startedAt.isAfter(startOfThisWeek)).length;
  final lastWeek = sessions
      .where((s) =>
          s.startedAt.isAfter(startOfLastWeek) &&
          s.startedAt.isBefore(startOfThisWeek))
      .length;

  return SessionStats(
    totalSessions: total,
    streakDays: streak,
    avgDurationMin: avgMin,
    lastScore: lastScore,
    bestScore: bestScore,
    totalMinutes: (totalSec / 60).round(),
    morningCount: morning,
    afternoonCount: afternoon,
    eveningCount: evening,
    lastSession: sessions.first,
    thisWeekCount: thisWeek,
    lastWeekCount: lastWeek,
  );
}
