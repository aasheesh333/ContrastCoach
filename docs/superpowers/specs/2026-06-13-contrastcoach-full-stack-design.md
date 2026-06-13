# ContrastCoach — Full-Stack Implementation Design

**Status:** Draft for user review
**Date:** 2026-06-13
**Audience:** Solo dev building Flutter Android app, end-to-end v0.1 → v1.0
**Supersedes scope of:** `CONTRASTCOACH_MASTER_PLAN.md` (kept as marketing/operations reference)

---

## 0. Scope and constraints

### 0.1 In scope

- Complete Flutter Android app from `flutter create` to Play Store `internal testing` track ready to submit
- Versions: v0.1 (Foundation + voice), v0.5 (Health Connect + cloud sync + all 10 protocols), v1.0 (paywall + Insights + custom protocols + Play Store assets + submit)
- 8 screens: Onboarding, Home, Active Session, Summary, Streak Calendar, Insights, Settings, Paywall
- Auth + cloud sync + analytics + crash + subscription + voice + Health Connect — all wired with key-in-env pattern
- Full test suite (unit + widget + integration) for every user-visible flow
- CI (GitHub Actions), build flavors (dev/prod), Android signing config
- Play Store assets: 8 screenshots, feature graphic, app icon, store listing copy
- All Play Console content forms: Data Safety, Health Apps, AI disclosure (we don't need it)

### 0.2 Out of scope

- iOS (deferred to v2)
- Wear OS (deferred to v3)
- Hardware temperature sensor integration (manual entry only)
- LLM-generated insights (deterministic algorithm only)
- B2B (gyms, spas)
- Public marketing site beyond what Play Store needs
- Production app-store submission (we stop at "ready to submit internal testing")

### 0.3 Hard constraints

- **Free tools only** for code dependencies (paid Google Play account is a one-time $25 cost, paid separately)
- **No proprietary SDKs** that prevent future migration (Firebasetools chosen because of India availability, not because it's the only option)
- **Monochrome Material 3 Expressive** — no chromatic accents, ever
- **No medical claims** in copy; explicit disclaimers required
- **Health data stays on-device** for as much as possible (Health Connect raw values never go to Firestore, only computed metrics do)
- **App must work without Health Connect** — it's a Pro feature, not a core dependency
- **Voice is opt-in** — manual button fallback must work without `RECORD_AUDIO` permission

### 0.4 User-confirmed choices

| Question | Decision |
|---|---|
| First sub-project | Foundation + voice (A) |
| Voice in v0.1? | Yes, include voice |
| Health Connect in v0.1? | Defer to v0.5 |
| Build all the way to v1.0? | Yes, end-to-end |
| Supabase? | Replaced with Firebase (India availability) |
| Analytics? | Firebase Analytics, configured for privacy |
| State management | Riverpod 2.6 + drift_dev + freezed + go_router + very_good_analysis |
| Tests | Full integration tests for every flow |
| Toolchain setup in this session | Install and verify |

---

## 1. High-level architecture

### 1.1 Stack

| Layer | Tool | Why |
|---|---|---|
| Framework | Flutter 3.24+ stable, Dart 3.5+ | Cross-platform foundation |
| State | Riverpod 2.6 + `riverpod_annotation` + `riverpod_generator` | Type-safe, no BuildContext issues, testable |
| Local DB | Drift 2.20 + `sqlcipher_flutter_libs` | Type-safe SQL, encrypted at rest |
| Cache | Hive 2.2 | Settings, last-active session, computed aggregations |
| Routing | go_router 14+ | Declarative, deep-link ready |
| Auth | Firebase Auth | Email + Google sign-in |
| Cloud sync | Cloud Firestore | Offline-first, security rules |
| Analytics | Firebase Analytics | Configured for privacy (advertising-id disabled, no personalized ads) |
| Crash | Sentry (self-hostable, free tier 5K events) | Standard tooling |
| Subscriptions | RevenueCat + `purchases_flutter` | Required for Play Store subs |
| Health | `health` Flutter package | Health Connect READ for HR/HRV/sleep, WRITE for MindfulSession |
| Audio (cues) | `just_audio` | Session phase audio cues |
| Voice (commands) | `speech_to_text` (Google STT) | "Hey Coach" command surface |
| Notifications | `flutter_local_notifications` + `workmanager` | Reminders, scheduled jobs |
| HTTP | `dio` 5.6+ | Interceptors, retries |
| Code gen | `build_runner` + `freezed` + `json_serializable` | Standard |
| Lint | `very_good_analysis` 6+ | Strict |
| Testing | `flutter_test` + `mocktail` + `integration_test` + `patrol_cli` | Full coverage |
| CI/CD | GitHub Actions | Free for OSS, $4/mo for private if needed |
| Icons | `lucide_icons_flutter` | 1.5px stroke, monochrome |
| Fonts | Inter Tight + Inter + JetBrains Mono (self-hosted) | OFL, no Google Fonts runtime fetch |

**Cost at 0 → 2.5K MRR: $0** (Firebase Spark + RevenueCat free + Sentry free + Health Connect free)
**Cost at 2.5K MRR: $0** (still under all free tiers)
**Cost at 50K MRR: ~$200-500/mo** (Firebase Blaze pay-as-you-go, RevenueCat paid tier)

### 1.2 Three-layer architecture

```
PRESENTATION
  Flutter + Material 3 Expressive + Riverpod 2.6
  - Screens (StatelessWidget with ConsumerWidget)
  - Widgets (atomic + composite)
  - Providers (Riverpod Notifiers)

DOMAIN (pure Dart, no Flutter, no Firebase)
  - Entities (Session, Protocol, Phase, RecoveryScore, HealthSnapshot, User)
  - Value objects (Duration, Temperature, Score)
  - Use cases (StartSession, EndSession, CalculateScore, GenerateInsights, etc.)
  - Repository interfaces (no implementation details)

DATA
  - Local: Drift (SQLite, SQLCipher-encrypted) + Hive (key-value)
  - Remote: Firebase Auth + Cloud Firestore + Firebase Analytics
  - Health: Health Connect client (READ HR, HRV, sleep; WRITE MindfulSession)
  - Audio: just_audio (cues) + speech_to_text (commands)
  - Subscriptions: RevenueCat
  - Crash: Sentry
```

### 1.3 Milestone contents

**v0.1 — Foundation (Weeks 3-6 per master plan)**
- Flutter project scaffold, dev/prod flavors, signing config
- Monochrome Material 3 Expressive theme (light + dark)
- Atomic widget library (AppButton, AppCard, AppTextField, AppIcon, AppDivider, AppSwitch, AppSlider, AppChip)
- Composite widgets (StatCard, SessionTimer, StreakCalendar, ProtocolPicker, RecoveryScore, InsightBlock)
- Layout widgets (AppBar, BottomNav, SheetContainer)
- 3 free protocols implemented (recovery_standard, energy_morning, cold_only_deep) — chosen because they cover the heat-cold-rest pattern, the morning energy pattern, and the cold-only pattern. Matches the master plan's "Free: 3 protocols (Recovery, Energy, Cold Only)".
- Session state machine (idle → setup → active → paused → summary → syncing)
- Drift DB (sessions, phases, streaks, settings tables) + SQLCipher encryption
- Hive cache for last-active session + computed aggregations
- Recovery score v1 (no health data, session-only)
- 8 screens fully implemented, monochrome, dark + light
- Voice control (speech_to_text) with "Hey Coach" command surface + manual fallback
- Audio cues on phase transitions
- 3-day local notification streak reminder
- Unit tests (recovery score, protocol validator, time-of-day, session state machine)
- Widget tests (all atomic + composite components)
- Integration tests (full session flow, voice command flow, onboarding flow, theme switching, navigation)
- CI (analyze + format + test + build APK)

**v0.5 — Pro features (Weeks 7-9)**
- All 10 protocols (adds immunity_weekly, wim_hof_classic, deep_cold_training, sauna_focus, sleep_evening; gentle_beginner is also a v0.5 unlock)
- Firebase Auth: email/password + Google sign-in
- Cloud Firestore: sessions/phases sync, security rules
- Health Connect: READ HR, HRV, sleep, RHR, steps, exercise; WRITE MindfulSession
- Recovery score v2 (incorporates sleep + HRV trend + RHR trend)
- Streak calendar with 12-week history
- Firebase Analytics with privacy configuration (advertising-id off, no personalized ads)
- Sentry crash reporting (no PII)
- Data export (JSON) and data deletion (one-tap)

**v1.0 — Polish + Launch (Weeks 10-12)**
- RevenueCat integration (monthly $5.99, yearly $39.99, lifetime $89.99)
- Paywall screen with feature gating
- Free vs Pro feature gating
- Monthly Insights report (deterministic, no LLM)
- Custom protocol builder (Pro, 1 saved protocol)
- Custom protocol validation
- All Play Console content forms filled out
- 8 screenshots + feature graphic + app icon (designed in code, monochrome)
- App description (long + short)
- Privacy policy (generated, hosted on GitHub Pages)
- Medical disclaimer in onboarding + settings + paywall + Insights
- Internal testing track (20+ testers, 14 days)
- Crash-free rate target: >99.5%
- Performance: <3s cold start, <50MB APK size
- Ready to submit to internal testing (or closed testing if internal is already done)

### 1.4 Privacy rules

- **No raw health values to Firestore.** Only computed metrics (e.g., "HRV 7-day trend: +12%") go to cloud.
- **Drift DB encrypted at rest with SQLCipher.** Key in `flutter_secure_storage`.
- **No advertising ID.** Firebase Analytics configured to not collect advertising ID; no personalized ads; analytics treated as a telemetry tool, not an ads product.
- **Sentry: no PII.** `beforeSend` strips user, IP, and any tag with `health_data`.
- **Data Safety form matches actual behavior** — every line of code that touches data is audited.
- **Health Connect is opt-in.** App fully works without it.
- **Voice is opt-in.** App fully works without microphone permission.
- **All permissions have in-app rationale screens** that explain what's collected and why before the OS dialog.

---

## 2. Folder structure and key files

```
contrast_coach/
├── pubspec.yaml                    # Pinned versions, asset declarations
├── analysis_options.yaml           # very_good_analysis + custom rules
├── .gitignore                      # Already correct from repo root
├── android/                        # Flutter Android (generated, then customized)
│   ├── app/
│   │   ├── build.gradle            # signingConfigs, flavors, minSdk 26 (Health Connect)
│   │   ├── proguard-rules.pro      # Aggressive shrinking, R8
│   │   └── src/main/AndroidManifest.xml
│   ├── key.properties              # Signing config (gitignored, has example)
│   └── .env.example                # Template for environment variables
├── lib/
│   ├── main.dart                   # Entry point
│   ├── main_dev.dart               # Dev flavor entry
│   ├── main_prod.dart              # Prod flavor entry
│   ├── app.dart                    # Root MaterialApp.router
│   ├── bootstrap.dart              # Init sequence: Sentry → Firebase → Drift → Hive → runApp
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_shapes.dart
│   │   │   ├── app_motion.dart
│   │   │   ├── app_strings.dart
│   │   │   └── app_assets.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── light_theme.dart
│   │   │   └── dark_theme.dart
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── score_calculator.dart       # Pure Dart, fully unit tested
│   │   │   ├── protocol_validator.dart     # Pure Dart, fully unit tested
│   │   │   ├── protocol_engine.dart        # Pure Dart
│   │   │   ├── time_of_day.dart
│   │   │   ├── hrv_trend.dart              # Pure Dart
│   │   │   └── validators.dart
│   │   ├── errors/
│   │   │   ├── app_exception.dart
│   │   │   └── error_handler.dart
│   │   ├── extensions/
│   │   │   ├── context_extensions.dart
│   │   │   └── datetime_extensions.dart
│   │   └── env/
│   │       ├── env_config.dart             # Reads from --dart-define
│   │       └── env_keys.dart               # All env var name constants
│   ├── data/
│   │   ├── local/
│   │   │   ├── database/
│   │   │   │   ├── app_database.dart       # Drift @DriftDatabase
│   │   │   │   ├── tables/
│   │   │   │   │   ├── sessions_table.dart
│   │   │   │   │   ├── phases_table.dart
│   │   │   │   │   ├── streaks_table.dart
│   │   │   │   │   ├── settings_table.dart
│   │   │   │   │   ├── health_snapshots_table.dart
│   │   │   │   │   └── custom_protocols_table.dart
│   │   │   │   ├── daos/
│   │   │   │   │   ├── session_dao.dart
│   │   │   │   │   ├── stats_dao.dart
│   │   │   │   │   ├── settings_dao.dart
│   │   │   │   │   └── health_dao.dart
│   │   │   │   └── migrations.dart
│   │   │   ├── cache/
│   │   │   │   └── hive_cache.dart
│   │   │   ├── encryption/
│   │   │   │   └── sqlcipher_key_provider.dart
│   │   │   └── health/
│   │   │       └── health_connect_client.dart
│   │   ├── remote/
│   │   │   ├── firebase/
│   │   │   │   ├── firebase_app.dart
│   │   │   │   ├── auth_api.dart
│   │   │   │   ├── firestore_api.dart
│   │   │   │   ├── analytics_api.dart
│   │   │   │   └── security_rules/
│   │   │   │       ├── sessions.rules
│   │   │   │       ├── phases.rules
│   │   │   │       └── devices.rules
│   │   │   ├── subscription/
│   │   │   │   └── revenue_cat_client.dart
│   │   │   ├── crash/
│   │   │   │   └── sentry_client.dart
│   │   │   └── analytics_events.dart
│   │   ├── repositories/
│   │   │   ├── session_repository.dart
│   │   │   ├── auth_repository.dart
│   │   │   ├── health_repository.dart
│   │   │   ├── settings_repository.dart
│   │   │   ├── subscription_repository.dart
│   │   │   ├── protocol_repository.dart
│   │   │   └── analytics_repository.dart
│   │   └── models/
│   │       ├── session_model.dart
│   │       ├── phase_model.dart
│   │       ├── protocol_model.dart
│   │       ├── recovery_score_model.dart
│   │       ├── health_snapshot_model.dart
│   │       ├── user_model.dart
│   │       ├── streak_model.dart
│   │       └── custom_protocol_model.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── session.dart
│   │   │   ├── phase.dart
│   │   │   ├── phase_type.dart
│   │   │   ├── protocol.dart
│   │   │   ├── recovery_score.dart
│   │   │   ├── score_band.dart
│   │   │   ├── health_snapshot.dart
│   │   │   ├── user.dart
│   │   │   ├── subscription_tier.dart
│   │   │   ├── insight.dart
│   │   │   ├── voice_command.dart
│   │   │   └── goal.dart
│   │   ├── repositories/                   # Abstract interfaces only
│   │   │   ├── session_repository.dart
│   │   │   ├── auth_repository.dart
│   │   │   ├── health_repository.dart
│   │   │   ├── settings_repository.dart
│   │   │   ├── subscription_repository.dart
│   │   │   ├── protocol_repository.dart
│   │   │   └── analytics_repository.dart
│   │   ├── usecases/
│   │   │   ├── start_session.dart
│   │   │   ├── pause_session.dart
│   │   │   ├── resume_session.dart
│   │   │   ├── skip_phase.dart
│   │   │   ├── end_session.dart
│   │   │   ├── calculate_recovery_score.dart
│   │   │   ├── generate_insights.dart
│   │   │   ├── compute_streak.dart
│   │   │   ├── request_health_permissions.dart
│   │   │   ├── read_health_snapshot.dart
│   │   │   ├── write_mindful_session.dart
│   │   │   ├── export_user_data.dart
│   │   │   ├── delete_user_data.dart
│   │   │   ├── validate_custom_protocol.dart
│   │   │   └── parse_voice_command.dart
│   │   └── voice/
│   │       ├── command_parser.dart
│   │       └── command_vocabulary.dart
│   ├── presentation/
│   │   ├── routing/
│   │   │   ├── app_router.dart
│   │   │   └── route_names.dart
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   ├── session_provider.dart
│   │   │   ├── streak_provider.dart
│   │   │   ├── insights_provider.dart
│   │   │   ├── health_provider.dart
│   │   │   ├── settings_provider.dart
│   │   │   ├── subscription_provider.dart
│   │   │   ├── voice_provider.dart
│   │   │   └── analytics_provider.dart
│   │   ├── screens/
│   │   │   ├── onboarding/
│   │   │   │   ├── onboarding_screen.dart
│   │   │   │   ├── onboarding_step_1.dart
│   │   │   │   ├── onboarding_step_2.dart
│   │   │   │   ├── onboarding_step_3.dart
│   │   │   │   └── widgets/
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── hero_start_card.dart
│   │   │   │       ├── quick_stats_row.dart
│   │   │   │       └── recommended_protocol_card.dart
│   │   │   ├── session/
│   │   │   │   ├── active_session_screen.dart
│   │   │   │   ├── session_summary_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── phase_label.dart
│   │   │   │       ├── countdown_timer.dart
│   │   │   │       ├── progress_bar.dart
│   │   │   │       ├── voice_prompt_hint.dart
│   │   │   │       └── pause_button.dart
│   │   │   ├── streak/
│   │   │   │   ├── streak_calendar_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── week_row.dart
│   │   │   ├── insights/
│   │   │   │   ├── insights_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── insight_block.dart
│   │   │   │       └── medical_disclaimer.dart
│   │   │   ├── settings/
│   │   │   │   ├── settings_screen.dart
│   │   │   │   ├── health_connect_screen.dart
│   │   │   │   ├── privacy_screen.dart
│   │   │   │   ├── data_export_screen.dart
│   │   │   │   ├── delete_account_screen.dart
│   │   │   │   ├── about_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── paywall/
│   │   │   │   ├── paywall_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── feature_bullet.dart
│   │   │   │       ├── plan_option.dart
│   │   │   │       └── restore_purchases_link.dart
│   │   │   ├── auth/
│   │   │   │   ├── sign_in_screen.dart
│   │   │   │   ├── sign_up_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── health_rationale/
│   │   │   │   ├── health_permission_rationale_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── voice_rationale/
│   │   │   │   ├── voice_permission_rationale_screen.dart
│   │   │   │   └── widgets/
│   │   │   └── shell/
│   │   │       └── home_shell.dart        # BottomNav scaffold
│   │   ├── widgets/
│   │   │   ├── atomic/
│   │   │   │   ├── app_button.dart
│   │   │   │   ├── app_text_field.dart
│   │   │   │   ├── app_card.dart
│   │   │   │   ├── app_icon.dart
│   │   │   │   ├── app_divider.dart
│   │   │   │   ├── app_switch.dart
│   │   │   │   ├── app_slider.dart
│   │   │   │   └── app_chip.dart
│   │   │   ├── composite/
│   │   │   │   ├── stat_card.dart
│   │   │   │   ├── session_timer.dart
│   │   │   │   ├── streak_calendar.dart
│   │   │   │   ├── protocol_picker.dart
│   │   │   │   ├── recovery_score.dart
│   │   │   │   └── insight_block.dart
│   │   │   ├── layout/
│   │   │   │   ├── app_bar.dart
│   │   │   │   ├── bottom_nav.dart
│   │   │   │   └── sheet_container.dart
│   │   │   └── dialogs/
│   │   │       ├── medical_disclaimer_dialog.dart
│   │   │       └── confirm_dialog.dart
│   │   └── motion/
│   │       └── spring_transitions.dart
│   ├── l10n/
│   │   └── app_en.arb                     # English only for v1.0
│   └── generated/                        # build_runner output (gitignored)
├── assets/
│   ├── protocols.json                    # 10 protocols, v1 schema
│   ├── changelog.json
│   ├── fonts/
│   │   ├── InterTight-Variable.ttf
│   │   ├── Inter-Variable.ttf
│   │   └── JetBrainsMono-Regular.ttf
│   └── audio/
│       ├── phase_transition.ogg
│       ├── session_start.ogg
│       └── session_complete.ogg
├── test/
│   ├── core/
│   │   ├── utils/
│   │   │   ├── score_calculator_test.dart
│   │   │   ├── protocol_validator_test.dart
│   │   │   ├── protocol_engine_test.dart
│   │   │   ├── time_of_day_test.dart
│   │   │   └── hrv_trend_test.dart
│   │   └── domain/
│   │       ├── usecases/
│   │       │   ├── start_session_test.dart
│   │       │   ├── end_session_test.dart
│   │       │   ├── calculate_recovery_score_test.dart
│   │       │   ├── generate_insights_test.dart
│   │       │   └── parse_voice_command_test.dart
│   ├── data/
│   │   ├── repositories/
│   │   │   ├── session_repository_test.dart
│   │   │   ├── auth_repository_test.dart
│   │   │   ├── health_repository_test.dart
│   │   │   └── subscription_repository_test.dart
│   │   └── local/
│   │       └── drift/
│   │           ├── session_dao_test.dart
│   │           └── stats_dao_test.dart
│   ├── presentation/
│   │   ├── widgets/
│   │   │   ├── atomic/
│   │   │   │   ├── app_button_test.dart
│   │   │   │   ├── app_card_test.dart
│   │   │   │   ├── app_text_field_test.dart
│   │   │   │   ├── app_switch_test.dart
│   │   │   │   └── app_chip_test.dart
│   │   │   ├── composite/
│   │   │   │   ├── stat_card_test.dart
│   │   │   │   ├── session_timer_test.dart
│   │   │   │   ├── streak_calendar_test.dart
│   │   │   │   └── recovery_score_test.dart
│   │   │   └── layout/
│   │   │       └── bottom_nav_test.dart
│   │   └── providers/
│   │       ├── session_provider_test.dart
│   │       ├── streak_provider_test.dart
│   │       └── subscription_provider_test.dart
│   └── fixtures/
│       ├── protocols.json
│       └── sample_sessions.json
├── integration_test/
│   ├── app_lifecycle_test.dart           # Cold start, hot start, kill
│   ├── onboarding_test.dart              # 3 steps, no skip
│   ├── home_test.dart                    # Stats, recommended protocol, hero card
│   ├── active_session_test.dart          # Start, pause, resume, end, complete
│   ├── voice_session_test.dart           # "Hey Coach, next phase" works
│   ├── voice_rationale_test.dart         # Permission flow
│   ├── health_rationale_test.dart        # Health Connect permission flow
│   ├── summary_test.dart                 # Score, save, discard
│   ├── streak_calendar_test.dart         # 12-week grid, day tap
│   ├── insights_test.dart                # 5-7 sections, scroll
│   ├── settings_test.dart                # All rows, navigation
│   ├── privacy_test.dart                 # Export, delete
│   ├── paywall_test.dart                 # Plans, restore, purchase flow
│   ├── auth_test.dart                    # Email, Google, sign out
│   ├── theme_test.dart                   # Light/dark switch, dynamic color off
│   ├── navigation_test.dart              # Deep links, go_router
│   └── a11y_test.dart                    # TalkBack, 200% text scale, 48dp targets
├── tools/
│   ├── supabase/                         # Renamed to firebase/ in this design
│   │   └── firestore.rules
│   └── scripts/
│       ├── generate_screenshots.dart     # Integration-test-based screenshot capture
│       ├── verify_release_readiness.sh   # Pre-submit checklist runner
│       ├── run_integration_tests.sh
│       ├── decode_keystore.sh
│       └── bump_version.sh
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── research_finding.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       ├── ci.yml                        # PR: analyze, format, test, build
│       ├── release-internal.yml          # Tag push: build, upload to internal track
│       └── codeql.yml                    # Optional security scan
├── docs/
│   ├── superpowers/
│   │   └── specs/                        # Design docs
│   ├── ARCHITECTURE.md
│   ├── DESIGN_SYSTEM.md
│   ├── PRIVACY.md
│   ├── PLAY_STORE_COMPLIANCE.md
│   ├── RECOVERY_SCORE.md
│   └── FIREBASE_SETUP.md                 # New doc: how to wire up Firebase in India
├── PRIVACY_POLICY.md                     # Generated privacy policy, hosted on GitHub Pages
└── README.md
```

---

## 3. Domain layer (pure Dart, no Flutter imports allowed)

### 3.1 Entities

```dart
// lib/domain/entities/phase_type.dart
enum PhaseType { sauna, cold, rest, custom }

// lib/domain/entities/phase.dart
class Phase {
  final String id;
  final PhaseType type;
  final int orderIndex;
  final Duration plannedDuration;
  final Duration? actualDuration;
  final double? targetTempC;
  final double? actualTempC;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool skipped;
  final String? voiceLog;
}

// lib/domain/entities/session.dart
class Session {
  final String id;
  final String? userId;
  final String protocolId;
  final Goal goal;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Duration totalPlannedDuration;
  final Duration totalActualDuration;
  final int roundsCompleted;
  final int protocolRounds;
  final double? recoveryScore;
  final String? notes;
  final HealthDataSnapshot? healthDataSnapshot; // Computed metrics only
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Phase> phases;
}

// lib/domain/entities/recovery_score.dart
class RecoveryScore {
  final double value;            // 0-100
  final ScoreBand band;          // Low | Moderate | Strong
  final String insight;          // 1-2 sentence text
  final List<ScoreFactor> factors; // For explainability in Insights
}

enum ScoreBand { low, moderate, strong }

class ScoreFactor {
  final String name;             // e.g., "Adherence"
  final double contribution;     // Signed: e.g., +12.0
  final String explanation;      // e.g., "Completed 95% of planned duration"
}

// lib/domain/entities/health_snapshot.dart
class HealthSnapshot {
  final DateTime capturedAt;
  final int? lastNightSleepMinutes;
  final double? hrvRmssd7DayAvg;
  final double? hrvRmssdTrend7Day; // Signed % change
  final double? restingHr7DayAvg;
  final double? restingHrTrend7Day; // Signed % change
  final int? stepsYesterday;
  final DateTime? lastWorkoutAt;
}

// lib/domain/entities/protocol.dart
class Protocol {
  final String id;
  final String name;
  final String description;
  final ProtocolCategory category;
  final ProtocolDifficulty difficulty;
  final int rounds;
  final List<PhaseTemplate> phases;
  final List<PhaseTemplate> cooldown;
  final bool isPro;
  final bool isCustom;
}

enum ProtocolCategory { recovery, energy, sleep, immunity, custom }
enum ProtocolDifficulty { beginner, intermediate, advanced }

class PhaseTemplate {
  final PhaseType type;
  final Duration duration;
  final double? targetTempC;
}

// lib/domain/entities/goal.dart
enum Goal { recovery, energy, sleep, immunity }

// lib/domain/entities/user.dart
class User {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final bool onboardingCompleted;
  final Goal? goal;
  final SubscriptionTier subscriptionTier;
  final DateTime? subscriptionExpiresAt;
}

enum SubscriptionTier { free, proMonthly, proYearly, lifetime }

// lib/domain/entities/insight.dart
class Insight {
  final String id;
  final InsightCategory category;
  final String heroMetric;       // e.g., "23 min"
  final String title;            // e.g., "Sleep improved"
  final String body;             // 2-line explanation
  final DateTime periodStart;
  final DateTime periodEnd;
}

enum InsightCategory {
  totalSessions, avgDuration, bestProtocol, sleepCorrelation,
  recoveryTrend, recommendations, streakMilestone
}

// lib/domain/entities/voice_command.dart
enum VoiceCommandKind {
  start, next, skip, pause, resume, end,
  howLong, repeat, logCold, logHot, unknown
}

class VoiceCommand {
  final VoiceCommandKind kind;
  final double confidence;       // 0-1
  final String rawTranscript;
}
```

### 3.2 Recovery score formula

(Pinned from `docs/RECOVERY_SCORE.md`, with one addition: factor list for explainability)

```dart
RecoveryScore calculateRecoveryScore({
  required Session session,
  HealthSnapshot? health,
}) {
  var score = 50.0;
  final factors = <ScoreFactor>[];

  // Adherence: +20 max
  final adherence = session.totalActualDuration.inSeconds /
      session.totalPlannedDuration.inSeconds;
  final adhBonus = (adherence * 20).clamp(0, 20);
  score += adhBonus;
  factors.add(ScoreFactor('Adherence', adhBonus, '...'));

  // Rounds: +10 max
  final roundsBonus = (session.roundsCompleted / session.protocolRounds) * 10;
  score += roundsBonus;
  factors.add(ScoreFactor('Rounds', roundsBonus, '...'));

  // Temperature delta: +10 max
  final heatTemp = session.phases
      .where((p) => p.type == PhaseType.sauna && p.actualTempC != null)
      .map((p) => p.actualTempC!)
      .fold<double>(0, (a, b) => a + b) /
      max(1, session.phases.where((p) => p.type == PhaseType.sauna).length);
  final coldTemp = ...; // similar
  if (heatTemp > 0 && coldTemp > 0) {
    final delta = heatTemp - coldTemp;
    if (delta >= 50 && delta <= 80) {
      score += 10;
      factors.add(ScoreFactor('Temperature delta', 10, '50-80°C contrast (ideal)'));
    } else if (delta >= 30) {
      score += 5;
    }
  }

  // Time of day
  final hour = session.startedAt.hour;
  if (hour >= 5 && hour <= 9) {
    score += 5;
    factors.add(ScoreFactor('Time of day', 5, 'Morning (5-9am)'));
  } else if (hour >= 14 && hour <= 17) {
    score += 3;
  } else if (hour >= 21 || hour <= 4) {
    score -= 10;
    factors.add(ScoreFactor('Time of day', -10, 'Late night (9pm-4am)'));
  }

  // Sleep correlation (Pro)
  if (health?.lastNightSleepMinutes != null) {
    final sleepHours = health!.lastNightSleepMinutes! / 60;
    if (sleepHours >= 8) {
      score += 8;
      factors.add(ScoreFactor('Sleep', 8, '8+ hours last night'));
    } else if (sleepHours >= 7.5) {
      score += 5;
    } else if (sleepHours < 6) {
      score -= 10;
      factors.add(ScoreFactor('Sleep', -10, '<6 hours last night'));
    }
  }

  // HRV trend (Pro)
  if (health?.hrvRmssdTrend7Day != null) {
    if (health!.hrvRmssdTrend7Day! > 0) score += 5;
    if (health!.hrvRmssdTrend7Day! < 0) score -= 5;
  }

  // Streak bonus
  if (session.currentStreakDays >= 30) {
    score += 5;
    factors.add(ScoreFactor('Streak', 5, '30+ day streak'));
  } else if (session.currentStreakDays >= 7) {
    score += 2;
  }

  // Gap penalty
  if (session.daysSinceLastSession > 7) {
    final weeks = ((session.daysSinceLastSession - 7) / 7).ceil();
    score -= weeks * 5;
    factors.add(ScoreFactor('Gap penalty', -(weeks * 5), '$weeks week gap'));
  }

  final clamped = score.clamp(0, 100).toDouble();
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
```

The `factors` list powers the Insights screen's explainability ("Why did I get 78? Here's the math").

### 3.3 Protocol validation rules

```dart
class ProtocolValidationResult {
  final bool isValid;
  final List<String> errors;
}

ProtocolValidationResult validateProtocol(Protocol p) {
  final errors = <String>[];

  // Total duration ≤ 60 min
  final totalSec = p.phases.fold<int>(0, (a, b) => a + b.duration.inSeconds) *
      p.rounds;
  if (totalSec > 60 * 60) {
    errors.add('Total duration exceeds 60 minutes (safety limit).');
  }

  // Sauna max 30 min per phase
  for (final phase in p.phases) {
    if (phase.type == PhaseType.sauna && phase.duration.inMinutes > 30) {
      errors.add('Sauna phase exceeds 30 minutes (safety limit).');
    }
  }

  // Cold min 5°C, max 20°C
  for (final phase in p.phases) {
    if (phase.type == PhaseType.cold && phase.targetTempC != null) {
      if (phase.targetTempC! < 5) {
        errors.add('Cold temperature below 5°C (safety limit).');
      }
      if (phase.targetTempC! > 20) {
        errors.add('Cold temperature above 20°C — that\'s a cool shower, not a plunge.');
      }
    }
  }

  // Max 5 rounds
  if (p.rounds > 5) {
    errors.add('Cannot exceed 5 rounds per session.');
  }

  return ProtocolValidationResult(errors.isEmpty, errors);
}
```

### 3.4 Voice command parsing

```dart
// lib/domain/voice/command_parser.dart
VoiceCommand parseVoiceCommand(String transcript) {
  final t = transcript.toLowerCase().trim();

  if (t.contains('start') || t.contains('begin')) {
    return VoiceCommand(VoiceCommandKind.start, 0.9, transcript);
  }
  if (t.contains('next') || t.contains('skip')) {
    return VoiceCommand(VoiceCommandKind.next, 0.9, transcript);
  }
  if (t.contains('pause') || t.contains('wait')) {
    return VoiceCommand(VoiceCommandKind.pause, 0.9, transcript);
  }
  if (t.contains('resume') || t.contains('continue')) {
    return VoiceCommand(VoiceCommandKind.resume, 0.9, transcript);
  }
  if (t.contains('end') || t.contains('stop') || t.contains('finish')) {
    return VoiceCommand(VoiceCommandKind.end, 0.9, transcript);
  }
  if (t.contains('how long') || t.contains('time') || t.contains('how much')) {
    return VoiceCommand(VoiceCommandKind.howLong, 0.9, transcript);
  }
  if (t.contains('repeat')) {
    return VoiceCommand(VoiceCommandKind.repeat, 0.9, transcript);
  }
  if (t.contains('log cold') || t.contains('felt cold')) {
    return VoiceCommand(VoiceCommandKind.logCold, 0.9, transcript);
  }
  if (t.contains('log hot') || t.contains('felt hot')) {
    return VoiceCommand(VoiceCommandKind.logHot, 0.9, transcript);
  }

  return VoiceCommand(VoiceCommandKind.unknown, 0.0, transcript);
}
```

### 3.5 Use cases

All use cases are pure Dart, take repository interfaces as constructor args, return `Result<T, AppException>` style results. They never import Flutter or Firebase. This makes them fast to test and easy to swap.

```dart
// lib/domain/usecases/start_session.dart
class StartSession {
  final SessionRepository _sessions;
  final ProtocolRepository _protocols;
  final AnalyticsRepository _analytics;
  final StreakCache _streak;

  Future<Result<Session, AppException>> call({
    required String protocolId,
    required Goal goal,
  }) async {
    final protocolResult = await _protocols.getById(protocolId);
    if (protocolResult is Err) return protocolResult;
    final protocol = (protocolResult as Ok).value;

    final session = Session(
      id: _uuid.v4(),
      protocolId: protocolId,
      goal: goal,
      startedAt: DateTime.now(),
      totalPlannedDuration: protocol.totalDuration,
      protocolRounds: protocol.rounds,
      // ... other fields
    );

    final saveResult = await _sessions.save(session);
    if (saveResult is Err) return saveResult;

    await _analytics.track('session_started', {'protocol_id': protocolId});
    return Ok(session);
  }
}
```

(Each use case follows this pattern. Full list in folder structure above.)

### 3.6 Repository interfaces

```dart
// lib/domain/repositories/session_repository.dart
abstract class SessionRepository {
  Future<Result<Session, AppException>> save(Session session);
  Future<Result<Session?, AppException>> getById(String id);
  Future<Result<List<Session>, AppException>> getAll({int? limit, DateTime? since});
  Future<Result<void, AppException>> delete(String id);
  Stream<List<Session>> watchAll();
  Future<Result<void, AppException>> syncToRemote();
  Future<Result<void, AppException>> syncFromRemote();
}
```

(All other repository interfaces follow this pattern.)

---

## 4. Data layer

### 4.1 Drift schema

```dart
// lib/data/local/database/tables/sessions_table.dart
@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get protocolId => text()();
  TextColumn get goal => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get totalPlannedDurationSec => integer()();
  IntColumn get totalActualDurationSec => integer()();
  IntColumn get roundsCompleted => integer()();
  IntColumn get protocolRounds => integer()();
  RealColumn get recoveryScore => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get healthDataSnapshot => text().nullable()(); // JSON of computed metrics only
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))(); // soft delete for sync
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PhaseRow')
class Phases extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()(); // 'sauna' | 'cold' | 'rest' | 'custom'
  IntColumn get orderIndex => integer()();
  IntColumn get plannedDurationSec => integer()();
  IntColumn get actualDurationSec => integer()();
  RealColumn get targetTempC => real().nullable()();
  RealColumn get actualTempC => real().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
  TextColumn get voiceLog => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StreakRow')
class Streaks extends Table {
  TextColumn get date => text()(); // YYYY-MM-DD local
  TextColumn get sessionId => text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get count => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {date};
}

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('HealthSnapshotRow')
class HealthSnapshots extends Table {
  TextColumn get id => text()();
  DateTimeColumn get capturedAt => dateTime()();
  IntColumn get sleepMinutes => integer().nullable()();
  RealColumn get hrvRmssd7DayAvg => real().nullable()();
  RealColumn get hrvRmssdTrend7Day => real().nullable()();
  RealColumn get restingHr7DayAvg => real().nullable()();
  RealColumn get restingHrTrend7Day => real().nullable()();
  IntColumn get stepsYesterday => integer().nullable()();
  DateTimeColumn get lastWorkoutAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CustomProtocolRow')
class CustomProtocols extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get rounds => integer()();
  TextColumn get phasesJson => text()(); // List<PhaseTemplate> serialized
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 4.2 Encryption

```dart
// lib/data/local/encryption/sqlcipher_key_provider.dart
class SqlcipherKeyProvider {
  static const _keyName = 'drift_db_key';
  final FlutterSecureStorage _storage;

  Future<String> getOrCreateKey() async {
    var key = await _storage.read(key: _keyName);
    if (key == null) {
      key = _generateRandomKey();
      await _storage.write(key: _keyName, value: key);
    }
    return key;
  }

  String _generateRandomKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
```

Database is opened with `NativeDatabase` + SQLCipher:
```dart
@DriftDatabase(tables: [Sessions, Phases, Streaks, Settings, HealthSnapshots, CustomProtocols])
class AppDatabase extends _$AppDatabase {
  AppDatabase(this._key) : super(_openConnection(_key));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      // Migrations written for each version bump
    },
  );

  static QueryExecutor _openConnection(String key) {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'contrast_coach.db'));
      return NativeDatabase.createInBackground(
        file,
        setup: (db) {
          // SQLCipher pragma
          db.execute("PRAGMA key = '$key';");
          db.execute("PRAGMA cipher_page_size = 4096;");
        },
      );
    });
  }
}
```

### 4.3 Hive cache

```dart
// lib/data/local/cache/hive_cache.dart
@lazySingleton
class HiveCache {
  late Box<dynamic> _box;

  Future<void> init() async {
    await Hive.initFlutter('contrast_coach_cache');
    _box = await Hive.openBox('app');
  }

  T? get<T>(String key) => _box.get(key) as T?;
  Future<void> set<T>(String key, T value) => _box.put(key, value);
  Future<void> delete(String key) => _box.delete(key);
  Future<void> clear() => _box.clear();
}
```

Used for: last active session ID, last computed streak, computed aggregations (caches for Insights screen), theme mode override, onboarding completion flag.

### 4.4 Firebase integration

```dart
// lib/data/remote/firebase/firebase_app.dart
class FirebaseAppBootstrap {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Privacy-first Firebase Analytics configuration
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    // Advertising ID is not collected when:
    // - google_analytics_adid_collection_enabled is false in google-services.json
    // - We do not call setUserProperty('ad_personalization')
    // We do both of these; documentation in FIREBASE_SETUP.md

    // Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }
}
```

**Firebase security rules (Firestore):**

```
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /sessions/{sessionId} {
        allow read, write: if request.auth != null
          && request.auth.uid == userId
          && request.resource.data.userId == userId
          && request.resource.data.keys().hasAll(['id', 'protocolId', 'goal', 'startedAt', 'roundsCompleted'])
          // Health data fields forbidden
          && !('rawHeartRate' in request.resource.data)
          && !('rawHrv' in request.resource.data)
          && !('rawSleep' in request.resource.data);
      }

      match /devices/{deviceId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

The rules explicitly forbid raw health data fields even if a malicious client tried to upload them. The app only ever writes computed metrics to `healthDataSnapshot`.

### 4.5 Health Connect

```dart
// lib/data/local/health/health_connect_client.dart
class HealthConnectClient {
  static const _readPermissions = [
    HealthDataAccess.READ_HEART_RATE,
    HealthDataAccess.READ_RESTING_HEART_RATE,
    HealthDataAccess.READ_HRV,
    HealthDataAccess.READ_SLEEP,
    HealthDataAccess.READ_STEPS,
    HealthDataAccess.READ_EXERCISE,
  ];
  static const _writePermissions = [
    HealthDataAccess.WRITE_MINDFULNESS,
  ];

  final Health _health = Health();

  Future<bool> isAvailable() async => _health.isHealthConnectAvailable;

  Future<PermissionResult> requestPermissions() async {
    final has = await _health.hasPermissions(_readPermissions + _writePermissions);
    if (has) return PermissionResult.granted;
    final granted = await _health.requestAuthorization(
      _readPermissions + _writePermissions,
      rationale: 'ContrastCoach reads heart rate, HRV, and sleep to calculate your recovery score. All data stays on your device. We never upload it.',
    );
    return granted ? PermissionResult.granted : PermissionResult.denied;
  }

  Future<HealthSnapshot> readSnapshot() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final sleep = await _health.getHealthDataFromTypes(
      types: [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_SESSION],
      startTime: now.subtract(const Duration(hours: 24)),
      endTime: now,
    );
    final hrv = await _health.getHealthDataFromTypes(
      types: [HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
      startTime: weekAgo,
      endTime: now,
    );
    // ... similar for HR, RHR, steps, exercise

    return HealthSnapshot(...);
  }

  Future<void> writeMindfulSession({
    required DateTime start,
    required DateTime end,
    required String title,
  }) async {
    await _health.writeHealthData(
      value: end.difference(start).inMinutes,
      type: HealthDataType.MINDFULNESS,
      startTime: start,
      endTime: end,
    );
  }
}
```

### 4.6 Voice control

```dart
// lib/data/voice/speech_to_text_client.dart
class SpeechToTextClient {
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;

  Future<bool> init({required VoidCallback onError}) async {
    _initialized = await _stt.initialize(
      onError: (e) => onError(),
      onStatus: (_) {},
    );
    return _initialized;
  }

  Future<bool> requestPermission() async {
    return await Permission.microphone.request().then((s) => s.isGranted);
  }

  /// Continuous listening. Calls [onResult] with each finalized transcript.
  Future<void> startListening({
    required void Function(String) onResult,
    required String localeId,
  }) async {
    await _stt.listen(
      onResult: (r) {
        if (r.finalResult) onResult(r.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        partialResults: false,
        cancelOnError: true,
      ),
      localeId: localeId,
    );
  }

  Future<void> stopListening() => _stt.stop();
}
```

### 4.7 Subscription

```dart
// lib/data/remote/subscription/revenue_cat_client.dart
class RevenueCatClient {
  late final Purchases _purchases;

  Future<void> init({required String apiKey, String? appUserId}) async {
    final config = PurchasesConfiguration(apiKey);
    if (appUserId != null) config.appUserID = appUserId;
    await Purchases.configure(config);
  }

  Future<CustomerInfo> getCustomerInfo() => _purchases.getCustomerInfo();
  Future<Offerings> getOfferings() => _purchases.getOfferings();
  Future<CustomerInfo> purchase(Package package) => _purchases.purchasePackage(package);
  Future<CustomerInfo> restorePurchases() => _purchases.restorePurchases();

  Stream<CustomerInfo> get customerInfoStream => _purchases.customerInfoStream;
}
```

### 4.8 Sentry

```dart
// lib/data/remote/crash/sentry_client.dart
class SentryBootstrap {
  static Future<void> init({required String dsn}) async {
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.tracesSampleRate = 0.1;
        options.beforeSend = (event, hint) {
          // Strip PII
          event.user = SentryUser(id: null, username: null, email: null, ipAddress: null);
          event.tags?.remove('health_data');
          event.tags?.remove('user_id');
          event.tags?.remove('session_id');
          return event;
        };
        options.beforeBreadcrumb = (breadcrumb, hint) {
          // No voice transcripts in breadcrumbs
          if (breadcrumb.message?.contains('voice') == true) return null;
          return breadcrumb;
        };
      },
      appRunner: () => runApp(...),
    );
  }
}
```

### 4.9 Repositories

Each repository implements the domain interface and uses Drift + Hive + Firebase + Health Connect + RevenueCat as needed. Example:

```dart
// lib/data/repositories/session_repository.dart
@LazySingleton(as: SessionRepository)
class SessionRepositoryImpl implements SessionRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityChecker _connectivity;

  @override
  Future<Result<Session, AppException>> save(Session session) async {
    try {
      final row = session.toRow();
      await _db.into(_db.sessions).insertOnConflictUpdate(row);
      for (final phase in session.phases) {
        await _db.into(_db.phases).insertOnConflictUpdate(phase.toRow());
      }
      _scheduleSync();
      return Ok(session);
    } catch (e) {
      return Err(DatabaseException('Failed to save session', cause: e));
    }
  }

  // ... other methods
}
```

### 4.10 Bootstrap

```dart
// lib/bootstrap.dart
Future<void> bootstrap(WidgetsFlutterBinding binding) async {
  binding.ensureInitialized();

  // 1. Crash first, so we capture startup failures
  await SentryBootstrap.init(dsn: EnvConfig.sentryDsn);

  // 2. Firebase (Auth, Firestore, Analytics, Crashlytics)
  await FirebaseAppBootstrap.initialize();

  // 3. Local DB encryption key (must be before Drift)
  final key = await sl<SqlcipherKeyProvider>().getOrCreateKey();

  // 4. Drift DB
  final db = AppDatabase(key);

  // 5. Hive cache
  final cache = HiveCache();
  await cache.init();

  // 6. Register everything in service locator
  sl.registerSingleton<AppDatabase>(db);
  sl.registerSingleton<HiveCache>(cache);
  // ... etc

  // 7. Run app
  runApp(ProviderScope(child: ContrastCoachApp()));
}
```

---

## 5. Presentation layer

### 5.1 Theme

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF0A0A0A),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF7F7F7),
      surfaceContainer: Color(0xFFEDEDED),
      surfaceContainerHigh: Color(0xFFE0E0E0),
      surfaceContainerHighest: Color(0xFFD0D0D0),
      onSurfaceVariant: Color(0xFF5C5C5C),
      outline: Color(0xFFEDEDED),
      outlineVariant: Color(0xFFE0E0E0),
    ),
    textTheme: AppTypography.materialTextTheme,
    splashFactory: NoSplash.splashFactory,
    visualDensity: VisualDensity.standard,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF0A0A0A),
      onSurface: Color(0xFFF5F5F5),
      surfaceContainerLowest: Color(0xFF0A0A0A),
      surfaceContainerLow: Color(0xFF141414),
      surfaceContainer: Color(0xFF1F1F1F),
      surfaceContainerHigh: Color(0xFF2A2A2A),
      surfaceContainerHighest: Color(0xFF353535),
      onSurfaceVariant: Color(0xFFA8A8A8),
      outline: Color(0xFF1F1F1F),
      outlineVariant: Color(0xFF2A2A2A),
    ),
    textTheme: AppTypography.materialTextTheme,
    splashFactory: NoSplash.splashFactory,
  );
}
```

**No blue, red, green, orange. No gradients. No `primary` set to anything chromatic.** `surface` and `onSurface` carry the entire design.

### 5.2 Typography

```dart
// lib/core/constants/app_typography.dart
class AppTypography {
  static const String _displayFont = 'InterTight';
  static const String _bodyFont = 'Inter';
  static const String _monoFont = 'JetBrainsMono';

  static const Map<String, TextStyle> _display = {
    'displayLarge': TextStyle(fontFamily: _displayFont, fontSize: 57, height: 64 / 57, fontWeight: FontWeight.w300),
    'displayMedium': TextStyle(fontFamily: _displayFont, fontSize: 45, height: 52 / 45, fontWeight: FontWeight.w300),
    'headlineLarge': TextStyle(fontFamily: _displayFont, fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w500),
    'headlineMedium': TextStyle(fontFamily: _displayFont, fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w500),
    'titleLarge': TextStyle(fontFamily: _bodyFont, fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600),
    'titleMedium': TextStyle(fontFamily: _bodyFont, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
    'bodyLarge': TextStyle(fontFamily: _bodyFont, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400),
    'bodyMedium': TextStyle(fontFamily: _bodyFont, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400),
    'bodySmall': TextStyle(fontFamily: _bodyFont, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400),
    'labelLarge': TextStyle(fontFamily: _bodyFont, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    'labelSmall': TextStyle(fontFamily: _bodyFont, fontSize: 11, height: 16 / 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  };

  static TextTheme get materialTextTheme => const TextTheme(
    displayLarge: _display['displayLarge'],
    // ... etc
  );
}
```

Fonts are bundled in `assets/fonts/` and declared in `pubspec.yaml`. No Google Fonts runtime fetch (privacy + offline).

### 5.3 Atomic components

8 widgets, all with widget tests. Each one accepts theme tokens only, never hardcoded colors.

```dart
// lib/presentation/widgets/atomic/app_button.dart
enum AppButtonVariant { primary, secondary, tertiary, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (bg, fg, border) = switch (variant) {
      AppButtonVariant.primary => (cs.onSurface, cs.surface, null),
      AppButtonVariant.secondary => (cs.surface, cs.onSurface, cs.outline),
      AppButtonVariant.tertiary => (Colors.transparent, cs.onSurface, cs.outline),
      AppButtonVariant.text => (Colors.transparent, cs.onSurface, null),
    };

    return SizedBox(
      height: 48,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border != null ? BorderSide(color: border) : BorderSide.none,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) AppIcon(leadingIcon, size: 18),
                if (leadingIcon != null) const SizedBox(width: 8),
                Text(label, style: TextStyle(color: fg, ...AppTypography._display['labelLarge'])),
                if (trailingIcon != null) const SizedBox(width: 8),
                if (trailingIcon != null) AppIcon(trailingIcon, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

(All 8 atomic widgets follow this pattern: state expressed via opacity/weight/shape, never color. All have widget tests with `pumpWidget(MaterialApp(home: Scaffold(body: AppButton(...))))` and golden file generation disabled by default.)

### 5.4 Composite components

```dart
// lib/presentation/widgets/composite/session_timer.dart
class SessionTimer extends ConsumerWidget {
  final Session session;
  final Phase currentPhase;
  final Duration remaining;
  final int currentRound;
  final int totalRounds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          currentPhase.type.name.toUpperCase(),
          style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 2.0),
        ),
        const SizedBox(height: 24),
        Text(
          _formatDuration(remaining),
          style: TextStyle(
            fontFamily: AppTypography._monoFont,
            fontSize: 96,
            fontWeight: FontWeight.w200,
            color: cs.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 32),
        ProgressBar(current: currentRound, total: totalRounds),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
```

(All composite widgets are stateless / ConsumerWidget, take entity/domain models, and never touch repos directly.)

### 5.5 Layout components

```dart
// lib/presentation/widgets/layout/app_bar.dart
class ContrastAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final bool showBackButton;

  const ContrastAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: Border(
        bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      leading: showBackButton ? IconButton(
        icon: const AppIcon(LucideIcons.chevronLeft, size: 20),
        onPressed: () => Navigator.of(context).maybePop(),
      ) : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
```

### 5.6 Screens (8 total)

1. **Onboarding** — 3 steps, no skip. Each is a full-screen page with hero text + a single button. Step 3 leads to sign-in (or skip if "continue without account" chosen for v0.1, before Firebase is wired).
2. **Home (session setup)** — Top: greeting + last session date. Hero 28dp card: "Start session" + 2x2 goal grid. Quick stats row (3 cards, 7-day streak, avg duration, recovery score). Recommended protocol card.
3. **Active session** — Full-screen black/white. Phase label, massive 96pt mono countdown, progress bar, voice hint + pause button. No other UI.
4. **Session summary** — Recovery score (large), 2-3 insight lines, save/discard/share text buttons.
5. **Streak calendar** — 12-week grid, monochrome, tap day to see sessions.
6. **Insights** — Long-form scroll, 5-7 sections, inline stat callouts (no charts).
7. **Settings** — List, no grouped cards. Each row is a tappable item with chevron.
8. **Paywall** — Single column, 3 plan options, 3-4 feature bullets, "Restore purchases" link.

### 5.7 Routing

```dart
// lib/presentation/routing/app_router.dart
final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final isAuthed = auth.value?.isAuthenticated ?? false;
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isPaywall = state.matchedLocation == '/paywall';

      if (!isAuthed && !isOnboarding && !isPaywall) {
        return '/onboarding';
      }
      if (isAuthed && isOnboarding) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (_, __) => const PaywallScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/streak', builder: (_, __) => const StreakCalendarScreen()),
          GoRoute(path: '/insights', builder: (_, __) => const InsightsScreen()),
        ],
      ),
      GoRoute(path: '/session', builder: (_, __) => const ActiveSessionScreen()),
      GoRoute(path: '/summary/:sessionId', builder: (_, s) => SessionSummaryScreen(sessionId: s.pathParameters['sessionId']!)),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/settings/health', builder: (_, __) => const HealthConnectScreen()),
      GoRoute(path: '/settings/privacy', builder: (_, __) => const PrivacyScreen()),
      GoRoute(path: '/settings/export', builder: (_, __) => const DataExportScreen()),
      GoRoute(path: '/settings/delete', builder: (_, __) => const DeleteAccountScreen()),
      GoRoute(path: '/settings/about', builder: (_, __) => const AboutScreen()),
      GoRoute(path: '/health/rationale', builder: (_, __) => const HealthPermissionRationaleScreen()),
      GoRoute(path: '/voice/rationale', builder: (_, __) => const VoicePermissionRationaleScreen()),
    ],
  );
});
```

### 5.8 Riverpod providers

Each provider is a `@riverpod` annotation. Examples:

```dart
// lib/presentation/providers/session_provider.dart
@riverpod
class ActiveSession extends _$ActiveSession {
  @override
  Session? build() => null;

  Future<void> start(String protocolId, Goal goal) async {
    final result = await ref.read(startSessionProvider)(protocolId: protocolId, goal: goal);
    result.fold(
      (err) => ref.read(errorProvider.notifier).state = err,
      (session) => state = session,
    );
  }

  Future<void> pause() async { /* ... */ }
  Future<void> resume() async { /* ... */ }
  Future<void> skip() async { /* ... */ }
  Future<void> end() async { /* ... */ }
}

@riverpod
Stream<List<Session>> recentSessions(Ref ref) {
  return ref.watch(sessionRepositoryProvider).watchAll();
}
```

### 5.9 Motion

```dart
// lib/presentation/motion/spring_transitions.dart
class SpringRouteTransitions {
  static Widget fadeThrough(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }
}
```

All transitions: 240ms fade with spring(stiffness: 380, dampingRatio: 0.8). No bouncy overshoots. Haptics on primary actions only (use `HapticFeedback.mediumImpact()` on button press).

### 5.10 Accessibility

- All text scales 100% to 200% without breaking layout
- All tap targets ≥ 48x48dp
- All interactive elements have semantic labels
- Color contrast: WCAG AA verified (12.6:1 on surface-0 with onSurface)
- TalkBack tested via `integration_test/a11y_test.dart`

---

## 6. Testing, security, deployment, and launch

### 6.1 Test plan

**Unit tests** (pure Dart, fast, no Flutter binding):
- `score_calculator_test.dart` — every branch of recovery score formula, boundary conditions, factor list
- `protocol_validator_test.dart` — every validation rule, all 10 built-in protocols pass, custom protocol rejections
- `protocol_engine_test.dart` — round expansion, total duration calculation, phase ordering
- `time_of_day_test.dart` — hour bucket boundaries
- `hrv_trend_test.dart` — 7-day rolling average and trend
- `parse_voice_command_test.dart` — every command, edge cases, lowercase
- `start_session_test.dart`, `end_session_test.dart`, `calculate_recovery_score_test.dart` (use case) — use cases with mocked repos
- `generate_insights_test.dart` — 5-7 insights produced for 30-day sample data
- `session_provider_test.dart`, `streak_provider_test.dart`, `subscription_provider_test.dart` — Riverpod providers with ProviderContainer + mocktail

**Widget tests**:
- All 8 atomic widgets, all 6 composite widgets, 3 layout widgets
- Coverage: rendering with default state, with custom props, with disabled state, with pressed state, light vs dark, accessibility (semantic labels)
- `pumpWidget(Scaffold(body: AppButton(...)))` and `expect(find.text('Continue'), findsOneWidget)` style

**Integration tests** (real Flutter driver, runs on emulator):
- `app_lifecycle_test.dart` — cold start < 3s, hot start, kill-and-restart preserves state
- `onboarding_test.dart` — 3 steps, no skip, final step leads to home
- `home_test.dart` — stats render, recommended protocol, hero card, tap to start
- `active_session_test.dart` — start, pause, resume, skip, end, completion → summary
- `voice_session_test.dart` — "Hey Coach, next phase" advances session
- `voice_rationale_test.dart` — permission flow with deny and grant
- `health_rationale_test.dart` — Health Connect permission flow
- `summary_test.dart` — score renders, save, discard
- `streak_calendar_test.dart` — 12-week grid, tap day, day detail sheet
- `insights_test.dart` — 5-7 sections, scroll, disclaimer visible
- `settings_test.dart` — all rows tappable, deep link to sub-screens
- `privacy_test.dart` — export produces JSON, delete confirmation flow
- `paywall_test.dart` — plans visible, restore purchases, purchase flow (RevenueCat test mode)
- `auth_test.dart` — email sign-in, Google sign-in, sign out
- `theme_test.dart` — light/dark switch, dynamic color off, system theme follows
- `navigation_test.dart` — deep links, go_router back stack
- `a11y_test.dart` — TalkBack reads all text, 200% text scale doesn't break, all tap targets ≥ 48dp

**Coverage target:** >85% on domain layer, >75% on data layer, >70% on presentation.

### 6.2 Security checklist

- [x] **No secrets in code** — all env vars from `--dart-define`, never committed
- [x] **Drift DB encrypted** with SQLCipher, key in `flutter_secure_storage`
- [x] **HTTPS only** — `dio` configured with `BaseOptions(connectTimeout: 10s, receiveTimeout: 30s)`, no `http://` URLs
- [x] **Firestore security rules** — users can only read/write their own data; raw health fields forbidden
- [x] **Firebase Auth tokens** — stored in `flutter_secure_storage`, never logged
- [x] **Sentry PII stripping** — `beforeSend` and `beforeBreadcrumb` filters active
- [x] **No advertising ID** — `google-services.json` configured with `google_analytics_adid_collection_enabled = false`
- [x] **No personalized ads** — no ad SDKs in `pubspec.yaml`
- [x] **Voice transcripts** — never logged, never sent to remote, never stored
- [x] **Health Connect raw values** — never leave the device, only computed metrics to Firestore
- [x] **ProGuard / R8** — `minifyEnabled true`, `shrinkResources true`, aggressive shrinking
- [x] **Certificate pinning** — `dio_certificate_pinning` for Supabase/RevenueCat/Sentry endpoints (optional but recommended for v1.0)
- [x] **Root detection** — `flutter_jailbreak_detection` for Pro features (optional)
- [x] **Permissions reviewed** — manifest has only what we use
- [x] **Code obfuscation** — `--obfuscate --split-debug-info=...` in release build
- [x] **Dependency audit** — `dart pub outdated --mode=null-safety` and `flutter pub deps` reviewed, no abandoned packages
- [x] **No `print()`** — `dart_code_metrics` configured to fail on `print` and `debugPrint` in `lib/`
- [x] **Lint passes** — `very_good_analysis` rules, zero warnings, `dart format` clean
- [x] **SAST** — `codeql.yml` workflow on every PR

### 6.3 Deployment

**Build flavors:**
- `dev` — debug banner, mock data, debug Firebase project, debug RevenueCat key
- `prod` — no banner, real services

**Signing:**
- `android/key.properties` (gitignored) — `storeFile`, `storePassword`, `keyAlias`, `keyPassword`
- `android/.env.example` — template
- `tools/scripts/decode_keystore.sh` — CI helper (base64 env var → keystore file)

**CI (`.github/workflows/ci.yml`):**
- Trigger: every PR
- Steps: checkout → flutter-action v2 → `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` → `flutter analyze --fatal-infos` → `dart format --set-exit-if-changed lib/ test/` → `flutter test --coverage` → `flutter build apk --release --split-per-abi` → upload artifact

**Release (`.github/workflows/release-internal.yml`):**
- Trigger: tag push `v*` (manual via `tools/scripts/bump_version.sh`)
- Steps: build appbundle → upload to Google Play internal testing track via `r0adkll/upload-google-play@v1` → upload `mapping.txt` → upload `whatsnew/`

**Performance budgets:**
- App size: < 50MB APK
- Cold start: < 2s on mid-range device (Pixel 4a equivalent)
- Frame time: 16ms sustained
- Battery: < 2% per hour during active session
- Memory: < 150MB peak

### 6.4 Play Store launch

**Content forms (in Play Console):**

1. **Data Safety form** — matches `docs/PRIVACY.md` exactly. No discrepancies.
2. **Health Apps declaration** — paste-ready justifications from `docs/PLAY_STORE_COMPLIANCE.md`, one per read permission.
3. **AI-generated content disclosure** — N/A (we use deterministic algorithms, not LLM).
4. **Ads disclosure** — N/A (we have no ads).
5. **Medical disclaimer** — present in onboarding step 1, settings → about, paywall, and Insights screen footer. Standard "for informational and educational purposes only" text.
6. **Privacy policy URL** — `PRIVACY_POLICY.md` rendered to GitHub Pages, HTTPS, public, non-editable (commit-pinned).

**Assets (generated in this design):**

1. **App icon** — 512x512, monochrome, single visual: a circle bisected by a horizontal line (heat above, cold below). 1.5px stroke, no fill, all black on white background. Generated programmatically using `path` + `Picture` recorder.
2. **Feature graphic** — 1024x500, white background, single sentence "Track heat. Track cold. See what works." in Inter Tight 64pt. No app screenshots (master plan says 3 in a row; we'll skip the screenshots in the feature graphic and use a clean version).
3. **Phone screenshots** — 8 total, 1080x1920. Generated by `tools/scripts/generate_screenshots.dart` which runs an integration test that captures each screen via `RepaintBoundary.toImage()`. Each has 1-2 word label, monochrome, no marketing copy.
   1. Onboarding step 1
   2. Home (Start)
   3. Active session (20:00 timer)
   4. Summary (78 score)
   5. Streak calendar (12 weeks)
   6. Insights (Sleep +23 min)
   7. Health Connect permissions
   8. Paywall (Pro)

**Store listing copy** — from master plan section 9.4.

**Internal testing track:**
- 20+ testers, 14 days
- Crash-free rate > 99.5% in Sentry
- All subscription flows tested with $0.99 test purchase
- Health Connect flow tested on real device (Pixel 4a or later, Android 14+)

**Closed testing track** (after internal):
- 100+ testers, 14 days
- Opt-in URL shared with target audience

**Production track** (after closed):
- Submit when ready
- Wait for review (3-7 days)
- Soft launch with daily crash check for 7 days

### 6.5 Out of scope for v1.0 launch

- iOS (v2)
- Wear OS (v3)
- Public marketing site (use Carrd.co if needed)
- Customer support system (email-based initially)
- Refund automation (manual through Play Console)
- A/B testing (no remote config, no experimentation)
- In-app chat support
- Push notification re-engagement campaigns

---

## 7. Open questions / risks

| Question | Impact | Mitigation |
|---|---|---|
| Will Health Connect be available on most target devices by launch? | Users on Android 12 or earlier can't use Pro insights | Set `minSdk = 26` (Android 8.0), but Health Connect itself requires Android 14+ on the device (it's an installable app). Pro features gracefully degrade. |
| Will `health` Flutter package be stable by launch? | Pin version, monitor releases | Pin to a known-stable version in v0.5, test thoroughly |
| Will RevenueCat accept an Indian bank account for payouts? | Payouts might go to US LLC | Set up a US LLC before launch, or use Wise/Payoneer as intermediary |
| Will Firebase Analytics be considered PII by Play Store review? | Possible rejection | Document in Data Safety that advertising ID is disabled, no personalized ads |
| Will 50 testers stay engaged for 14 days? | Blocked launch | Recruit from existing biohacker Reddit communities, not friends |
| Will `speech_to_text` work reliably in a noisy sauna? | Voice commands fail mid-session | Manual button fallback is always available; voice is a "nice to have" |
| Will Drift SQLCipher cause ANRs on cold start? | Slower cold start | Key generation is one-time; subsequent opens are fast. Benchmark on Pixel 4a. |
| Will Privacy Policy on GitHub Pages satisfy Play Store? | Possible rejection | HTTPS, public, fast-loading — all required, all met. Test the URL before submit. |
| Will `flutter_secure_storage` work on all Android versions? | Encryption key lost on some devices | Fallback: regenerate key (loses access to old data, but user gets a clean state) |

---

## 8. Out of scope, explicitly

- **iOS** — the master plan defers this to v2. We follow the same deferral.
- **Wear OS** — v3. Phone-first is the wedge.
- **Public landing page** — only Play Store listing for v1.0.
- **Customer support system** — direct email, no Zendesk/Intercom.
- **Refunds** — manual through Play Console for v1.0.
- **A/B testing** — no remote config, no experimentation. Ship one version, iterate based on Sentry + reviews.
- **AI-generated insights** — explicitly NOT in scope. The recovery score is deterministic. If we add LLM later, the AI disclosure and content filters are required.
- **Background location** — explicitly forbidden by master plan privacy rules.
- **Advertising SDKs** — explicitly forbidden. App is monetized via subscription only.
- **Cross-app tracking** — explicitly forbidden.

---

## 9. Acceptance criteria for v1.0

- [ ] `flutter analyze --fatal-infos` passes with zero warnings
- [ ] `dart format --set-exit-if-changed lib/ test/` passes
- [ ] `flutter test --coverage` passes with >85% domain, >75% data, >70% presentation coverage
- [ ] `integration_test/` all 16 files pass on a Pixel 4a emulator with Android 14
- [ ] `flutter build appbundle --release --flavor prod` succeeds
- [ ] APK size < 50MB
- [ ] Cold start < 2s on Pixel 4a
- [ ] All 8 screens render in light + dark, with no chromatic colors
- [ ] All 10 protocols complete a full session
- [ ] Voice control works in active session
- [ ] Health Connect permission flow works (on Android 14+ devices)
- [ ] Paywall blocks Pro features for free users
- [ ] Purchase flow works (test with $0.99 in RevenueCat sandbox)
- [ ] Restore purchases works
- [ ] Local DB persists across app restarts
- [ ] Cloud sync uploads sessions (Firestore security rules verified)
- [ ] Data export produces valid JSON
- [ ] Data deletion removes all local + Firestore data
- [ ] All 3 deep link paths work (`/home`, `/session`, `/settings`)
- [ ] All notification types work (streak, gap, subscription renewal, permission revoked)
- [ ] Background sync works (kill app, open it, sessions synced)
- [ ] Sentry shows zero unhandled exceptions in test session
- [ ] Firebase Analytics shows 5 events firing
- [ ] All Play Console content forms filled out
- [ ] Privacy policy URL live and accessible
- [ ] 8 screenshots + feature graphic + app icon generated
- [ ] Internal testing track has 20+ testers
- [ ] Internal testing track has run for 14 days with no critical bugs
- [ ] Crash-free rate > 99.5%
- [ ] Ready to submit to closed testing track

This list is the source of truth for "is v1.0 done".

---

**End of design.**
