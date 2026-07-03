# ContrastCoach v4 UI/UX Port — Design Spec

**Date:** 2026-07-03
**Status:** Approved by user (pending final spec review)
**Owner:** aasheesh333
**Reference mockup:** `ContrastCoach v4 plan.md` §2.4 (exact v4 CSS tokens), the v4 HTML prototype pasted by the user.

## 1. Goal

Port the v4 premium HTML mockup's UI/UX — **pixel-faithful** — onto the existing ContrastCoach Flutter app, while keeping every screen wired to **real data** (Drift / Firebase / Gemini), building the 10 v4 screens that don't yet exist as Flutter screens, and shipping the code-side §4 wiring gaps from `ContrastCoach v4 plan.md`. Both light + dark themes polished, default light.

**Out of scope (owner's tasks, do NOT touch):** Play Store listing, Data Safety form, Health Apps Declaration, store submission, marketing, real Firebase `google-services.json` (will document the slot, leave placeholder).

## 2. Design-System Tokens (Section 1 of brainstorm)

### 2.1 `lib/core/constants/app_colors.dart` — replace with exact v4 hex

Accents identical in light + dark:

| Token | Hex |
|---|---|
| heat | `#FF6B35` |
| coral | `#FF8A65` |
| cold | `#2D7CF1` |
| cold2 | `#5B9CFF` |
| purple | `#7A5BFF` |
| ok / success | `#33C27F` (replaces current `#4CAF50`) |
| error | `#E53935` |

Light neutrals:
- ink `#0C0C0E`, ink2 `#6B6E76`, ink3 `#9AA0A8`
- bg `#EEF0F5` (was `#FAFAF7`), card `#FFFFFF`, line `#ECEEF2`

Dark neutrals (accents unchanged):
- ink `#F4F5F7`, ink2 `#AEB2BC`, ink3 `#7B7F8A`
- bg `#0A0B0F`, card `#15161B`, line `#24252C`

Remove vestige v2 tokens (`warmBeige`, `coralPop`). Keep deprecated aliases one release so existing tests don't break en masse.

### 2.2 New `lib/core/theme/app_colors_extension.dart`

`ThemeExtension<AppColors>` exposing: `warmAccent`(coral), `coldAccent2`(5B9CFF), `textMuted`(ink2), `textFaint`(ink3), `success`, `purple`, `lineColor`. Wired into both `light_theme.dart` + `dark_theme.dart` via `extensions: [AppColors.light, AppColors.dark]`. The whole app reads accents via `Theme.of(context).extension<AppColors>()!` — a `ThemeController` swaps one extension instance to live-recolor everything.

### 2.3 Typography (`app_typography.dart`)

Add JetBrains Mono weights 300 & 500. Add `titleHero=19`, `bodyLarge=15`, `labelMedium=13`, `caption=11` to match v4 scale. Plus Jakarta Sans stays (already wired). No Inter references anywhere (confirmed by survey).

### 2.4 Shapes (`app_shapes.dart`)

card=20 ✓, small=14 (was 12), large=26 (was 28).

### 2.5 Motion (`app_motion.dart`)

Add `AppCurves.spring = Cubic(0.22, 1, 0.36, 1)` + `defaultDuration = Duration(milliseconds: 260)`. Used for nav transitions, phase changes, paywall sheet.

### 2.6 Shadows (`app_spacing.dart`)

Replace `cardSoftFor`/`cardStrongFor` with exact v4 tinted:
- soft: `0 8px 24px -16px rgba(20,20,45,.28)` → `BoxShadow(color: Color(0x2814142D), blurRadius: 24, offset: Offset(0, -16), spreadRadius: -8)` (approximation; tunable)
- raised: `0 20px 44px -22px rgba(20,20,45,.4)`
- dark variants stronger per v4

### 2.7 Gradients (`gradients.dart`) — add full v4 set

- `splashBg`: `linear-gradient(160deg, #FF6B35, #7A2AA8 58%, #2D7CF1)`
- `heroDark`: `linear-gradient(140deg, #12121a, #25252f)` + radial heat glow TR + cold glow BL
- `btnPrimary`: `linear-gradient(120deg, heat, coral)`
- `btnCold`: `linear-gradient(120deg, cold, cold2)`
- `btnDelete`: `linear-gradient(120deg, #E53935, #ff6b68)`
- `sessionWarm`: `radial-gradient(120% 80% at 50% 0%, #7a2a0e, #0c0c0e)`
- `sessionCold`: `radial-gradient(120% 80% at 50% 0%, #0d3a7a, #0c0c0e)` — crossfade ~1.1s on phase change
- `scoreText`: heat→cold horizontal, used as `ShaderMask`
- `bodyGlow`: radial `#ffe1d0` TL + `#d4e4ff` TR over `#eceef3` — painted once via `CustomPaint` at `home_shell.dart` so all screens inherit

## 3. Screen Inventory & New Tables (Section 2 of brainstorm)

### 3.1 Existing screens — restyle to v4 (keep real-data wiring)

1. Onboarding — `onboarding_screen.dart` — full-screen `splashBg` gradient, 🔥, 3-dot carousel
2. Sign in / Sign up — `auth/*` — 🔥 brand, Google + Apple + email on gradient
3. Home — `home_screen.dart` — dark `heroDark` readiness card w/ SVG gauge, 2-col emoji protocol grid, resume card, ▶️ start, pills 🔥 ⏱
4. Active session — `session/active_session_screen.dart` — radial warm/cold bg, SVG ring, mono timer, 88dp manual buttons + breath pacer in cold phase
5. Session summary — `session_summary_screen.dart` — 🎉, gradient-text score, insight rows 📈⏰🌡️🏅, mood chips, share
6. Streak calendar — `streak_calendar_screen.dart` — weekday header row, done/cold/today dots, 7-day free gate
7. Insights — `insights_screen.dart` — trend card, 14×5 heatmap, bars (`fl_chart`), Pro gate
8. Settings + 5 sub-screens — settings/* — profile menu rows w/ emoji (🏅🗓️📝🏆🔐🔔🎨❤️🧩⭐💾❓)
9. Paywall — `paywall_screen.dart` — badge 🔥, trust row, 3 plans, reviews carousel
10. Custom builder — `custom_protocol_builder_screen.dart` — phase editor 🌡️❄️🙌 + Pro gate
11. Health rationale / Voice rationale — restyle
12. Home shell + bottom nav — `home_shell.dart`, `bottom_nav.dart` — **5 tabs**: Home/Explore/Insights/Coach/You

### 3.2 New screens (10) — build with real data

| New screen | File path | Data source | New table? |
|---|---|---|---|
| Splash | `screens/splash/splash_screen.dart` | prefs | no |
| Explore (protocols catalog) | `screens/explore/explore_screen.dart` | `ProtocolRepository` + programs JSON | no |
| Coach chat | `screens/coach/coach_screen.dart` | Gemini API + Drift | no (replies ephemeral) |
| Achievements | `screens/achievements/achievements_screen.dart` | derives from sessions/streaks | no — derive on the fly |
| Challenges + leaderboard | `screens/challenges/challenges_screen.dart` | static `assets/challenges.json` + sessions for "you" row | no |
| Journal | `screens/journal/journal_screen.dart` | new `JournalEntriesRepository` | **YES — new `journal_entries` table** |
| Referral | `screens/referral/referral_screen.dart` | deterministic code from settings userId | no |
| Share card | `screens/share/share_card_screen.dart` | the just-written session + score | no — `RepaintBoundary` → PNG via `dart:ui` |
| Appearance (+ accent picker) | `screens/settings/appearance_screen.dart` | `settings` (accent, themeMode) | no — add columns via migration |
| Edit profile + Session detail | `screens/profile/edit_profile_screen.dart`, `screens/history/session_detail_screen.dart` | Firebase profile + Drift sessions | no |

### 3.3 New Drift table (exactly one)

`journal_entries` (id TEXT PK, createdAt INTEGER, mood TEXT, note TEXT). Bump `schemaVersion`, add `onUpgrade` migration case, regenerate `app_database.g.dart` via `dart run build_runner build --delete-conflicting-outputs`.

Same migration adds `settings.accentColor` (TEXT, default "#FF6B35") + `settings.themeMode` (TEXT, default "system") columns.

### 3.4 Bottom nav restructure

`/streak` route moves under `/settings` (Profile menu → 🗓️ History). New tab route `/explore` + `/coach` added to `ShellRoute`. New `RouteNames`: `splash`, `explore`, `coach`, `achievements`, `challenges`, `journal`, `referral`, `share`, `appearance`, `editProfile`, `sessionDetail`. ~11 new route entries.

## 4. New Wiring + Plan §4 Gaps (Section 3 of brainstorm)

### 4.1 Cross-cutting (in scope, all)

1. Splash route + boot flow (`app_router.dart`, `main.dart`) — `/splash` → `/onboarding` if `!onboardingComplete` else `/home` after 1.9s
2. Auth guard — already exists ✓, verify Explore/Coach/Profile reached via ShellRoute are auth-gated
3. Analytics wire — `trackSessionStarted/Completed/PaywallViewed/SubscriptionStarted` in active_session, paywall, subscription_repository
4. Sentry PII strip — `beforeSend` strip user/health tags + `beforeBreadcrumb` drop voice
5. Notification channels on init — `notification_service.dart` `init()` registers the 5 channels once (not inline per call)
6. Single AppDatabase instance — `database_provider.dart` is singleton ✓; grep for any per-screen `AppDatabase()` and convert to provider
7. Sessions carry userId — verify `sessions` has `userId`; if not, add via migration; `SessionRepositoryImpl.create()` sets from Auth
8. Health Connect manifest + flow — `AndroidManifest.xml` adds `ACTIVITY_RECOGNITION` + HC intent filter; wire Connect button to `requestPermissions()` then `readSnapshot()`; subscribe `permissionsRevokedStream`
9. Audio extensions aligned — pubspec declares `.wav` (session_start/phase_transition/session_complete), MEMORY says code currently references `.ogg` and files are missing. Fix: generate 3 royalty-free `.wav` chimes into `assets/audio/`, make `audio_cue_service.dart` reference the exact `.wav` names in pubspec.
10. Custom protocol Pro gate — verify on Home entry tile too
11. Accent-picker persistence — `appearance_screen.dart` + `app.dart` rebuild `MaterialApp` from `ThemeController`
12. Google Sign-In verify — already calls `signInWithGoogle` ✓; verify on real device during P7
13. Workmanager sync init — confirm `Workmanager().initialize(syncCallback,...)` registered inside `_initSyncWorkerSafely`
14. App icon mipmaps — `flutter_launcher_icons.yaml` + run; converts `app_icon.svg` → adaptive mipmaps
15. Firebase config in CI — document the secret slot, leave placeholder for the real `google-services.json`

### 4.2 ThemeController

Riverpod `StateNotifier<ThemeMode + accent>` reading/writing `settings` table on change; `app.dart` consumes it to rebuild `MaterialApp.theme` + the `AppColors` ThemeExtension instance. Powers "live-recolor whole app" accent picker.

### 4.3 Coach backend

- Domain: `coach_message.dart` (freezed), `coach_repository.dart` (abstract: `sendMessage(history, profile, recentSessions) → Stream<CoachMessage>`), `send_coach_message.dart` usecase w/ offline-fallback logic
- Data: `gemini_client.dart` (calls `gemini-2.5-flash-lite` via `google_generative_ai`; system prompt includes user's HRV/streak/recovery from Drift), `coach_repository_impl.dart` (decides: `!canUseCoach` → reject; offline → `CoachReplyService`; else → Gemini stream)
- `coach_reply_service.dart` — deterministic templated replies derived from local session/streak data
- FeatureGating flag added: `canUseCoach` (Pro-only)
- API key: `GEMINI_API_KEY` via `EnvKeys.dart` + `EnvConfig.geminiApiKey` getter (reads `String.fromEnvironment`); injected via `flutter run --dart-define=GEMINI_API_KEY=<real AIzaSy...key>`. `.env.example` documents the slot. Key NOT committed.

### 4.4 Share-card backend

- `share_card_painter.dart` widget — `RepaintBoundary` around v4 branded card; `dart:ui` `toImage()` → PNG bytes → `share_plus` `XFile` → OS share sheet
- `render_share_card.dart` usecase — takes a `Session` + recovery score, returns PNG bytes

### 4.5 Achievements backend

- `achievement.dart` (id, title, emoji, unlockedAt?), `evaluate_achievements.dart` usecase — pure Dart deterministic, scans `sessions` + `streaks` for thresholds (7-day 🔥, 100 sessions 💯, etc.)
- `FeatureGating.canUseFullAchievementsHistory` (free = unlocked badges today + 7-day window; Pro = full history)

### 4.6 Reviews carousel (paywall)

Static `assets/reviews.json` marketing copy per plan §9.5 (not user reviews, to avoid fake-review policy issues).

## 5. Architecture, Testing, File Boundaries (Section 4 of brainstorm)

- `domain/` — pure Dart, no Flutter, no 3rd-party. New: coach_message, achievement entities; coach_repository abstract; send_coach_message, render_share_card, evaluate_achievements usecases. Pure-Dart unit tests.
- `data/` — Flutter + 3rd-party OK. New: gemini_client, coach_repository_impl, coach_reply_service, journal_entries_table, sessions_table userId migration, share_card_renderer. Drift `onUpgrade` for journal + settings columns.
- `presentation/` — only Flutter widgets/screens. New screens under their own subfolders. No Drift/Firebase/Gemini imports — always via Riverpod providers / repos.

Test discipline (full): existing 103 tests stay green; `flutter analyze` + `flutter test` after each task; only commit when both pass. New tests: `evaluate_achievements_test`, `send_coach_message_test`, `coach_reply_service_test`, `app_colors_extension_test`, `journal_entries_table_test`, plus widget smoke tests for every new screen (splash, explore, coach, achievements, challenges, journal, referral, share_card, appearance, edit_profile, session_detail). Baseline grows 103 → ~140+.

## 6. New Dependencies (all free)

- `google_generative_ai: ^0.4.6` — Gemini SDK
- `flutter_launcher_icons: ^0.14.3` (dev) — icon mipmaps
- `fl_chart: ^0.69.0` — Insights charts

`share_plus`, `RepaintBoundary`, `dart:ui`, Drift, Riverpod already present.

## 7. Execution Order (Section 5 of brainstorm)

Each phase ends with `flutter analyze` clean + `flutter test` green + commit.

- **P1 — Tokens & theme infra.** Rewrite constants + theme files + ThemeExtension + ThemeController + body-glow CustomPaint. ~6 commits
- **P2 — Layout shell + bottom nav + routing.** 5th `/coach` tab; `/streak`→Profile menu; new routes; `app_bar` v4 back-button style. ~3 commits
- **P3 — Real-data foundation for NEW screens.** `journal_entries` table + migration; settings columns; build_runner; achievements usecase; coach backend (Gemini + offline fallback); pubspec deps + key injection docs. ~5 commits
- **P4 — Restyle existing screens to v4.** All 12 existing screens (herit-via-theme + per-screen visual work); wire analytics + Sentry PII + notif-on-init. ~15 commits
- **P5 — Build new screens.** The 10 new screens, each with widget smoke test. ~11 commits
- **P6 — Cross-cutting §4 + assets.** HC manifest + permission flow; 3 `.wav` audio chimes; audio_cue extensions aligned; sessions userId; single-DB audit; Workmanager init verify; app icon. ~5 commits
- **P7 — Verify.** Analyze clean, tests ≥140 green, build APK, manual smoke pass end-to-end (splash → onboarding → sign-in → home → session → summary → share → coach → achievements → paywall → appearance accent-switch live → dark-toggle → offline-coach fallback).

## 8. Definition of Done

Every screen reads real Drift/Firebase/Gemini data (zero hardcoded mocks except intentional static `assets/challenges.json`, `assets/reviews.json`, `assets/protocols.json`). All Pro gates match `FeatureGating` (with new `canUseCoach` + `canUseFullAchievementsHistory`). v4 visuals pixel-faithful. Dark + light both polished. Audio cues + icon mipmaps present. Release APK runs a full session offline + online.
