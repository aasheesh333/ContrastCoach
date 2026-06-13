# ContrastCoach — Advanced Implementation Master Plan

**Target:** Solo Indian dev. Vibe coding. Free tools only. Play Store policy-compliant from day one.
**Design:** Monochrome Material 3 Expressive. Chrome/Amazon-tier restraint.
**Last updated:** June 13, 2026

---

## Table of Contents
1. Design System (Monochrome Material 3 Expressive)
2. App Architecture
3. Feature Specification (Detailed)
4. Tech Stack (Free Tools Only)
5. Build & DevOps Pipeline
6. Data Layer (Privacy-First)
7. Health Connect Integration (Play-Store-Compliant)
8. Subscription & Monetization
9. Play Store Publishing (Full Compliance)
10. ASO and Marketing (Free Channels)
11. 90-Day Build Roadmap
12. Pre-Launch Checklist
13. Post-Launch Operations
14. Appendices

---

## 1. Design System

### 1.1 Visual Identity

**Reference apps:** Google Chrome, Amazon Shopping, Linear, Things 3, Apple Notes, Bear, Notion, Kindle.

**Color tokens (single neutral, no chromatic accents):**
- surface-0: `#FFFFFF` light / `#0A0A0A` dark
- surface-1: `#F7F7F7` / `#141414`
- surface-2: `#EDEDED` / `#1F1F1F`
- surface-3: `#E0E0E0` / `#2A2A2A`
- on-surface-primary: `#0A0A0A` / `#F5F5F5`
- on-surface-secondary: `#5C5C5C` / `#A8A8A8`
- on-surface-tertiary: `#8C8C8C` / `#6E6E6E`
- divider: `#EDEDED` / `#1F1F1F`
- accent: `#0A0A0A` / `#F5F5F5` (black or white only)

**Rules:**
- No blue, red, green, orange, or any chromatic accent. Ever.
- No gradients except monochrome tonal.
- All states communicate via opacity, weight, or shape. Never color.
- Light mode is default. Dark mode follows system.

**Typography:**
- Display: Inter Tight (variable, weight 200 to 700)
- Body: Inter (variable, weight 400 to 600)
- Mono: JetBrains Mono (timer, data tables)
- No serif. No display. No decorative fonts.

**Type scale (Material 3 Expressive, 2026):**
- Display Large: 57/64, weight 300
- Display Medium: 45/52, weight 300
- Headline Large: 32/40, weight 500
- Headline Medium: 28/36, weight 500
- Title Large: 22/28, weight 600
- Title Medium: 16/24, weight 600, tracking +0.15
- Body Large: 16/24, weight 400
- Body Medium: 14/20, weight 400
- Body Small: 12/16, weight 400
- Label Large: 14/20, weight 500, tracking +0.1
- Label Small: 11/16, weight 500, tracking +0.5, uppercase

**Shape (Material 3 Expressive shape library, 35+ variants):**
- Cards: 16dp (medium emphasis), 28dp (hero moments)
- Buttons: 12dp (filled), 999dp (FAB pill)
- Sheets: 28dp top corners
- Hero session card: 28dp asymmetric, only top corners

**Motion (Material 3 Expressive spring physics):**
- All transitions: `spring(stiffness: 380, dampingRatio: 0.8)`
- Page transitions: shared-element + 240ms fade
- No bouncy overshoots. No flashy animations.
- Haptic feedback only on primary actions.

### 1.2 Screen-by-Screen Mockup Logic

**Screen 1: Onboarding (3 steps, no skip)**
- Single hero text per page, no illustration
- Step 1: "Track heat. Track cold. See what works." [Continue]
- Step 2: "Built for your phone. Not your watch." [Why?]
- Step 3: "Your data stays on your device." [Continue] to sign in

**Screen 2: Home (Session Setup)**
- Top: Greeting + last session date
- Hero card (28dp, single tone): "Start session" with 2x2 grid of goals (Recovery, Energy, Sleep, Immunity). Only icon and label, no color, just border on selection
- Middle: Quick stats (3 cards, monochrome, 16dp): Last 7 days streak, Avg duration, Recovery score
- Bottom: Today's recommended protocol (text only, no imagery)

**Screen 3: Active Session (most screen time)**
- Full-screen black/white. Nothing else.
- Top: Current phase label (SAUNA / COLD / REST), large mono
- Center: Massive countdown timer (96pt mono, weight 200, 4 digits)
- Below: Progress bar (single line, 2dp, current round / total rounds)
- Bottom: Single voice prompt hint ("Say 'next phase'") + small pause button
- No graphs, no charts, no buttons in main view. Distraction-free.

**Screen 4: Session Summary**
- Top: Session complete. Duration. Rounds.
- Middle: Recovery score (0-100, single number, large)
- Insights: 2-3 short bullet lines from data analysis
- Bottom: Save / Discard / Share (text buttons only)

**Screen 5: Streak Calendar**
- 12 weeks grid (GitHub-style contribution graph but monochrome)
- Tap a day to see session details
- No badges, no confetti. Just numbers.

**Screen 6: Insights (Monthly Report)**
- 5-7 sections, each with a hero metric + 2-line explanation
- Sections: Total sessions, Avg duration, Best protocol, Sleep correlation, Recovery trend, Recommendations
- Long-form scroll, no charts (use inline stat callouts)

**Screen 7: Settings**
- List, no grouped cards
- Account, Health Connect, Notifications, Privacy, Data Export, Help
- Each row: label + subtle chevron, no descriptions

**Screen 8: Paywall (Pro Upgrade)**
- Single column, 3-4 feature bullets
- No fake urgency, no countdown, no "limited time"
- $5.99/mo | $39.99/yr | $89.99 lifetime. Three plain text options
- "Restore purchases" link in small text

### 1.3 Component Library (Reusable)

```
components/
├── atomic/
│   ├── AppButton (primary/secondary/tertiary/text)
│   ├── AppTextField (borderless bottom-line style)
│   ├── AppCard (3 elevation tones)
│   ├── AppIcon (Lucide icon set, 1.5px stroke only)
│   ├── AppDivider (1px hairline)
│   ├── AppSwitch (iOS-style, monochrome)
│   ├── AppSlider (continuous, no tick marks)
│   └── AppChip (border-only, no fill)
├── composite/
│   ├── StatCard (label + value + delta)
│   ├── SessionTimer (with phase indicator)
│   ├── StreakCalendar (12-week grid)
│   ├── ProtocolPicker (list of cards)
│   ├── RecoveryScore (0-100 radial or linear)
│   └── InsightBlock (number + 2-line takeaway)
└── layout/
    ├── AppBar (slim, no shadow, just bottom border)
    ├── BottomNav (3 items: Home, Insights, Profile)
    └── SheetContainer (28dp top corners, drag handle)
```

---

## 2. App Architecture

### 2.1 High-Level Architecture

```
PRESENTATION LAYER
  Flutter + Material 3 Expressive + Riverpod 2.6
  - Screens (StatelessWidget)
  - Widgets (composable)
  - Controllers (Riverpod Notifiers)

DOMAIN LAYER
  Pure Dart (no Flutter, no Firebase)
  - Entities (Session, Protocol, Score)
  - Use Cases (StartSession, EndSession, CalculateScore)
  - Repository Interfaces

DATA LAYER
  - Local: Drift (SQLite) + Hive (key-value cache)
  - Remote: Supabase (Postgres + Auth + Storage)
  - Health: Health Connect (READ-only)
  - Audio: just_audio + record
```

### 2.2 State Management

**Choice:** Riverpod 2.6 with `riverpod_generator` (type-safe, no code generation errors)

**Notifier structure:**
- `SessionController`: active session state
- `StreakController`: calendar data, streak count
- `InsightsController`: monthly aggregations
- `AuthController`: Supabase auth state
- `SettingsController`: user preferences, theme
- `HealthController`: Health Connect permissions + sync

**Why not Bloc/Provider:** Riverpod is faster to vibe code, has no `BuildContext` issues, and is more testable.

### 2.3 Folder Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_shapes.dart
│   │   ├── app_motion.dart
│   │   └── app_strings.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── light_theme.dart
│   │   └── dark_theme.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── score_calculator.dart
│   │   ├── protocol_engine.dart
│   │   └── validators.dart
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── error_handler.dart
│   └── extensions/
│       ├── context_extensions.dart
│       └── datetime_extensions.dart
├── data/
│   ├── local/
│   │   ├── database/
│   │   │   ├── app_database.dart (Drift)
│   │   │   ├── tables/
│   │   │   │   ├── sessions_table.dart
│   │   │   │   ├── phases_table.dart
│   │   │   │   ├── streaks_table.dart
│   │   │   │   └── settings_table.dart
│   │   │   └── daos/
│   │   │       ├── session_dao.dart
│   │   │       └── stats_dao.dart
│   │   ├── cache/
│   │   │   └── hive_cache.dart
│   │   └── health/
│   │       └── health_connect_client.dart
│   ├── remote/
│   │   ├── supabase/
│   │   │   ├── supabase_client.dart
│   │   │   ├── auth_api.dart
│   │   │   └── sync_api.dart
│   │   └── analytics/
│   │       └── umami_client.dart
│   ├── repositories/
│   │   ├── session_repository.dart
│   │   ├── auth_repository.dart
│   │   ├── health_repository.dart
│   │   ├── settings_repository.dart
│   │   └── subscription_repository.dart
│   └── models/
│       ├── session_model.dart
│       ├── phase_model.dart
│       ├── protocol_model.dart
│       ├── recovery_score_model.dart
│       └── user_model.dart
├── domain/
│   ├── entities/
│   │   ├── session.dart
│   │   ├── phase.dart
│   │   ├── protocol.dart
│   │   ├── recovery_score.dart
│   │   └── user.dart
│   ├── repositories/ (interfaces)
│   └── usecases/
│       ├── start_session.dart
│       ├── end_session.dart
│       ├── calculate_recovery_score.dart
│       ├── generate_monthly_insights.dart
│       ├── sync_health_data.dart
│       └── validate_protocol.dart
├── presentation/
│   ├── screens/
│   │   ├── onboarding/
│   │   ├── home/
│   │   ├── session/
│   │   ├── streak/
│   │   ├── insights/
│   │   ├── settings/
│   │   ├── paywall/
│   │   └── auth/
│   ├── widgets/
│   │   ├── atomic/
│   │   ├── composite/
│   │   └── layout/
│   └── providers/
│       ├── session_provider.dart
│       ├── streak_provider.dart
│       ├── insights_provider.dart
│       ├── health_provider.dart
│       ├── auth_provider.dart
│       ├── settings_provider.dart
│       └── subscription_provider.dart
└── l10n/
    ├── app_en.arb
    └── app_es.arb (later)
```

---

## 3. Feature Specification

### 3.1 Session Lifecycle (Core Feature)

**States:**
- `idle`: no session
- `setup`: user configuring protocol
- `active`: session running
- `paused`: user paused
- `summary`: post-session
- `syncing`: uploading to cloud
- `error`: recoverable error

**Session record schema (Drift table):**

```dart
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get protocolId => text()();
  TextColumn get goal => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get totalDurationSec => integer()();
  IntColumn get roundsCompleted => integer()();
  RealColumn get recoveryScore => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get weatherContext => text().nullable()();
  TextColumn get healthDataSnapshot => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Phases extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  IntColumn get orderIndex => integer()();
  IntColumn get plannedDurationSec => integer()();
  IntColumn get actualDurationSec => integer()();
  RealColumn get targetTempC => real().nullable()();
  RealColumn get actualTempC => real().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
  TextColumn get voiceLog => text().nullable()();
}
```

### 3.2 Protocol Engine

**Built-in protocols (10 total):**

```yaml
recovery_standard:
  name: "Standard Recovery"
  description: "Balanced contrast for post-workout recovery"
  rounds: 3
  phases:
    - type: sauna
      duration: 900
      target_temp_c: 80
    - type: cold
      duration: 120
      target_temp_c: 12
    - type: rest
      duration: 60
  cooldown:
    - type: rest
      duration: 300

energy_morning:
  name: "Morning Energy"
  rounds: 2
  phases:
    - type: sauna
      duration: 600
      target_temp_c: 75
    - type: cold
      duration: 60
      target_temp_c: 15

sleep_evening:
  name: "Sleep Recovery"
  rounds: 2
  phases:
    - type: sauna
      duration: 720
      target_temp_c: 70
    - type: cold
      duration: 90
      target_temp_c: 18

immunity_weekly:
  name: "Immune Boost"
  rounds: 4
  phases:
    - type: sauna
      duration: 720
      target_temp_c: 85
    - type: cold
      duration: 60
      target_temp_c: 10

wim_hof_classic:
  name: "Wim Hof Style"
  rounds: 4
  phases:
    - type: cold
      duration: 120
      target_temp_c: 8

deep_cold_training:
  name: "Cold Hardening"
  rounds: 1
  phases:
    - type: cold
      duration: 300
      target_temp_c: 5

gentle_beginner:
  name: "Gentle Start"
  rounds: 2
  phases:
    - type: sauna
      duration: 480
      target_temp_c: 65
    - type: cold
      duration: 30
      target_temp_c: 20

sauna_focus:
  name: "Sauna Only"
  rounds: 1
  phases:
    - type: sauna
      duration: 1200
      target_temp_c: 80

cold_only_deep:
  name: "Ice Bath Only"
  rounds: 1
  phases:
    - type: cold
      duration: 600
      target_temp_c: 5

custom:
  name: "Custom"
```

**Protocol validation rules:**
- Total duration ≤ 60 min (safety)
- Sauna max 30 min per phase
- Cold min 5°C, max 20°C (safety)
- Max 5 rounds
- Rest phase optional but recommended between hot/cold

### 3.3 Recovery Score Algorithm

**Inputs:**
- Session adherence (% of planned duration completed)
- Round completion (X/Y rounds done)
- Temperature delta (if recorded): Δ between hottest and coldest
- Time of day (penalty for late-night sessions, bonus for morning)
- User's recent sleep (Health Connect, 7-day average)
- User's HRV trend (Health Connect, 7-day average)
- Days since last session (penalty for >7 day gaps)
- Streak length (small bonus for consistency)

**Algorithm (v1, deterministic, on-device):**

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

**Output:**
- 0 to 100 numeric score
- 1-2 sentence insight ("Strong session. Your 7-day HRV trend is +12%.")
- Color coding: never. Use word: "Low" (0-40), "Moderate" (41-70), "Strong" (71-100)

### 3.4 Voice Control

**Wake word:** "Hey Coach"

**Commands (in active session):**
- "Start": begin next phase
- "Next" / "Skip": skip current phase
- "Pause": pause session
- "Resume": resume
- "End": end session early
- "How long?" / "Time": speak remaining time
- "Repeat": replay last audio cue
- "Log cold": log "I felt cold" (for subjective tracking)
- "Log hot": log "I felt hot"

**Implementation:**
- `speech_to_text` package (Google STT, on-device mode)
- Continuous listening only when session is active
- Manual button fallback (large bottom button, 88dp tap target)
- Offline vocabulary: pre-bundled small language model for noise robustness

**Permissions:**
- `RECORD_AUDIO`: declared in manifest, runtime requested
- Disclosed in Data Safety: "App uses microphone only during active session for voice commands. No audio is recorded or transmitted. All processing on-device."

### 3.5 Health Connect Integration

**Data types accessed (READ only):**
- `HeartRate`: for HR response tracking
- `RestingHeartRate`: for recovery baseline
- `HRV` (RMSSD): for stress/recovery insight
- `SleepSession`: for correlation insights
- `Steps`: for activity context (light only)
- `WorkoutSession`: to time suggestions around workouts

**Data types written (opt-in):**
- `MindfulSession`: log contrast therapy session as a wellness session

**Justification (for Play Console):**
> "Heart rate, HRV, and sleep data are used solely to provide personalized recovery insights and trend analysis. The app reads this data only when the user has an active Pro subscription or has explicitly opted in. The data is processed on-device and is not transmitted to our servers. Sleep and HRV trends are used to generate the monthly Insights report. Without these data points, the recovery score would be limited to session-only data and would be less accurate."

**Permissions declared in manifest:**

```xml
<uses-permission android:name="android.permission.health.READ_HEART_RATE"/>
<uses-permission android:name="android.permission.health.READ_RESTING_HEART_RATE"/>
<uses-permission android:name="android.permission.health.READ_HRV"/>
<uses-permission android:name="android.permission.health.READ_SLEEP"/>
<uses-permission android:name="android.permission.health.READ_STEPS"/>
<uses-permission android:name="android.permission.health.READ_EXERCISE"/>
<uses-permission android:name="android.permission.health.WRITE_MINDFULNESS"/>

<queries>
  <package android:name="com.google.android.apps.healthdata" />
</queries>

<activity-alias
    android:name="ViewPermissionUsageActivity"
    android:targetPackage="${applicationId}"
    android:targetClass=".health.PermissionUsageActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="androidx.health.ACTION_VIEW_PERMISSION_USAGE" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
</activity-alias>
```

### 3.6 Notifications

**Types (all opt-in):**
1. Streak reminder: daily 8pm, "Day 4 of 6. Keep the streak."
2. Optimal timing: after 3 days no session, "Your last session was 4 days ago. Best time today: 5-7pm based on your schedule."
3. Sleep correlation insight: weekly Sunday 9am
4. Subscription renewal: 3 days before
5. Health Connect permission revoked: immediate

**Implementation:**
- `flutter_local_notifications` (free, no Firebase)
- `workmanager` for scheduled jobs
- All notifications user-configurable in Settings

### 3.7 Offline-First Architecture

**Sync strategy:**
- All data writes go to local Drift DB first
- Background worker syncs to Supabase when network available
- Conflict resolution: last-write-wins (timestamp)
- User data export: JSON file in Downloads folder

**Local DB size estimate:**
- 1 session = ~2 KB (with phases)
- 365 sessions/year = 730 KB
- Negligible storage

---

## 4. Tech Stack (Free Tools Only)

### 4.1 Core Stack

| Layer | Tool | License | Cost | Reason |
|---|---|---|---|---|
| Framework | Flutter 3.24+ | BSD | Free | Cross-platform, fast, mature |
| Language | Dart 3.5+ | BSD | Free | Type-safe, null-safe |
| State Mgmt | Riverpod 2.6 | MIT | Free | Type-safe, no codegen errors |
| Local DB | Drift 2.20+ | MIT | Free | Type-safe SQL, migrations |
| Local Cache | Hive 2.2+ | Apache 2.0 | Free | Fast key-value |
| Auth + Backend | Supabase | Apache 2.0 | Free up to 500MB DB, 50k MAU | Open source Firebase alt |
| Cloud Storage | Supabase Storage | Apache 2.0 | Free 1GB | For voice notes, future |
| Health Data | health (Flutter) | BSD | Free | Health Connect wrapper |
| Audio | just_audio + record | MIT/BSD | Free | Audio cues + voice cmd |
| Notifications | flutter_local_notifications | MIT | Free | Cross-platform |
| Background | workmanager | MIT | Free | Scheduled jobs |
| Analytics | Umami (self-hosted) or Plausible | MIT/AGPL | Free | Privacy-first, no cookies |
| Crash Reports | Sentry | MIT (self-host) | Free up to 5K events/mo | Standard |
| Subscription | RevenueCat | Commercial | Free up to $2.5k MRR | Subscription mgmt |
| Payments | Google Play Billing | N/A | 15% Google cut | Required for Play |
| Routing | go_router 14+ | BSD | Free | Declarative |
| HTTP | Dio 5.6+ | MIT | Free | Interceptors, retries |
| Code Gen | build_runner | BSD | Free | Standard |
| JSON | freezed + json_serializable | MIT/BSD | Free | Immutable models |
| Lint | very_good_analysis 6+ | MIT | Free | Strict linting |
| Testing | flutter_test + mocktail | BSD/MIT | Free | Standard |
| Widget Tests | integration_test | BSD | Free | Play Store pre-launch |
| CI/CD | GitHub Actions | Free 2K min/mo | Free | Free for OSS, $4/mo for private |
| Design | Figma free tier | Free | Free for 3 projects | Material 3 design |
| Icons | Lucide | ISC | Free | 1.5px stroke, monochrome |
| Fonts | Inter, JetBrains Mono | OFL | Free | Self-hosted |
| App Icon | Figma to icon.kitchen | N/A | Free | All sizes generated |

**Total monthly cost at 0 to 2,500 MRR: $0**
**At >2,500 MRR: $0 (Supabase free tier covers up to 50k MAU, Sentry free covers 5K events, RevenueCat free covers $2.5k MRR)**

### 4.2 Why This Stack Beats "Just Use Firebase"

| Concern | Firebase | This Stack |
|---|---|---|
| Vendor lock-in | High | Low (Postgres, SQLite) |
| Cost at scale | $$$ | Free (Supabase generous free tier) |
| Privacy | Google data policies | Self-hostable, GDPR-friendly |
| Offline support | Limited (Firestore offline) | First-class (Drift + sync) |
| Open source | No | Yes (Supabase, Drift, etc.) |
| Migration cost | High (proprietary APIs) | Low (standard SQL, standard auth) |
| Track record | Strong | Supabase: 50k+ projects, BaaS market leader #2 after Firebase |

### 4.3 Initial Setup (Day 1)

```bash
# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
export PATH="$HOME/flutter/bin:$PATH"

# Create project (with org prefix)
flutter create --org com.contrastcoach --project-name contrast_coach contrast_coach

# Add dependencies
flutter pub add flutter_riverpod riverpod_annotation
flutter pub add go_router
flutter pub add drift drift_flutter sqlite3_flutter_libs path_provider path
flutter pub add hive hive_flutter
flutter pub add supabase_flutter
flutter pub add health
flutter pub add just_audio record
flutter pub add flutter_local_notifications workmanager
flutter pub add dio
flutter pub add freezed_annotation json_annotation
flutter pub add sentry_flutter
flutter pub add purchases_flutter
flutter pub add lucide_icons_flutter
flutter pub add google_fonts
flutter pub add intl

# Dev dependencies
flutter pub add --dev build_runner
flutter pub add --dev riverpod_generator
flutter pub add --dev drift_dev
flutter pub add --dev freezed json_serializable
flutter pub add --dev mocktail
flutter pub add --dev very_good_analysis
flutter pub add --dev integration_test
flutter pub add --dev patrol_cli

# Initialize Supabase locally
npx supabase init
npx supabase start
```

---

## 5. Build and DevOps Pipeline

### 5.1 GitHub Actions

**Workflow 1: ci.yml (on every PR)**

```yaml
name: CI
on: [pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze --fatal-infos
      - run: flutter test --coverage
      - run: dart format --set-exit-if-changed lib/ test/
  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release --split-per-abi
      - uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/
```

**Workflow 2: release.yml (on tag push)**

```yaml
name: Release
on:
  push:
    tags: ['v*']
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build appbundle --release
      - run: flutter build apk --release
      - uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT }}
          packageName: com.contrastcoach.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
          mappingFile: build/app/outputs/mapping/release/mapping.txt
          whatsNewDirectory: whatsnew/
```

### 5.2 Versioning and Changelog

**Semantic Versioning:** MAJOR.MINOR.PATCH
- 1.0.0: initial public release
- 1.1.0: new feature
- 1.1.1: bug fix

**In-app changelog screen (offline, no Firebase Remote Config):**

```dart
class ChangelogItem {
  final String version;
  final DateTime releasedAt;
  final List<String> changes;
}
```

Stored in `assets/changelog.json`, bundled with app. No remote call needed.

### 5.3 Build Flavors

```bash
flutter build apk --flavor dev -t lib/main_dev.dart
flutter build apk --flavor prod -t lib/main_prod.dart
```

**lib/main_dev.dart:** debug banner, mock data, debug Supabase URL
**lib/main_prod.dart:** production, real Supabase, real RevenueCat key

### 5.4 Crash and Performance Monitoring

**Sentry (free tier, 5K events/mo):**
- Set up in `main.dart` before runApp
- Capture: unhandled exceptions, async errors, navigation failures
- Do NOT capture: voice audio, session data, health data, PII

**Performance:**
- Use `flutter run --profile` for profiling
- Frame time budget: 16ms (60fps)
- App startup: <2s to first frame

---

## 6. Data Layer (Privacy-First)

### 6.1 Supabase Schema

```sql
-- users
create table users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  display_name text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  onboarding_completed boolean default false,
  goal text,
  subscription_status text default 'free',
  subscription_expires_at timestamptz,
  revenue_cat_user_id text unique
);

-- devices (for sync)
create table devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  device_id text not null,
  platform text not null,
  os_version text,
  app_version text,
  last_seen_at timestamptz default now(),
  unique(user_id, device_id)
);

-- sessions (synced from local)
create table sessions (
  id uuid primary key,
  user_id uuid references users(id) on delete cascade,
  protocol_id text not null,
  goal text not null,
  started_at timestamptz not null,
  ended_at timestamptz,
  total_duration_sec int not null,
  rounds_completed int not null,
  recovery_score real,
  notes text,
  health_data_snapshot jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  client_updated_at timestamptz not null,
  deleted_at timestamptz
);

create index idx_sessions_user_started on sessions(user_id, started_at desc);

-- phases
create table phases (
  id uuid primary key,
  session_id uuid references sessions(id) on delete cascade,
  type text not null,
  order_index int not null,
  planned_duration_sec int not null,
  actual_duration_sec int not null,
  target_temp_c real,
  actual_temp_c real,
  started_at timestamptz not null,
  ended_at timestamptz,
  skipped boolean default false
);

create index idx_phases_session on phases(session_id, order_index);

-- Row Level Security (CRITICAL)
alter table sessions enable row level security;
alter table phases enable row level security;
alter table devices enable row level security;

create policy "Users see own sessions" on sessions
  for all using (auth.uid() = user_id);
create policy "Users see own phases" on phases
  for all using (
    session_id in (select id from sessions where user_id = auth.uid())
  );
create policy "Users see own devices" on devices
  for all using (auth.uid() = user_id);
```

**No analytics data stored on server.** All stats computed on-device from local data.

### 6.2 Privacy-First Analytics (Umami)

**Why Umami over Firebase Analytics:**
- No cookies, no device IDs, no PII
- Self-hostable, free
- GDPR/CCPA compliant by design
- Tracked via POST to API, not SDK

**Setup (self-hosted on Supabase Edge or free tier Vercel/Railway):**

```bash
git clone https://github.com/umami-software/umami.git
# Follow Railway one-click deploy
```

**Client integration (no SDK):**

```dart
class UmamiClient {
  static const _endpoint = 'https://umami.yourdomain.com/api/send';
  static const _websiteId = 'your-website-id';

  final Dio _dio;

  Future<void> track(String eventName, {Map<String, dynamic>? data}) async {
    try {
      await _dio.post(_endpoint, data: {
        'type': 'event',
        'payload': {
          'website': _websiteId,
          'name': eventName,
          'data': data ?? {},
        },
      });
    } catch (_) {
      // Silent fail, never crash app for analytics
    }
  }
}
```

**Events to track (5 total, minimal):**
1. session_started
2. session_completed
3. paywall_viewed
4. subscription_started
5. feature_used (e.g., protocol_name)

**No tracking of:** health data, voice, location, age, gender, individual sessions beyond the events above.

### 6.3 Sentry (Crash Only)

```dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'https://...@sentry.io/...';
    options.tracesSampleRate = 0.1;
    options.beforeSend = (event, hint) {
      // Strip any PII
      event.user = null;
      event.tags?.remove('health_data');
      return event;
    };
  },
  appRunner: () => runApp(...),
);
```

---

## 7. Health Connect Integration

### 7.1 Permission Flow

```dart
class HealthConnectService {
  static const _permissions = [
    HealthDataAccess.READ_HEART_RATE,
    HealthDataAccess.READ_RESTING_HEART_RATE,
    HealthDataAccess.READ_HRV,
    HealthDataAccess.READ_SLEEP,
    HealthDataAccess.READ_STEPS,
    HealthDataAccess.READ_EXERCISE,
    HealthDataAccess.WRITE_MINDFULNESS,
  ];

  Future<bool> requestPermissions() async {
    if (!await Health().isHealthConnectAvailable()) {
      await Health().installHealthConnect();
      return false;
    }

    final granted = await Health().requestAuthorization(
      _permissions,
      rationale: 'ContrastCoach reads heart rate, HRV, and sleep to provide personalized recovery insights. We do not store this data on our servers.',
    );
    return granted;
  }

  Future<HealthSnapshot> getSnapshot({required DateTime since}) async {
    final hr = await Health().getHealthDataFromTypes(
      startTime: since,
      endTime: DateTime.now(),
      types: [HealthDataType.HEART_RATE, HealthDataType.RESTING_HEART_RATE, HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
    );
    final sleep = await Health().getHealthDataFromTypes(
      startTime: since,
      endTime: DateTime.now(),
      types: [HealthDataType.SLEEP_SESSION, HealthDataType.SLEEP_ASLEEP],
    );
    return HealthSnapshot(...);
  }
}
```

### 7.2 Privacy Architecture

**All health data stays on-device.** Period.

- Health Connect data is read into Drift DB
- Drift DB is encrypted using `sqlcipher` (free) with a key derived from user password or generated randomly and stored in `flutter_secure_storage`
- Health data is NEVER sent to Supabase
- The `health_data_snapshot` column in `sessions` table contains only computed metrics (e.g., "HRV trend: +12%"), never raw values
- User can export all data (JSON) and delete all data (one tap)

---

## 8. Subscription and Monetization

### 8.1 RevenueCat Setup (Free up to $2.5k MRR)

**Account:** revenuecat.com (free)
**Products (configured in Google Play Console + RevenueCat):**
- cc_pro_monthly: $5.99/mo
- cc_pro_yearly: $39.99/yr (44% savings)
- cc_pro_lifetime: $89.99 one-time

**Entitlements:**
- pro: all paid features

**Offerings:**
- default: monthly + yearly
- lifetime: one-time

**Client integration:**

```dart
class SubscriptionService {
  final Purchases _purchases = Purchases(
    configuration: PurchasesConfiguration('your_revenue_cat_api_key')
      ..appUserID = null
  );

  Future<CustomerInfo> getCustomerInfo() async {
    return await _purchases.getCustomerInfo();
  }

  Future<Offering?> getCurrentOffering() async {
    final offerings = await _purchases.getOfferings();
    return offerings.current;
  }

  Future<bool> purchase(Package package) async {
    try {
      final result = await _purchases.purchase(package);
      return result.customerInfo.entitlements.all['pro']?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> restore() async {
    await _purchases.restorePurchases();
  }
}
```

### 8.2 Feature Gating

**Free tier:**
- Unlimited sessions
- 3 protocols (Recovery, Energy, Cold Only)
- Basic recovery score (no HRV/sleep correlation)
- 7-day streak history
- Local data only (no cloud sync)

**Pro tier:**
- All 10 protocols
- Full recovery score (HRV, sleep, HR trend)
- Unlimited cloud sync
- Health Connect integration
- Monthly Insights report
- Voice control
- Custom protocols (1 saved)
- Priority email support

**Why this split:**
- Free is genuinely useful (people will use it daily)
- Pro features are about depth of insight, not basic functionality
- Health Connect is Pro (covers RevenueCat commission + cost of $0.99 to 1.99 user LTV is achievable in 1 month)

### 8.3 Affiliate Revenue (Free, Performance-Based)

**Amazon Associates (free to join, $0 monthly):**
- Sauna blankets, plunge tubs, thermometers, mouth tape
- Tag: `contrastcoach-20` (4% commission on most categories)
- Place affiliate links in:
  - Settings to "Equipment we use" page
  - Insights to "Recommended products" footer
  - Onboarding to "Setup your space" step

**Direct brand partnerships (after 10k users):**
- Reach out to sauna blanket companies, plunge tub companies
- Negotiate 10-15% commission
- Revenue: $50-75 per sale x 1,500 active buyers x 30% conversion = ~$30k/year

**Why no upfront affiliate partnerships:**
- Brands won't talk to you with 0 users
- Build first, pitch after 10k MAU

---

## 9. Play Store Publishing

### 9.1 Developer Account Setup

**One-time:**
1. Create Google Play Developer account: $25 (lifetime)
2. Verify identity (govt ID, address, phone), 7-14 days
3. Set up payment profile (bank account for earnings)
4. Accept Developer Distribution Agreement

**Tax:**
- US tax form: W-8BEN (you're non-US, but you receive US revenue)
- India: Declare as "export of services" in ITR, pay GST on reverse charge (or zero-rated if under 20L)

### 9.2 App Content Declarations (CRITICAL, Do First)

#### 9.2.1 Data Safety Form (mandatory)

Answer every question truthfully. Common mistakes:
- Saying "no data collected" while using analytics
- Saying "data is encrypted in transit" without HTTPS
- Missing required declarations for health data

**Required disclosures for ContrastCoach:**

| Data Type | Collected? | Shared? | Purpose | User Control |
|---|---|---|---|---|
| Email address | Yes (for auth) | No | Account creation | Delete account |
| App interactions (analytics) | Yes (Umami) | No | Improve app | Opt-out in Settings |
| Health info (HR, HRV, sleep) | Yes (local) | No | Recovery score | Disconnect Health Connect |
| Crash logs | Yes (Sentry) | No | Fix bugs | Cannot opt-out (but no PII) |
| Purchase history | Yes (RevenueCat) | No | Subscription mgmt | Delete account |
| Device ID | No (intentionally avoided) | -- | -- | -- |
| Location | No | -- | -- | -- |
| Contacts | No | -- | -- | -- |
| Photos | No | -- | -- | -- |
| Voice recordings | No (processed, not stored) | No | Voice commands | Disable voice in Settings |

**Encryption:**
- All data in transit: HTTPS/TLS 1.3
- All data at rest: Drift DB encrypted with SQLCipher
- User can request data deletion: yes (Settings, Delete Account)
- User can request data export: yes (Settings, Export Data)

#### 9.2.2 Health Apps Declaration (mandatory)

Complete this form in Play Console to App content to Health apps.

**Justification for each data type (paste-ready):**

> Heart Rate (READ)
> Purpose: Calculate session intensity and recovery response. Used to provide real-time heart-rate-aware protocol recommendations.
> Core feature: Yes. Without HR data, the recovery score cannot account for cardiovascular response to contrast.
> Justification: Contrast therapy's main effect is cardiovascular, alternating vasodilation/vasoconstriction. HR data is essential to the app's primary function.
>
> HRV (READ)
> Purpose: Calculate weekly stress/recovery trend. Display as part of monthly Insights.
> Core feature: Yes. HRV is the gold-standard recovery biomarker.
> Justification: HRV trend is the single most validated recovery metric. Without it, the app's recovery score would be speculative.
>
> Sleep (READ)
> Purpose: Correlate contrast sessions with next-day sleep quality. Display in Insights.
> Core feature: Yes. Sleep is a primary outcome measure of contrast therapy.
> Justification: Users want to know "is contrast therapy actually helping my sleep?" Without sleep data, this question is unanswerable.
>
> Mindful Session (WRITE)
> Purpose: Log contrast therapy session as wellness activity for user's overall health record.
> Core feature: Yes. Many users want their contrast sessions visible alongside meditation, yoga, etc.
> Justification: Writing one entry per session is the most basic logging function expected.
>
> Resting Heart Rate, Steps, Exercise (READ)
> Purpose: Provide activity context for protocol recommendations.
> Core feature: Partial. Used only to suggest "good time to do contrast" (e.g., post-workout window).
> Justification: Knowing user's recent activity level allows smarter timing recommendations.

#### 9.2.3 AI-Generated Content Disclosure (mandatory if using AI for insights)

We don't use LLM for content generation. We use deterministic algorithms. No disclosure required.

If you add AI-generated insights later (e.g., "GPT explains your monthly report"), you MUST:
- Disclose "AI-generated insights" in app description
- Add a clear label: "This insight was generated by AI. It is for informational purposes only."
- Implement content filters (no medical advice)

### 9.3 Privacy Policy (mandatory, public URL)

**Free option:** Use iubenda.com or termly.io
- Free tier: 1 privacy policy, 25k page views/mo
- Cost: $0 to start
- URL must be: HTTPS, public, non-geofenced, non-editable

**Required sections (Google's checklist):**
- What data is collected
- Why data is collected
- How data is used
- Whether data is shared with third parties (we don't)
- How users can request deletion
- How users can request export
- Contact information
- Effective date
- Children's policy (we don't target <13)
- California privacy rights (CCPA)
- EU/UK privacy rights (GDPR)

**URL goes in:**
- Play Console to App content to Privacy policy
- In-app Settings to Privacy Policy (opens browser)
- Health Connect permission rationale screen

### 9.4 Store Listing

**App name:** ContrastCoach: Sauna and Plunge
**Short description (80 chars):** Track heat, cold, recovery. Phone-first. No wearable.
**Full description (4,000 chars):**

```
Track heat, cold, and recovery with the phone-first contrast therapy app.

Whether you use a sauna, infrared blanket, or cold plunge, ContrastCoach helps you see what works. Built for the 95% of contrast therapy users who don't wear a watch into a 90C sauna (Apple warns against it above 35C).

10 RESEARCH-BACKED PROTOCOLS
- Standard Recovery (3 rounds, sauna + cold)
- Wim Hof style
- Sleep Recovery (gentle evening)
- Morning Energy
- Immune Boost
- And 5 more, plus custom

RECOVERY SCORE (0-100)
A single number that improves when you stick to your protocols and correlates with your sleep, HRV, and resting heart rate (Pro).

STREAK WITHOUT GAMIFICATION NOISE
A simple calendar. Tap a day. See your sessions. No badges. No confetti.

LOCAL-FIRST PRIVACY
Your health data (heart rate, HRV, sleep) stays on your device. We don't see it. We don't store it. We don't sell it. Open the app, disconnect Health Connect, all your data is gone.

NO WEARABLE REQUIRED
Phone in the locker. Voice commands work from inside the sauna ("Hey Coach, next phase"). No watch damage.

HARDWARE-AGNOSTIC
Any sauna, any cold source, any temperature. We don't sell equipment.

SUBSCRIPTION
- Free: Unlimited sessions, 3 protocols, basic recovery score
- Pro ($5.99/mo or $39.99/yr): All protocols, full recovery score, Health Connect, monthly Insights, voice control

NOT MEDICAL ADVICE
This app is for informational and educational purposes only. It is not a medical device. Consult a healthcare professional before starting any new recovery routine.

Built by a solo developer. Open source on GitHub (link in app).
```

**Screenshots (8 required, 4 of each size):**

Format: 1080 x 1920 (phone) or 1920 x 1080 (landscape/feature graphic)
Style: No marketing copy on screenshots. Just clean monochrome UI with 1-2 word labels.

1. Home screen, "Start"
2. Active session, "20:00" (timer)
3. Summary, "78" (score)
4. Streak calendar, "12 weeks"
5. Insights, "Sleep +23 min"
6. Health Connect permissions, "Your data. Your device."
7. Paywall, "Pro"
8. Settings, "Private by design"

**App icon:**
- Monochrome on white background
- Single visual: a circle bisected by a horizontal line (heat above, cold below)
- Or: 3 vertical bars (3 rounds)
- 1.5px stroke, no fill, all black

**Feature graphic (1024 x 500):**
- White background
- Single sentence: "Track heat. Track cold. See what works."
- Below: 3 small app screenshots in a row

### 9.5 Pre-Launch Testing

**Required tests (Play Console):**
- Internal testing: 20+ testers, 14 days
- Closed testing: 100+ testers, 14 days (must include opt-in URL for users)
- Open testing: optional

**Minimum 20 testers for internal, must use the app actively for 14 consecutive days.**

**Test checklist (do before submitting):**
- All declared permissions in manifest match Play Console
- All health permissions justified in Health Apps Declaration
- Privacy policy URL is live and matches the one in the app
- Data Safety form matches actual data practices
- AI disclosure added (if applicable)
- Medical disclaimer visible in app
- "Not affiliated with any government health agency" disclaimer
- Crash-free rate > 99.5% in Sentry
- App size < 50MB (no bloat)
- Cold start time < 3s
- All deep links work
- All subscription flows work (test with $0.99 test purchase)
- Health Connect flow tested on real device
- Dark mode tested
- Tablet layout (if claimed)
- All languages (English only for v1)
- All required text strings present (no "TODO" placeholders)
- App bundle (.aab) builds without warnings

### 9.6 Common Rejection Reasons (Avoid)

| Reason | Fix |
|---|---|
| Health permission not justified | Fill Health Apps Declaration thoroughly |
| Data Safety form doesn't match behavior | Audit every SDK, every line of code that touches data |
| Privacy policy inaccessible | Make sure URL is HTTPS, public, loads fast |
| App requests unnecessary permissions | Only request what you actively use; explain each in console |
| Medical claims without disclaimer | Add prominent "Not medical advice" in onboarding + settings + paywall |
| App doesn't work without Health Connect | Make Health Connect optional; core features work without it |
| Health data sent to server | Don't. Period. Document this in privacy policy. |
| Background location | Don't request |
| Excessive ads | We don't have ads. No issue. |
| Crashes on launch | Test on at least 5 devices before submission |

---

## 10. ASO and Marketing (Free Channels)

### 10.1 Keyword Strategy

**Primary keywords (in title + short description):**
- contrast therapy
- sauna
- cold plunge
- ice bath
- recovery
- biohacking

**Long-tail keywords (in long description, naturally):**
- "sauna cold plunge app"
- "ice bath timer"
- "contrast therapy tracker"
- "sauna session log"
- "recovery score"
- "wim hof tracker"
- "wellness streak"
- "HRV recovery"

**Negative keywords (avoid):**
- "medical"
- "diagnose"
- "treatment"
- "cure"

### 10.2 Free Marketing Channels

**Reddit (highest ROI for niche apps):**
- r/biohacking (200k+)
- r/coldplunge (10k+)
- r/HubermanLab (Andrew Huberman audience)
- r/HeatColdExposure
- r/AndrewHuberman
- r/fitness (40M+, hard to break)
- r/QuantifiedSelf
- r/wimhofmethod

**Tactics:**
- 1 helpful post/week (no app mention)
- 1 "I built this" post/month (with full transparency)
- Daily 5-10 comments on related posts
- Build karma for 3 months before launch

**YouTube (slowest but longest-lasting):**
- 1 short/week: "30-second contrast tip"
- 1 long-form/month: "My 30-day cold plunge experiment"
- Link to app in description

**Twitter/X:**
- Biohacking community is active
- Tweet 3x/week
- Engage with @hubermanlab, @galpin_institute, etc.

**Discord:**
- Biohacking servers (10k+ members)
- Andrew Huberman Discord (50k+)
- Cold plunge / Wim Hof servers
- Lurking > Posting. Be helpful first.

**Product Hunt:**
- Launch on a Tuesday or Wednesday, 12:01am PT
- Get 5 friends to upvote + comment in first hour
- Prepare 3-4 week campaign before launch

**Hacker News:**
- Post on Show HN: "I built a privacy-first contrast therapy tracker"
- Be honest about struggles
- Respond to every comment

### 10.3 Launch Week Plan

**Pre-launch (Week -2):**
- 10 Reddit posts answering contrast therapy questions (no app mention)
- 1 YouTube video: "Why I'm building ContrastCoach"
- Email list sign-up: "Get early access" landing page (Carrd.co free)
- 50 emails collected

**Launch week (Day 0-7):**
- Day 0 (Sunday): Soft launch on Product Hunt (low traffic, but good for ranking)
- Day 1 (Monday): Reddit r/biohacking post (full transparency)
- Day 2 (Tuesday): Twitter thread (10 tweets)
- Day 3 (Wednesday): YouTube short + Hacker News
- Day 4 (Thursday): Cold plunge community post
- Day 5 (Friday): Email blast to list
- Day 6 (Saturday): Respond to all comments, collect testimonials
- Day 7 (Sunday): Reflect, plan week 2

**Post-launch (Week 2+):**
- Weekly Reddit post
- Weekly YouTube short
- Daily community engagement
- Monthly Product Hunt-style update ("What's new in ContrastCoach")

---

## 11. 90-Day Build Roadmap

### Phase 1: Research and Validation (Week 1-2)

**Week 1:**
- Read top 100 r/biohacking + r/coldplunge posts
- Watch 20 Huberman Lab cold/sauna episodes
- Build 10-protocol YAML/JSON file
- List 50 feature ideas, narrow to MVP 8

**Week 2:**
- Figma: 8 main screens (monochrome, Material 3 Expressive)
- User test: 5 biohackers give 30-min feedback ($50 each)
- Decide final feature list for MVP
- Set up GitHub repo, CI, signing config

### Phase 2: Vibe Code MVP (Week 3-6)

**Week 3:**
- Lovable: scaffold all 8 screens with mock data
- Add navigation (go_router)
- Onboarding flow with 3 steps
- Auth screens (Supabase email)

**Week 4:**
- Convert to Flutter (Lovable export + manual polish)
- Add Drift local DB
- Implement session lifecycle (start, pause, resume, end)
- Add timer with audio cues

**Week 5:**
- Implement 3 free protocols (Standard Recovery, Energy, Cold Only)
- Calculate recovery score v1 (without health data)
- Streak calendar
- Settings screen

**Week 6:**
- Beta build (APK) for internal testing
- Set up Sentry
- Set up RevenueCat sandbox
- 20 beta testers recruited (Reddit, friends)

### Phase 3: Pro Features (Week 7-9)

**Week 7:**
- Health Connect integration (read HR, HRV, sleep)
- Update recovery score to use health data
- Full 10 protocols

**Week 8:**
- Monthly Insights report
- Paywall + RevenueCat integration
- Subscription tiers (free, monthly, yearly, lifetime)
- Restore purchases

**Week 9:**
- Voice control (speech_to_text)
- Custom protocol builder (1 saved for Pro)
- Custom protocol validation
- All Pro features gated

### Phase 4: Polish and Compliance (Week 10-11)

**Week 10:**
- Complete Health Apps Declaration in Play Console
- Complete Data Safety form
- Write privacy policy (iubenda)
- Add medical disclaimers everywhere
- Add AI disclosure (if any)

**Week 11:**
- All screenshots, app icon, feature graphic
- App description (long + short)
- Internal testing track (20+ testers, 14 days)
- Crash-free rate target: >99.5%
- Performance: <3s cold start, <50MB APK size

### Phase 5: Launch (Week 12+)

**Week 12:**
- Submit to Play Store (closed testing to production)
- Wait for review (3-7 days)
- Set up Product Hunt page
- Prepare Reddit posts

**Week 13 (LAUNCH WEEK):**
- Monday: Reddit r/biohacking post
- Tuesday: Product Hunt launch
- Wednesday: Hacker News
- Thursday: YouTube
- Friday: Email blast
- Respond to every comment

**Week 14+ (post-launch):**
- Daily community engagement
- Weekly Reddit post
- Weekly YouTube short
- Monthly feature release
- First affiliate partnership outreach at 10k installs

---

## 12. Pre-Launch Checklist

### 12.1 Code Quality

- flutter analyze passes with zero warnings
- dart format formatted
- very_good_analysis enabled and passing
- All public APIs documented (dart doc)
- Widget tests for all critical components
- Integration tests for core flows
- No print() statements (use debugPrint or logger)
- No hardcoded secrets (use --dart-define)
- All strings in .arb files (i18n ready)
- No unused imports, no dead code
- All async functions have error handling
- All futures awaited (no unawaited() except for fire-and-forget)
- All BuildContext usage after async is mounted-checked

### 12.2 Functional

- Onboarding completes successfully
- Auth (sign up, sign in, sign out, password reset)
- All 3 free protocols complete a full session
- All 10 Pro protocols complete a full session
- Voice control works in active session
- Health Connect permission flow works
- Health data shows in insights
- Streak updates correctly
- Recovery score calculates correctly
- Paywall blocks Pro features for free users
- Purchase flow works (test with $0.99)
- Restore purchases works
- Local DB persists across app restarts
- Cloud sync uploads sessions
- Cloud sync downloads sessions on new device
- Data export produces valid JSON
- Data deletion removes all local + cloud data
- All 3 deep link paths work
- All push notification types work
- Background sync works (test by killing app)

### 12.3 Design

- Light mode correct
- Dark mode correct
- System theme follows correctly
- All text sizes accessible (test at 200% scale)
- All tap targets ≥ 48dp
- All interactive elements have haptics
- All transitions smooth (60fps)
- All screens load in <1s
- All images optimized (use SVG, no PNG bloat)
- No emoji used in UI
- No marketing copy in UI
- No color usage (monochrome verified)
- App icon visible against all launcher backgrounds
- Splash screen no flash of wrong color

### 12.4 Compliance

- Privacy policy URL live, accessible, matches app
- Data Safety form 100% accurate
- Health Apps Declaration 100% accurate
- AI disclosure (if applicable)
- Medical disclaimer in onboarding
- Medical disclaimer in Settings
- Medical disclaimer before any "advice"
- "Not affiliated with Google" disclaimer
- All permissions explained in app (in-app rationale screens)
- All third-party SDKs disclosed in Data Safety
- Sentry has no PII
- Analytics have no PII
- No data sharing with third parties for advertising
- GDPR-compliant (EU users can request export + deletion)
- CCPA-compliant (CA users can opt-out)
- COPPA-compliant (not targeting <13)

### 12.5 Performance

- App size: < 50MB
- Cold start: < 2s on mid-range device
- Frame time: 16ms (60fps) sustained
- Battery: < 2% per hour during active session
- Memory: < 150MB peak
- No ANRs in last 100 sessions
- No crashes in last 100 sessions

### 12.6 Store Listing

- App name (30 chars max)
- Short description (80 chars max)
- Full description (4,000 chars max)
- 8 phone screenshots
- 1 feature graphic (1024 x 500)
- 1 app icon (512 x 512)
- All localized (English only for v1)
- All category tags correct (Health and Fitness)
- Content rating: Everyone
- Target audience: 18+
- Pricing: Free (with in-app purchases)
- Country availability: All countries
- Contact email set
- Website link (optional but professional)

---

## 13. Post-Launch Operations

### 13.1 Daily (5 min)
- Check Sentry for crashes
- Reply to Play Store reviews
- Check RevenueCat dashboard for new subscribers

### 13.2 Weekly (2-3 hours)
- Respond to Reddit/Discord comments
- 1 Reddit post (helpful, no app mention)
- 1 YouTube short
- Review Supabase logs for errors
- Review Umami analytics
- 1 product improvement (small fix)

### 13.3 Monthly (1 day)
- Monthly Insights email (to subscribers)
- Release notes published
- App update (every 4-6 weeks)
- 1 new feature shipped
- 1 YouTube long-form video
- Affiliate partnership outreach (after 10k users)

### 13.4 Quarterly (2-3 days)
- Major feature release
- Pricing review
- iOS version (if Android succeeds)
- Wear OS version (if demand)
- Annual subscription discount campaign
- Tax filing (India + US)

### 13.5 Annual
- Tax filing (IT India, US 1099 if applicable)
- LLC renewal (if formed)
- Insurance renewal (cyber + liability)
- Privacy policy review
- Major UI refresh
- Roadmap planning for next year

---

## Appendix A: 12-Month Financial Projection

| Month | Installs | Paid | MRR | Affiliate | Total |
|---|---:|---:|---:|---:|---:|
| 1 (launch) | 500 | 0 | $0 | $0 | $0 |
| 2 | 1,200 | 8 | $48 | $0 | $48 |
| 3 | 2,500 | 30 | $180 | $50 | $230 |
| 4 | 5,000 | 75 | $450 | $150 | $600 |
| 5 | 8,000 | 130 | $780 | $300 | $1,080 |
| 6 | 12,000 | 200 | $1,200 | $500 | $1,700 |
| 7 | 18,000 | 290 | $1,740 | $800 | $2,540 |
| 8 | 25,000 | 400 | $2,400 | $1,200 | $3,600 |
| 9 | 35,000 | 550 | $3,300 | $1,800 | $5,100 |
| 10 | 50,000 | 750 | $4,500 | $2,500 | $7,000 |
| 11 | 70,000 | 1,000 | $6,000 | $3,500 | $9,500 |
| 12 | 100,000 | 1,400 | $8,400 | $5,000 | $13,400 |

**Assumptions:**
- 5% MoM install growth (front-loaded by Reddit launch, then product hunt, then word of mouth)
- 2% free-to-paid conversion (industry average for niche health apps)
- 20% monthly churn (good for new app)
- Average revenue per paid: $6/mo
- Affiliate conversion: 1.5% of active users x $50 average order

**Total Year 1: ~$45,000**
**Year 2 projection (with iOS + Wear OS): $150,000+**
**Year 3 projection (with B2B + international): $400,000+**

---

## Appendix B: Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Play Store rejection (health data) | Medium | High | Pre-submit checklist, thorough Health Apps Declaration |
| Health Connect API changes | Low | Medium | Pin version, monitor Android developer blog |
| Supabase outage | Low | Medium | Local-first, offline works fully without server |
| Sentry quota exceeded | Low | Low | Increase tier ($26/mo) if needed |
| Indie burnout | High | Critical | Find accountability partner, take weekends off |
| Negative press ("Indian dev makes US biohacker app") | Low | High | Full transparency in all posts, advisory board |
| Reddit ban for self-promotion | Medium | Medium | 90% value posts, 10% app mention max |
| Saturated biohacker market | Medium | Medium | Differentiate on privacy + phone-first + design |
| Algorithmic change drops install rate | Medium | Medium | Diversify marketing channels |
| Burnout kills maintenance | High | Critical | Don't build more features than you can maintain |

---

## Appendix C: When to Hire Help

**At 0 to 1,000 users (free):**
- Do everything yourself
- Use freelance code review once a month ($200)

**At 1,000 to 10,000 users ($300-500/mo budget):**
- 1 freelance Flutter dev (10 hours/month for bug fixes)
- 1 designer (1 hour/month for ASO screenshots)

**At 10,000 to 50,000 users ($2,000/mo budget):**
- 1 part-time Flutter dev (20 hours/week)
- 1 part-time community manager
- Maybe quit your day job

**At 50,000+ users ($10,000/mo budget):**
- 1 full-time Flutter dev
- 1 part-time designer
- 1 part-time marketing/community
- Time to incorporate (LLC in US + India)

---

## Appendix D: Free Tools Reference

**Design:**
- Figma (free for 3 projects)
- Lucide icons (free, 1.5px stroke, monochrome)
- Inter + JetBrains Mono (OFL, self-host)
- icon.kitchen (free Play Store icons)
- Carrd.co (free landing pages)
- Canva (free Play Store banners)

**Backend:**
- Supabase (free 500MB DB, 50k MAU, 1GB storage)
- GitHub (free private repos with CI)
- Vercel/Railway (free tier for Umami)

**Analytics:**
- Umami (self-hosted, free)
- Sentry (free 5K events/mo)
- Plausible (free self-host, or $9/mo cloud)

**Monetization:**
- RevenueCat (free up to $2.5k MRR)
- Google Play Billing (15% cut, no other option)

**Productivity:**
- Notion (free for personal)
- Linear (free for 1 user)
- Loom (free 25 videos)
- Trello (free for personal)

**Learning:**
- YouTube (free)
- Flutter docs (free)
- Huberman Lab podcast (free)

**Total monthly cost at 0 users: $0**
**Total monthly cost at $2,500 MRR: $0**
**Total monthly cost at $10,000 MRR: $0-50 (if you self-host Umami + Sentry)**
**Total monthly cost at $50,000 MRR: $200-500 (Supabase Pro, RevenueCat paid tier, Plausible Pro)**

---

## Appendix E: Why This Beats a "Just Use Firebase" Approach

1. No vendor lock-in: If Supabase dies tomorrow, you move to any Postgres + auth provider in a weekend
2. Privacy is real: We can literally host on our own server
3. Cost is zero until success: Firebase can cost $100/mo at 10k MAU
4. Offline is first-class: Drift + sync vs Firestore's limited offline
5. Code is yours: No proprietary APIs to learn
6. Open source community: Supabase, Drift, Riverpod all have huge communities

---

## Appendix F: Solo Dev Survival Guide

**Don't:**
- Build more than 1 feature per week
- Work more than 4 hours/day on this
- Add "just one more thing" to MVP
- Compare yourself to funded startups
- Quit your day job until $5k MRR sustained for 3 months

**Do:**
- Ship the smallest possible thing
- Talk to 5 users per week
- Take weekends off
- Celebrate every install
- Build in public (Twitter, Reddit)
- Save 6 months of expenses before going full-time
- Find 1 other solo dev friend for accountability

---

## Appendix G: The "Hard" Decisions You'll Face

| Decision | Recommendation |
|---|---|
| Monochrome vs color | Monochrome. Easier to maintain, looks premium, differentiates. |
| Flutter vs native | Flutter. 30% effort for 100% Android, 80% for iOS later. |
| iOS at launch or v2? | v2. Android first, validate, then iOS. |
| iOS at 5k or 50k users? | 10k. By then you have revenue to invest in iOS. |
| Wear OS or v2? | v2. Phone-first is the wedge. Wear OS in v3. |
| Open source the code? | Yes. Builds trust, attracts contributors, costs nothing. |
| B2B (gyms/spas) or v2? | v2. After 50k users, gyms will come to you. |
| Hardware integration (temp sensors)? | v3. Manual entry is fine for v1. |
| AI insights (LLM)? | v3. Algorithm-based insights are 80% as good, free. |
| Acquired by bigger app? | Sell at $1M+ only. Don't sell early. |

---

## Appendix H: Resources

**Reddit communities to lurk:**
- r/biohacking
- r/coldplunge
- r/HeatColdExposure
- r/wimhofmethod
- r/HubermanLab
- r/QuantifiedSelf
- r/fitness
- r/Health
- r/AndroidDev
- r/FlutterDev

**YouTube channels to watch:**
- Andrew Huberman (cold, sauna, dopamine)
- Galpin Institute (physiology)
- Thomas DeLauer (metabolism, cold)
- Ben Greenfield (biohacking)
- Wim Hof (cold)
- The Iceman (Wim Hof)

**Books to read:**
- "The Wim Hof Method" by Wim Hof
- "Tools of Titans" by Tim Ferriss (sauna/cold sections)
- "Why Zebras Don't Get Ulcers" by Robert Sapolsky (stress physiology)
- "Breath" by James Nestor (breathwork)

**Papers to cite in app (for credibility):**
- Buijze et al. (2016): "The effect of cold showering on health and work"
- Laukkanen et al. (2018): "Cardiovascular and other health benefits of sauna"
- Dugué and Leppänen (2018): "Sauna bathing and inflammation"
- Sheng et al. (2021): "Sauna use and risk of cardiovascular disease"

---

## Final Note

This plan is realistic for a solo Indian dev using vibe coding tools. It is not a fantasy roadmap that takes $100k and a team of 5. It is exactly what one person can do in 90 days part-time, using only free tools, with a monochrome Material 3 Expressive design that looks like a $50M-funded startup.

**Start date: Today.**
**First step: Set up the Figma file and design 8 screens in monochrome.**
**Second step: Vibe code the home screen in Lovable.**
**Third step: Post your first 5 helpful comments on r/biohacking (no app mention).**

Bhai, the only difference between you and a $1M ARR app is shipping. Bol kya chahiye next: Figma template, ya r/biohacking ka first post, ya GitHub repo starter code?
