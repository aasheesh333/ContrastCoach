# ContrastCoach

Phone-first contrast therapy tracker (sauna + cold plunge). Privacy-first. Monochrome Material 3. Built with Flutter.

## What is this?

ContrastCoach helps you track heat + cold recovery sessions without putting a smartwatch in a 90°C sauna. Built for the 95% of contrast therapy users who don't want to damage their Apple Watch.

- 10 research-backed protocols
- Recovery score (0-100) with optional HRV/sleep correlation
- Voice control ("Hey Coach, next phase")
- Local-first privacy — your health data stays on your device
- Hardware-agnostic — works with any sauna, cold plunge, or shower
- Monochrome Material 3 Expressive design (Chrome/Amazon-tier restraint)

## Why this exists

Most contrast therapy apps either:
1. Require you to wear a watch in extreme heat (Apple warns against 35°C+)
2. Send your health data to their servers
3. Have cluttered, gamified UI

We do none of these.

## Tech stack (all free, open source)

- **Flutter 3.24+** — cross-platform
- **Riverpod 2.6** — state management
- **Drift** — local SQLite
- **Supabase** — auth + sync (replaces Firebase)
- **Health Connect** — health data (Pro)
- **RevenueCat** — subscription management
- **Sentry** — crash reporting
- **Umami** — privacy-first analytics (replaces Google Analytics)
- **GitHub Actions** — CI/CD

## Status

🚧 **Pre-development** — this is a fresh repo. Roadmap and architecture documented in [`CONTRASTCOACH_MASTER_PLAN.md`](./CONTRASTCOACH_MASTER_PLAN.md).

## Repository layout

```
ContrastCoach/
├── README.md
├── LICENSE (MIT)
├── CONTRASTCOACH_MASTER_PLAN.md  (full design + dev plan)
├── CONTRIBUTING.md
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── research_finding.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       ├── ci.yml
│       └── release.yml
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DESIGN_SYSTEM.md
│   ├── PRIVACY.md
│   ├── PLAY_STORE_COMPLIANCE.md
│   ├── RECOVERY_SCORE.md
│   └── PROTOCOLS.md
├── android/  (Flutter Android, generated)
├── ios/  (Flutter iOS, generated, v2)
├── lib/  (Flutter source, generated)
├── test/
├── assets/
│   ├── protocols.json
│   └── changelog.json
├── tools/
│   ├── supabase/
│   └── scripts/
└── .gitignore
```

## Roadmap (90 days)

- **Weeks 1-2:** Research, design, validation
- **Weeks 3-6:** Vibe-code MVP (8 screens, 3 free protocols, session lifecycle)
- **Weeks 7-9:** Pro features (Health Connect, voice control, full recovery score)
- **Weeks 10-11:** Polish, compliance, pre-launch testing
- **Week 12+:** Launch on Play Store

See [`CONTRASTCOACH_MASTER_PLAN.md`](./CONTRASTCOACH_MASTER_PLAN.md) for the full plan.

## Contributing

This is currently a solo project. Contributions welcome after MVP launch. See [`CONTRIBUTING.md`](./CONTRIBUTING.md) (to be added).

## License

MIT — see [`LICENSE`](./LICENSE).

## Disclaimer

This app is for informational and educational purposes only. It is not a medical device. Consult a healthcare professional before starting any new recovery routine.
