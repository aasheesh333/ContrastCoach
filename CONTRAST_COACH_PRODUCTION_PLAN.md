# ContrastCoach — Production Readiness Plan

> **Purpose:** Complete analysis of the ContrastCoach Flutter app at commit `1c2fe93` on `main`, with a detailed task-by-task plan for other agents to bring it to production-ready, publish-ready status.
>
> **Analyzed by:** World-class UI/UX developer + senior software engineer review
> **Date:** 2026-06-21
> **Repo:** `aasheesh333/ContrastCoach`
> **Commit:** `1c2fe93` — "fix(home): catch FirebaseException in proxy so test env doesn't throw"

---

## Table of Contents

1. [Commit 1c2fe93 Analysis](#1-commit-1c2fe93-analysis)
2. [What Is Done](#2-what-is-done)
3. [What Is Left (Per CONTRAST_COACH_PLAN)](#3-what-is-left-per-contrast_coach_plan)
4. [Critical Bugs (P0 — Blocks Production)](#4-critical-bugs-p0--blocks-production)
5. [High-Severity Issues (P1 — Breaks Core UX)](#5-high-severity-issues-p1--breaks-core-ux)
6. [Medium Issues (P2 — Polish & Compliance)](#6-medium-issues-p2--polish--compliance)
7. [UI/UX Analysis & Improvements](#7-uiux-analysis--improvements)
8. [Privacy & Security Audit](#8-privacy--security-audit)
9. [CI/CD & Build Pipeline Issues](#9-cicd--build-pipeline-issues)
10. [Production Readiness Task List](#10-production-readiness-task-list)
11. [Environment Variables for GitHub Actions Secrets](#11-environment-variables-for-github-actions-secrets)
12. [File-by-File Change Matrix](#12-file-by-file-change-matrix)
13. [Testing Strategy](#13-testing-strategy)
14. [Pre-Launch Checklist](#14-pre-launch-checklist)

---

## 1. Commit 1c2fe93 Analysis

**Commit message:** `fix(home): catch FirebaseException in proxy so test env doesn't throw`
**Date:** 2026-06-17
**Files changed:** 2 (16 additions, 2 deletions)

### What was done in this commit:

1. **`firebase_auth_proxy.dart`** — Refactored `FirebaseAuthNullableProxy` from a static field (`static fb.FirebaseAuth auth = fb.FirebaseAuth.instance`) to a safe `tryGet()` method that catches exceptions when Firebase isn't initialized (test environment). Added a getter `auth` that throws `StateError('Firebase not initialized')` if `tryGet()` returns null.

2. **`home_screen.dart`** — Changed the test-environment bail-out check from `FirebaseAuthNullableProxy.auth == null` to `FirebaseAuthNullableProxy.tryGet() == null` to avoid throwing when Firebase isn't wired up in tests.

### Assessment of this commit:
This is a **test infrastructure fix**, not a feature or production fix. It correctly prevents `FirebaseAuth.instance` from throwing `[core/no-app] Firebase has not been initialized` in widget tests. The approach is sound — wrapping the access in try/catch and providing a nullable variant. However, it reveals a deeper architectural issue: **the app has no dependency injection or service locator pattern**, so every screen directly instantiates Firebase, Drift, and repository objects. This makes testing fragile and creates resource leaks (see Bug #5 below).

---

## 2. What Is Done

### Architecture (Complete)
- ✅ 3-layer Clean Architecture: `domain/` (pure Dart), `data/` (Drift, Firebase, HC, RevenueCat), `presentation/` (Flutter widgets)
- ✅ GoRouter with 16+ routes, ShellRoute for tabbed screens
- ✅ Drift database with 6 tables (sessions, phases, streaks, settings, health_snapshots, custom_protocols)
- ✅ SQLCipher encryption via `flutter_secure_storage` key provider
- ✅ Result type (Ok/Err) for error handling
- ✅ AppException hierarchy (Auth, Database, Health, Subscription, Validation)

### Features (Implemented)
- ✅ Onboarding (3 steps + medical disclaimer dialog)
- ✅ Home screen with greeting, hero start card, quick stats, goal grid, recent session card
- ✅ Active session screen with ticker-based countdown, phase progression, voice control, audio cues
- ✅ Session summary with recovery score card, insights, streak banner
- ✅ Streak calendar (12-week GitHub-style heatmap grid)
- ✅ Insights screen with range selector (week/month/year), 5-7 deterministic insights
- ✅ Settings screen with profile card, appearance, health, privacy, data export, delete account
- ✅ Auth: email/password sign-in + sign-up + Google Sign-In
- ✅ Paywall screen with RevenueCat offerings, purchase, restore
- ✅ Custom protocol builder (phase editor, duration/temp sliders, validation)
- ✅ Health Connect client (read HR, HRV, sleep, steps, workouts; write MindfulSession)
- ✅ Data export to JSON
- ✅ Account deletion (local + Firebase)
- ✅ Privacy policy, medical disclaimer
- ✅ 10 protocols in protocols.json (3 free, 6 pro, 1 custom placeholder)
- ✅ Recovery score calculator (6 factors: adherence, rounds, temp delta, time of day, sleep, HRV)
- ✅ Voice command parser (10 commands: next, pause, resume, end, how long, etc.)
- ✅ Audio cue service (3 WAV files: session_start, phase_transition, session_complete)
- ✅ Notification service (5 channels: streak, timing, insight, subscription, health)
- ✅ Firestore sync API (computed metrics only, never raw health data)
- ✅ Firestore security rules (user owns data, raw health fields forbidden)
- ✅ Crashlytics client
- ✅ Deep links (contrastcoach:// and https://contrastcoach.app)
- ✅ Android flavors (dev, prod)
- ✅ CI workflow (analyze + test + build debug APK)
- ✅ Release workflow (build AAB + universal APK + Play Store internal track)
- ✅ 103 unit/widget tests

### Design System (Implemented but diverges from plan — see Section 7)
- ✅ Warm/cool color palette (orange + blue brand colors)
- ✅ Plus Jakarta Sans typography system with JetBrains Mono for timer
- ✅ Light + dark themes
- ✅ Atomic widget library (AppButton, AppCard, AppChip, AppDivider, AppIcon, AppSlider, AppSwitch, AppTextField)
- ✅ Composite widgets (HeroStartCard, InsightBlock, ProgressBar, QuickStatsRow, RecoveryScore, SessionTimer, StreakCalendar)
- ✅ Layout widgets (AppBar, BottomNav, SheetContainer)

---

## 3. What Is Left (Per CONTRAST_COACH_PLAN)

### Critical Incomplete Items (from CONTRASTCOACH_MEMORY.md)

| # | Task | Plan Ref | Status | Impact |
|---|------|----------|--------|--------|
| 1 | Feature gating (Pro vs Free) | §8.2 | ❌ **FILE IS EMPTY** — `feature_gating.dart` exists but contains only whitespace | Free users access ALL Pro features |
| 2 | Firebase real config injection | T43 | ⚠️ Uses `.env.example` with hardcoded values, no `--dart-define` in CI | Auth/sync fails in production builds |
| 3 | Analytics API not called everywhere | T60 | ⚠️ Partially wired (active session + paywall) but not subscription repo | Missing analytics events |
| 4 | Restore purchases on cold start | §8 | ✅ Done in `main.dart` (`_restoreOnLaunch`) | OK |
| 5 | Paywall gate on Home + other screens | §8.2 | ❌ No gating anywhere | Pro features freely accessible |
| 6 | Health Connect permission flow | T49 | ✅ Wired in `health_connect_screen.dart` | OK |
| 7 | Sentry/Crashlytics PII stripping | T59 | ❌ No `beforeSend`, no PII stripping | Privacy violation |
| 8 | Manual control buttons (88dp) | §3.4 | ❌ No manual next/pause/resume buttons | Voice-only control, no fallback |
| 9 | Workmanager initialization | T41 | ❌ `SyncWorker.init()` never called in `main.dart` | Background sync doesn't run |
| 10 | App icon conversion | T63 | ❌ SVG exists, not converted to mipmaps | Default Flutter icon |
| 11 | Notification channels on init | T41 | ✅ Done in `NotificationService.init()` | OK |
| 12 | Auth state persistence | §3 | ❌ No SharedPreferences/Hive for onboarding/auth state | Users re-onboard every launch |
| 13 | Google Sign-In | §3 | ✅ Implemented in auth repo + sign-in screen | OK |
| 14 | Health Connect revoke detection | §3.5 | ❌ No `permissionsRevokedStream` subscription | Silent failure when revoked |
| 15 | HC rate-limit detection | §3.5 | ❌ No retry/backoff | Crashes on throttle |
| 16 | Integration tests | §5 | ❌ Only unit/widget tests | No E2E coverage |
| 17 | Voice TTS confirmation | §3.4 | ❌ No text-to-speech response | No audio feedback for voice commands |
| 18 | Hydrated session resume | T29 | ❌ No "resume last protocol" on home | Users re-select every time |

---

## 4. Critical Bugs (P0 — Blocks Production)

### Bug P0-1: `feature_gating.dart` is empty — no Pro/Free gating exists

**File:** `lib/core/feature_gating.dart`
**Evidence:** File exists but contains only whitespace (3 blank lines).
**Impact:** Free users can access ALL Pro features: Pro protocols (sleep_evening, immunity_weekly, wim_hof_classic, deep_cold_training, sauna_focus, cold_only_deep), Health Connect, voice control, cloud sync, insights, custom protocol builder. RevenueCat subscription is meaningless.
**Fix:**
```dart
// lib/core/feature_gating.dart
import 'package:contrast_coach/domain/entities/subscription_tier.dart';

class FeatureGating {
  const FeatureGating._();

  static const _freeProtocols = {
    'recovery_standard', 'energy_morning', 'gentle_beginner',
  };

  static bool canAccessProtocol(String protocolId, SubscriptionTier tier) {
    if (tier.isPro) return true;
    return _freeProtocols.contains(protocolId);
  }

  static bool canUseHealthConnect(SubscriptionTier tier) => tier.isPro;
  static bool canUseVoiceControl(SubscriptionTier tier) => tier.isPro;
  static bool canUseCloudSync(SubscriptionTier tier) => tier.isPro;
  static bool canUseInsights(SubscriptionTier tier) => tier.isPro;
  static bool canUseCustomProtocols(SubscriptionTier tier) => tier.isPro;
}
```
Then wire checks into: HomeScreen (goal grid → check protocol), ActiveSessionScreen (check before starting), InsightsScreen, CustomProtocolBuilderScreen, HealthConnectScreen, SettingsScreen (voice toggle).

### Bug P0-2: No auth guard / route redirect — users bypass sign-in

**File:** `lib/app.dart`, `lib/presentation/routing/app_router.dart`
**Evidence:** `ContrastCoachApp` always constructs with `isOnboarded: false, isAuthed: false`. No `GoRouter.redirect` logic. No FirebaseAuth state listener.
**Impact:** Users can navigate directly to `/home` without signing in. After sign-in, restarting the app shows onboarding again.
**Fix:** Add a redirect based on FirebaseAuth state + SharedPreferences for onboarding:
```dart
// In app_router.dart, add redirect:
redirect: (context, state) {
  final authed = FirebaseAuth.instance.currentUser != null;
  final isOnboardingComplete = prefs.getBool('onboarded') ?? false;
  final path = state.uri.path;
  if (!isOnboardingComplete && path != '/onboarding') return '/onboarding';
  if (isOnboardingComplete && !authed && !path.startsWith('/sign')) return '/sign-in';
  if (isOnboardingComplete && authed && (path == '/onboarding' || path.startsWith('/sign'))) return '/home';
  return null;
},
```
Also: persist onboarding completion in SharedPreferences. Use a `StreamBuilder` around `FirebaseAuth.instance.authStateChanges()` to rebuild the router when auth state changes.

### Bug P0-3: Database instance leak — every screen opens a new SQLite connection

**Files:** `home_screen.dart`, `session_summary_screen.dart`, `insights_screen.dart`, `streak_calendar_screen.dart`, `settings_screen.dart`, `data_export_screen.dart`, `delete_account_screen.dart`, `active_session_screen.dart`
**Evidence:** Each screen does:
```dart
final keyProvider = SqlcipherKeyProvider(storage: const FlutterSecureStorage());
final key = await keyProvider.getOrCreateKey();
final db = AppDatabase(key);
final repo = SessionRepositoryImpl(db);
```
`AppDatabase` is never closed (except in `custom_protocol_builder_screen.dart`). Each creates a new `LazyDatabase` → new SQLite file handle.
**Impact:** Memory leak, file descriptor exhaustion, potential database lock contention. On low-end Android devices, this will crash after navigating between screens several times.
**Fix:** Create a singleton or Riverpod provider for `AppDatabase`:
```dart
// lib/data/local/database/database_provider.dart
final databaseProvider = Provider<AppDatabase>((ref) {
  // Key obtained once, DB opened once
  return AppDatabase(key); // disposed via ref.onDispose
});
```
Or at minimum, a singleton pattern with lazy initialization.

### Bug P0-4: Sessions saved without `userId` — cloud sync silently fails

**File:** `lib/presentation/screens/session/active_session_screen.dart`
**Evidence:** `_buildSession()` creates a `Session` without setting `userId`:
```dart
final session = Session(
  id: const Uuid().v4(),
  protocolId: widget.protocolId,
  // userId is NOT set — defaults to null
  ...
);
```
**Impact:** The sync worker filters sessions by `userId`:
```dart
final userIds = sessions.map((s) => (s as dynamic).userId as String?).where((id) => id != null)...
```
Sessions with null userId are skipped. Cloud sync never uploads any sessions.
**Fix:** Set `userId` from `FirebaseAuth.instance.currentUser?.uid`:
```dart
userId: FirebaseAuthNullableProxy.tryGet()?.currentUser?.uid,
```

### Bug P0-5: `SyncWorker.init()` never called — background sync doesn't run

**File:** `lib/main.dart`
**Evidence:** `main()` calls `_initFirebaseSafely()`, `_initNotificationsSafely()`, `_initCrashlyticsSafely()`, `RevenueCatBootstrap.init()`, `_restoreOnLaunch()` — but never calls `SyncWorker.init()`.
**Impact:** The 15-minute periodic sync task is never registered with Workmanager. Sessions never sync to Firestore in the background.
**Fix:** Add to `main.dart`:
```dart
await SyncWorker.init();
```

### Bug P0-6: CI/CD doesn't inject env variables — release builds use placeholder Firebase config

**Files:** `.github/workflows/ci.yml`, `.github/workflows/release-internal.yml`
**Evidence:** Neither workflow passes `--dart-define` for `FIREBASE_API_KEY`, `FIREBASE_PROJECT_ID`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_STORAGE_BUCKET`, `REVENUECAT_API_KEY`. The build commands are just `flutter build apk --debug --flavor dev` and `flutter build appbundle --release --flavor prod`.
**Impact:** Production AAB will use placeholder Firebase config (`'placeholder-api-key'`, `'1:0000000000:android:...'`). Auth, Firestore sync, Analytics, and Crashlytics will all fail in production. RevenueCat won't initialize (no API key).
**Fix:** Add `--dart-define` flags to build commands using GitHub Actions secrets:
```yaml
- name: Build App Bundle
  run: |
    flutter build appbundle --release --flavor prod \
      --dart-define=FIREBASE_API_KEY=${{ secrets.FIREBASE_API_KEY }} \
      --dart-define=FIREBASE_PROJECT_ID=${{ secrets.FIREBASE_PROJECT_ID }} \
      --dart-define=FIREBASE_APP_ID=${{ secrets.FIREBASE_APP_ID }} \
      --dart-define=FIREBASE_MESSAGING_SENDER_ID=${{ secrets.FIREBASE_MESSAGING_SENDER_ID }} \
      --dart-define=FIREBASE_STORAGE_BUCKET=${{ secrets.FIREBASE_STORAGE_BUCKET }} \
      --dart-define=REVENUECAT_API_KEY=${{ secrets.REVENUECAT_API_KEY }} \
      --dart-define=ENV=prod
```

### Bug P0-7: Release build signed with debug keys — Play Store will reject

**File:** `contrast_coach/android/app/build.gradle`
**Evidence:**
```gradle
buildTypes {
    release {
        signingConfig signingConfigs.debug
    }
}
```
**Impact:** Play Store requires release-signed AABs. Debug-signed builds cannot be uploaded.
**Fix:** Create `key.properties` (from GitHub secret) and configure release signing:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

buildTypes {
    release {
        signingConfig signingConfigs.create('release') {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
}
```

### Bug P0-8: `EnvConfig.init()` loads `.env.example` instead of `.env`

**File:** `lib/core/env/env_config.dart`
**Evidence:**
```dart
await dotenv.load(fileName: '.env.example');
```
**Impact:** The app loads the example env file (which has hardcoded placeholder Firebase values and empty RevenueCat key) instead of real environment variables. Even if `--dart-define` is used, the dotenv fallback will override with wrong values if the `String.fromEnvironment` check fails.
**Fix:** Change to load `.env` (which should be in `.gitignore`), or better: remove dotenv entirely and rely only on `--dart-define`:
```dart
static Future<void> init() async {
  _initialized = true;
  // --dart-define values are available at compile time, no file needed
}
```

### Bug P0-9: ActiveSessionScreen and PaywallScreen crash if Firebase not initialized

**Files:** `active_session_screen.dart`, `paywall_screen.dart`
**Evidence:**
```dart
// active_session_screen.dart
final AnalyticsApi _analytics = AnalyticsApi(FirebaseAnalytics.instance);

// paywall_screen.dart
final AnalyticsApi _analytics = AnalyticsApi(FirebaseAnalytics.instance);
```
Unlike `home_screen.dart` which uses `FirebaseAuthNullableProxy.tryGet()`, these screens directly access `FirebaseAnalytics.instance` which throws if Firebase isn't initialized.
**Impact:** If Firebase init fails (network issue, misconfigured project), the active session screen and paywall screen will crash on construction.
**Fix:** Wrap in try/catch or use a nullable analytics proxy similar to `FirebaseAuthNullableProxy`:
```dart
AnalyticsApi? _analytics;
// In initState:
try {
  _analytics = AnalyticsApi(FirebaseAnalytics.instance);
} catch (_) {
  _analytics = null;
}
```

---

## 5. High-Severity Issues (P1 — Breaks Core UX)

### P1-1: No Riverpod state management despite dependency

**Files:** All screens in `lib/presentation/screens/`
**Evidence:** `pubspec.yaml` includes `flutter_riverpod: ^2.6.1` and `riverpod_annotation: ^2.6.1` but NO screen uses Riverpod. All use `StatefulWidget` + `setState()`.
**Impact:**
- No reactive subscription state (if user purchases Pro in paywall, home screen doesn't update)
- No shared state (each screen independently loads from DB)
- Database instances created per-screen (see P0-3)
- No global error handling
- Settings changes don't propagate
**Fix:** Migrate to Riverpod with providers for:
- `databaseProvider` — singleton AppDatabase
- `sessionRepositoryProvider` — singleton SessionRepositoryImpl
- `subscriptionProvider` — StreamProvider watching RevenueCat tier
- `authProvider` — StreamProvider watching FirebaseAuth state
- `settingsProvider` — user preferences (theme, voice, notifications, analytics opt-in)

### P1-2: Settings toggles are non-functional

**File:** `lib/presentation/screens/settings/settings_screen.dart`
**Evidence:**
```dart
bool _voice = true;
bool _notifications = true;
// ...
AppSwitch(value: _voice, onChanged: (v) => setState(() => _voice = v))
AppSwitch(value: _notifications, onChanged: (v) => setState(() => _notifications = v))
```
Theme picker shows "System" and accent color shows "Orange" — both are static labels with no functionality.
**Impact:** Users can toggle switches but changes don't persist, don't affect behavior, and reset on screen exit.
**Fix:** Persist settings in Drift `settings` table or SharedPreferences. Wire toggles to actual behavior:
- Voice toggle → controls whether `ActiveSessionScreen` initializes speech-to-text
- Notifications toggle → controls whether `NotificationService` schedules reminders
- Theme picker → changes `ThemeMode` in `MaterialApp.router`
- Analytics toggle → enables/disables `FirebaseAnalytics` collection

### P1-3: Privacy screen analytics toggle doesn't disable analytics

**File:** `lib/presentation/screens/settings/privacy_screen.dart`
**Evidence:**
```dart
bool _analytics = true;
AppSwitch(value: _analytics, onChanged: (v) => setState(() => _analytics = v))
```
**Impact:** Privacy policy says "Opt out of analytics — Settings → Privacy → Analytics off" but the toggle does nothing. `AnalyticsApi` always sends events. This is a **privacy violation** and **Play Store Data Safety form discrepancy**.
**Fix:**
```dart
// Persist the setting
await prefs.setBool('analytics_enabled', v);
// In AnalyticsApi:
Future<void> track(String eventName, {Map<String, Object>? params}) async {
  if (!analyticsEnabled) return; // Check persisted setting
  await _analytics.logEvent(name: eventName, parameters: params);
}
```

### P1-4: No onboarding/auth state persistence

**Files:** `lib/app.dart`, `lib/presentation/screens/onboarding/onboarding_screen.dart`
**Evidence:** `ContrastCoachApp` hardcodes `isOnboarded: false, isAuthed: false`. Onboarding completion is never saved. Auth state is never checked at startup.
**Impact:** Users see onboarding every app launch. After signing in, restarting shows onboarding → sign-in again.
**Fix:** Use `shared_preferences` to persist onboarding completion. Use `FirebaseAuth.instance.authStateChanges()` stream to drive the router's initial location and redirects.

### P1-5: Voice control starts without microphone permission

**File:** `lib/presentation/screens/session/active_session_screen.dart`
**Evidence:**
```dart
Future<void> _initVoice() async {
  final ok = await _stt.init();
  if (ok && mounted) {
    setState(() => _voiceActive = true);
    _startListening(); // Starts listening without requesting RECORD_AUDIO permission
  }
}
```
`SpeechToTextClient.requestPermission()` exists but is never called.
**Impact:** On Android 13+, microphone access requires runtime permission. `speech_to_text` may handle this internally on some platforms, but the app should explicitly request it. If permission is denied, voice control silently fails.
**Fix:**
```dart
Future<void> _initVoice() async {
  final hasPermission = await _stt.requestPermission();
  if (!hasPermission) return;
  final ok = await _stt.init();
  if (ok && mounted) {
    setState(() => _voiceActive = true);
    _startListening();
  }
}
```

### P1-6: No manual control buttons in ActiveSessionScreen

**File:** `lib/presentation/screens/session/active_session_screen.dart`
**Evidence:** The screen has only a text "End session" button. No "Next phase", "Pause", "Resume" buttons. The `SessionTimer` widget has `onPause` and `onMic` callbacks but no "Next phase" button.
**Impact:** If voice control fails (no mic permission, noisy environment, speech-to-text unavailable), users have NO way to advance phases. They can only end the session.
**Fix:** Add manual control buttons (minimum 88dp touch targets per plan):
```dart
// Bottom area: Next Phase button (primary), Pause/Resume toggle, End Session
Row(
  children: [
    Expanded(
      child: AppButton(
        label: _paused ? 'Resume' : 'Pause',
        onPressed: _togglePause,
        fullWidth: true,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: AppButton(
        label: 'Next phase',
        onPressed: () => _advanceToNextPhase(_totalPhaseElapsed + _lastElapsed),
        variant: AppButtonVariant.warm,
        fullWidth: true,
      ),
    ),
  ],
),
```

### P1-7: Streak calculation resets to 0 if user hasn't session today

**File:** `lib/domain/usecases/session_stats.dart`
**Evidence:**
```dart
var cursor = DateTime.now();
cursor = DateTime(cursor.year, cursor.month, cursor.day);
while (days.contains(cursor)) {
  streak++;
  cursor = cursor.subtract(const Duration(days: 1));
}
```
**Impact:** If user did sessions Mon, Tue, Wed but not today (Thursday), streak shows 0. This is demotivating and incorrect — the streak should be 3 (ending yesterday).
**Fix:**
```dart
// Start from today; if today has no session, start from yesterday
var cursor = DateTime.now();
cursor = DateTime(cursor.year, cursor.month, cursor.day);
if (!days.contains(cursor)) {
  cursor = cursor.subtract(const Duration(days: 1));
}
while (days.contains(cursor)) {
  streak++;
  cursor = cursor.subtract(const Duration(days: 1));
}
```

### P1-8: Health data snapshot not saved with session

**File:** `lib/presentation/screens/session/active_session_screen.dart`
**Evidence:** `_buildSession()` creates session with no `healthDataSnapshot`:
```dart
final session = Session(
  id: ...,
  // healthDataSnapshot is not set — defaults to null
);
```
**Impact:** Even if Health Connect is connected and data is read, the health snapshot (HRV, sleep) is never incorporated into the session. The recovery score calculator accepts `lastNightSleepMinutes` and `hrvRmssdTrend7Day` but they're never passed. Recovery score is based only on adherence, rounds, temp delta, and time of day.
**Fix:** Before building the session, read from Health Connect:
```dart
final healthClient = HealthConnectClient();
final snapResult = await healthClient.readSnapshot();
final snapshot = snapResult is Ok ? snapResult.value : null;
// Pass to calculateRecoveryScore:
final score = calculateRecoveryScore(
  session: session,
  lastNightSleepMinutes: snapshot?.lastNightSleepMinutes,
  hrvRmssdTrend7Day: snapshot?.hrvRmssdTrend7Day,
);
// Save snapshot with session:
healthDataSnapshot: snapshot != null ? {
  'sleepMinutes': snapshot.lastNightSleepMinutes,
  'hrvRmssd7DayAvg': snapshot.hrvRmssd7DayAvg,
  'hrvRmssdTrend7Day': snapshot.hrvRmssdTrend7Day,
} : null,
```

### P1-9: Home screen has duplicate bottom navigation bar

**Files:** `lib/presentation/screens/home/home_screen.dart`, `lib/presentation/screens/shell/home_shell.dart`, `lib/presentation/routing/app_router.dart`
**Evidence:** `HomeScreen` includes `bottomNavigationBar: ContrastBottomNav(...)` in its Scaffold. But `/home` is inside a `ShellRoute` that wraps with `HomeShell`, which ALSO has `ContrastBottomNav`. Two bottom nav bars render.
**Impact:** Double bottom nav on home screen. Visually broken.
**Fix:** Remove `bottomNavigationBar` from `HomeScreen`'s Scaffold. The `HomeShell` already provides it.

### P1-10: No error states for database failures

**Files:** All screens that load from Drift
**Evidence:** Every screen shows `CircularProgressIndicator` while loading, then content. If the database fails to open (corruption, encryption error), the spinner spins forever. No error UI, no retry button.
**Fix:** Add error state to each screen:
```dart
if (_error != null) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Something went wrong'),
        const SizedBox(height: 16),
        AppButton(label: 'Retry', onPressed: _load),
      ],
    ),
  );
}
```

---

## 6. Medium Issues (P2 — Polish & Compliance)

### P2-1: No Crashlytics PII stripping
**File:** `lib/data/remote/crash/crashlytics_client.dart`
**Issue:** `setUserIdentifier('')` is set but no `beforeSend` filter. Crash logs may contain voice transcripts, health data references, or user IDs in stack traces.
**Fix:** The plan originally called for Sentry's `beforeSend`, but the app switched to Crashlytics. Crashlytics doesn't have `beforeSend`, but you can:
- Strip PII from error messages before recording
- Use `customKeys` instead of embedding data in messages
- Avoid logging voice transcripts or health data in `CrashlyticsClient.log()`

### P2-2: No Health Connect permission revoke detection
**File:** `lib/data/local/health/health_connect_client.dart`
**Issue:** Plan requires subscribing to `permissionsRevokedStream`. Not implemented.
**Fix:** Add a stream subscription in the Health Connect screen or a global provider.

### P2-3: No HC rate-limit / retry logic
**File:** `lib/data/local/health/health_connect_client.dart`
**Issue:** No retry/backoff if Health Connect throttles requests.
**Fix:** Add exponential backoff with max 3 retries.

### P2-4: Account deletion doesn't cancel Workmanager or revoke HC
**File:** `lib/presentation/screens/settings/delete_account_screen.dart`
**Issue:** `deleteAllUserData` deletes local sessions and Firebase account, but doesn't:
- Cancel the Workmanager periodic sync task
- Revoke Health Connect permissions
- Clear the SQLCipher key from secure storage
- Clear SharedPreferences
**Fix:** Add cleanup steps after deletion.

### P2-5: Data export saves to app-private directory with no share
**File:** `lib/presentation/screens/settings/data_export_screen.dart`
**Issue:** Export writes to `getApplicationDocumentsDirectory()` which is app-private. Users can't access the file without a file manager. No share sheet.
**Fix:** Use `share_plus` package to show a share sheet, or save to Downloads via `getExternalStorageDirectory()`.

### P2-6: No medical disclaimer on insights screen
**File:** `lib/presentation/screens/insights/insights_screen.dart`
**Issue:** Plan requires medical disclaimer on insights screen. Not present.
**Fix:** Add `MedicalDisclaimerDialog` reference or a footer text with the disclaimer.

### P2-7: README is outdated
**File:** `README.md`
**Issue:** Says "Pre-development" (app is nearly complete). Mentions Supabase (uses Firebase), Sentry (uses Crashlytics), Umami (uses Firebase Analytics), iOS (Android-only). Repository layout is wrong.
**Fix:** Update README with current status, correct tech stack, correct layout.

### P2-8: App icon not converted from SVG
**File:** `assets/app_icon.svg`
**Issue:** SVG exists but Android uses default Flutter icon (`@mipmap/ic_launcher`).
**Fix:** Convert SVG to PNG at multiple densities (mdpi: 48x48, hdpi: 72x72, xhdpi: 96x96, xxhdpi: 144x144, xxxhdpi: 192x192) and place in `android/app/src/main/res/mipmap-*/`. Also create adaptive icon (foreground + background).

### P2-9: No R8/ProGuard rules for release
**File:** `android/app/proguard-rules.pro` (missing)
**Issue:** Release builds may fail or crash due to obfuscation stripping needed classes. RevenueCat, Firebase, and Drift may need keep rules.
**Fix:** Add `proguard-rules.pro` with keep rules for:
```
-keep class com.revenuecat.purchases.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
```

### P2-10: `withOpacity` deprecation
**Files:** Multiple (home_screen, sign_in_screen, sign_up_screen, health_connect_screen, delete_account_screen, data_export_screen, paywall_screen, etc.)
**Issue:** `Color.withOpacity()` is deprecated in Flutter 3.27+. The project uses Flutter 3.24.5 so it works now, but will break on upgrade.
**Fix:** Replace with `Color.withValues(alpha: ...)` when upgrading Flutter.

### P2-11: No integration tests
**Issue:** Only unit/widget tests. Plan calls for Patrol integration tests for core flows (onboarding → sign-in → start session → summary → streak).
**Fix:** Add `integration_test/` directory with Patrol tests for:
- Onboarding flow
- Sign-in flow
- Start session → complete → summary
- Streak calendar display
- Settings navigation

### P2-12: No loading/error state on Paywall when RevenueCat not configured
**File:** `lib/presentation/screens/paywall/paywall_screen.dart`
**Issue:** If `REVENUECAT_API_KEY` is empty (which it is in `.env.example`), `RevenueCatBootstrap.init()` silently returns. `getOfferings()` returns empty list. Paywall shows no packages with no explanation.
**Fix:** Show a message: "Subscriptions are currently unavailable. Please try again later." when packages list is empty.

### P2-13: Custom protocol builder doesn't list existing custom protocols
**File:** `lib/presentation/screens/custom_protocol/custom_protocol_builder_screen.dart`
**Issue:** Users can create custom protocols but can't see, edit, or delete existing ones. `CustomProtocolRepository.getAll()` exists but isn't called.
**Fix:** Add a list of existing custom protocols at the top of the screen with edit/delete actions.

### P2-14: No haptic feedback on primary actions
**Issue:** Plan specifies "Haptic feedback only on primary actions." Not implemented anywhere.
**Fix:** Add `HapticFeedback.lightImpact()` on session start, phase advance, and save.

### P2-15: No spring physics animations
**Issue:** Plan specifies `spring(stiffness: 380, dampingRatio: 0.8)` for all transitions. Not implemented.
**Fix:** Use `SpringSimulation` or `AnimatedContainer` with spring curves.

---

## 7. UI/UX Analysis & Improvements

### 7.1 Design System Divergence (MAJOR)

The master plan specifies **"Monochrome Material 3 Expressive"** with strict rules:
- "No blue, red, green, orange, or any chromatic accent. Ever."
- "No gradients except monochrome tonal."
- "All states communicate via opacity, weight, or shape. Never color."

The actual implementation uses a **warm/cool color palette**:
- `brandWarm = #FF6B35` (vibrant orange)
- `brandCool = #2D7CF1` (bright blue)
- `brandCoral = #FF8A65` (coral)
- `brandCoralPop = #FF6B9D` (pink)
- `success = #4CAF50` (green)
- `error = #E53935` (red)
- Heatmap: 5-level orange gradient
- Gradients: `heat` (orange→coral), `contrast` (orange→blue), `contrastHorizontal`

**Decision needed:** Either:
- **Option A:** Align with the plan — strip ALL chromatic colors, go true monochrome (black/white/gray only). This is a significant redesign.
- **Option B:** Update the plan to accept the warm/cool palette. The current design is actually quite polished and the orange/blue contrast metaphorically represents heat/cold therapy.

**Recommendation:** Option B. The warm/cool palette is more appropriate for a contrast therapy app (orange = heat, blue = cold). The monochrome plan was aspirational but the implemented design is better for this domain. Update the plan docs to match.

### 7.2 Typography Divergence

**Plan:** Inter Tight (display), Inter (body), JetBrains Mono (timer)
**Actual:** PlusJakartaSans (everything), JetBrains Mono (timer only)

All 4 font families are bundled in `assets/fonts/` but only PlusJakartaSans and JetBrainsMono are used. Inter and InterTight are dead weight (1.46MB of unused fonts).

**Fix:** Either use the planned fonts or remove the unused ones from `pubspec.yaml` and `assets/fonts/`.

### 7.3 Screen-by-Screen UI/UX Issues

#### Onboarding
- ✅ 3 steps, no skip, medical disclaimer — matches plan
- ⚠️ Copy doesn't match plan exactly (plan says "Track heat. Track cold. See what works." but actual uses "HEAT.\nCOLD.\nREPEAT.")
- ⚠️ `Spacer()` inside `SingleChildScrollView` + `IntrinsicHeight` is fragile — may not distribute space correctly on small screens
- ⚠️ Page dots use `brandWarm` (orange) — fine if keeping warm/cool palette

#### Home Screen
- ❌ **Double bottom nav** (P1-9) — critical visual bug
- ⚠️ Greeting uses `DateTime.now().hour` but doesn't use timezone-aware datetime
- ⚠️ Goal cards map to protocol IDs but don't check Pro gating — free users can start Pro protocols
- ⚠️ "Custom" button in section header navigates to custom builder without Pro check
- ⚠️ `_RecentSessionCard` shows goal label but not the protocol name or date
- 💡 **Improvement:** Add "Resume last session" quick-start if user has a recent incomplete session
- 💡 **Improvement:** Add pull-to-refresh (already has RefreshIndicator ✅)

#### Active Session Screen
- ❌ **No manual control buttons** (P1-6) — critical UX gap
- ⚠️ Voice control starts without permission check (P1-5)
- ⚠️ `ActiveSessionBackground` uses phase-type-based colors but the plan says "Full-screen black/white. Nothing else."
- ⚠️ Phase pills at top show ALL phase types, not just the current protocol's phases
- ⚠️ Mic button shows a SnackBar but doesn't actually toggle listening or request permission
- ⚠️ No visual indication of voice listening state (active/inactive)
- 💡 **Improvement:** Add a subtle pulsing animation when voice is actively listening
- 💡 **Improvement:** Show "Phase X of Y" text below the timer
- 💡 **Improvement:** Add a confirmation dialog before "End session" (prevent accidental taps)

#### Session Summary
- ✅ Recovery score card, insights, streak banner — well structured
- ⚠️ No "Share" button (plan says "Save / Discard / Share")
- ⚠️ `_Celebration` widget is referenced but its implementation wasn't fully visible — verify it's not just an empty container
- 💡 **Improvement:** Add phase-by-phase breakdown (duration per phase, temp if available)
- 💡 **Improvement:** Add "Start another session" button

#### Streak Calendar
- ✅ 12-week heatmap grid — matches plan concept
- ⚠️ Heatmap uses orange gradient (plan says monochrome)
- ⚠️ No tap-to-see-session-details (plan says "Tap a day to see session details")
- 💡 **Improvement:** Add month labels above the grid
- 💡 **Improvement:** Add a "longest streak" stat

#### Insights Screen
- ✅ Range selector (week/month/year), insight blocks — well structured
- ⚠️ No medical disclaimer (P2-6)
- ⚠️ `GradientHeroStat` uses gradients (plan says no gradients)
- ⚠️ Insights don't include "Recommendations" section (plan specifies it)
- 💡 **Improvement:** Add a simple bar chart for sessions per week (plan says "no charts" but a minimal monochrome bar would aid comprehension)

#### Settings Screen
- ❌ **All toggles non-functional** (P1-2)
- ⚠️ Theme picker and accent color picker are static labels with no functionality
- ⚠️ No "Sign out" button visible (should be in profile section)
- ⚠️ No app version display
- 💡 **Improvement:** Add "Rate the app" and "Share with friends" actions
- 💡 **Improvement:** Add "Help & Support" / FAQ link

#### Paywall Screen
- ✅ Loads offerings from RevenueCat, purchase, restore
- ⚠️ Uses orange→coral gradient background (plan says monochrome, no urgency)
- ⚠️ "UPGRADE" in caps with letter spacing — plan says "No fake urgency"
- ⚠️ Feature list is hardcoded, not dynamic from feature gating
- ⚠️ No "Terms" and "Privacy Policy" links (Play Store requirement for subscriptions)
- ⚠️ No package prices displayed dynamically from RevenueCat (hardcoded `$5.99/mo | $39.99/yr | $89.99 lifetime` in `AppStrings` but not shown in UI from offerings)
- 💡 **Improvement:** Show actual prices from RevenueCat offerings, not hardcoded strings
- 💡 **Improvement:** Add "Manage subscription" link for existing Pro users

#### Auth Screens (Sign In / Sign Up)
- ✅ Email/password + Google sign-in
- ⚠️ No "Forgot password" link on sign-in
- ⚠️ No password visibility toggle
- ⚠️ No email validation (format check)
- ⚠️ No "Sign in anonymously" / "Skip for now" option (plan says privacy-first, should allow local-only mode)
- 💡 **Improvement:** Add biometric auth (Face ID / fingerprint) for returning users

#### Health Connect Screen
- ✅ Permission request + snapshot reading wired
- ⚠️ No "Disconnect" button (privacy policy says "Disconnect Health Connect")
- ⚠️ No permission revoke detection
- 💡 **Improvement:** Show last sync time
- 💡 **Improvement:** Show which data types are being read

#### Custom Protocol Builder
- ✅ Phase editor with type chips, duration/temp sliders
- ⚠️ No Pro gate (P0-1)
- ⚠️ No list of existing custom protocols (P2-13)
- ⚠️ No delete/edit existing protocols
- ⚠️ No "Start session with this protocol" after saving
- 💡 **Improvement:** Add protocol preview (total duration, phase breakdown)
- 💡 **Improvement:** Add templates (start from an existing protocol)

### 7.4 Dark Mode Issues

Many screens hardcode light-mode colors instead of using `Theme.of(context).colorScheme`:
- `AppColors.offWhite` used as background in multiple screens (should be `cs.surface`)
- `AppColors.charcoal` used for text (should be `cs.onSurface`)
- `AppColors.darkGray` for secondary text (should be `cs.onSurfaceVariant`)
- `AppColors.white` for card backgrounds (should be `cs.surfaceContainerLow`)

In dark mode, these hardcoded light colors will make screens look wrong (white cards on dark background, light gray text on dark background).

**Fix:** Replace all hardcoded `AppColors.*` with `Theme.of(context).colorScheme.*` equivalents, or use `AppColors` values that have dark-mode counterparts.

### 7.5 Accessibility

- ⚠️ No `Semantics` labels on icon-only buttons (close, mic, etc.)
- ⚠️ No `MediaQuery.textScaler` support — large text may overflow
- ⚠️ Touch targets: some buttons may be below 48dp minimum
- ⚠️ No `ExcludeSemantics` on decorative elements
- ⚠️ No `MergeSemantics` on composite card widgets

---

## 8. Privacy & Security Audit

### 8.1 Firebase API Key in `.env.example` (committed to repo)

**File:** `contrast_coach/.env.example`
**Content:**
```
FIREBASE_API_KEY=AIzaSyD-tUKrlQsGHQerAhaoDSs-qnF4Ii03UIo
FIREBASE_PROJECT_ID=contrastcoach-1ed0a
FIREBASE_APP_ID=1:1008265304464:android:497d3034401edde6897b15
FIREBASE_MESSAGING_SENDER_ID=1008265304464
FIREBASE_STORAGE_BUCKET=contrastcoach-1ed0a.firebasestorage.app
```
**Risk:** LOW (Firebase API keys are designed to be embedded in client apps and are not secret). However, best practice is to not commit them in example files. The real risk is that `.env.example` is loaded as the actual env file (P0-8).
**Fix:** Remove real values from `.env.example`, use placeholders. Inject real values via `--dart-define` in CI.

### 8.2 Firestore Security Rules

**File:** `firestore.rules`
**Assessment:** Good — users can only read/write their own data. Raw health fields are forbidden. However:
- No rate limiting rules
- No data validation (e.g., ensuring `recoveryScore` is a number 0-100)
- No schema validation
**Fix:** Add data validation rules:
```
allow write: if request.auth != null
  && request.auth.uid == userId
  && request.resource.data.recoveryScore is float
  && request.resource.data.recoveryScore >= 0
  && request.resource.data.recoveryScore <= 100;
```

### 8.3 SQLCipher Encryption

**Assessment:** Good — database is encrypted with a random 256-bit key stored in `flutter_secure_storage` (which uses Android Keystore).
**Issue:** The key is never rotated. If compromised, all historical data is exposed.
**Recommendation:** Acceptable for v1.0. Document key rotation as a future enhancement.

### 8.4 Health Data Handling

**Assessment:** Good — `HealthConnectClient` reads data on-device, only computed metrics (averages, trends) are stored. Raw HR/HRV/sleep values are never persisted to Firestore (enforced by both code and Firestore rules).
**Issue:** Health snapshot is not saved with sessions (P1-8), so the computed metrics aren't even being used yet.

### 8.5 Voice Data

**Assessment:** Good — `speech_to_text` processes on-device. No voice recordings are stored. `voiceLog` field exists in the Phase table but is never populated.
**Issue:** Crashlytics may capture voice transcripts in error messages if a voice command fails. Need PII stripping (P2-1).

### 8.6 Analytics

**Assessment:** 5 event types, no PII. But the opt-out toggle doesn't work (P1-3).
**Events tracked:** `session_started`, `session_completed`, `paywall_viewed`, `subscription_started`, `feature_used`.
**Fix:** Wire the analytics opt-out toggle to `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false)`.

### 8.7 Data Export & Deletion

**Assessment:** Export works (JSON to app directory). Deletion works (local + Firebase). But:
- Export file is in app-private directory (P2-5)
- Deletion doesn't cancel Workmanager or clear secure storage (P2-4)

---

## 9. CI/CD & Build Pipeline Issues

### 9.1 CI Workflow (`ci.yml`)

**Issues:**
- ❌ No `--dart-define` for env variables (P0-6)
- ⚠️ `flutter analyze --no-fatal-infos --no-fatal-warnings || true` — the `|| true` means analyze NEVER fails the build. Lint issues are silently ignored.
- ⚠️ `dart format --set-exit-if-changed lib/ test/ || true` — same, formatting never fails.
- ⚠️ Debug APK build doesn't need env vars but should still verify compilation with real config
- ⚠️ No code coverage reporting (runs `--coverage` but doesn't upload or check threshold)

**Fix:**
- Remove `|| true` from analyze and format steps (or at least from analyze)
- Add `--dart-define` for debug build too (use dev Firebase config)
- Add coverage threshold check (minimum 60% for v1.0)

### 9.2 Release Workflow (`release-internal.yml`)

**Issues:**
- ❌ No `--dart-define` for env variables (P0-6) — production build uses placeholder Firebase
- ❌ No release signing (P0-7) — uses debug keys
- ⚠️ No `google-services.json` — app uses runtime FirebaseOptions, but `google-services.json` is still needed for some Firebase plugins (Crashlytics, Analytics) to work at the native level
- ⚠️ `PLAY_SERVICE_ACCOUNT` secret is checked but upload is `continue-on-error: true` — silent failure
- ⚠️ No version bump automation
- ⚠️ No mapping file upload for Crashlytics (deobfuscation won't work)

**Fix:**
- Add `--dart-define` flags from secrets
- Add release keystore from secret
- Add `google-services.json` from secret (needed for Crashlytics native initialization)
- Remove `continue-on-error: true` from Play Store upload (or add a separate validation step)
- Upload mapping file to Crashlytics

### 9.3 Missing: `google-services.json`

**Issue:** The app uses runtime `FirebaseOptions` from env vars, which works for Firebase Auth and Firestore. However, **Firebase Crashlytics and Firebase Analytics require `google-services.json`** at the native Android level for proper initialization. Without it:
- Crashlytics may not report crashes
- Analytics events may not be sent
- FCM (if added later) won't work

**Fix:** Add `google-services.json` as a GitHub secret and write it to `android/app/` before build. Re-add the `com.google.gms.google-services` Gradle plugin.

### 9.4 Missing: Play Store Signing Key

**Issue:** No upload key for Play Store. The release workflow uses debug signing.
**Fix:** Generate a release keystore, store as base64 in GitHub secret `RELEASE_KEYSTORE`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`. Write `key.properties` in workflow.

---

## 10. Production Readiness Task List

> Tasks are ordered by priority. Each task includes: ID, priority, title, files to modify, estimated effort, and acceptance criteria.

### Phase 1: Critical Fixes (P0 — Must do before any production build)

| ID | Task | Files | Effort | Acceptance |
|----|------|-------|--------|------------|
| T1 | Implement feature gating | `lib/core/feature_gating.dart`, all screens | 4h | Free users cannot access Pro protocols, HC, voice, insights, custom builder. Paywall shown when blocked. |
| T2 | Add auth guard + route redirect | `app_router.dart`, `app.dart`, new `auth_guard.dart` | 3h | Unauthenticated users redirected to sign-in. Onboarding completion persisted. Auth state drives initial route. |
| T3 | Fix database singleton | New `lib/data/local/database/database_provider.dart`, all screens | 3h | Single AppDatabase instance shared across screens. Properly disposed on app exit. |
| T4 | Set userId on session save | `active_session_screen.dart` | 0.5h | Sessions include Firebase user UID. Cloud sync uploads sessions. |
| T5 | Call SyncWorker.init() | `main.dart` | 0.5h | Workmanager registered with 15-min periodic task. |
| T6 | Fix EnvConfig to not load .env.example | `env_config.dart` | 1h | Env vars come from --dart-define only. No .env file loading. |
| T7 | Add --dart-define to CI/CD | `ci.yml`, `release-internal.yml` | 1h | Build commands include all env vars from secrets. |
| T8 | Configure release signing | `build.gradle`, `key.properties` template, `release-internal.yml` | 2h | Release AAB signed with upload key. Play Store accepts upload. |
| T9 | Fix ActiveSessionScreen/PaywallScreen Firebase crash | `active_session_screen.dart`, `paywall_screen.dart` | 1h | Screens handle Firebase not initialized gracefully. |
| T10 | Add google-services.json to CI | `release-internal.yml` | 1h | `google-services.json` written from secret before build. Crashlytics + Analytics work natively. |

### Phase 2: Core UX Fixes (P1 — Must do before user testing)

| ID | Task | Files | Effort | Acceptance |
|----|------|-------|--------|------------|
| T11 | Migrate to Riverpod providers | New providers, all screens | 8h | Shared state for DB, auth, subscription, settings. Reactive updates. |
| T12 | Make settings toggles functional | `settings_screen.dart`, new `settings_provider.dart` | 3h | Voice, notifications, theme, analytics toggles persist and control behavior. |
| T13 | Fix analytics opt-out | `privacy_screen.dart`, `analytics_api.dart` | 1h | Toggle disables Firebase Analytics collection. Persisted in SharedPreferences. |
| T14 | Fix onboarding/auth persistence | `onboarding_screen.dart`, `app.dart`, `app_router.dart` | 2h | Onboarding completion saved. Auth state checked at startup. No re-onboarding. |
| T15 | Fix voice permission | `active_session_screen.dart` | 0.5h | Microphone permission requested before listening. |
| T16 | Add manual control buttons | `active_session_screen.dart` | 1h | Next Phase, Pause/Resume, End buttons with 88dp touch targets. |
| T17 | Fix streak calculation | `session_stats.dart` | 0.5h | Streak counts consecutive days up to last session, not just today. |
| T18 | Save health snapshot with session | `active_session_screen.dart` | 1h | HRV and sleep data passed to score calculator. Snapshot stored with session. |
| T19 | Fix duplicate bottom nav | `home_screen.dart` | 0.5h | Single bottom nav on home (from ShellRoute). |
| T20 | Add error states to all screens | All loading screens | 2h | Database/network errors show error UI with retry button. |

### Phase 3: Privacy & Compliance (P2 — Must do before Play Store submission)

| ID | Task | Files | Effort | Acceptance |
|----|------|-------|--------|------------|
| T21 | Add Crashlytics PII stripping | `crashlytics_client.dart` | 1h | No voice transcripts, health data, or user IDs in crash logs. |
| T22 | Add HC permission revoke detection | `health_connect_client.dart`, `health_connect_screen.dart` | 1h | User notified when HC permissions revoked. Notification sent. |
| T23 | Add HC retry/backoff | `health_connect_client.dart` | 1h | Exponential backoff on rate limit. Max 3 retries. |
| T24 | Fix account deletion cleanup | `delete_account_screen.dart` | 1h | Cancels Workmanager, revokes HC, clears secure storage, clears prefs. |
| T25 | Fix data export with share | `data_export_screen.dart` | 1h | Share sheet shown after export. File accessible to user. |
| T26 | Add medical disclaimer to insights | `insights_screen.dart` | 0.5h | Disclaimer text at bottom of insights screen. |
| T27 | Update README | `README.md` | 1h | Correct status, tech stack, layout. No mention of Supabase/Sentry/Umami. |
| T28 | Convert app icon to mipmaps | `android/app/src/main/res/mipmap-*/` | 1h | Custom app icon at all densities. Adaptive icon configured. |
| T29 | Add ProGuard/R8 rules | `android/app/proguard-rules.pro` | 1h | Release build doesn't crash from obfuscation. |
| T30 | Add Paywall terms/privacy links | `paywall_screen.dart` | 0.5h | Links to Terms of Service and Privacy Policy. Play Store requirement. |
| T31 | Add password visibility toggle + forgot password | `sign_in_screen.dart` | 1h | Eye icon to toggle password visibility. "Forgot password?" link with reset flow. |

### Phase 4: UI/UX Polish

| ID | Task | Files | Effort | Acceptance |
|----|------|-------|--------|------------|
| T32 | Fix dark mode color usage | All screens | 4h | All colors use Theme.of(context).colorScheme. Dark mode looks correct. |
| T33 | Add tap-to-see-details on streak calendar | `streak_calendar.dart`, `streak_calendar_screen.dart` | 2h | Tapping a day shows session details (protocol, duration, score). |
| T34 | Add session phase breakdown in summary | `session_summary_screen.dart` | 1h | Per-phase duration and temp shown. |
| T35 | Add "Start another session" in summary | `session_summary_screen.dart` | 0.5h | Button to start a new session from summary. |
| T36 | Add existing custom protocols list | `custom_protocol_builder_screen.dart` | 2h | List, edit, delete existing custom protocols. Start session with one. |
| T37 | Add haptic feedback | `active_session_screen.dart`, `home_screen.dart` | 0.5h | HapticFeedback on session start, phase advance, save. |
| T38 | Add accessibility labels | All icon buttons | 2h | Semantics labels on all interactive elements. |
| T39 | Add sign-out button | `settings_screen.dart` | 0.5h | Sign-out in profile section. Clears state, navigates to sign-in. |
| T40 | Add app version in settings | `settings_screen.dart`, `about_screen.dart` | 0.5h | Version + build number displayed. |
| T41 | Remove unused fonts or use them | `pubspec.yaml`, `assets/fonts/` | 0.5h | Either use Inter/InterTight or remove them. Save ~1.5MB. |
| T42 | Add Paywall dynamic pricing | `paywall_screen.dart` | 1h | Prices from RevenueCat offerings, not hardcoded strings. |
| T43 | Add "Manage subscription" link | `paywall_screen.dart`, `settings_screen.dart` | 1h | Pro users can manage/cancel subscription. |

### Phase 5: Testing & CI

| ID | Task | Files | Effort | Acceptance |
|----|------|-------|--------|------------|
| T44 | Add integration tests | `integration_test/` | 4h | Patrol tests for onboarding, sign-in, session flow, streak, settings. |
| T45 | Fix CI to fail on lint errors | `ci.yml` | 0.5h | Remove `\|\| true` from analyze step. Lint errors fail CI. |
| T46 | Add coverage threshold | `ci.yml` | 0.5h | Build fails if coverage < 60%. |
| T47 | Add mapping file upload to Crashlytics | `release-internal.yml` | 1h | Mapping file uploaded for deobfuscation. |
| T48 | Add version bump automation | `release-internal.yml` or script | 1h | Version bumped from tag or manual input. |

### Phase 6: Pre-Launch

| ID | Task | Files | Effort | Acceptance |
|----|------|-------|--------|------------|
| T49 | Remove `continue-on-error` from Play upload | `release-internal.yml` | 0.5h | Upload failure fails the workflow. |
| T50 | Verify Firestore rules in production | `firestore.rules` | 1h | Test with real auth tokens. Verify data validation. |
| T51 | Test privacy flow end-to-end | Manual | 2h | Export, delete, HC disconnect, analytics opt-out all work. |
| T52 | Test subscription flow | Manual + sandbox | 2h | Purchase, restore, Pro feature unlock, manage subscription. |
| T53 | Test on real device | Manual | 4h | Test on minimum API 26 (Android 8.0). Verify performance. |
| T54 | Run Play Store pre-launch report | Play Console | 1h | Fix any issues found by automated review. |

---

## 11. Environment Variables for GitHub Actions Secrets

Set these in GitHub repo → Settings → Secrets and variables → Actions:

### Firebase Configuration
| Secret Name | Value | Used In | Notes |
|-------------|-------|---------|-------|
| `FIREBASE_API_KEY` | Your Firebase Web API key | `--dart-define=FIREBASE_API_KEY` | From Firebase Console → Project Settings → Web API Key |
| `FIREBASE_PROJECT_ID` | `contrastcoach-1ed0a` | `--dart-define=FIREBASE_PROJECT_ID` | From Firebase Console → Project Settings |
| `FIREBASE_APP_ID` | `1:1008265304464:android:497d3034401edde6897b15` | `--dart-define=FIREBASE_APP_ID` | From Firebase Console → Project Settings → Your apps → Android |
| `FIREBASE_MESSAGING_SENDER_ID` | `1008265304464` | `--dart-define=FIREBASE_MESSAGING_SENDER_ID` | From Firebase Console → Project Settings → Cloud Messaging |
| `FIREBASE_STORAGE_BUCKET` | `contrastcoach-1ed0a.firebasestorage.app` | `--dart-define=FIREBASE_STORAGE_BUCKET` | From Firebase Console → Project Settings → Storage |

### RevenueCat
| Secret Name | Value | Used In | Notes |
|-------------|-------|---------|-------|
| `REVENUECAT_API_KEY` | Your RevenueCat public Android SDK key | `--dart-define=REVENUECAT_API_KEY` | From RevenueCat Dashboard → Project Settings → API Keys → Android |

### Google Services
| Secret Name | Value | Used In | Notes |
|-------------|-------|---------|-------|
| `GOOGLE_SERVICES_JSON` | Base64-encoded `google-services.json` | Written to `android/app/google-services.json` | From Firebase Console → Download config file → base64 encode |

### Release Signing
| Secret Name | Value | Used In | Notes |
|-------------|-------|---------|-------|
| `RELEASE_KEYSTORE` | Base64-encoded `.jks` or `.keystore` file | Written to `android/app/release.keystore` | Generate with `keytool -genkey -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias upload` |
| `KEYSTORE_PASSWORD` | Keystore password | `key.properties` | Password used when generating keystore |
| `KEY_ALIAS` | Key alias (e.g., `upload`) | `key.properties` | Alias used when generating keystore |
| `KEY_PASSWORD` | Key password | `key.properties` | Password for the key entry |

### Play Store
| Secret Name | Value | Used In | Notes |
|-------------|-------|---------|-------|
| `PLAY_SERVICE_ACCOUNT` | JSON content of service account key | `r0adkll/upload-google-play@v1` | From Google Cloud Console → IAM → Service Accounts → Create key → JSON |

### Example CI build command with all secrets:
```yaml
- name: Build Release AAB
  run: |
    flutter build appbundle --release --flavor prod \
      --dart-define=FIREBASE_API_KEY=${{ secrets.FIREBASE_API_KEY }} \
      --dart-define=FIREBASE_PROJECT_ID=${{ secrets.FIREBASE_PROJECT_ID }} \
      --dart-define=FIREBASE_APP_ID=${{ secrets.FIREBASE_APP_ID }} \
      --dart-define=FIREBASE_MESSAGING_SENDER_ID=${{ secrets.FIREBASE_MESSAGING_SENDER_ID }} \
      --dart-define=FIREBASE_STORAGE_BUCKET=${{ secrets.FIREBASE_STORAGE_BUCKET }} \
      --dart-define=REVENUECAT_API_KEY=${{ secrets.REVENUECAT_API_KEY }} \
      --dart-define=ENV=prod
```

### Example google-services.json injection:
```yaml
- name: Write google-services.json
  run: echo "${{ secrets.GOOGLE_SERVICES_JSON }}" | base64 --decode > contrast_coach/android/app/google-services.json
```

### Example release signing setup:
```yaml
- name: Write release keystore
  run: echo "${{ secrets.RELEASE_KEYSTORE }}" | base64 --decode > contrast_coach/android/app/release.keystore

- name: Write key.properties
  run: |
    cat > contrast_coach/android/key.properties << EOF
    storePassword=${{ secrets.KEYSTORE_PASSWORD }}
    storeFile=release.keystore
    keyAlias=${{ secrets.KEY_ALIAS }}
    keyPassword=${{ secrets.KEY_PASSWORD }}
    EOF
```

---

## 12. File-by-File Change Matrix

| File | Changes Needed | Priority | Tasks |
|------|---------------|----------|-------|
| `lib/core/feature_gating.dart` | Implement from scratch (currently empty) | P0 | T1 |
| `lib/core/env/env_config.dart` | Remove dotenv loading, use --dart-define only | P0 | T6 |
| `lib/main.dart` | Add SyncWorker.init(), add --dart-define env | P0 | T5, T6 |
| `lib/app.dart` | Add auth state listener, persist onboarding | P0/P1 | T2, T14 |
| `lib/presentation/routing/app_router.dart` | Add redirect logic for auth/onboarding | P0 | T2 |
| `lib/presentation/screens/home/home_screen.dart` | Remove duplicate bottom nav, add Pro gates, use DB singleton | P0/P1 | T1, T3, T19 |
| `lib/presentation/screens/session/active_session_screen.dart` | Add userId, manual buttons, voice permission, health snapshot, Firebase-safe analytics | P0/P1 | T4, T9, T15, T16, T18 |
| `lib/presentation/screens/session/session_summary_screen.dart` | Add phase breakdown, start another, use DB singleton | P1/P4 | T3, T34, T35 |
| `lib/presentation/screens/insights/insights_screen.dart` | Add medical disclaimer, Pro gate, use DB singleton | P1/P2/P4 | T1, T3, T26 |
| `lib/presentation/screens/streak/streak_calendar_screen.dart` | Add tap-to-details, use DB singleton | P1/P4 | T3, T33 |
| `lib/presentation/screens/settings/settings_screen.dart` | Functional toggles, sign-out, version, use DB singleton | P1/P4 | T3, T12, T39, T40 |
| `lib/presentation/screens/settings/privacy_screen.dart` | Wire analytics opt-out | P1 | T13 |
| `lib/presentation/screens/settings/health_connect_screen.dart` | Add disconnect, revoke detection | P2 | T22 |
| `lib/presentation/screens/settings/data_export_screen.dart` | Add share sheet | P2 | T25 |
| `lib/presentation/screens/settings/delete_account_screen.dart` | Full cleanup | P2 | T24 |
| `lib/presentation/screens/paywall/paywall_screen.dart` | Firebase-safe analytics, dynamic pricing, terms/privacy links, manage subscription | P0/P2/P4 | T9, T30, T42, T43 |
| `lib/presentation/screens/auth/sign_in_screen.dart` | Password toggle, forgot password | P2 | T31 |
| `lib/presentation/screens/custom_protocol/custom_protocol_builder_screen.dart` | Pro gate, list existing, edit/delete | P0/P4 | T1, T36 |
| `lib/presentation/screens/onboarding/onboarding_screen.dart` | Persist completion | P1 | T14 |
| `lib/data/remote/firebase/analytics_api.dart` | Add opt-out check | P1 | T13 |
| `lib/data/remote/crash/crashlytics_client.dart` | PII stripping | P2 | T21 |
| `lib/data/local/health/health_connect_client.dart` | Revoke detection, retry/backoff | P2 | T22, T23 |
| `lib/data/background/sync_worker.dart` | (No change needed, just call init) | P0 | T5 |
| `lib/domain/usecases/session_stats.dart` | Fix streak calculation | P1 | T17 |
| `lib/presentation/widgets/layout/bottom_nav.dart` | (No change, already correct) | — | — |
| `contrast_coach/android/app/build.gradle` | Release signing config | P0 | T8 |
| `contrast_coach/android/app/proguard-rules.pro` | Create with keep rules | P2 | T29 |
| `.github/workflows/ci.yml` | Add --dart-define, fix lint failure | P0/P5 | T7, T45 |
| `.github/workflows/release-internal.yml` | Add --dart-define, signing, google-services.json, mapping | P0/P5 | T7, T8, T10, T47 |
| `README.md` | Update status, tech stack, layout | P2 | T27 |
| `contrast_coach/.env.example` | Remove real Firebase values, use placeholders | P0 | T6 |
| `contrast_coach/pubspec.yaml` | Remove unused fonts or add share_plus | P2/P4 | T25, T41 |
| `firestore.rules` | Add data validation | P6 | T50 |

---

## 13. Testing Strategy

### Current State
- 103 unit/widget tests passing
- No integration tests
- CI runs tests but doesn't fail on lint/format

### Required Additions

#### Unit Tests
- `feature_gating_test.dart` — test all 6 feature flags with free vs pro tier
- `session_stats_test.dart` — test streak calculation with gap (yesterday but not today)
- `env_config_test.dart` — test --dart-define takes priority over dotenv

#### Widget Tests
- `home_screen_test.dart` — test Pro protocol is blocked for free users
- `active_session_screen_test.dart` — test manual control buttons work
- `settings_screen_test.dart` — test toggles persist and affect behavior
- `paywall_screen_test.dart` — test empty offerings shows message

#### Integration Tests (Patrol)
- `onboarding_flow_test.dart` — complete onboarding → verify persisted
- `auth_flow_test.dart` — sign in → verify route to home → restart → verify stays
- `session_flow_test.dart` — start session → advance phases → complete → verify summary
- `subscription_flow_test.dart` — open paywall → verify packages → purchase (sandbox)
- `privacy_flow_test.dart` — export data → delete account → verify clean state

#### Coverage Targets
- Domain layer: 90%+ (pure Dart, easy to test)
- Data layer: 70%+ (repository tests with mock Drift)
- Presentation layer: 50%+ (widget tests for key screens)
- Overall: 60%+ minimum for v1.0

---

## 14. Pre-Launch Checklist

### Code Quality
- [ ] All P0 bugs fixed (T1-T10)
- [ ] All P1 issues fixed (T11-T20)
- [ ] All P2 compliance items fixed (T21-T31)
- [ ] No `|| true` in CI — lint errors fail the build
- [ ] `flutter analyze` passes with no errors
- [ ] `dart format` passes
- [ ] All tests pass
- [ ] Coverage ≥ 60%

### Build & Release
- [ ] `--dart-define` env vars set in CI from secrets
- [ ] `google-services.json` injected from secret
- [ ] Release keystore configured from secret
- [ ] `key.properties` generated in workflow
- [ ] ProGuard/R8 rules configured
- [ ] App icon converted to mipmaps (all densities)
- [ ] Adaptive icon configured
- [ ] Version code incremented
- [ ] AAB builds successfully in CI
- [ ] AAB uploads to Play Store internal track

### Privacy & Compliance
- [ ] Firebase API key removed from `.env.example`
- [ ] Analytics opt-out works
- [ ] Crashlytics PII stripping implemented
- [ ] Data export accessible to user (share sheet)
- [ ] Account deletion fully cleans up (local + cloud + Workmanager + HC + secure storage)
- [ ] Privacy Policy matches actual data practices
- [ ] Medical disclaimer on onboarding, insights, paywall
- [ ] Firestore rules tested with real auth
- [ ] No raw health data in Firestore (verified by rules + code)

### Play Store
- [ ] Data Safety form matches actual data collection
- [ ] Health Apps Declaration submitted
- [ ] App content rating completed
- [ ] Target audience set (13+)
- [ ] Ads declared (AD_ID permission — declare as "used for analytics" or remove)
- [ ] Privacy Policy URL accessible
- [ ] Terms of Service URL accessible (for subscriptions)
- [ ] Store listing (screenshots, feature graphic, description) — user task
- [ ] App signed with upload key
- [ ] Mapping file uploaded to Crashlytics

### Functional Testing
- [ ] Onboarding → sign in → home → start session → complete → summary → streak
- [ ] Pro subscription purchase unlocks features
- [ ] Pro subscription restore works
- [ ] Free user blocked from Pro features with paywall
- [ ] Health Connect permission request → read → display
- [ ] Health Connect permission revoke → notification
- [ ] Voice control: next phase, pause, resume, end
- [ ] Manual control buttons work without voice
- [ ] Data export produces valid JSON
- [ ] Account deletion removes all data
- [ ] Dark mode renders correctly on all screens
- [ ] App works on Android 8.0 (API 26) minimum
- [ ] No memory leaks (database connections closed)
- [ ] Background sync runs every 15 minutes
- [ ] Notifications fire correctly (5 types)
- [ ] Deep links open correct screens
- [ ] Custom protocol creation, save, and start session

---

## Appendix A: Architecture Diagram (Current)

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                          │
│  MaterialApp.router → GoRouter (16 routes)              │
│  ├── Screens (StatefulWidget + setState)                │
│  │   ├── Onboarding → SignIn/SignUp → Home              │
│  │   ├── Home → ActiveSession → Summary                │
│  │   ├── Streak, Insights, Settings (5 sub-screens)    │
│  │   ├── Paywall, CustomProtocolBuilder                │
│  │   └── HealthRationale, VoiceRationale               │
│  ├── Widgets (atomic, composite, layout)                │
│  └── NO Riverpod (despite dependency)                   │
├─────────────────────────────────────────────────────────┤
│                    DOMAIN                                │
│  ├── Entities (Session, Protocol, Phase, Goal, etc.)   │
│  ├── Repository Interfaces                               │
│  └── Use Cases (StartSession, GenerateInsights, etc.)  │
├─────────────────────────────────────────────────────────┤
│                    DATA                                  │
│  ├── Local: Drift (6 tables, SQLCipher)                 │
│  ├── Remote: Firebase (Auth, Firestore, Analytics,     │
│  │          Crashlytics)                                │
│  ├── Health: Health Connect (read HR/HRV/sleep/steps)  │
│  ├── Subscription: RevenueCat                           │
│  ├── Audio: just_audio (3 WAV cues)                     │
│  ├── Voice: speech_to_text                              │
│  ├── Notifications: flutter_local_notifications (5 ch) │
│  └── Background: Workmanager (sync, NOT INITIALIZED)    │
└─────────────────────────────────────────────────────────┘
```

## Appendix B: Architecture Diagram (Target)

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                          │
│  MaterialApp.router → GoRouter (with auth redirect)     │
│  ├── Screens (ConsumerWidget + Riverpod)                │
│  ├── Providers:                                          │
│  │   ├── authProvider (StreamProvider<FirebaseAuth>)   │
│  │   ├── databaseProvider (Provider<AppDatabase>)      │
│  │   ├── subscriptionProvider (StreamProvider<Tier>)   │
│  │   ├── settingsProvider (NotifierProvider<Settings>) │
│  │   └── featureGatingProvider (Provider<FeatureGating>)│
│  └── Widgets (atomic, composite, layout)                │
├─────────────────────────────────────────────────────────┤
│                    DOMAIN (unchanged)                    │
├─────────────────────────────────────────────────────────┤
│                    DATA (unchanged + fixes)              │
│  ├── Local: Drift (singleton, SQLCipher)                │
│  ├── Remote: Firebase (env from --dart-define)         │
│  ├── Health: HC (with revoke detection + retry)        │
│  ├── Subscription: RevenueCat (with restore on start)  │
│  ├── Audio, Voice, Notifications (unchanged)           │
│  └── Background: Workmanager (INITIALIZED in main)      │
└─────────────────────────────────────────────────────────┘
```

---

**End of Plan. Total tasks: 54. Estimated total effort: ~80 hours.**

> **For agents executing this plan:** Work through tasks in order (P0 → P1 → P2 → P4 → P5 → P6). Each task is independently actionable. Commit after each task with conventional commit format (e.g., `fix(auth): add route redirect for unauthenticated users`). Run `flutter test` after each task. Do not skip P0 tasks — they block production builds entirely.