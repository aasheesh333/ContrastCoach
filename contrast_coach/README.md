# ContrastCoach

A privacy-first contrast therapy (sauna + cold plunge) tracker. Built with Flutter 3.24+, Riverpod 2.6, Drift 2.20, Firebase Auth + Firestore, Health Connect, RevenueCat, and Sentry.

Monochrome Material 3 Expressive design. Offline-first. On-device health data processing.

## Features

- **10 built-in protocols** across 4 goals: Refresh, Focus, Sleep, Immunity
- **Recovery score (0-100)** with 8 factors: adherence, rounds, temperature delta, time of day, sleep, HRV, streak, gap penalty
- **Voice control** (10 commands, on-device speech recognition, manual fallback)
- **Health Connect** (HR, Resting HR, HRV, Sleep, Steps, Workouts read; MindfulSession write)
- **Streak calendar** (12 weeks, computed from Drift)
- **Monthly Insights** (5-7 deterministic insights per period)
- **Custom protocol builder** (Pro, 1 saved)
- **Cloud sync** (Firestore, last-write-wins)
- **JSON data export** (Settings → Export)
- **Account deletion** (local + cloud)
- **Subscription via RevenueCat** (Pro Monthly, Pro Yearly, Lifetime)

## Architecture

3-layer architecture:
- `lib/domain/` — pure Dart entities, repositories (abstract), use cases
- `lib/data/` — Drift database, Firebase, Health Connect, RevenueCat, repositories (concrete)
- `lib/presentation/` — Flutter widgets, screens, routing

## Running

```bash
flutter pub get
flutter pub run build_runner build
flutter test
flutter build apk --debug
```

## Configuration

Copy `.env.example` to `.env` and fill in:
- `REVENUECAT_API_KEY` — for Pro subscriptions
- `SENTRY_DSN` — for crash reporting
- Firebase config — for auth and sync

If keys are missing, the app gracefully degrades:
- No RevenueCat key → paywall shows static prices, no real purchase
- No Sentry DSN → no crash reporting
- No Firebase → sessions are local-only

## Disclaimer

This app is for informational and educational purposes only. It is not a medical device. Consult a healthcare professional before starting any new recovery routine.
