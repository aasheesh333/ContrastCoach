import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/recovery_score.dart';
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:contrast_coach/domain/entities/score_factor.dart';
import 'package:contrast_coach/domain/entities/session.dart';

RecoveryScore calculateRecoveryScore({
  required Session session,
  int currentStreakDays = 0,
  int daysSinceLastSession = 0,
  int? lastNightSleepMinutes,
  double? hrvRmssdTrend7Day,
}) {
  var score = 50.0;
  final factors = <ScoreFactor>[];

  // 1. Adherence
  final plannedSec = session.totalPlannedDuration.inSeconds;
  final actualSec = session.totalActualDuration.inSeconds;
  if (plannedSec > 0) {
    final adherence = (actualSec / plannedSec).clamp(0.0, 1.0);
    final adhBonus = adherence * 20;
    score += adhBonus;
    factors.add(ScoreFactor(
      name: 'Adherence',
      contribution: adhBonus,
      explanation: 'Completed ${(adherence * 100).round()}% of planned duration.',
    ));
  }

  // 2. Rounds
  if (session.protocolRounds > 0) {
    final roundsBonus =
        (session.roundsCompleted / session.protocolRounds).clamp(0.0, 1.0) * 10;
    score += roundsBonus;
    factors.add(ScoreFactor(
      name: 'Rounds',
      contribution: roundsBonus,
      explanation: '${session.roundsCompleted} of ${session.protocolRounds} rounds completed.',
    ));
  }

  // 3. Temperature delta
  final saunaTemps = session.phases
      .where((p) => p.type == PhaseType.sauna && p.actualTempC != null)
      .map((p) => p.actualTempC!)
      .toList();
  final coldTemps = session.phases
      .where((p) => p.type == PhaseType.cold && p.actualTempC != null)
      .map((p) => p.actualTempC!)
      .toList();
  if (saunaTemps.isNotEmpty && coldTemps.isNotEmpty) {
    final heatAvg = saunaTemps.reduce((a, b) => a + b) / saunaTemps.length;
    final coldAvg = coldTemps.reduce((a, b) => a + b) / coldTemps.length;
    final delta = heatAvg - coldAvg;
    if (delta >= 50 && delta <= 80) {
      score += 10;
      factors.add(const ScoreFactor(
        name: 'Temperature delta',
        contribution: 10,
        explanation: '50-80C contrast (ideal range).',
      ));
    } else if (delta >= 30) {
      score += 5;
      factors.add(const ScoreFactor(
        name: 'Temperature delta',
        contribution: 5,
        explanation: 'Moderate contrast (30-50C).',
      ));
    }
  }

  // 4. Time of day
  final hour = session.startedAt.hour;
  if (hour >= 5 && hour <= 9) {
    score += 5;
    factors.add(const ScoreFactor(
      name: 'Time of day',
      contribution: 5,
      explanation: 'Morning session (5-9am).',
    ));
  } else if (hour >= 14 && hour <= 17) {
    score += 3;
  } else if (hour >= 21 || hour <= 4) {
    score -= 10;
    factors.add(const ScoreFactor(
      name: 'Time of day',
      contribution: -10,
      explanation: 'Late night (9pm-4am).',
    ));
  }

  // 5. Sleep
  if (lastNightSleepMinutes != null) {
    final sleepHours = lastNightSleepMinutes / 60.0;
    if (sleepHours >= 8) {
      score += 8;
      factors.add(ScoreFactor(
        name: 'Sleep',
        contribution: 8,
        explanation: '${sleepHours.toStringAsFixed(1)} hours last night.',
      ));
    } else if (sleepHours >= 7.5) {
      score += 5;
    } else if (sleepHours < 6) {
      score -= 10;
      factors.add(ScoreFactor(
        name: 'Sleep',
        contribution: -10,
        explanation: 'Only ${sleepHours.toStringAsFixed(1)} hours last night.',
      ));
    }
  }

  // 6. HRV trend
  if (hrvRmssdTrend7Day != null) {
    if (hrvRmssdTrend7Day > 0) {
      score += 5;
      factors.add(ScoreFactor(
        name: 'HRV trend',
        contribution: 5,
        explanation: '7-day HRV trend +${hrvRmssdTrend7Day.toStringAsFixed(0)}%.',
      ));
    } else if (hrvRmssdTrend7Day < 0) {
      score -= 5;
      factors.add(ScoreFactor(
        name: 'HRV trend',
        contribution: -5,
        explanation: '7-day HRV trend ${hrvRmssdTrend7Day.toStringAsFixed(0)}%.',
      ));
    }
  }

  // 7. Streak bonus
  if (currentStreakDays >= 30) {
    score += 5;
    factors.add(ScoreFactor(
      name: 'Streak',
      contribution: 5,
      explanation: '$currentStreakDays day streak.',
    ));
  } else if (currentStreakDays >= 7) {
    score += 2;
    factors.add(ScoreFactor(
      name: 'Streak',
      contribution: 2,
      explanation: '$currentStreakDays day streak.',
    ));
  }

  // 8. Gap penalty
  if (daysSinceLastSession > 7) {
    final weeks = ((daysSinceLastSession - 7) / 7).ceil();
    final penalty = weeks * 5;
    score -= penalty;
    factors.add(ScoreFactor(
      name: 'Gap penalty',
      contribution: -penalty.toDouble(),
      explanation: '$daysSinceLastSession days since last session.',
    ));
  }

  final clamped = score.clamp(0.0, 100.0).toDouble();
  final band = clamped <= 40
      ? ScoreBand.low
      : clamped <= 70
          ? ScoreBand.moderate
          : ScoreBand.strong;

  return RecoveryScore(
    value: clamped,
    band: band,
    insight: _scoreToInsight(clamped, band, factors),
    factors: factors,
  );
}

String _scoreToInsight(double value, ScoreBand band, List<ScoreFactor> factors) {
  final positiveFactors = factors.where((f) => f.contribution > 0).toList()
    ..sort((a, b) => b.contribution.compareTo(a.contribution));
  final topPositive = positiveFactors.isNotEmpty ? positiveFactors.first : null;
  if (topPositive == null) {
    return '${band.label} session. No standout positives.';
  }
  return '${band.label} session. ${topPositive.name}: ${topPositive.explanation}';
}
