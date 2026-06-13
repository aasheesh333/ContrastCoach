# Recovery Score Algorithm

The recovery score is a 0-100 number that quantifies session quality and its impact on recovery. Calculated on-device, no server required.

## Formula (v1)

```dart
double calculateRecoveryScore({
  required Session session,
  required HealthSnapshot health,
}) {
  double score = 50.0;

  // Adherence: +20 max
  final adherence = session.actualDurationSec / session.plannedDurationSec;
  score += min(20, adherence * 20);

  // Rounds completed: +10 max
  score += (session.roundsCompleted / session.protocolRounds) * 10;

  // Temperature delta: +10 max
  if (session.heatTemp != null && session.coldTemp != null) {
    final delta = session.heatTemp! - session.coldTemp!;
    if (delta >= 50 && delta <= 80) {
      score += 10;
    } else if (delta >= 30) {
      score += 5;
    }
  }

  // Time of day: -10 to +5
  final hour = session.startedAt.hour;
  if (hour >= 5 && hour <= 9) score += 5;
  if (hour >= 14 && hour <= 17) score += 3;
  if (hour >= 21 || hour <= 4) score -= 10;

  // Sleep correlation: -10 to +10
  if (health.lastNightSleepMinutes != null) {
    final sleepHours = health.lastNightSleepMinutes! / 60;
    if (sleepHours >= 7.5) score += 5;
    if (sleepHours >= 8) score += 3;
    if (sleepHours < 6) score -= 10;
  }

  // HRV trend: -5 to +5
  if (health.hrvTrend7Day != null) {
    if (health.hrvTrend7Day! > 0) score += 5;
    if (health.hrvTrend7Day! < 0) score -= 5;
  }

  // Streak bonus: +5 max
  if (session.currentStreakDays >= 7) score += 2;
  if (session.currentStreakDays >= 30) score += 3;

  // Gap penalty: -5 per week over 1 week
  if (session.daysSinceLastSession > 7) {
    score -= ((session.daysSinceLastSession - 7) / 7).ceil() * 5;
  }

  return score.clamp(0, 100).toDouble();
}
```

## Inputs explained

### 1. Adherence (% of planned duration completed)
- 100% completion = +20
- 50% completion = +10
- 0% = +0

### 2. Rounds completed
- All planned rounds = +10
- Half = +5
- Skipped rounds = no bonus

### 3. Temperature delta (Δ = hot - cold)
- 50-80°C Δ = +10 (ideal contrast)
- 30-50°C Δ = +5
- <30°C = no bonus

### 4. Time of day
- 5-9am (morning) = +5
- 2-5pm (afternoon) = +3
- 9pm-4am (late night) = -10

### 5. Sleep correlation (Pro)
- 8+ hours = +8
- 7.5-8 hours = +5
- <6 hours = -10

### 6. HRV trend (Pro)
- Improving 7-day trend = +5
- Declining 7-day trend = -5

### 7. Streak bonus
- 7+ day streak = +2
- 30+ day streak = +3 (total +5)

### 8. Gap penalty
- >7 days since last session = -5 per week over

## Output interpretation

| Score | Word | Meaning |
|---|---|---|
| 0-40 | Low | Session didn't meet protocol or recovery signals are off |
| 41-70 | Moderate | Solid session, room to improve |
| 71-100 | Strong | Excellent session, recovery signals positive |

**Never use color.** Only the word.

## Why this formula?

- **Deterministic** — same inputs always produce same output
- **Transparent** — user can mentally verify the math
- **On-device** — no server round-trip
- **Localizable** — works for any health data source
- **Forgiving** — partial sessions don't tank the score
- **Penalizes bad patterns** — late night, long gaps, missed sleep

## Future improvements (v2+)

- Weighted by user's training load (if Health Connect workout data available)
- Heart rate response curve (recovery within 60s post-cold)
- Subjective feel (1-5 stars after session)
- Cold tolerance adaptation (regular users can handle colder)
- Personalized baselines (user's own average instead of population)
