# ContrastCoach

Phone-first contrast therapy tracker (sauna + cold plunge). Privacy-first. Built with Flutter.

## What is this?

ContrastCoach helps you track heat + cold recovery sessions without putting a smartwatch in a 90°C sauna.

- 10 research-backed protocols
- Recovery score (0-100) with optional HRV/sleep correlation
- Voice control
- Local-first privacy — your health data stays on your device
- Pro tier with Health Connect integration, custom protocols, and advanced insights

## Tech stack

- **Flutter 3.24** — cross-platform
- **Riverpod 2.6** — state management
- **Drift** — local SQLite with SQLCipher encryption
- **Firebase** — auth, Firestore, crash reporting (Crashlytics), analytics
- **Health Connect** — health data (Pro)
- **RevenueCat** — subscription management
- **GitHub Actions** — CI/CD

## Status

Released on Google Play Store.

## Repository layout

```
ContrastCoach/
├── README.md
├── CONTRAST_COACH_PRODUCTION_PLAN.md
├── .github/workflows/
│   └── ci.yml
├── contrast_coach/
│   ├── android/
│   ├── ios/
│   ├── lib/
│   ├── test/
│   └── assets/
└── docs/
```

## License

MIT — see [`LICENSE`](./LICENSE).

## Disclaimer

This app is for informational and educational purposes only. It is not a medical device. Consult a healthcare professional before starting any new recovery routine.
