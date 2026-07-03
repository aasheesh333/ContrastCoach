import 'package:contrast_coach/domain/entities/achievement.dart';
import 'package:contrast_coach/domain/entities/session.dart';

const List<Achievement> _kAchievementCatalog = [
  Achievement(id: 'first_session', title: 'First Steps', emoji: '🌱',
      description: 'Logged your first session.'),
  Achievement(id: 'streak_7', title: 'Week Warrior', emoji: '🔥',
      description: '7-day streak of contrast sessions.'),
  Achievement(id: 'streak_30', title: 'Cold Consistency', emoji: '❄️',
      description: '30-day streak of contrast sessions.'),
  Achievement(id: 'sessions_50', title: 'Half Centurion', emoji: '🥈',
      description: 'Completed 50 sessions.'),
  Achievement(id: 'sessions_100', title: 'Triple Digits', emoji: '💯',
      description: 'Completed 100 sessions.'),
  Achievement(id: 'score_85', title: 'Recovery Pro', emoji: '🏆',
      description: 'Earned a recovery score of 85+.'),
];

/// Evaluate the full achievement catalog against the user's real sessions.
/// Pure Dart, no IO.
List<Achievement> evaluateAchievements(List<Session> sessions) {
  if (sessions.isEmpty) {
    return _kAchievementCatalog
        .map((a) => a.copyWith())
        .toList(growable: false);
  }

  final total = sessions.length;
  final streakDays = _streakDays(sessions);
  final bestScore = sessions
      .map((s) => s.recoveryScore)
      .whereType<double>()
      .fold<double>(0, (a, b) => a > b ? a : b);

  final now = DateTime.now();

  bool unlocked(String id) {
    switch (id) {
      case 'first_session':
        return total >= 1;
      case 'streak_7':
        return streakDays >= 7;
      case 'streak_30':
        return streakDays >= 30;
      case 'sessions_50':
        return total >= 50;
      case 'sessions_100':
        return total >= 100;
      case 'score_85':
        return bestScore >= 85;
      default:
        return false;
    }
  }

  return _kAchievementCatalog.map((base) {
    final earned = unlocked(base.id);
    return base.copyWith(unlockedAt: earned ? now : base.unlockedAt);
  }).toList(growable: false);
}

int _streakDays(List<Session> sessions) {
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
  return streak;
}
