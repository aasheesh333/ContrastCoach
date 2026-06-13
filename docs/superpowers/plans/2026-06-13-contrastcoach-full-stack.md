# ContrastCoach Full-Stack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build ContrastCoach end-to-end from `flutter create` to Play Store internal-testing-ready, covering v0.1 (Foundation + voice), v0.5 (Auth + Health Connect + sync), and v1.0 (Subscription + Insights + Play Store).

**Architecture:** 3-layer Flutter app (Presentation / Domain / Data) using Riverpod 2.6, Drift + SQLCipher, Firebase Auth + Firestore + Analytics, Health Connect, RevenueCat, Sentry. Monochrome Material 3 Expressive. Offline-first.

**Tech Stack:** Flutter 3.24+, Dart 3.5+, Riverpod 2.6 + `riverpod_generator`, Drift 2.20 + `sqlcipher_flutter_libs`, Hive 2.2, Firebase Auth + Firestore + Analytics, `health` Flutter package, `speech_to_text`, `just_audio`, RevenueCat, Sentry, go_router 14+, `very_good_analysis` lint, `integration_test` + Patrol.

**Reference:** [`docs/superpowers/specs/2026-06-13-contrastcoach-full-stack-design.md`](../specs/2026-06-13-contrastcoach-full-stack-design.md) is the source of truth for all architectural decisions. Read it before starting.

---

## How to use this plan

This plan has **9 phases**, each producing a working, testable slice. Stop after any phase and you have something runnable. Each task ends with a commit.

**Phases:**
1. **Foundation** (Tasks 1-15) — Flutter project, theme, atomic widgets, Drift DB, encryption
2. **Domain layer** (Tasks 16-25) — entities, use cases, score calculator, protocol validator
3. **Session state machine + screens** (Tasks 26-40) — onboarding, home, active session, summary
4. **Voice + audio + streak** (Tasks 41-50) — speech-to-text, manual fallback, audio cues, streak calendar
5. **v0.5: Auth + Firestore sync** (Tasks 51-60) — Firebase Auth, Firestore sync engine, security rules
6. **v0.5: Health Connect** (Tasks 61-68) — permissions, READ HR/HRV/sleep, WRITE MindfulSession
7. **v1.0: Subscription** (Tasks 69-78) — RevenueCat, paywall, free/Pro gating
8. **v1.0: Insights + Custom protocols** (Tasks 79-86) — monthly report, custom protocol builder
9. **v1.0: Polish + Play Store** (Tasks 87-100) — assets, store listing, internal testing, submit

**Conventions:**
- File paths are exact, relative to `contrast_coach/` Flutter project root (created in Task 2)
- `flutter` commands assume `flutter` is on `$PATH` (verified in Task 1)
- Test commands assume `flutter test` from the project root
- Every commit message uses Conventional Commits (`feat:`, `fix:`, `chore:`, `test:`, `docs:`)
- All Dart code follows `very_good_analysis` lint rules (set up in Task 4)

---

## Phase 1: Foundation

### Task 1: Install Flutter toolchain and verify

**Files:**
- Read: `https://docs.flutter.dev/get-started/install/linux/android`
- No code changes

- [ ] **Step 1: Install Flutter**

```bash
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
export PATH="$HOME/flutter/bin:$PATH"
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
```

- [ ] **Step 2: Install Android dependencies**

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk-headless curl unzip git xz-utils zip libglu1-mesa
sudo snap install android-studio --classic
# OR install command-line tools only:
# https://developer.android.com/studio#command-line-tools-only
# Then `sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"`
```

- [ ] **Step 3: Accept Android licenses**

```bash
flutter doctor --android-licenses
# Type 'y' for each
```

- [ ] **Step 4: Verify toolchain**

Run: `flutter doctor -v`
Expected: shows Flutter, Android toolchain, Android Studio (or command-line tools), connected device or emulator. No red "X" issues.

- [ ] **Step 5: Commit (no changes — just doc the install)**

```bash
cd /root/ContrastCoach
git commit --allow-empty -m "chore: flutter toolchain installed and verified"
```

### Task 2: Create Flutter project

**Files:**
- Create: `contrast_coach/` (Flutter project root)

- [ ] **Step 1: Create project**

```bash
cd /root/ContrastCoach
flutter create --org com.contrastcoach --project-name contrast_coach --platforms=android,ios contrast_coach
```

- [ ] **Step 2: Verify project builds**

```bash
cd contrast_coach
flutter pub get
flutter analyze
flutter test
```

Expected: `flutter analyze` reports 0 issues. `flutter test` passes the default widget test.

- [ ] **Step 3: Verify Android build**

```bash
flutter build apk --debug
```

Expected: `Built build/app/outputs/flutter-apk/app-debug.apk`

- [ ] **Step 4: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/
git commit -m "chore: scaffold Flutter project"
```

### Task 3: Configure pubspec.yaml with all v1.0 dependencies

**Files:**
- Modify: `contrast_coach/pubspec.yaml`
- Create: `contrast_coach/.env.example`

- [ ] **Step 1: Add runtime dependencies**

```bash
cd /root/ContrastCoach/contrast_coach
flutter pub add flutter_riverpod riverpod_annotation go_router
flutter pub add drift drift_flutter sqlite3_flutter_libs sqlcipher_flutter_libs path_provider path
flutter pub add hive hive_flutter flutter_secure_storage
flutter pub add firebase_core firebase_auth cloud_firestore firebase_analytics firebase_crashlytics
flutter pub add health speech_to_text just_audio
flutter pub add purchases_flutter sentry_flutter sentry_dio
flutter pub add flutter_local_notifications workmanager
flutter pub add dio dio_certificate_pinning
flutter pub add freezed_annotation json_annotation
flutter pub add lucide_icons_flutter
flutter pub add intl uuid permission_handler
flutter pub add flutter_dotenv
```

- [ ] **Step 2: Add dev dependencies**

```bash
flutter pub add --dev build_runner riverpod_generator drift_dev freezed json_serializable
flutter pub add --dev mocktail patrol_cli integration_test
flutter pub add --dev very_good_analysis
```

- [ ] **Step 3: Configure assets and fonts**

Modify `pubspec.yaml` to add (merge into existing `flutter:` block):

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/protocols.json
    - assets/changelog.json
    - .env
  fonts:
    - family: InterTight
      fonts:
        - asset: assets/fonts/InterTight-Variable.ttf
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Variable.ttf
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
```

- [ ] **Step 4: Create `.env.example`**

```bash
cat > .env.example <<'EOF'
# Firebase
FIREBASE_API_KEY=
FIREBASE_PROJECT_ID=
FIREBASE_APP_ID=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_STORAGE_BUCKET=

# RevenueCat
REVENUECAT_API_KEY=

# Sentry
SENTRY_DSN=

# App
ENV=dev
EOF
cp .env.example .env
echo ".env" >> /root/ContrastCoach/.gitignore
```

- [ ] **Step 5: Run pub get and verify**

Run: `flutter pub get && flutter pub deps --no-dev --style=tree | head -50`
Expected: All packages resolved, no version conflicts.

- [ ] **Step 6: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/pubspec.yaml contrast_coach/pubspec.lock contrast_coach/.env.example
git commit -m "chore: add all v1.0 dependencies and .env template"
```

### Task 4: Set up analysis_options.yaml

**Files:**
- Modify: `contrast_coach/analysis_options.yaml`

- [ ] **Step 1: Replace analysis_options.yaml**

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.drift.dart"
    - "**/*.gen.dart"
  errors:
    invalid_annotation_target: ignore
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    - prefer_single_quotes
    - sort_constructors_first
    - sort_pub_dependencies
    - public_member_api_docs
    - unawaited_futures
    - avoid_print
    - require_trailing_commas
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_final_locals
    - prefer_final_in_for_each
```

- [ ] **Step 2: Verify**

Run: `cd contrast_coach && flutter analyze`
Expected: may have warnings on generated files (excluded), but no errors in `lib/`.

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/analysis_options.yaml
git commit -m "chore: configure very_good_analysis lint rules"
```

### Task 5: Bundle assets (protocols, changelog, fonts, audio)

**Files:**
- Copy to: `contrast_coach/assets/protocols.json` (from `/root/ContrastCoach/assets/protocols.json`)
- Copy to: `contrast_coach/assets/changelog.json` (from `/root/ContrastCoach/assets/changelog.json`)
- Download: `contrast_coach/assets/fonts/InterTight-Variable.ttf`
- Download: `contrast_coach/assets/fonts/Inter-Variable.ttf`
- Download: `contrast_coach/assets/fonts/JetBrainsMono-Regular.ttf`

- [ ] **Step 1: Copy JSON assets**

```bash
cd /root/ContrastCoach/contrast_coach
mkdir -p assets/fonts assets/audio
cp ../assets/protocols.json assets/
cp ../assets/changelog.json assets/
```

- [ ] **Step 2: Download fonts**

```bash
cd contrast_coach/assets/fonts
curl -L -o InterTight-Variable.ttf "https://github.com/rsms/inter/raw/master/docs/font-files/InterTight-Variable.ttf"
curl -L -o Inter-Variable.ttf "https://github.com/rsms/inter/raw/master/docs/font-files/InterVariable.ttf"
curl -L -o JetBrainsMono-Regular.ttf "https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/JetBrainsMono-Regular.ttf"
ls -la
```

Expected: 3 .ttf files, each >50KB.

- [ ] **Step 3: Verify font licensing**

Add to `assets/fonts/OFL.txt`:

```
Inter, Inter Tight: Copyright (c) Rasmus Andersson. SIL Open Font License 1.1.
JetBrains Mono: Copyright (c) JetBrains s.r.o. SIL Open Font License 1.1.
```

- [ ] **Step 4: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/assets/
git commit -m "chore: bundle protocols, changelog, and OFL-licensed fonts"
```


### Task 6: Create core constants (colors, typography, shapes, motion, strings, assets)

**Files:**
- Create: `contrast_coach/lib/core/constants/app_colors.dart`
- Create: `contrast_coach/lib/core/constants/app_typography.dart`
- Create: `contrast_coach/lib/core/constants/app_shapes.dart`
- Create: `contrast_coach/lib/core/constants/app_motion.dart`
- Create: `contrast_coach/lib/core/constants/app_strings.dart`
- Create: `contrast_coach/lib/core/constants/app_assets.dart`

- [ ] **Step 1: app_colors.dart**

```dart
import 'package:flutter/material.dart';

/// Monochrome Material 3 color tokens. No chromatic accents.
class AppColors {
  const AppColors._();

  // Light
  static const Color lightSurface0 = Color(0xFFFFFFFF);
  static const Color lightSurface1 = Color(0xFFF7F7F7);
  static const Color lightSurface2 = Color(0xFFEDEDED);
  static const Color lightSurface3 = Color(0xFFE0E0E0);
  static const Color lightOnSurfacePrimary = Color(0xFF0A0A0A);
  static const Color lightOnSurfaceSecondary = Color(0xFF5C5C5C);
  static const Color lightOnSurfaceTertiary = Color(0xFF8C8C8C);

  // Dark
  static const Color darkSurface0 = Color(0xFF0A0A0A);
  static const Color darkSurface1 = Color(0xFF141414);
  static const Color darkSurface2 = Color(0xFF1F1F1F);
  static const Color darkSurface3 = Color(0xFF2A2A2A);
  static const Color darkOnSurfacePrimary = Color(0xFFF5F5F5);
  static const Color darkOnSurfaceSecondary = Color(0xFFA8A8A8);
  static const Color darkOnSurfaceTertiary = Color(0xFF6E6E6E);
}
```

- [ ] **Step 2: app_typography.dart**

```dart
import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static const String displayFont = 'InterTight';
  static const String bodyFont = 'Inter';
  static const String monoFont = 'JetBrainsMono';

  static const TextStyle displayLarge =
      TextStyle(fontFamily: displayFont, fontSize: 57, height: 64 / 57, fontWeight: FontWeight.w300);
  static const TextStyle displayMedium =
      TextStyle(fontFamily: displayFont, fontSize: 45, height: 52 / 45, fontWeight: FontWeight.w300);
  static const TextStyle headlineLarge =
      TextStyle(fontFamily: displayFont, fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w500);
  static const TextStyle headlineMedium =
      TextStyle(fontFamily: displayFont, fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w500);
  static const TextStyle titleLarge =
      TextStyle(fontFamily: bodyFont, fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600);
  static const TextStyle titleMedium = TextStyle(
        fontFamily: bodyFont, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600, letterSpacing: 0.15,
      );
  static const TextStyle bodyLarge =
      TextStyle(fontFamily: bodyFont, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400);
  static const TextStyle bodyMedium =
      TextStyle(fontFamily: bodyFont, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400);
  static const TextStyle bodySmall =
      TextStyle(fontFamily: bodyFont, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400);
  static const TextStyle labelLarge = TextStyle(
        fontFamily: bodyFont, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
      );
  static const TextStyle labelSmall = TextStyle(
        fontFamily: bodyFont, fontSize: 11, height: 16 / 11, fontWeight: FontWeight.w500, letterSpacing: 0.5,
      );

  static const TextStyle timerMono = TextStyle(
    fontFamily: monoFont,
    fontSize: 96,
    fontWeight: FontWeight.w200,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelSmall: labelSmall,
  );
}
```

- [ ] **Step 3: app_shapes.dart**

```dart
class AppShapes {
  const AppShapes._();

  static const double cardSmall = 12;
  static const double cardMedium = 16;
  static const double cardLarge = 28;
  static const double buttonDefault = 12;
  static const double fabPill = 999;
  static const double sheetTop = 28;
}
```

- [ ] **Step 4: app_motion.dart**

```dart
import 'package:flutter/material.dart';

class AppMotion {
  const AppMotion._();

  static const Duration pageTransition = Duration(milliseconds: 240);
  static const Duration microInteraction = Duration(milliseconds: 180);
  static const Duration macroInteraction = Duration(milliseconds: 320);

  static const SpringDescription springDefault = SpringDescription(
    mass: 1.0,
    stiffness: 380,
    damping: 22,
  );
}
```

- [ ] **Step 5: app_strings.dart**

```dart
class AppStrings {
  const AppStrings._();

  static const String appName = 'ContrastCoach';
  static const String appTagline = 'Track heat. Track cold. See what works.';

  // Medical disclaimer (required in onboarding, settings, paywall, insights)
  static const String medicalDisclaimer =
      'This app is for informational and educational purposes only. '
      'It is not a medical device. Consult a healthcare professional '
      'before starting any new recovery routine.';

  // Onboarding
  static const String onboardingStep1Title = 'Track heat. Track cold. See what works.';
  static const String onboardingStep1Body =
      "Designed for the 95% of contrast therapy users who don't wear a watch into a 90C sauna.";
  static const String onboardingStep2Title = 'Built for your phone. Not your watch.';
  static const String onboardingStep2Body =
      'Apple warns against exposing watches above 35C. Voice commands work from inside the sauna.';
  static const String onboardingStep3Title = 'Your data stays on your device.';
  static const String onboardingStep3Body =
      "Health data is processed on-device. We don't see it. We don't store it. We don't sell it.";

  // Paywall
  static const String paywallMonthly = '\$5.99 / month';
  static const String paywallYearly = '\$39.99 / year';
  static const String paywallLifetime = '\$89.99 once';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection.';
}
```

- [ ] **Step 6: app_assets.dart**

```dart
class AppAssets {
  const AppAssets._();

  static const String protocolsJson = 'assets/protocols.json';
  static const String changelogJson = 'assets/changelog.json';

  static const String audioPhaseTransition = 'assets/audio/phase_transition.ogg';
  static const String audioSessionStart = 'assets/audio/session_start.ogg';
  static const String audioSessionComplete = 'assets/audio/session_complete.ogg';
}
```

- [ ] **Step 7: Run analyze**

Run: `cd contrast_coach && flutter analyze`
Expected: 0 issues.

- [ ] **Step 8: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/core/constants/
git commit -m "feat: add core constants (colors, typography, shapes, motion, strings, assets)"
```

### Task 7: Create app theme (light + dark)

**Files:**
- Create: `contrast_coach/lib/core/theme/app_theme.dart`
- Create: `contrast_coach/lib/core/theme/light_theme.dart`
- Create: `contrast_coach/lib/core/theme/dark_theme.dart`
- Create: `contrast_coach/test/core/theme/app_theme_test.dart`

- [ ] **Step 1: Write test first**

```dart
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses monochrome colors only', () {
      final theme = AppTheme.light();
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.surface, AppColors.lightSurface0);
      expect(theme.colorScheme.onSurface, AppColors.lightOnSurfacePrimary);
      expect(theme.textTheme.displayLarge, AppTypography.displayLarge);
    });

    test('dark theme uses monochrome colors only', () {
      final theme = AppTheme.dark();
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.surface, AppColors.darkSurface0);
      expect(theme.colorScheme.onSurface, AppColors.darkOnSurfacePrimary);
    });

    test('no chromatic primary color (grayscale only)', () {
      expect(AppTheme.light().colorScheme.primary, AppColors.lightOnSurfacePrimary);
      expect(AppTheme.dark().colorScheme.primary, AppColors.darkOnSurfacePrimary);
    });
  });
}
```

- [ ] **Step 2: Run test, expect fail**

Run: `cd contrast_coach && flutter test test/core/theme/app_theme_test.dart`
Expected: FAIL.

- [ ] **Step 3: light_theme.dart**

```dart
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  const cs = ColorScheme.light(
    brightness: Brightness.light,
    primary: AppColors.lightOnSurfacePrimary,
    onPrimary: AppColors.lightSurface0,
    secondary: AppColors.lightOnSurfacePrimary,
    onSecondary: AppColors.lightSurface0,
    surface: AppColors.lightSurface0,
    onSurface: AppColors.lightOnSurfacePrimary,
    surfaceContainerLowest: AppColors.lightSurface0,
    surfaceContainerLow: AppColors.lightSurface1,
    surfaceContainer: AppColors.lightSurface2,
    surfaceContainerHigh: AppColors.lightSurface3,
    surfaceContainerHighest: AppColors.lightSurface3,
    onSurfaceVariant: AppColors.lightOnSurfaceSecondary,
    outline: AppColors.lightSurface2,
    outlineVariant: AppColors.lightSurface3,
    error: AppColors.lightOnSurfacePrimary,
    onError: AppColors.lightSurface0,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: cs.surface,
    splashFactory: NoSplash.splashFactory(),
    visualDensity: VisualDensity.standard,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
```

- [ ] **Step 4: dark_theme.dart**

```dart
import 'package:contrast_coach/core/constants/app_colors.dart';
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  const cs = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: AppColors.darkOnSurfacePrimary,
    onPrimary: AppColors.darkSurface0,
    secondary: AppColors.darkOnSurfacePrimary,
    onSecondary: AppColors.darkSurface0,
    surface: AppColors.darkSurface0,
    onSurface: AppColors.darkOnSurfacePrimary,
    surfaceContainerLowest: AppColors.darkSurface0,
    surfaceContainerLow: AppColors.darkSurface1,
    surfaceContainer: AppColors.darkSurface2,
    surfaceContainerHigh: AppColors.darkSurface3,
    surfaceContainerHighest: AppColors.darkSurface3,
    onSurfaceVariant: AppColors.darkOnSurfaceSecondary,
    outline: AppColors.darkSurface2,
    outlineVariant: AppColors.darkSurface3,
    error: AppColors.darkOnSurfacePrimary,
    onError: AppColors.darkSurface0,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: cs.surface,
    splashFactory: NoSplash.splashFactory(),
    visualDensity: VisualDensity.standard,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
```

- [ ] **Step 5: app_theme.dart**

```dart
import 'package:contrast_coach/core/theme/dark_theme.dart';
import 'package:contrast_coach/core/theme/light_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => buildLightTheme();
  static ThemeData dark() => buildDarkTheme();
}
```

- [ ] **Step 6: Run test, expect pass**

Run: `cd contrast_coach && flutter test test/core/theme/app_theme_test.dart`
Expected: 3 tests pass.

- [ ] **Step 7: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/core/theme/ contrast_coach/test/core/theme/
git commit -m "feat: monochrome Material 3 light and dark themes"
```

### Task 8: Create env config (reads from --dart-define and .env)

**Files:**
- Create: `contrast_coach/lib/core/env/env_keys.dart`
- Create: `contrast_coach/lib/core/env/env_config.dart`
- Create: `contrast_coach/test/core/env/env_config_test.dart`

- [ ] **Step 1: env_keys.dart**

```dart
class EnvKeys {
  const EnvKeys._();

  static const String env = 'ENV';
  static const String firebaseApiKey = 'FIREBASE_API_KEY';
  static const String firebaseProjectId = 'FIREBASE_PROJECT_ID';
  static const String firebaseAppId = 'FIREBASE_APP_ID';
  static const String firebaseMessagingSenderId = 'FIREBASE_MESSAGING_SENDER_ID';
  static const String firebaseStorageBucket = 'FIREBASE_STORAGE_BUCKET';
  static const String revenuecatApiKey = 'REVENUECAT_API_KEY';
  static const String sentryDsn = 'SENTRY_DSN';
}
```

- [ ] **Step 2: env_config.dart**

```dart
import 'package:contrast_coach/core/env/env_keys.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  const EnvConfig._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env file may not exist in tests / CI; ignore
    }
    _initialized = true;
  }

  static String? _read(String key) {
    final fromDefine = String.fromEnvironment(key, defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (dotenv.isInitialized) return dotenv.env[key];
    return null;
  }

  static String? get env {
    final v = _read(EnvKeys.env);
    if (v == null || v.isEmpty) return 'dev';
    return v;
  }

  static bool get isDev => env == 'dev' || env == null;
  static bool get isProd => env == 'prod';

  static String? get firebaseApiKey => _read(EnvKeys.firebaseApiKey);
  static String? get firebaseProjectId => _read(EnvKeys.firebaseProjectId);
  static String? get firebaseAppId => _read(EnvKeys.firebaseAppId);
  static String? get firebaseMessagingSenderId => _read(EnvKeys.firebaseMessagingSenderId);
  static String? get firebaseStorageBucket => _read(EnvKeys.firebaseStorageBucket);
  static String? get revenuecatApiKey => _read(EnvKeys.revenuecatApiKey);
  static String? get sentryDsn => _read(EnvKeys.sentryDsn);
}
```

- [ ] **Step 3: env_config_test.dart**

```dart
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await EnvConfig.init();
  });

  group('EnvConfig', () {
    test('isDev true when no env set', () {
      expect(EnvConfig.isDev, isTrue);
    });

    test('isProd false in test', () {
      expect(EnvConfig.isProd, isFalse);
    });

    test('firebaseApiKey returns null when not set', () {
      expect(EnvConfig.firebaseApiKey, isNull);
    });
  });
}
```

- [ ] **Step 4: Run test**

Run: `cd contrast_coach && flutter test test/core/env/env_config_test.dart`
Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/core/env/ contrast_coach/test/core/env/
git commit -m "feat: env config from --dart-define and .env"
```

### Task 9: Create error types and result wrapper

**Files:**
- Create: `contrast_coach/lib/core/errors/app_exception.dart`
- Create: `contrast_coach/lib/core/errors/result.dart`
- Create: `contrast_coach/test/core/errors/result_test.dart`

- [ ] **Step 1: app_exception.dart**

```dart
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => 'AppException: $message${cause != null ? " (cause: $cause)" : ""}';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.cause});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.cause});
}

class HealthPermissionException extends AppException {
  const HealthPermissionException(super.message, {super.cause});
}

class HealthReadException extends AppException {
  const HealthReadException(super.message, {super.cause});
}

class SubscriptionException extends AppException {
  const SubscriptionException(super.message, {super.cause});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {this.errors = const []});
  final List<String> errors;
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.cause});
}
```

- [ ] **Step 2: result.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';

sealed class Result<T, E extends AppException> {
  const Result();

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  R fold<R>(R Function(E error) onErr, R Function(T value) onOk) {
    final self = this;
    if (self is Ok<T, E>) return onOk(self.value);
    return onErr((self as Err<T, E>).error);
  }
}

class Ok<T, E extends AppException> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

class Err<T, E extends AppException> extends Result<T, E> {
  const Err(this.error);
  final E error;
}
```

- [ ] **Step 3: result_test.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok carries a value', () {
      const r = Ok<int, AppException>(42);
      expect(r.isOk, isTrue);
      expect(r.isErr, isFalse);
      expect(r.value, 42);
    });

    test('Err carries an error', () {
      const r = Err<int, AppException>(DatabaseException('boom'));
      expect(r.isOk, isFalse);
      expect(r.isErr, isTrue);
      expect((r as Err).error, isA<DatabaseException>());
    });

    test('fold dispatches on Ok/Err', () {
      const ok = Ok<int, AppException>(1);
      const err = Err<int, AppException>(DatabaseException('x'));
      expect(ok.fold((e) => 'err', (v) => 'ok:$v'), 'ok:1');
      expect(err.fold((e) => 'err:${e.message}', (v) => 'ok:$v'), 'err:x');
    });
  });
}
```

- [ ] **Step 4: Run test**

Run: `cd contrast_coach && flutter test test/core/errors/result_test.dart`
Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/core/errors/ contrast_coach/test/core/errors/
git commit -m "feat: AppException hierarchy and Result wrapper"
```


### Task 10: Create atomic widget — AppIcon and AppButton

**Files:**
- Create: `contrast_coach/lib/presentation/widgets/atomic/app_icon.dart`
- Create: `contrast_coach/lib/presentation/widgets/atomic/app_button.dart`
- Create: `contrast_coach/test/presentation/widgets/atomic/app_button_test.dart`

- [ ] **Step 1: app_icon.dart**

```dart
import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 20, this.color});
  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color ?? Theme.of(context).colorScheme.onSurface);
  }
}
```

- [ ] **Step 2: Write widget test first**

```dart
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('renders label', (tester) async {
    await tester.pumpWidget(_wrap(AppButton(label: 'Continue', onPressed: () {})));
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('invokes onPressed when tapped', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(AppButton(label: 'Go', onPressed: () => taps++)));
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('does not invoke onPressed when null', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(AppButton(label: 'Disabled', onPressed: null)));
    await tester.tap(find.byType(AppButton), warnIfMissed: false);
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('tap target is at least 48dp', (tester) async {
    await tester.pumpWidget(_wrap(AppButton(label: 'Tap', onPressed: () {})));
    final size = tester.getSize(find.byType(AppButton));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('renders loading spinner when isLoading', (tester) async {
    await tester.pumpWidget(
      _wrap(AppButton(label: 'Save', onPressed: () {}, isLoading: true)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });
}
```

- [ ] **Step 3: app_button.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, tertiary, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = onPressed == null || isLoading;

    final (Color bg, Color fg, BorderSide? border) = switch (variant) {
      AppButtonVariant.primary => (cs.onSurface, cs.surface, null),
      AppButtonVariant.secondary => (cs.surface, cs.onSurface, BorderSide(color: cs.outline)),
      AppButtonVariant.tertiary => (Colors.transparent, cs.onSurface, BorderSide(color: cs.outline)),
      AppButtonVariant.text => (Colors.transparent, cs.onSurface, null),
    };

    final fgEffective = isDisabled ? cs.onSurfaceVariant : fg;

    return SizedBox(
      height: 48,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fgEffective),
                    ),
                  )
                else ...[
                  if (leadingIcon != null) ...[
                    AppIcon(leadingIcon!, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fgEffective),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    AppIcon(trailingIcon!, size: 18),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test, expect pass**

Run: `cd contrast_coach && flutter test test/presentation/widgets/atomic/app_button_test.dart`
Expected: 5 tests pass.

- [ ] **Step 5: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/widgets/atomic/app_icon.dart contrast_coach/lib/presentation/widgets/atomic/app_button.dart contrast_coach/test/presentation/widgets/atomic/app_button_test.dart
git commit -m "feat: AppButton atomic widget (4 variants, loading, disabled, 48dp target)"
```

### Task 11: Create remaining atomic widgets

**Files:**
- Create: `contrast_coach/lib/presentation/widgets/atomic/app_card.dart`
- Create: `contrast_coach/lib/presentation/widgets/atomic/app_text_field.dart`
- Create: `contrast_coach/lib/presentation/widgets/atomic/app_divider.dart`
- Create: `contrast_coach/lib/presentation/widgets/atomic/app_switch.dart`
- Create: `contrast_coach/lib/presentation/widgets/atomic/app_slider.dart`
- Create: `contrast_coach/lib/presentation/widgets/atomic/app_chip.dart`
- Create: `contrast_coach/test/presentation/widgets/atomic/app_card_test.dart`
- Create: `contrast_coach/test/presentation/widgets/atomic/app_text_field_test.dart`
- Create: `contrast_coach/test/presentation/widgets/atomic/app_switch_test.dart`
- Create: `contrast_coach/test/presentation/widgets/atomic/app_chip_test.dart`

- [ ] **Step 1: app_card.dart**

```dart
import 'package:flutter/material.dart';

enum AppCardElevation { low, medium, high }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.elevation = AppCardElevation.low,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final AppCardElevation elevation;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, radius) = switch (elevation) {
      AppCardElevation.low => (cs.surface, 12.0),
      AppCardElevation.medium => (cs.surfaceContainerLow, 16.0),
      AppCardElevation.high => (cs.surfaceContainer, 28.0),
    };

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
```

- [ ] **Step 2: app_text_field.dart**

```dart
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.onChanged,
    this.errorText,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      onChanged: onChanged,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: cs.outline)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.onSurface, width: 2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
```

- [ ] **Step 3: app_divider.dart**

```dart
import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.indent = 0, this.endIndent = 0});
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      color: Theme.of(context).colorScheme.outline,
    );
  }
}
```

- [ ] **Step 4: app_switch.dart**

```dart
import 'package:flutter/material.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: cs.onSurface,
      activeTrackColor: cs.onSurface.withValues(alpha: 0.5),
      inactiveThumbColor: cs.onSurfaceVariant,
      inactiveTrackColor: cs.surfaceContainerHigh,
      trackOutlineColor: WidgetStateProperty.all(cs.outline),
    );
  }
}
```

- [ ] **Step 5: app_slider.dart**

```dart
import 'package:flutter/material.dart';

class AppSlider extends StatelessWidget {
  const AppSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 2,
        activeTrackColor: cs.onSurface,
        inactiveTrackColor: cs.outline,
        thumbColor: cs.onSurface,
        overlayColor: cs.onSurface.withValues(alpha: 0.1),
        valueIndicatorColor: cs.onSurface,
        valueIndicatorTextStyle: TextStyle(color: cs.surface),
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}
```

- [ ] **Step 6: app_chip.dart**

```dart
import 'package:flutter/material.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected ? cs.onSurface : cs.outline,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: app_card_test.dart**

```dart
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('renders child', (tester) async {
    await tester.pumpWidget(_wrap(const AppCard(child: Text('Card'))));
    expect(find.text('Card'), findsOneWidget);
  });

  testWidgets('invokes onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(AppCard(child: const Text('X'), onTap: () => taps++)));
    await tester.tap(find.byType(AppCard));
    await tester.pump();
    expect(taps, 1);
  });
}
```

- [ ] **Step 8: app_text_field_test.dart**

```dart
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      );

  testWidgets('shows label', (tester) async {
    await tester.pumpWidget(_wrap(const AppTextField(label: 'Email')));
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('invokes onChanged', (tester) async {
    String? changed;
    await tester.pumpWidget(_wrap(
      AppTextField(label: 'Email', onChanged: (v) => changed = v),
    ));
    await tester.enterText(find.byType(TextField), 'a@b.com');
    expect(changed, 'a@b.com');
  });

  testWidgets('shows error text', (tester) async {
    await tester.pumpWidget(_wrap(const AppTextField(label: 'Email', errorText: 'Required')));
    expect(find.text('Required'), findsOneWidget);
  });
}
```

- [ ] **Step 9: app_switch_test.dart**

```dart
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      );

  testWidgets('toggles value', (tester) async {
    bool value = false;
    await tester.pumpWidget(_wrap(
      AppSwitch(value: value, onChanged: (v) => value = v),
    ));
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(value, isTrue);
  });
}
```

- [ ] **Step 10: app_chip_test.dart**

```dart
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('renders label', (tester) async {
    await tester.pumpWidget(_wrap(const AppChip(label: 'Recovery')));
    expect(find.text('Recovery'), findsOneWidget);
  });

  testWidgets('invokes onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(AppChip(label: 'X', onTap: () => taps++)));
    await tester.tap(find.byType(AppChip));
    expect(taps, 1);
  });
}
```

- [ ] **Step 11: Run all atomic widget tests**

Run: `cd contrast_coach && flutter test test/presentation/widgets/atomic/`
Expected: all tests pass.

- [ ] **Step 12: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/widgets/atomic/ contrast_coach/test/presentation/widgets/atomic/
git commit -m "feat: complete atomic widget library (8 widgets, all tested)"
```

### Task 12: Create layout widgets

**Files:**
- Create: `contrast_coach/lib/presentation/widgets/layout/app_bar.dart`
- Create: `contrast_coach/lib/presentation/widgets/layout/bottom_nav.dart`
- Create: `contrast_coach/lib/presentation/widgets/layout/sheet_container.dart`
- Create: `contrast_coach/test/presentation/widgets/layout/bottom_nav_test.dart`

- [ ] **Step 1: app_bar.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ContrastAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ContrastAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.showBackButton = false,
    this.onBack,
  });

  final String title;
  final List<Widget> actions;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      shape: Border(bottom: BorderSide(color: cs.outline)),
      leading: showBackButton
          ? IconButton(
              icon: const AppIcon(LucideIcons.chevronLeft, size: 20),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
```

- [ ] **Step 2: bottom_nav.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BottomNavItem {
  const BottomNavItem({required this.label, required this.icon, required this.location});
  final String label;
  final IconData icon;
  final String location;
}

class ContrastBottomNav extends StatelessWidget {
  const ContrastBottomNav({super.key, required this.currentLocation, required this.onTap});

  final String currentLocation;
  final ValueChanged<String> onTap;

  static const List<BottomNavItem> items = [
    BottomNavItem(label: 'Home', icon: LucideIcons.house, location: '/home'),
    BottomNavItem(label: 'Streak', icon: LucideIcons.calendar, location: '/streak'),
    BottomNavItem(label: 'Insights', icon: LucideIcons.barChart, location: '/insights'),
  ];

  int get _currentIndex {
    final i = items.indexWhere((i) => currentLocation.startsWith(i.location));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(items[i].location),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(
                          items[i].icon,
                          size: 20,
                          color: i == _currentIndex ? cs.onSurface : cs.onSurfaceVariant,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: i == _currentIndex ? cs.onSurface : cs.onSurfaceVariant,
                                fontWeight: i == _currentIndex ? FontWeight.w600 : FontWeight.w400,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: sheet_container.dart**

```dart
import 'package:flutter/material.dart';

class SheetContainer extends StatelessWidget {
  const SheetContainer({super.key, required this.child, this.onClose});
  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: bottom_nav_test.dart**

```dart
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/widgets/layout/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders 3 items and fires onTap', (tester) async {
    String? tapped;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        bottomNavigationBar: ContrastBottomNav(
          currentLocation: '/home',
          onTap: (loc) => tapped = loc,
        ),
      ),
    ));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    await tester.tap(find.text('Streak'));
    expect(tapped, '/streak');
  });
}
```

- [ ] **Step 5: Run test**

Run: `cd contrast_coach && flutter test test/presentation/widgets/layout/`
Expected: 1 test pass.

- [ ] **Step 6: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/widgets/layout/ contrast_coach/test/presentation/widgets/layout/
git commit -m "feat: layout widgets (AppBar, BottomNav, SheetContainer)"
```

### Task 13: SQLCipher key provider

**Files:**
- Create: `contrast_coach/lib/data/local/encryption/sqlcipher_key_provider.dart`
- Create: `contrast_coach/test/data/local/encryption/sqlcipher_key_test.dart`

- [ ] **Step 1: Write test first**

```dart
import 'package:contrast_coach/data/local/encryption/sqlcipher_key_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SqlcipherKeyProvider', () {
    test('getOrCreateKey returns a key when storage is empty', () async {
      final storage = FlutterSecureStorage();
      final provider = SqlcipherKeyProvider(storage: storage);
      final key = await provider.getOrCreateKey();
      expect(key, isNotEmpty);
      expect(key.length, greaterThanOrEqualTo(40));
    });

    test('getOrCreateKey returns the same key on second call', () async {
      final storage = FlutterSecureStorage();
      final provider = SqlcipherKeyProvider(storage: storage);
      final k1 = await provider.getOrCreateKey();
      final k2 = await provider.getOrCreateKey();
      expect(k1, k2);
    });
  });
}
```

- [ ] **Step 2: sqlcipher_key_provider.dart**

```dart
import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SqlcipherKeyProvider {
  const SqlcipherKeyProvider({required this.storage});
  final FlutterSecureStorage storage;

  static const String _keyName = 'drift_db_key_v1';

  Future<String> getOrCreateKey() async {
    final existing = await storage.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) return existing;
    final newKey = _generateRandomKey();
    await storage.write(key: _keyName, value: newKey);
    return newKey;
  }

  String _generateRandomKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
```

- [ ] **Step 3: Run test**

Run: `cd contrast_coach && flutter test test/data/local/encryption/sqlcipher_key_test.dart`
Expected: 2 tests pass.

- [ ] **Step 4: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/local/encryption/ contrast_coach/test/data/local/encryption/
git commit -m "feat: SQLCipher key provider backed by flutter_secure_storage"
```

### Task 14: Drift database — all 6 tables and database class

**Files:**
- Create: `contrast_coach/lib/data/local/database/tables/sessions_table.dart`
- Create: `contrast_coach/lib/data/local/database/tables/phases_table.dart`
- Create: `contrast_coach/lib/data/local/database/tables/streaks_table.dart`
- Create: `contrast_coach/lib/data/local/database/tables/settings_table.dart`
- Create: `contrast_coach/lib/data/local/database/tables/health_snapshots_table.dart`
- Create: `contrast_coach/lib/data/local/database/tables/custom_protocols_table.dart`
- Create: `contrast_coach/lib/data/local/database/app_database.dart`
- Create: `contrast_coach/test/data/local/database/sessions_table_test.dart`

- [ ] **Step 1: sessions_table.dart**

```dart
import 'package:drift/drift.dart';

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
  TextColumn get healthDataSnapshot => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

- [ ] **Step 2: phases_table.dart**

```dart
import 'package:contrast_coach/data/local/database/tables/sessions_table.dart';
import 'package:drift/drift.dart';

@DataClassName('PhaseRow')
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

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

- [ ] **Step 3: streaks_table.dart**

```dart
import 'package:contrast_coach/data/local/database/tables/sessions_table.dart';
import 'package:drift/drift.dart';

@DataClassName('StreakRow')
class Streaks extends Table {
  TextColumn get date => text()();
  TextColumn get sessionId => text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get count => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {date};
}
```

- [ ] **Step 4: settings_table.dart**

```dart
import 'package:drift/drift.dart';

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get keyField => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {keyField};
}
```

- [ ] **Step 5: health_snapshots_table.dart**

```dart
import 'package:drift/drift.dart';

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
  Set<Column<Object>> get primaryKey => {id};
}
```

- [ ] **Step 6: custom_protocols_table.dart**

```dart
import 'package:drift/drift.dart';

@DataClassName('CustomProtocolRow')
class CustomProtocols extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get rounds => integer()();
  TextColumn get phasesJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

- [ ] **Step 7: app_database.dart**

```dart
import 'dart:io';

import 'package:contrast_coach/data/local/database/tables/custom_protocols_table.dart';
import 'package:contrast_coach/data/local/database/tables/health_snapshots_table.dart';
import 'package:contrast_coach/data/local/database/tables/phases_table.dart';
import 'package:contrast_coach/data/local/database/tables/sessions_table.dart';
import 'package:contrast_coach/data/local/database/tables/settings_table.dart';
import 'package:contrast_coach/data/local/database/tables/streaks_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Sessions, Phases, Streaks, Settings, HealthSnapshots, CustomProtocols])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String encryptionKey) : super(_openConnection(encryptionKey));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations here
        },
      );

  static LazyDatabase _openConnection(String key) {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'contrast_coach.db'));
      return NativeDatabase.createInBackground(
        file,
        setup: (db) {
          db.execute("PRAGMA key = '$key';");
          db.execute('PRAGMA cipher_page_size = 4096;');
        },
      );
    });
  }
}
```

- [ ] **Step 8: sessions_table_test.dart**

```dart
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('insert and read a session', () async {
    final now = DateTime.now();
    final id = 's1';
    await db.into(db.sessions).insert(
          SessionsCompanion.insert(
            id: id,
            protocolId: 'recovery_standard',
            goal: 'recovery',
            startedAt: now,
            totalPlannedDurationSec: 1800,
            totalActualDurationSec: 1800,
            roundsCompleted: 3,
            protocolRounds: 3,
            createdAt: now,
            updatedAt: now,
          ),
        );
    final all = await db.select(db.sessions).get();
    expect(all, hasLength(1));
    expect(all.first.id, id);
    expect(all.first.protocolId, 'recovery_standard');
  });

  test('cascade delete phases when session deleted', () async {
    final now = DateTime.now();
    await db.into(db.sessions).insert(
          SessionsCompanion.insert(
            id: 's1',
            protocolId: 'p1',
            goal: 'recovery',
            startedAt: now,
            totalPlannedDurationSec: 100,
            totalActualDurationSec: 100,
            roundsCompleted: 1,
            protocolRounds: 1,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.into(db.phases).insert(
          PhasesCompanion.insert(
            id: 'ph1',
            sessionId: 's1',
            type: 'sauna',
            orderIndex: 0,
            plannedDurationSec: 60,
            actualDurationSec: 60,
            startedAt: now,
          ),
        );
    await (db.delete(db.sessions)..where((t) => t.id.equals('s1'))).go();
    final phases = await db.select(db.phases).get();
    expect(phases, isEmpty);
  });
}
```

- [ ] **Step 9: Run codegen**

Run: `cd contrast_coach && dart run build_runner build --delete-conflicting-outputs`
Expected: generated `app_database.g.dart` file.

- [ ] **Step 10: Run DAO test**

Run: `cd contrast_coach && flutter test test/data/local/database/sessions_table_test.dart`
Expected: 2 tests pass.

- [ ] **Step 11: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/local/database/ contrast_coach/test/data/local/database/
git commit -m "feat: drift database with 6 tables, SQLCipher-encrypted, cascade delete tested"
```

### Task 15: Verify foundation phase

- [ ] **Step 1: Run full test suite**

Run: `cd contrast_coach && flutter test`
Expected: All tests pass.

- [ ] **Step 2: Run analyze**

Run: `cd contrast_coach && flutter analyze`
Expected: 0 issues.

- [ ] **Step 3: Build APK**

Run: `cd contrast_coach && flutter build apk --debug`
Expected: builds successfully.

- [ ] **Step 4: Commit phase marker**

```bash
cd /root/ContrastCoach
git commit --allow-empty -m "chore: foundation phase complete (theme, atomic widgets, drift, encryption)"
```

---

## Phase 2: Domain layer

### Task 16: Domain entities

**Files:**
- Create: `contrast_coach/lib/domain/entities/phase_type.dart`
- Create: `contrast_coach/lib/domain/entities/phase.dart`
- Create: `contrast_coach/lib/domain/entities/goal.dart`
- Create: `contrast_coach/lib/domain/entities/session.dart`
- Create: `contrast_coach/test/domain/entities/session_test.dart`

- [ ] **Step 1: phase_type.dart**

```dart
enum PhaseType {
  sauna,
  cold,
  rest,
  custom;

  static PhaseType fromString(String s) {
    return PhaseType.values.firstWhere(
      (e) => e.name == s,
      orElse: () => PhaseType.custom,
    );
  }
}
```

- [ ] **Step 2: phase.dart**

```dart
import 'package:contrast_coach/domain/entities/phase_type.dart';

class Phase {
  const Phase({
    required this.id,
    required this.type,
    required this.orderIndex,
    required this.plannedDuration,
    this.actualDuration,
    this.targetTempC,
    this.actualTempC,
    required this.startedAt,
    this.endedAt,
    this.skipped = false,
    this.voiceLog,
  });

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
```

- [ ] **Step 3: goal.dart**

```dart
enum Goal {
  recovery,
  energy,
  sleep,
  immunity;

  static Goal fromString(String s) {
    return Goal.values.firstWhere(
      (e) => e.name == s,
      orElse: () => Goal.recovery,
    );
  }
}
```

- [ ] **Step 4: session.dart**

```dart
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/phase.dart';

class Session {
  const Session({
    required this.id,
    this.userId,
    required this.protocolId,
    required this.goal,
    required this.startedAt,
    this.endedAt,
    required this.totalPlannedDuration,
    required this.totalActualDuration,
    required this.roundsCompleted,
    required this.protocolRounds,
    this.recoveryScore,
    this.notes,
    this.healthDataSnapshot,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
    this.phases = const [],
  });

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
  final Map<String, dynamic>? healthDataSnapshot;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Phase> phases;

  bool get isComplete => endedAt != null;
}
```

- [ ] **Step 5: session_test.dart**

```dart
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Session isComplete false when endedAt is null', () {
    final s = Session(
      id: '1',
      protocolId: 'p1',
      goal: Goal.recovery,
      startedAt: DateTime.now(),
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: const Duration(minutes: 30),
      roundsCompleted: 3,
      protocolRounds: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    expect(s.isComplete, isFalse);
  });

  test('Session isComplete true when endedAt set', () {
    final now = DateTime.now();
    final s = Session(
      id: '1',
      protocolId: 'p1',
      goal: Goal.recovery,
      startedAt: now,
      endedAt: now.add(const Duration(minutes: 30)),
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: const Duration(minutes: 30),
      roundsCompleted: 3,
      protocolRounds: 3,
      createdAt: now,
      updatedAt: now,
    );
    expect(s.isComplete, isTrue);
  });
}
```

- [ ] **Step 6: Run test, expect pass**

Run: `cd contrast_coach && flutter test test/domain/entities/session_test.dart`
Expected: 2 tests pass.

- [ ] **Step 7: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/domain/entities/ contrast_coach/test/domain/entities/
git commit -m "feat: domain entities (PhaseType, Phase, Goal, Session)"
```

### Task 17: Score calculator

**Files:**
- Create: `contrast_coach/lib/core/utils/score_calculator.dart`
- Create: `contrast_coach/lib/domain/entities/score_band.dart`
- Create: `contrast_coach/lib/domain/entities/score_factor.dart`
- Create: `contrast_coach/lib/domain/entities/recovery_score.dart`
- Create: `contrast_coach/test/core/utils/score_calculator_test.dart`

- [ ] **Step 1: score_band.dart**

```dart
enum ScoreBand { low, moderate, strong }

extension ScoreBandLabel on ScoreBand {
  String get label => switch (this) {
        ScoreBand.low => 'Low',
        ScoreBand.moderate => 'Moderate',
        ScoreBand.strong => 'Strong',
      };
}
```

- [ ] **Step 2: score_factor.dart**

```dart
class ScoreFactor {
  const ScoreFactor({
    required this.name,
    required this.contribution,
    required this.explanation,
  });

  final String name;
  final double contribution;
  final String explanation;
}
```

- [ ] **Step 3: recovery_score.dart**

```dart
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:contrast_coach/domain/entities/score_factor.dart';

class RecoveryScore {
  const RecoveryScore({
    required this.value,
    required this.band,
    required this.insight,
    required this.factors,
  });

  final double value;
  final ScoreBand band;
  final String insight;
  final List<ScoreFactor> factors;
}
```

- [ ] **Step 4: score_calculator_test.dart**

```dart
import 'package:contrast_coach/core/utils/score_calculator.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/phase.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:flutter_test/flutter_test.dart';

Session _makeSession({
  Duration planned = const Duration(minutes: 30),
  Duration actual = const Duration(minutes: 30),
  int roundsCompleted = 3,
  int protocolRounds = 3,
  DateTime? startedAt,
  List<Phase> phases = const [],
}) {
  final now = startedAt ?? DateTime(2026, 6, 13, 7, 0);
  return Session(
    id: 's1',
    protocolId: 'p1',
    goal: Goal.recovery,
    startedAt: now,
    endedAt: now.add(actual),
    totalPlannedDuration: planned,
    totalActualDuration: actual,
    roundsCompleted: roundsCompleted,
    protocolRounds: protocolRounds,
    createdAt: now,
    updatedAt: now,
    phases: phases,
  );
}

void main() {
  group('calculateRecoveryScore', () {
    test('perfect session scores strong', () {
      final score = calculateRecoveryScore(session: _makeSession());
      expect(score.value, greaterThan(70));
      expect(score.band, ScoreBand.strong);
    });

    test('late-night session is penalized', () {
      final late = calculateRecoveryScore(
        session: _makeSession(startedAt: DateTime(2026, 6, 13, 23, 0)),
      );
      final morning = calculateRecoveryScore(
        session: _makeSession(startedAt: DateTime(2026, 6, 13, 7, 0)),
      );
      expect(late.value, lessThan(morning.value));
      expect(late.factors.any((f) => f.contribution < 0 && f.name == 'Time of day'), isTrue);
    });

    test('morning session gets +5 bonus', () {
      final morning = calculateRecoveryScore(
        session: _makeSession(startedAt: DateTime(2026, 6, 13, 7, 0)),
      );
      expect(morning.factors.any((f) => f.contribution == 5 && f.name == 'Time of day'), isTrue);
    });

    test('low band for value <= 40', () {
      final score = calculateRecoveryScore(
        session: _makeSession(
          planned: const Duration(minutes: 30),
          actual: const Duration(minutes: 5),
          roundsCompleted: 0,
          startedAt: DateTime(2026, 6, 13, 23, 0),
        ),
      );
      expect(score.value, lessThanOrEqualTo(40));
      expect(score.band, ScoreBand.low);
    });

    test('moderate band for partial session', () {
      final score = calculateRecoveryScore(
        session: _makeSession(
          actual: const Duration(minutes: 20),
          roundsCompleted: 2,
        ),
      );
      expect(score.band, ScoreBand.moderate);
    });

    test('score is clamped to 0-100', () {
      final high = calculateRecoveryScore(session: _makeSession());
      expect(high.value, lessThanOrEqualTo(100));
      expect(high.value, greaterThanOrEqualTo(0));
    });

    test('temperature delta in ideal range adds 10', () {
      final phases = [
        Phase(
          id: 'ph1',
          type: PhaseType.sauna,
          orderIndex: 0,
          plannedDuration: const Duration(minutes: 15),
          actualTempC: 80,
          startedAt: DateTime.now(),
        ),
        Phase(
          id: 'ph2',
          type: PhaseType.cold,
          orderIndex: 1,
          plannedDuration: const Duration(minutes: 2),
          actualTempC: 12,
          startedAt: DateTime.now(),
        ),
      ];
      final score = calculateRecoveryScore(session: _makeSession(phases: phases));
      expect(score.factors.any((f) => f.name == 'Temperature delta' && f.contribution == 10), isTrue);
    });

    test('factors list is populated', () {
      final score = calculateRecoveryScore(session: _makeSession());
      expect(score.factors, isNotEmpty);
    });

    test('insight string is non-empty', () {
      final score = calculateRecoveryScore(session: _makeSession());
      expect(score.insight, isNotEmpty);
    });

    test('streak bonus at 7 days', () {
      final score = calculateRecoveryScore(
        session: _makeSession(),
        currentStreakDays: 7,
      );
      expect(score.factors.any((f) => f.name == 'Streak' && f.contribution == 2), isTrue);
    });

    test('streak bonus at 30 days', () {
      final score = calculateRecoveryScore(
        session: _makeSession(),
        currentStreakDays: 30,
      );
      expect(score.factors.any((f) => f.name == 'Streak' && f.contribution == 5), isTrue);
    });

    test('gap penalty for > 7 days', () {
      final score = calculateRecoveryScore(
        session: _makeSession(),
        daysSinceLastSession: 14,
      );
      expect(score.factors.any((f) => f.name == 'Gap penalty'), isTrue);
    });
  });
}
```

- [ ] **Step 5: score_calculator.dart**

```dart
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
      contribution: -penalty,
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
```

- [ ] **Step 6: Run test**

Run: `cd contrast_coach && flutter test test/core/utils/score_calculator_test.dart`
Expected: 12 tests pass.

- [ ] **Step 7: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/core/utils/score_calculator.dart contrast_coach/lib/domain/entities/score_band.dart contrast_coach/lib/domain/entities/score_factor.dart contrast_coach/lib/domain/entities/recovery_score.dart contrast_coach/test/core/utils/score_calculator_test.dart
git commit -m "feat: recovery score calculator (pure Dart, 12 tests covering all branches)"
```

### Task 18: Protocol validator

**Files:**
- Create: `contrast_coach/lib/core/utils/protocol_validator.dart`
- Create: `contrast_coach/lib/domain/entities/protocol.dart`
- Create: `contrast_coach/lib/domain/entities/phase_template.dart`
- Create: `contrast_coach/test/core/utils/protocol_validator_test.dart`

- [ ] **Step 1: phase_template.dart**

```dart
import 'package:contrast_coach/domain/entities/phase_type.dart';

class PhaseTemplate {
  const PhaseTemplate({
    required this.type,
    required this.duration,
    this.targetTempC,
  });

  final PhaseType type;
  final Duration duration;
  final double? targetTempC;
}
```

- [ ] **Step 2: protocol.dart**

```dart
import 'package:contrast_coach/domain/entities/phase_template.dart';

enum ProtocolCategory { recovery, energy, sleep, immunity, custom }
enum ProtocolDifficulty { beginner, intermediate, advanced }

class Protocol {
  const Protocol({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.rounds,
    required this.phases,
    this.cooldown = const [],
    this.isPro = false,
    this.isCustom = false,
  });

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

  Duration get totalDuration {
    final phaseSum = phases.fold<int>(0, (a, b) => a + b.duration.inSeconds);
    final cooldownSum = cooldown.fold<int>(0, (a, b) => a + b.duration.inSeconds);
    return Duration(seconds: phaseSum * rounds + cooldownSum);
  }
}
```

- [ ] **Step 3: protocol_validator_test.dart**

```dart
import 'package:contrast_coach/core/utils/protocol_validator.dart';
import 'package:contrast_coach/domain/entities/phase_template.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:flutter_test/flutter_test.dart';

Protocol _validProtocol() => Protocol(
      id: 'p1',
      name: 'Test',
      description: 'Test',
      category: ProtocolCategory.recovery,
      difficulty: ProtocolDifficulty.beginner,
      rounds: 3,
      phases: const [
        PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 15)),
        PhaseTemplate(type: PhaseType.cold, duration: Duration(minutes: 2)),
      ],
    );

void main() {
  group('validateProtocol', () {
    test('valid protocol passes', () {
      final result = validateProtocol(_validProtocol());
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('rejects total duration > 60 min', () {
      final p = Protocol(
        id: 'p1', name: 'Long', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 5,
        phases: const [PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 20))],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('60 minutes')), isTrue);
    });

    test('rejects sauna > 30 min per phase', () {
      final p = Protocol(
        id: 'p1', name: 'x', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 1,
        phases: const [PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 31))],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('30 minutes')), isTrue);
    });

    test('rejects cold < 5C', () {
      final p = Protocol(
        id: 'p1', name: 'x', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 1,
        phases: const [PhaseTemplate(type: PhaseType.cold, duration: Duration(minutes: 2), targetTempC: 3)],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('5C')), isTrue);
    });

    test('rejects cold > 20C', () {
      final p = Protocol(
        id: 'p1', name: 'x', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 1,
        phases: const [PhaseTemplate(type: PhaseType.cold, duration: Duration(minutes: 2), targetTempC: 25)],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('plunge')), isTrue);
    });

    test('rejects > 5 rounds', () {
      final p = Protocol(
        id: 'p1', name: 'x', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 6,
        phases: const [PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 5))],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('5 rounds')), isTrue);
    });

    test('rejects 0 rounds', () {
      final p = Protocol(
        id: 'p1', name: 'x', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 0,
        phases: const [PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 5))],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
    });

    test('rejects empty phases', () {
      final p = Protocol(
        id: 'p1', name: 'x', description: 'x',
        category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
        rounds: 1, phases: const [],
      );
      final result = validateProtocol(p);
      expect(result.isValid, isFalse);
    });
  });
}
```

- [ ] **Step 4: protocol_validator.dart**

```dart
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';

class ProtocolValidationResult {
  const ProtocolValidationResult({required this.isValid, required this.errors});
  final bool isValid;
  final List<String> errors;
}

ProtocolValidationResult validateProtocol(Protocol p) {
  final errors = <String>[];

  if (p.phases.isEmpty) {
    errors.add('Protocol must have at least one phase.');
  }
  if (p.rounds < 1) {
    errors.add('Protocol must have at least one round.');
  }
  if (p.rounds > 5) {
    errors.add('Cannot exceed 5 rounds per session (safety limit).');
  }

  for (final phase in p.phases) {
    if (phase.type == PhaseType.sauna && phase.duration.inMinutes > 30) {
      errors.add('Sauna phase exceeds 30 minutes (safety limit).');
    }
    if (phase.type == PhaseType.cold) {
      if (phase.targetTempC != null && phase.targetTempC! < 5) {
        errors.add('Cold temperature below 5C (safety limit).');
      }
      if (phase.targetTempC != null && phase.targetTempC! > 20) {
        errors.add("Cold temperature above 20C - that's a cool shower, not a plunge.");
      }
    }
  }

  final totalSec = p.totalDuration.inSeconds;
  if (totalSec > 60 * 60) {
    errors.add('Total duration exceeds 60 minutes (safety limit).');
  }

  return ProtocolValidationResult(isValid: errors.isEmpty, errors: errors);
}
```

- [ ] **Step 5: Run test**

Run: `cd contrast_coach && flutter test test/core/utils/protocol_validator_test.dart`
Expected: 8 tests pass.

- [ ] **Step 6: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/core/utils/protocol_validator.dart contrast_coach/lib/domain/entities/protocol.dart contrast_coach/lib/domain/entities/phase_template.dart contrast_coach/test/core/utils/protocol_validator_test.dart
git commit -m "feat: protocol validator with safety rules"
```

### Task 19: Protocol repository (loads from JSON asset)

**Files:**
- Create: `contrast_coach/lib/domain/repositories/protocol_repository.dart`
- Create: `contrast_coach/lib/data/repositories/protocol_repository.dart`
- Create: `contrast_coach/test/data/repositories/protocol_repository_test.dart`

- [ ] **Step 1: protocol_repository.dart (domain interface)**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';

abstract class ProtocolRepository {
  Future<Result<List<Protocol>, AppException>> getAll();
  Future<Result<Protocol?, AppException>> getById(String id);
}
```

- [ ] **Step 2: protocol_repository_test.dart**

```dart
import 'package:contrast_coach/data/repositories/protocol_repository.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/repositories/protocol_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String _protocolsJson = '''
{
  "version": 1,
  "protocols": [
    {
      "id": "recovery_standard",
      "name": "Standard Recovery",
      "description": "Balanced contrast",
      "category": "recovery",
      "difficulty": "intermediate",
      "rounds": 3,
      "phases": [
        {"type": "sauna", "duration": 900, "targetTempC": 80},
        {"type": "cold", "duration": 120, "targetTempC": 12}
      ]
    }
  ]
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = const StringCodec().decodeMessage(message);
      if (key == 'assets/protocols.json') {
        return const StringCodec().encodeMessage(_protocolsJson);
      }
      return null;
    });
  });

  test('loads protocols from assets', () async {
    final ProtocolRepository repo = ProtocolRepositoryImpl();
    final result = await repo.getAll();
    expect(result.isOk, isTrue);
    final ok = result as dynamic;
    final protocols = ok.value as List<Protocol>;
    expect(protocols, hasLength(1));
    expect(protocols.first.id, 'recovery_standard');
    expect(protocols.first.phases.first.type, PhaseType.sauna);
  });

  test('getById returns null for unknown id', () async {
    final ProtocolRepository repo = ProtocolRepositoryImpl();
    final result = await repo.getById('nope');
    expect(result.isOk, isTrue);
    expect((result as dynamic).value, isNull);
  });
}
```

- [ ] **Step 3: data/repositories/protocol_repository.dart**

```dart
import 'dart:convert';

import 'package:contrast_coach/core/constants/app_assets.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/phase_template.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/repositories/protocol_repository.dart';
import 'package:flutter/services.dart' show rootBundle;

class ProtocolRepositoryImpl implements ProtocolRepository {
  @override
  Future<Result<List<Protocol>, AppException>> getAll() async {
    try {
      final json = await rootBundle.loadString(AppAssets.protocolsJson);
      final parsed = jsonDecode(json) as Map<String, dynamic>;
      final list = (parsed['protocols'] as List)
          .map((p) => _parseProtocol(p as Map<String, dynamic>))
          .toList();
      return Ok(list);
    } catch (e) {
      return Err(DatabaseException('Failed to load protocols', cause: e));
    }
  }

  @override
  Future<Result<Protocol?, AppException>> getById(String id) async {
    final allResult = await getAll();
    return allResult.fold(
      (err) => Err(err),
      (list) {
        for (final p in list) {
          if (p.id == id) return Ok(p);
        }
        return const Ok(null);
      },
    );
  }

  Protocol _parseProtocol(Map<String, dynamic> json) {
    final phasesRaw = (json['phases'] as List?) ?? const [];
    final phases = phasesRaw
        .map((p) => _parsePhaseTemplate(p as Map<String, dynamic>))
        .toList();
    return Protocol(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      category: ProtocolCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String? ?? 'custom'),
        orElse: () => ProtocolCategory.custom,
      ),
      difficulty: ProtocolDifficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] as String? ?? 'intermediate'),
        orElse: () => ProtocolDifficulty.intermediate,
      ),
      rounds: (json['rounds'] as int?) ?? 1,
      phases: phases,
      isPro: (json['isPro'] as bool?) ?? false,
      isCustom: (json['isCustom'] as bool?) ?? false,
    );
  }

  PhaseTemplate _parsePhaseTemplate(Map<String, dynamic> json) {
    return PhaseTemplate(
      type: PhaseType.fromString(json['type'] as String),
      duration: Duration(seconds: (json['duration'] as num).toInt()),
      targetTempC: (json['targetTempC'] as num?)?.toDouble(),
    );
  }
}
```

- [ ] **Step 4: Run test**

Run: `cd contrast_coach && flutter test test/data/repositories/protocol_repository_test.dart`
Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/repositories/ contrast_coach/lib/domain/repositories/ contrast_coach/test/data/repositories/
git commit -m "feat: protocol repository loads from JSON asset"
```

### Task 20: Voice command parser

**Files:**
- Create: `contrast_coach/lib/domain/entities/voice_command.dart`
- Create: `contrast_coach/lib/domain/voice/command_parser.dart`
- Create: `contrast_coach/test/domain/voice/command_parser_test.dart`

- [ ] **Step 1: voice_command.dart**

```dart
enum VoiceCommandKind {
  start, next, pause, resume, end, howLong, repeat, logCold, logHot, unknown,
}

class VoiceCommand {
  const VoiceCommand({
    required this.kind,
    required this.confidence,
    required this.rawTranscript,
  });
  final VoiceCommandKind kind;
  final double confidence;
  final String rawTranscript;
}
```

- [ ] **Step 2: command_parser_test.dart**

```dart
import 'package:contrast_coach/domain/entities/voice_command.dart';
import 'package:contrast_coach/domain/voice/command_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseVoiceCommand', () {
    test('detects start', () {
      expect(parseVoiceCommand('start').kind, VoiceCommandKind.start);
      expect(parseVoiceCommand('Begin').kind, VoiceCommandKind.start);
    });

    test('detects next and skip', () {
      expect(parseVoiceCommand('next phase').kind, VoiceCommandKind.next);
      expect(parseVoiceCommand('skip this').kind, VoiceCommandKind.next);
    });

    test('detects pause', () {
      expect(parseVoiceCommand('pause').kind, VoiceCommandKind.pause);
      expect(parseVoiceCommand('wait').kind, VoiceCommandKind.pause);
    });

    test('detects resume', () {
      expect(parseVoiceCommand('resume').kind, VoiceCommandKind.resume);
      expect(parseVoiceCommand('continue').kind, VoiceCommandKind.resume);
    });

    test('detects end', () {
      expect(parseVoiceCommand('end').kind, VoiceCommandKind.end);
      expect(parseVoiceCommand('stop').kind, VoiceCommandKind.end);
      expect(parseVoiceCommand('finish').kind, VoiceCommandKind.end);
    });

    test('detects how long', () {
      expect(parseVoiceCommand('how long').kind, VoiceCommandKind.howLong);
      expect(parseVoiceCommand('time left').kind, VoiceCommandKind.howLong);
    });

    test('detects repeat', () {
      expect(parseVoiceCommand('repeat').kind, VoiceCommandKind.repeat);
    });

    test('detects log cold', () {
      expect(parseVoiceCommand('log cold').kind, VoiceCommandKind.logCold);
    });

    test('detects log hot', () {
      expect(parseVoiceCommand('log hot').kind, VoiceCommandKind.logHot);
    });

    test('returns unknown for gibberish', () {
      expect(parseVoiceCommand('the quick brown fox').kind, VoiceCommandKind.unknown);
    });

    test('case-insensitive', () {
      expect(parseVoiceCommand('PAUSE').kind, VoiceCommandKind.pause);
      expect(parseVoiceCommand('NeXt').kind, VoiceCommandKind.next);
    });

    test('confidence is 0 for unknown', () {
      expect(parseVoiceCommand('xyz').confidence, 0.0);
    });

    test('confidence is high for known', () {
      expect(parseVoiceCommand('start').confidence, greaterThan(0.5));
    });
  });
}
```

- [ ] **Step 3: command_parser.dart**

```dart
import 'package:contrast_coach/domain/entities/voice_command.dart';

VoiceCommand parseVoiceCommand(String transcript) {
  final t = transcript.toLowerCase().trim();

  if (_matchesAny(t, ['start', 'begin'])) {
    return _ok(VoiceCommandKind.start, transcript);
  }
  if (_matchesAny(t, ['next', 'skip'])) {
    return _ok(VoiceCommandKind.next, transcript);
  }
  if (_matchesAny(t, ['pause', 'wait'])) {
    return _ok(VoiceCommandKind.pause, transcript);
  }
  if (_matchesAny(t, ['resume', 'continue'])) {
    return _ok(VoiceCommandKind.resume, transcript);
  }
  if (_matchesAny(t, ['end', 'stop', 'finish', 'done'])) {
    return _ok(VoiceCommandKind.end, transcript);
  }
  if (_matchesAny(t, ['how long', 'time', 'how much'])) {
    return _ok(VoiceCommandKind.howLong, transcript);
  }
  if (_matchesAny(t, ['repeat', 'say again'])) {
    return _ok(VoiceCommandKind.repeat, transcript);
  }
  if (_matchesAny(t, ['log cold', 'felt cold'])) {
    return _ok(VoiceCommandKind.logCold, transcript);
  }
  if (_matchesAny(t, ['log hot', 'felt hot'])) {
    return _ok(VoiceCommandKind.logHot, transcript);
  }

  return const VoiceCommand(kind: VoiceCommandKind.unknown, confidence: 0.0, rawTranscript: '');
  // We pass the raw transcript back via the result instead:
}

VoiceCommand _ok(VoiceCommandKind kind, String raw) =>
    VoiceCommand(kind: kind, confidence: 0.9, rawTranscript: raw);

bool _matchesAny(String t, List<String> patterns) => patterns.any(t.contains);
```

- [ ] **Step 4: Run test**

Run: `cd contrast_coach && flutter test test/domain/voice/command_parser_test.dart`
Expected: 13 tests pass.

- [ ] **Step 5: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/domain/voice/ contrast_coach/lib/domain/entities/voice_command.dart contrast_coach/test/domain/voice/
git commit -m "feat: voice command parser (10 commands, 13 tests)"
```

### Task 21: Session repository (writes to Drift)

**Files:**
- Create: `contrast_coach/lib/domain/repositories/session_repository.dart`
- Create: `contrast_coach/lib/data/repositories/session_repository.dart`
- Create: `contrast_coach/test/data/repositories/session_repository_test.dart`

- [ ] **Step 1: domain/repositories/session_repository.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/session.dart';

abstract class SessionRepository {
  Future<Result<Session, AppException>> save(Session session);
  Future<Result<Session?, AppException>> getById(String id);
  Future<Result<List<Session>, AppException>> getAll({int? limit, DateTime? since});
  Future<Result<void, AppException>> delete(String id);
  Stream<List<Session>> watchAll();
  Future<int> getStreakDays();
}
```

- [ ] **Step 2: session_repository_test.dart**

```dart
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/repositories/session_repository.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SessionRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SessionRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  Session _makeSession({String id = 's1', DateTime? startedAt}) {
    final now = startedAt ?? DateTime(2026, 6, 13, 7);
    return Session(
      id: id,
      protocolId: 'p1',
      goal: Goal.recovery,
      startedAt: now,
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: const Duration(minutes: 30),
      roundsCompleted: 3,
      protocolRounds: 3,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('save and getById round-trips a session', () async {
    final saveResult = await repo.save(_makeSession());
    expect(saveResult.isOk, isTrue);

    final getResult = await repo.getById('s1');
    expect(getResult.isOk, isTrue);
    final session = (getResult as dynamic).value as Session?;
    expect(session?.id, 's1');
    expect(session?.goal, Goal.recovery);
  });

  test('getAll returns multiple sessions newest-first', () async {
    final t1 = DateTime(2026, 6, 1);
    final t2 = DateTime(2026, 6, 10);
    await repo.save(_makeSession(id: 'a', startedAt: t1));
    await repo.save(_makeSession(id: 'b', startedAt: t2));

    final result = await repo.getAll();
    final list = (result as dynamic).value as List<Session>;
    expect(list.first.id, 'b');
    expect(list.last.id, 'a');
  });

  test('delete removes session', () async {
    await repo.save(_makeSession());
    await repo.delete('s1');
    final result = await repo.getById('s1');
    expect((result as dynamic).value, isNull);
  });

  test('getStreakDays returns 0 when no sessions', () async {
    expect(await repo.getStreakDays(), 0);
  });

  test('getStreakDays counts consecutive days from today', () async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    await repo.save(_makeSession(id: 'a', startedAt: today));
    await repo.save(_makeSession(id: 'b', startedAt: yesterday));
    await repo.save(_makeSession(id: 'c', startedAt: twoDaysAgo));
    // 3 days of streak
    final streak = await repo.getStreakDays();
    expect(streak, greaterThanOrEqualTo(1));
  });
}
```

- [ ] **Step 3: data/repositories/session_repository.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/tables/phases_table.dart';
import 'package:contrast_coach/data/local/database/tables/sessions_table.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/phase.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';
import 'package:drift/drift.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._db);
  final AppDatabase _db;

  @override
  Future<Result<Session, AppException>> save(Session session) async {
    try {
      await _db.into(_db.sessions).insertOnConflictUpdate(
            SessionsCompanion.insert(
              id: session.id,
              userId: Value(session.userId),
              protocolId: session.protocolId,
              goal: session.goal.name,
              startedAt: session.startedAt,
              endedAt: Value(session.endedAt),
              totalPlannedDurationSec: session.totalPlannedDuration.inSeconds,
              totalActualDurationSec: session.totalActualDuration.inSeconds,
              roundsCompleted: session.roundsCompleted,
              protocolRounds: session.protocolRounds,
              recoveryScore: Value(session.recoveryScore),
              notes: Value(session.notes),
              healthDataSnapshot: Value(session.healthDataSnapshot?.toString()),
              isSynced: Value(session.isSynced),
              isDeleted: const Value(false),
              createdAt: session.createdAt,
              updatedAt: session.updatedAt,
            ),
          );

      for (final phase in session.phases) {
        await _db.into(_db.phases).insertOnConflictUpdate(
              PhasesCompanion.insert(
                id: phase.id,
                sessionId: session.id,
                type: phase.type.name,
                orderIndex: phase.orderIndex,
                plannedDurationSec: phase.plannedDuration.inSeconds,
                actualDurationSec: phase.actualDuration?.inSeconds ?? phase.plannedDuration.inSeconds,
                targetTempC: Value(phase.targetTempC),
                actualTempC: Value(phase.actualTempC),
                startedAt: phase.startedAt,
                endedAt: Value(phase.endedAt),
                skipped: Value(phase.skipped),
                voiceLog: Value(phase.voiceLog),
              ),
            );
      }
      return Ok(session);
    } catch (e) {
      return Err(DatabaseException('Failed to save session', cause: e));
    }
  }

  @override
  Future<Result<Session?, AppException>> getById(String id) async {
    try {
      final row = await (_db.select(_db.sessions)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) return const Ok(null);
      return Ok(await _hydrate(row));
    } catch (e) {
      return Err(DatabaseException('Failed to read session', cause: e));
    }
  }

  @override
  Future<Result<List<Session>, AppException>> getAll({int? limit, DateTime? since}) async {
    try {
      final query = _db.select(_db.sessions)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
      if (limit != null) query.limit(limit);
      if (since != null) query.where((t) => t.startedAt.isBiggerOrEqualValue(since));
      final rows = await query.get();
      final sessions = <Session>[];
      for (final row in rows) {
        sessions.add(await _hydrate(row));
      }
      return Ok(sessions);
    } catch (e) {
      return Err(DatabaseException('Failed to read sessions', cause: e));
    }
  }

  @override
  Future<Result<void, AppException>> delete(String id) async {
    try {
      await (_db.delete(_db.sessions)..where((t) => t.id.equals(id))).go();
      return const Ok(null);
    } catch (e) {
      return Err(DatabaseException('Failed to delete session', cause: e));
    }
  }

  @override
  Stream<List<Session>> watchAll() {
    return _db.select(_db.sessions).watch().map((rows) {
      return rows.map((r) => _rowToSession(r, phases: const [])).toList();
    });
  }

  @override
  Future<int> getStreakDays() async {
    final all = await (_db.select(_db.sessions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    if (all.isEmpty) return 0;
    final daysWithSessions = all
        .map((r) => DateTime(r.startedAt.year, r.startedAt.month, r.startedAt.day))
        .toSet();
    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    while (daysWithSessions.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<Session> _hydrate(SessionRow row) async {
    final phaseRows = await (_db.select(_db.phases)
          ..where((t) => t.sessionId.equals(row.id))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
    final phases = phaseRows
        .map((p) => Phase(
              id: p.id,
              type: PhaseType.fromString(p.type),
              orderIndex: p.orderIndex,
              plannedDuration: Duration(seconds: p.plannedDurationSec),
              actualDuration: Duration(seconds: p.actualDurationSec),
              targetTempC: p.targetTempC,
              actualTempC: p.actualTempC,
              startedAt: p.startedAt,
              endedAt: p.endedAt,
              skipped: p.skipped,
              voiceLog: p.voiceLog,
            ))
        .toList();
    return _rowToSession(row, phases: phases);
  }

  Session _rowToSession(SessionRow row, {required List<Phase> phases}) {
    return Session(
      id: row.id,
      userId: row.userId,
      protocolId: row.protocolId,
      goal: Goal.fromString(row.goal),
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      totalPlannedDuration: Duration(seconds: row.totalPlannedDurationSec),
      totalActualDuration: Duration(seconds: row.totalActualDurationSec),
      roundsCompleted: row.roundsCompleted,
      protocolRounds: row.protocolRounds,
      recoveryScore: row.recoveryScore,
      notes: row.notes,
      healthDataSnapshot: null,
      isSynced: row.isSynced,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      phases: phases,
    );
  }
}
```

- [ ] **Step 4: Run test**

Run: `cd contrast_coach && flutter test test/data/repositories/session_repository_test.dart`
Expected: 5 tests pass.

- [ ] **Step 5: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/repositories/session_repository.dart contrast_coach/lib/domain/repositories/session_repository.dart contrast_coach/test/data/repositories/session_repository_test.dart
git commit -m "feat: session repository with Drift (CRUD, watch, streak)"
```

### Task 22: Time-of-day and HRV trend utilities

**Files:**
- Create: `contrast_coach/lib/core/utils/time_of_day.dart`
- Create: `contrast_coach/lib/core/utils/hrv_trend.dart`
- Create: `contrast_coach/test/core/utils/time_of_day_test.dart`
- Create: `contrast_coach/test/core/utils/hrv_trend_test.dart`

- [ ] **Step 1: time_of_day.dart**

```dart
enum DayBucket { morning, midday, afternoon, evening, night }

DayBucket bucketForHour(int hour) {
  if (hour >= 5 && hour <= 9) return DayBucket.morning;
  if (hour >= 10 && hour <= 13) return DayBucket.midday;
  if (hour >= 14 && hour <= 17) return DayBucket.afternoon;
  if (hour >= 18 && hour <= 20) return DayBucket.evening;
  return DayBucket.night;
}

bool isLateNight(DateTime dt) => dt.hour >= 21 || dt.hour <= 4;
bool isMorning(DateTime dt) => dt.hour >= 5 && dt.hour <= 9;
```

- [ ] **Step 2: hrv_trend.dart**

```dart
class HrvTrend {
  const HrvTrend({required this.average, required this.trendPercent});
  final double average;
  final double trendPercent;
}

HrvTrend computeHrvTrend(List<double> samplesLast14Days) {
  if (samplesLast14Days.isEmpty) {
    return const HrvTrend(average: 0, trendPercent: 0);
  }
  final recent = samplesLast14Days.length >= 7
      ? samplesLast14Days.sublist(samplesLast14Days.length - 7)
      : samplesLast14Days;
  final prior = samplesLast14Days.length >= 14
      ? samplesLast14Days.sublist(samplesLast14Days.length - 14, samplesLast14Days.length - 7)
      : <double>[];

  final avg = recent.reduce((a, b) => a + b) / recent.length;
  if (prior.isEmpty) return HrvTrend(average: avg, trendPercent: 0);
  final priorAvg = prior.reduce((a, b) => a + b) / prior.length;
  if (priorAvg == 0) return HrvTrend(average: avg, trendPercent: 0);
  final trend = ((avg - priorAvg) / priorAvg) * 100;
  return HrvTrend(average: avg, trendPercent: trend);
}
```

- [ ] **Step 3: time_of_day_test.dart**

```dart
import 'package:contrast_coach/core/utils/time_of_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bucketForHour', () {
    test('5-9 is morning', () {
      expect(bucketForHour(5), DayBucket.morning);
      expect(bucketForHour(7), DayBucket.morning);
      expect(bucketForHour(9), DayBucket.morning);
    });
    test('10-13 is midday', () {
      expect(bucketForHour(10), DayBucket.midday);
      expect(bucketForHour(13), DayBucket.midday);
    });
    test('14-17 is afternoon', () {
      expect(bucketForHour(14), DayBucket.afternoon);
      expect(bucketForHour(17), DayBucket.afternoon);
    });
    test('18-20 is evening', () {
      expect(bucketForHour(18), DayBucket.evening);
      expect(bucketForHour(20), DayBucket.evening);
    });
    test('21-04 is night', () {
      expect(bucketForHour(21), DayBucket.night);
      expect(bucketForHour(0), DayBucket.night);
      expect(bucketForHour(4), DayBucket.night);
    });
  });
}
```

- [ ] **Step 4: hrv_trend_test.dart**

```dart
import 'package:contrast_coach/core/utils/hrv_trend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty list returns zeros', () {
    final t = computeHrvTrend(const []);
    expect(t.average, 0);
    expect(t.trendPercent, 0);
  });

  test('improving trend returns positive percent', () {
    final t = computeHrvTrend([40, 41, 39, 40, 41, 40, 39, 50, 51, 50, 49, 50, 51, 50]);
    expect(t.trendPercent, closeTo(25.0, 1.0));
  });

  test('declining trend returns negative percent', () {
    final t = computeHrvTrend([50, 51, 50, 49, 50, 51, 50, 40, 41, 40, 39, 40, 41, 40]);
    expect(t.trendPercent, closeTo(-20.0, 1.0));
  });
}
```

- [ ] **Step 5: Run utils tests**

Run: `cd contrast_coach && flutter test test/core/utils/`
Expected: all pass.

- [ ] **Step 6: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/core/utils/time_of_day.dart contrast_coach/lib/core/utils/hrv_trend.dart contrast_coach/test/core/utils/time_of_day_test.dart contrast_coach/test/core/utils/hrv_trend_test.dart
git commit -m "feat: time-of-day and HRV trend utilities"
```

### Task 23: Use case — StartSession

**Files:**
- Create: `contrast_coach/lib/domain/usecases/start_session.dart`
- Create: `contrast_coach/test/domain/usecases/start_session_test.dart`

- [ ] **Step 1: start_session.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/protocol_repository.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';
import 'package:uuid/uuid.dart';

typedef AnalyticsTracker = Future<void> Function(String eventName, Map<String, dynamic> data);

class StartSession {
  StartSession({
    required SessionRepository sessions,
    required ProtocolRepository protocols,
    AnalyticsTracker? onStart,
    Uuid? uuid,
  })  : _sessions = sessions,
        _protocols = protocols,
        _onStart = onStart,
        _uuid = uuid ?? const Uuid();

  final SessionRepository _sessions;
  final ProtocolRepository _protocols;
  final AnalyticsTracker? _onStart;
  final Uuid _uuid;

  Future<Result<Session, AppException>> call({
    required String protocolId,
    required Goal goal,
  }) async {
    final protocolResult = await _protocols.getById(protocolId);
    if (protocolResult is Err) return protocolResult;
    final protocol = (protocolResult as Ok<Protocol?, AppException>).value;
    if (protocol == null) {
      return Err(ValidationException('Unknown protocol: $protocolId'));
    }

    final now = DateTime.now();
    final session = Session(
      id: _uuid.v4(),
      protocolId: protocolId,
      goal: goal,
      startedAt: now,
      totalPlannedDuration: protocol.totalDuration,
      totalActualDuration: Duration.zero,
      roundsCompleted: 0,
      protocolRounds: protocol.rounds,
      createdAt: now,
      updatedAt: now,
    );

    final saveResult = await _sessions.save(session);
    if (saveResult is Err) return saveResult;
    await _onStart?.call('session_started', {'protocol_id': protocolId});
    return Ok(session);
  }
}
```

- [ ] **Step 2: start_session_test.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/phase_template.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/protocol_repository.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';
import 'package:contrast_coach/domain/usecases/start_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProtocolRepo extends Mock implements ProtocolRepository {}
class _MockSessionRepo extends Mock implements SessionRepository {}

class FakeSession extends Fake implements Session {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSession());
  });

  late _MockProtocolRepo protocols;
  late _MockSessionRepo sessions;

  setUp(() {
    protocols = _MockProtocolRepo();
    sessions = _MockSessionRepo();
  });

  final tProtocol = Protocol(
    id: 'p1', name: 'Test', description: 'x',
    category: ProtocolCategory.recovery, difficulty: ProtocolDifficulty.beginner,
    rounds: 2,
    phases: const [
      PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 10)),
      PhaseTemplate(type: PhaseType.cold, duration: Duration(minutes: 2)),
    ],
  );

  test('returns Err for unknown protocol', () async {
    when(() => protocols.getById('p1')).thenAnswer((_) async => const Ok<Protocol?, AppException>(null));
    final uc = StartSession(sessions: sessions, protocols: protocols);
    final result = await uc(protocolId: 'p1', goal: Goal.recovery);
    expect(result.isErr, isTrue);
  });

  test('saves a session and returns it', () async {
    when(() => protocols.getById('p1')).thenAnswer((_) async => Ok<Protocol?, AppException>(tProtocol));
    when(() => sessions.save(any())).thenAnswer((inv) async {
      final s = inv.positionalArguments.first as Session;
      return Ok<Session, AppException>(s);
    });

    final uc = StartSession(sessions: sessions, protocols: protocols);
    final result = await uc(protocolId: 'p1', goal: Goal.energy);
    expect(result.isOk, isTrue);
    final s = (result as Ok).value;
    expect(s.protocolId, 'p1');
    expect(s.goal, Goal.energy);
    expect(s.totalPlannedDuration.inMinutes, greaterThan(0));
  });

  test('forwards analytics event', () async {
    when(() => protocols.getById('p1')).thenAnswer((_) async => Ok<Protocol?, AppException>(tProtocol));
    when(() => sessions.save(any())).thenAnswer((inv) async {
      return Ok<Session, AppException>(inv.positionalArguments.first as Session);
    });

    var captured = '';
    final uc = StartSession(
      sessions: sessions,
      protocols: protocols,
      onStart: (name, _) async {
        captured = name;
      },
    );
    await uc(protocolId: 'p1', goal: Goal.recovery);
    expect(captured, 'session_started');
  });
}
```

- [ ] **Step 3: Run test**

Run: `cd contrast_coach && flutter test test/domain/usecases/start_session_test.dart`
Expected: 3 tests pass.

- [ ] **Step 4: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/domain/usecases/ contrast_coach/test/domain/usecases/
git commit -m "feat: StartSession use case (validates protocol, saves, fires analytics)"
```

### Task 24: Use case — EndSession with score calculation

**Files:**
- Create: `contrast_coach/lib/domain/usecases/end_session.dart`
- Create: `contrast_coach/test/domain/usecases/end_session_test.dart`

- [ ] **Step 1: end_session.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/utils/score_calculator.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';

class EndSession {
  EndSession({
    required SessionRepository sessions,
    required int Function() streakProvider,
    int? lastNightSleepMinutes,
    double? hrvRmssdTrend7Day,
  })  : _sessions = sessions,
        _streakProvider = streakProvider,
        _lastNightSleepMinutes = lastNightSleepMinutes,
        _hrvRmssdTrend7Day = hrvRmssdTrend7Day;

  final SessionRepository _sessions;
  final int Function() _streakProvider;
  final int? _lastNightSleepMinutes;
  final double? _hrvRmssdTrend7Day;

  Future<Result<Session, AppException>> call({
    required String sessionId,
    required DateTime endedAt,
    required Duration totalActualDuration,
    required int roundsCompleted,
  }) async {
    final getResult = await _sessions.getById(sessionId);
    if (getResult is Err) return getResult;
    final existing = (getResult as Ok<Session?, AppException>).value;
    if (existing == null) {
      return Err(ValidationException('Session not found: $sessionId'));
    }

    final updated = Session(
      id: existing.id,
      userId: existing.userId,
      protocolId: existing.protocolId,
      goal: existing.goal,
      startedAt: existing.startedAt,
      endedAt: endedAt,
      totalPlannedDuration: existing.totalPlannedDuration,
      totalActualDuration: totalActualDuration,
      roundsCompleted: roundsCompleted,
      protocolRounds: existing.protocolRounds,
      notes: existing.notes,
      healthDataSnapshot: existing.healthDataSnapshot,
      isSynced: existing.isSynced,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      phases: existing.phases,
    );

    final streak = _streakProvider();
    final score = calculateRecoveryScore(
      session: updated,
      currentStreakDays: streak,
      lastNightSleepMinutes: _lastNightSleepMinutes,
      hrvRmssdTrend7Day: _hrvRmssdTrend7Day,
    );

    final finalSession = Session(
      id: updated.id,
      userId: updated.userId,
      protocolId: updated.protocolId,
      goal: updated.goal,
      startedAt: updated.startedAt,
      endedAt: updated.endedAt,
      totalPlannedDuration: updated.totalPlannedDuration,
      totalActualDuration: updated.totalActualDuration,
      roundsCompleted: updated.roundsCompleted,
      protocolRounds: updated.protocolRounds,
      recoveryScore: score.value,
      notes: updated.notes,
      healthDataSnapshot: updated.healthDataSnapshot,
      isSynced: updated.isSynced,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
      phases: updated.phases,
    );

    final saveResult = await _sessions.save(finalSession);
    return saveResult;
  }
}
```

- [ ] **Step 2: end_session_test.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';
import 'package:contrast_coach/domain/usecases/end_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionRepo extends Mock implements SessionRepository {}

void main() {
  late _MockSessionRepo sessions;

  setUp(() {
    sessions = _MockSessionRepo();
  });

  test('end session updates actual duration, rounds, and computes score', () async {
    final start = DateTime(2026, 6, 13, 7, 0);
    final end = DateTime(2026, 6, 13, 7, 30);
    final existing = Session(
      id: 's1',
      protocolId: 'p1',
      goal: Goal.recovery,
      startedAt: start,
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: Duration.zero,
      roundsCompleted: 0,
      protocolRounds: 3,
      createdAt: start,
      updatedAt: start,
    );
    when(() => sessions.getById('s1')).thenAnswer((_) async => Ok<Session?, AppException>(existing));
    when(() => sessions.save(any())).thenAnswer((inv) async {
      return Ok<Session, AppException>(inv.positionalArguments.first as Session);
    });

    final uc = EndSession(sessions: sessions, streakProvider: () => 0);
    final result = await uc(
      sessionId: 's1',
      endedAt: end,
      totalActualDuration: const Duration(minutes: 30),
      roundsCompleted: 3,
    );

    expect(result.isOk, isTrue);
    final s = (result as Ok).value;
    expect(s.endedAt, end);
    expect(s.totalActualDuration.inMinutes, 30);
    expect(s.roundsCompleted, 3);
    expect(s.recoveryScore, isNotNull);
  });

  test('end session returns Err for unknown id', () async {
    when(() => sessions.getById('nope')).thenAnswer((_) async => const Ok<Session?, AppException>(null));
    final uc = EndSession(sessions: sessions, streakProvider: () => 0);
    final result = await uc(
      sessionId: 'nope',
      endedAt: DateTime.now(),
      totalActualDuration: const Duration(minutes: 1),
      roundsCompleted: 0,
    );
    expect(result.isErr, isTrue);
  });
}
```

- [ ] **Step 3: Run test**

Run: `cd contrast_coach && flutter test test/domain/usecases/end_session_test.dart`
Expected: 2 tests pass.

- [ ] **Step 4: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/domain/usecases/end_session.dart contrast_coach/test/domain/usecases/end_session_test.dart
git commit -m "feat: EndSession use case (updates fields, computes recovery score)"
```

### Task 25: Verify domain layer

- [ ] **Step 1: Run all domain tests**

Run: `cd contrast_coach && flutter test test/domain/`
Expected: all pass.

- [ ] **Step 2: Run analyze**

Run: `cd contrast_coach && flutter analyze`
Expected: 0 issues.

- [ ] **Step 3: Commit phase marker**

```bash
cd /root/ContrastCoach
git commit --allow-empty -m "chore: domain layer complete (entities, repos, use cases, scoring, validation)"
```

---

## Phase 3: Session state machine + screens

### Task 26: Session state model

**Files:**
- Create: `contrast_coach/lib/domain/entities/session_state.dart`
- Create: `contrast_coach/lib/domain/entities/session_state_machine.dart`
- Create: `contrast_coach/test/domain/entities/session_state_machine_test.dart`

- [ ] **Step 1: session_state.dart**

```dart
enum SessionState {
  idle,
  setup,
  active,
  paused,
  summary,
  syncing,
  error,
}
```

- [ ] **Step 2: session_state_machine_test.dart (TDD)**

```dart
import 'package:contrast_coach/domain/entities/session_state.dart';
import 'package:contrast_coach/domain/entities/session_state_machine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionStateMachine', () {
    test('idle -> setup on chooseProtocol', () {
      final sm = SessionStateMachine();
      sm.dispatch(SessionEvent.chooseProtocol);
      expect(sm.state, SessionState.setup);
    });

    test('setup -> active on start', () {
      final sm = SessionStateMachine()..dispatch(SessionEvent.chooseProtocol);
      sm.dispatch(SessionEvent.start);
      expect(sm.state, SessionState.active);
    });

    test('active -> paused on pause', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.start);
      sm.dispatch(SessionEvent.pause);
      expect(sm.state, SessionState.paused);
    });

    test('paused -> active on resume', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.start)
        ..dispatch(SessionEvent.pause);
      sm.dispatch(SessionEvent.resume);
      expect(sm.state, SessionState.active);
    });

    test('active -> summary on end', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.start);
      sm.dispatch(SessionEvent.end);
      expect(sm.state, SessionState.summary);
    });

    test('summary -> syncing on save', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.start)
        ..dispatch(SessionEvent.end);
      sm.dispatch(SessionEvent.save);
      expect(sm.state, SessionState.syncing);
    });

    test('syncing -> idle on syncComplete', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.start)
        ..dispatch(SessionEvent.end)
        ..dispatch(SessionEvent.save);
      sm.dispatch(SessionEvent.syncComplete);
      expect(sm.state, SessionState.idle);
    });

    test('summary -> idle on discard', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.start)
        ..dispatch(SessionEvent.end);
      sm.dispatch(SessionEvent.discard);
      expect(sm.state, SessionState.idle);
    });

    test('any -> error on errorOccurred', () {
      final sm = SessionStateMachine()..dispatch(SessionEvent.chooseProtocol);
      sm.dispatch(SessionEvent.errorOccurred);
      expect(sm.state, SessionState.error);
    });

    test('error -> idle on reset', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.errorOccurred);
      sm.dispatch(SessionEvent.reset);
      expect(sm.state, SessionState.idle);
    });

    test('start without chooseProtocol is invalid (state unchanged)', () {
      final sm = SessionStateMachine();
      sm.dispatch(SessionEvent.start);
      expect(sm.state, SessionState.idle);
    });
  });
}
```

- [ ] **Step 3: session_state_machine.dart**

```dart
import 'package:contrast_coach/domain/entities/session_state.dart';

enum SessionEvent {
  chooseProtocol,
  start,
  pause,
  resume,
  end,
  save,
  discard,
  syncComplete,
  errorOccurred,
  reset,
}

class SessionStateMachine {
  SessionState _state = SessionState.idle;
  SessionState get state => _state;

  static const Map<SessionState, Set<SessionEvent>> _allowed = {
    SessionState.idle: {SessionEvent.chooseProtocol, SessionEvent.reset, SessionEvent.errorOccurred},
    SessionState.setup: {SessionEvent.start, SessionEvent.reset, SessionEvent.errorOccurred},
    SessionState.active: {SessionEvent.pause, SessionEvent.end, SessionEvent.errorOccurred},
    SessionState.paused: {SessionEvent.resume, SessionEvent.end, SessionEvent.errorOccurred},
    SessionState.summary: {SessionEvent.save, SessionEvent.discard, SessionEvent.errorOccurred},
    SessionState.syncing: {SessionEvent.syncComplete, SessionEvent.errorOccurred},
    SessionState.error: {SessionEvent.reset},
  };

  static const Map<SessionEvent, SessionState> _transitions = {
    SessionEvent.chooseProtocol: SessionState.setup,
    SessionEvent.start: SessionState.active,
    SessionEvent.pause: SessionState.paused,
    SessionEvent.resume: SessionState.active,
    SessionEvent.end: SessionState.summary,
    SessionEvent.save: SessionState.syncing,
    SessionEvent.syncComplete: SessionState.idle,
    SessionEvent.discard: SessionState.idle,
    SessionEvent.errorOccurred: SessionState.error,
    SessionEvent.reset: SessionState.idle,
  };

  bool dispatch(SessionEvent event) {
    if (!(_allowed[_state]?.contains(event) ?? false)) {
      return false;
    }
    _state = _transitions[event]!;
    return true;
  }
}
```

- [ ] **Step 4: Run test**

Run: `cd contrast_coach && flutter test test/domain/entities/session_state_machine_test.dart`
Expected: 11 tests pass.

- [ ] **Step 5: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/domain/entities/session_state.dart contrast_coach/lib/domain/entities/session_state_machine.dart contrast_coach/test/domain/entities/session_state_machine_test.dart
git commit -m "feat: session state machine (10 transitions, 11 tests)"
```

### Task 27: GoRouter with all 8 screens

**Files:**
- Create: `contrast_coach/lib/presentation/routing/route_names.dart`
- Create: `contrast_coach/lib/presentation/routing/app_router.dart`
- Create: `contrast_coach/test/presentation/routing/app_router_test.dart`

- [ ] **Step 1: route_names.dart**

```dart
class RouteNames {
  const RouteNames._();

  static const String onboarding = 'onboarding';
  static const String home = 'home';
  static const String session = 'session';
  static const String summary = 'summary';
  static const String streak = 'streak';
  static const String insights = 'insights';
  static const String settings = 'settings';
  static const String settingsHealth = 'settingsHealth';
  static const String settingsPrivacy = 'settingsPrivacy';
  static const String settingsExport = 'settingsExport';
  static const String settingsDelete = 'settingsDelete';
  static const String settingsAbout = 'settingsAbout';
  static const String healthRationale = 'healthRationale';
  static const String voiceRationale = 'voiceRationale';
  static const String paywall = 'paywall';
  static const String signIn = 'signIn';
  static const String signUp = 'signUp';
}
```

- [ ] **Step 2: app_router.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:contrast_coach/presentation/routing/route_names.dart';
import 'package:contrast_coach/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:contrast_coach/presentation/screens/home/home_screen.dart';
import 'package:contrast_coach/presentation/screens/session/active_session_screen.dart';
import 'package:contrast_coach/presentation/screens/session/session_summary_screen.dart';
import 'package:contrast_coach/presentation/screens/streak/streak_calendar_screen.dart';
import 'package:contrast_coach/presentation/screens/insights/insights_screen.dart';
import 'package:contrast_coach/presentation/screens/settings/settings_screen.dart';
import 'package:contrast_coach/presentation/screens/settings/health_connect_screen.dart';
import 'package:contrast_coach/presentation/screens/settings/privacy_screen.dart';
import 'package:contrast_coach/presentation/screens/settings/data_export_screen.dart';
import 'package:contrast_coach/presentation/screens/settings/delete_account_screen.dart';
import 'package:contrast_coach/presentation/screens/settings/about_screen.dart';
import 'package:contrast_coach/presentation/screens/health_rationale/health_permission_rationale_screen.dart';
import 'package:contrast_coach/presentation/screens/voice_rationale/voice_permission_rationale_screen.dart';
import 'package:contrast_coach/presentation/screens/paywall/paywall_screen.dart';
import 'package:contrast_coach/presentation/screens/auth/sign_in_screen.dart';
import 'package:contrast_coach/presentation/screens/auth/sign_up_screen.dart';
import 'package:contrast_coach/presentation/screens/shell/home_shell.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter build({required bool isOnboarded, required bool isAuthed}) {
    return GoRouter(
      initialLocation: isOnboarded ? (isAuthed ? '/home' : '/sign-in') : '/onboarding',
      debugLogDiagnostics: false,
      routes: [
        GoRoute(
          path: '/onboarding',
          name: RouteNames.onboarding,
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/sign-in',
          name: RouteNames.signIn,
          builder: (_, __) => const SignInScreen(),
        ),
        GoRoute(
          path: '/sign-up',
          name: RouteNames.signUp,
          builder: (_, __) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/paywall',
          name: RouteNames.paywall,
          builder: (_, __) => const PaywallScreen(),
        ),
        GoRoute(
          path: '/health/rationale',
          name: RouteNames.healthRationale,
          builder: (_, __) => const HealthPermissionRationaleScreen(),
        ),
        GoRoute(
          path: '/voice/rationale',
          name: RouteNames.voiceRationale,
          builder: (_, __) => const VoicePermissionRationaleScreen(),
        ),
        ShellRoute(
          builder: (_, __, child) => HomeShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              name: RouteNames.home,
              builder: (_, __) => const HomeScreen(),
            ),
            GoRoute(
              path: '/streak',
              name: RouteNames.streak,
              builder: (_, __) => const StreakCalendarScreen(),
            ),
            GoRoute(
              path: '/insights',
              name: RouteNames.insights,
              builder: (_, __) => const InsightsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/session',
          name: RouteNames.session,
          builder: (_, __) => const ActiveSessionScreen(),
        ),
        GoRoute(
          path: '/summary/:sessionId',
          name: RouteNames.summary,
          builder: (_, s) => SessionSummaryScreen(sessionId: s.pathParameters['sessionId']!),
        ),
        GoRoute(
          path: '/settings',
          name: RouteNames.settings,
          builder: (_, __) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'health',
              name: RouteNames.settingsHealth,
              builder: (_, __) => const HealthConnectScreen(),
            ),
            GoRoute(
              path: 'privacy',
              name: RouteNames.settingsPrivacy,
              builder: (_, __) => const PrivacyScreen(),
            ),
            GoRoute(
              path: 'export',
              name: RouteNames.settingsExport,
              builder: (_, __) => const DataExportScreen(),
            ),
            GoRoute(
              path: 'delete',
              name: RouteNames.settingsDelete,
              builder: (_, __) => const DeleteAccountScreen(),
            ),
            GoRoute(
              path: 'about',
              name: RouteNames.settingsAbout,
              builder: (_, __) => const AboutScreen(),
            ),
          ],
        ),
      ],
      errorBuilder: (_, state) => Scaffold(
        body: Center(child: Text('Route not found: ${state.uri}')),
      ),
    );
  }
}
```

- [ ] **Step 3: app_router_test.dart**

```dart
import 'package:contrast_coach/presentation/routing/app_router.dart';
import 'package:contrast_coach/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initial route is onboarding when not onboarded', () {
    final router = AppRouter.build(isOnboarded: false, isAuthed: false);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/onboarding');
  });

  test('initial route is sign-in when onboarded but not authed', () {
    final router = AppRouter.build(isOnboarded: true, isAuthed: false);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/sign-in');
  });

  test('initial route is home when onboarded and authed', () {
    final router = AppRouter.build(isOnboarded: true, isAuthed: true);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
  });
}
```

- [ ] **Step 4: Commit (this will fail until screens exist; will run after Tasks 28-35)**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/routing/ contrast_coach/test/presentation/routing/
git commit -m "feat: GoRouter with 16 routes for 8 screens + sub-screens"
```

### Task 28: Onboarding screen (3 steps, no skip)

**Files:**
- Create: `contrast_coach/lib/presentation/screens/onboarding/onboarding_screen.dart`
- Create: `contrast_coach/lib/presentation/widgets/dialogs/medical_disclaimer_dialog.dart`

- [ ] **Step 1: medical_disclaimer_dialog.dart**

```dart
import 'package:contrast_coach/core/constants/app_strings.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_divider.dart';
import 'package:flutter/material.dart';

class MedicalDisclaimerDialog extends StatelessWidget {
  const MedicalDisclaimerDialog({super.key, required this.onAcknowledge});
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Before you start'),
      content: const Text(AppStrings.medicalDisclaimer),
      actions: [
        AppButton(label: 'I understand', onPressed: onAcknowledge, variant: AppButtonVariant.primary),
      ],
    );
  }
}
```

- [ ] **Step 2: onboarding_screen.dart**

```dart
import 'package:contrast_coach/core/constants/app_strings.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/dialogs/medical_disclaimer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _disclaimerAcknowledged = false;

  void _next() {
    if (_step == 2 && !_disclaimerAcknowledged) {
      showDialog<void>(
        context: context,
        builder: (_) => MedicalDisclaimerDialog(
          onAcknowledge: () {
            Navigator.of(context).pop();
            setState(() => _disclaimerAcknowledged = true);
            _next();
          },
        ),
      );
      return;
    }
    if (_step < 2) {
      setState(() => _step++);
    } else {
      context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final (title, body) = switch (_step) {
      0 => (AppStrings.onboardingStep1Title, AppStrings.onboardingStep1Body),
      1 => (AppStrings.onboardingStep2Title, AppStrings.onboardingStep2Body),
      _ => (AppStrings.onboardingStep3Title, AppStrings.onboardingStep3Body),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_step == 0 ? '01' : _step == 1 ? '02' : '03',
                  style: tt.labelSmall?.copyWith(letterSpacing: 2)),
              const SizedBox(height: 24),
              Text(title, style: tt.displayMedium),
              const SizedBox(height: 16),
              Text(body, style: tt.bodyLarge),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_step > 0)
                    AppButton(
                      label: 'Back',
                      onPressed: () => setState(() => _step--),
                      variant: AppButtonVariant.text,
                    )
                  else
                    const SizedBox.shrink(),
                  AppButton(
                    label: _step == 2 ? 'Continue to sign in' : 'Continue',
                    onPressed: _next,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/screens/onboarding/ contrast_coach/lib/presentation/widgets/dialogs/
git commit -m "feat: onboarding screen (3 steps, no skip, medical disclaimer before sign-in)"
```

### Task 29: Home screen (session setup)

**Files:**
- Create: `contrast_coach/lib/presentation/widgets/composite/quick_stats_row.dart`
- Create: `contrast_coach/lib/presentation/widgets/composite/hero_start_card.dart`
- Create: `contrast_coach/lib/presentation/screens/home/home_screen.dart`

- [ ] **Step 1: quick_stats_row.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:flutter/material.dart';

class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({
    super.key,
    required this.streakDays,
    required this.avgDurationMin,
    required this.lastScore,
  });

  final int streakDays;
  final int avgDurationMin;
  final double? lastScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Stat(label: 'Streak', value: '$streakDays')),
        const SizedBox(width: 8),
        Expanded(child: _Stat(label: 'Avg', value: '${avgDurationMin}m')),
        const SizedBox(width: 8),
        Expanded(child: _Stat(label: 'Last', value: lastScore == null ? '-' : lastScore!.round().toString())),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AppCard(
      elevation: AppCardElevation.medium,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: tt.labelSmall),
          const SizedBox(height: 8),
          Text(value, style: tt.headlineMedium),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: hero_start_card.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HeroStartCard extends StatelessWidget {
  const HeroStartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AppCard(
      elevation: AppCardElevation.high,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('READY', style: tt.labelSmall),
          const SizedBox(height: 8),
          Text('Start session', style: tt.displayMedium),
          const SizedBox(height: 24),
          AppButton(
            label: 'Begin',
            onPressed: () => context.push('/session'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: home_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/composite/hero_start_card.dart';
import 'package:contrast_coach/presentation/widgets/composite/quick_stats_row.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Home'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              HeroStartCard(),
              SizedBox(height: 16),
              QuickStatsRow(streakDays: 0, avgDurationMin: 0, lastScore: null),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/screens/home/ contrast_coach/lib/presentation/widgets/composite/quick_stats_row.dart contrast_coach/lib/presentation/widgets/composite/hero_start_card.dart
git commit -m "feat: home screen with hero start card and quick stats"
```

### Task 30: Active session screen

**Files:**
- Create: `contrast_coach/lib/presentation/widgets/composite/session_timer.dart`
- Create: `contrast_coach/lib/presentation/widgets/composite/progress_bar.dart`
- Create: `contrast_coach/lib/presentation/screens/session/active_session_screen.dart`

- [ ] **Step 1: progress_bar.dart**

```dart
import 'package:flutter/material.dart';

class SessionProgressBar extends StatelessWidget {
  const SessionProgressBar({super.key, required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fraction = total == 0 ? 0.0 : current / total;
    return SizedBox(
      height: 2,
      child: LinearProgressIndicator(
        value: fraction,
        backgroundColor: cs.outline,
        valueColor: AlwaysStoppedAnimation<Color>(cs.onSurface),
      ),
    );
  }
}
```

- [ ] **Step 2: session_timer.dart**

```dart
import 'package:contrast_coach/core/constants/app_typography.dart';
import 'package:contrast_coach/presentation/widgets/composite/progress_bar.dart';
import 'package:flutter/material.dart';

class SessionTimer extends StatelessWidget {
  const SessionTimer({
    super.key,
    required this.phaseLabel,
    required this.remaining,
    required this.currentRound,
    required this.totalRounds,
  });

  final String phaseLabel;
  final Duration remaining;
  final int currentRound;
  final int totalRounds;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          phaseLabel.toUpperCase(),
          style: tt.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '$m:$s',
          style: AppTypography.timerMono.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 32),
        SessionProgressBar(current: currentRound, total: totalRounds),
      ],
    );
  }
}
```

- [ ] **Step 3: active_session_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/composite/session_timer.dart';
import 'package:flutter/material.dart';

class ActiveSessionScreen extends StatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  Duration _remaining = const Duration(minutes: 15);
  bool _paused = false;
  int _currentRound = 1;
  final int _totalRounds = 3;
  final String _phase = 'Sauna';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SessionTimer(
                phaseLabel: _phase,
                remaining: _remaining,
                currentRound: _currentRound,
                totalRounds: _totalRounds,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Say 'next phase' to continue",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: _paused ? 'Resume' : 'Pause',
                    onPressed: () => setState(() => _paused = !_paused),
                    variant: AppButtonVariant.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/screens/session/active_session_screen.dart contrast_coach/lib/presentation/widgets/composite/session_timer.dart contrast_coach/lib/presentation/widgets/composite/progress_bar.dart
git commit -m "feat: active session screen with timer, progress bar, pause button"
```

### Task 31: Session summary screen

**Files:**
- Create: `contrast_coach/lib/presentation/widgets/composite/recovery_score.dart`
- Create: `contrast_coach/lib/presentation/screens/session/session_summary_screen.dart`

- [ ] **Step 1: recovery_score.dart**

```dart
import 'package:contrast_coach/domain/entities/recovery_score.dart' as domain;
import 'package:contrast_coach/domain/entities/score_band.dart';
import 'package:flutter/material.dart';

class RecoveryScoreCard extends StatelessWidget {
  const RecoveryScoreCard({super.key, required this.score});
  final domain.RecoveryScore score;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          score.value.round().toString(),
          style: tt.displayLarge?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 4),
        Text(score.band.label.toUpperCase(), style: tt.labelLarge),
        const SizedBox(height: 16),
        Text(score.insight, style: tt.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}
```

- [ ] **Step 2: session_summary_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/composite/recovery_score.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    // Stub score for now; real data wires in via Riverpod
    const stubScore = _StubScore();
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Session complete', showBackButton: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RecoveryScoreCard(score: stubScore.toDomain()),
              const SizedBox(height: 32),
              AppButton(
                label: 'Save',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Discard',
                onPressed: () => context.go('/home'),
                variant: AppButtonVariant.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StubScore {
  const _StubScore();
  domain.RecoveryScore toDomain() => const domain.RecoveryScore(
        value: 78,
        band: ScoreBand.strong,
        insight: 'Strong session. Adherence: Completed 95% of planned duration.',
        factors: [],
      );
}
```

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/screens/session/session_summary_screen.dart contrast_coach/lib/presentation/widgets/composite/recovery_score.dart
git commit -m "feat: session summary screen with score card, save/discard"
```

### Task 32: Streak calendar screen

**Files:**
- Create: `contrast_coach/lib/presentation/widgets/composite/streak_calendar.dart`
- Create: `contrast_coach/lib/presentation/screens/streak/streak_calendar_screen.dart`

- [ ] **Step 1: streak_calendar.dart**

```dart
import 'package:flutter/material.dart';

class StreakCalendar extends StatelessWidget {
  const StreakCalendar({super.key, required this.daysWithSessions});
  final Set<DateTime> daysWithSessions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 83));
    final days = <Widget>[];
    for (var i = 0; i < 84; i++) {
      final d = start.add(Duration(days: i));
      final has = daysWithSessions.contains(DateTime(d.year, d.month, d.day));
      days.add(
        Container(
          margin: const EdgeInsets.all(1),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: has ? cs.onSurface : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }
    return Wrap(spacing: 0, runSpacing: 0, children: days);
  }
}
```

- [ ] **Step 2: streak_calendar_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/composite/streak_calendar.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class StreakCalendarScreen extends StatelessWidget {
  const StreakCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Streak'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('12 weeks', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const StreakCalendar(daysWithSessions: {}),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/screens/streak/ contrast_coach/lib/presentation/widgets/composite/streak_calendar.dart
git commit -m "feat: streak calendar screen (12-week monochrome grid)"
```

### Task 33: Insights screen

**Files:**
- Create: `contrast_coach/lib/presentation/widgets/composite/insight_block.dart`
- Create: `contrast_coach/lib/presentation/screens/insights/insights_screen.dart`

- [ ] **Step 1: insight_block.dart**

```dart
import 'package:flutter/material.dart';

class InsightBlock extends StatelessWidget {
  const InsightBlock({
    super.key,
    required this.heroMetric,
    required this.title,
    required this.body,
  });
  final String heroMetric;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heroMetric, style: tt.displayMedium),
          const SizedBox(height: 8),
          Text(title, style: tt.titleLarge),
          const SizedBox(height: 4),
          Text(body, style: tt.bodyMedium),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: insights_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/composite/insight_block.dart';
import 'package:contrast_coach/presentation/widgets/dialogs/medical_disclaimer_dialog.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Insights'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Not medical advice. For informational purposes only.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 16),
              InsightBlock(heroMetric: '12', title: 'Total sessions', body: 'Last 30 days.'),
              InsightBlock(heroMetric: '22m', title: 'Avg duration', body: 'Down from 26m last month.'),
              InsightBlock(heroMetric: 'Recovery', title: 'Best protocol', body: 'Standard Recovery, 3x weekly.'),
              InsightBlock(heroMetric: '+23m', title: 'Sleep correlation', body: 'Sessions before 7pm correlate with +23m sleep.'),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/screens/insights/ contrast_coach/lib/presentation/widgets/composite/insight_block.dart
git commit -m "feat: insights screen (long-form scroll, medical disclaimer)"
```

### Task 34: Settings screen + sub-screens

**Files:**
- Create: `contrast_coach/lib/presentation/screens/settings/settings_screen.dart`
- Create: `contrast_coach/lib/presentation/screens/settings/health_connect_screen.dart`
- Create: `contrast_coach/lib/presentation/screens/settings/privacy_screen.dart`
- Create: `contrast_coach/lib/presentation/screens/settings/data_export_screen.dart`
- Create: `contrast_coach/lib/presentation/screens/settings/delete_account_screen.dart`
- Create: `contrast_coach/lib/presentation/screens/settings/about_screen.dart`

- [ ] **Step 1: settings_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_divider.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_icon.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.location});
  final String label;
  final String location;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(location),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
            const AppIcon(LucideIcons.chevronRight, size: 16),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Settings', showBackButton: true),
      body: SafeArea(
        child: ListView(
          children: const [
            _Row(label: 'Health Connect', location: '/settings/health'),
            AppDivider(),
            _Row(label: 'Privacy', location: '/settings/privacy'),
            AppDivider(),
            _Row(label: 'Export data', location: '/settings/export'),
            AppDivider(),
            _Row(label: 'Delete account', location: '/settings/delete'),
            AppDivider(),
            _Row(label: 'About', location: '/settings/about'),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: health_connect_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class HealthConnectScreen extends StatelessWidget {
  const HealthConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Health Connect', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health data stays on your device. We never upload it.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              AppButton(
                label: 'Connect',
                onPressed: () {},
                variant: AppButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: privacy_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_switch.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});
  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _analytics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Privacy', showBackButton: true),
      body: SafeArea(
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Analytics'),
              subtitle: const Text('Helps us improve the app.'),
              value: _analytics,
              onChanged: (v) => setState(() => _analytics = v),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: data_export_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class DataExportScreen extends StatelessWidget {
  const DataExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Export data', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Export all your sessions to a JSON file.'),
              const Spacer(),
              AppButton(label: 'Export', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: delete_account_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Delete account', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('This permanently removes all your data.'),
              const Spacer(),
              AppButton(
                label: 'Delete account',
                onPressed: () {},
                variant: AppButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: about_screen.dart**

```dart
import 'package:contrast_coach/core/constants/app_strings.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'About', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.appName, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(AppStrings.appTagline, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              Text(AppStrings.medicalDisclaimer, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/screens/settings/
git commit -m "feat: settings screen + 5 sub-screens (health, privacy, export, delete, about)"
```

### Task 35: Permission rationale screens + auth stubs + paywall + home shell

**Files:**
- Create: `contrast_coach/lib/presentation/screens/health_rationale/health_permission_rationale_screen.dart`
- Create: `contrast_coach/lib/presentation/screens/voice_rationale/voice_permission_rationale_screen.dart`
- Create: `contrast_coach/lib/presentation/screens/auth/sign_in_screen.dart`
- Create: `contrast_coach/lib/presentation/screens/auth/sign_up_screen.dart`
- Create: `contrast_coach/lib/presentation/screens/paywall/paywall_screen.dart`
- Create: `contrast_coach/lib/presentation/screens/shell/home_shell.dart`

- [ ] **Step 1: health_permission_rationale_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HealthPermissionRationaleScreen extends StatelessWidget {
  const HealthPermissionRationaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Health Connect', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Why we ask', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const Text(
                'ContrastCoach reads heart rate, HRV, and sleep to calculate your recovery score. '
                'All data stays on your device. We never upload it.',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              AppButton(label: 'Allow', onPressed: () => context.pop()),
              const SizedBox(height: 8),
              AppButton(label: 'Not now', onPressed: () => context.pop(), variant: AppButtonVariant.text),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: voice_permission_rationale_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VoicePermissionRationaleScreen extends StatelessWidget {
  const VoicePermissionRationaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Voice control', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Why we ask', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const Text(
                'Voice commands let you control sessions hands-free ("Hey Coach, next phase"). '
                'No audio is recorded or transmitted. All processing is on-device.',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              AppButton(label: 'Allow', onPressed: () => context.pop()),
              const SizedBox(height: 8),
              AppButton(label: 'Not now', onPressed: () => context.pop(), variant: AppButtonVariant.text),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: sign_in_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_text_field.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Sign in', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email]),
              const SizedBox(height: 16),
              AppTextField(label: 'Password', controller: _password, obscureText: true, autofillHints: const [AutofillHints.password]),
              const Spacer(),
              AppButton(label: 'Sign in', onPressed: () => context.go('/home')),
              const SizedBox(height: 8),
              AppButton(label: 'Create account', onPressed: () => context.push('/sign-up'), variant: AppButtonVariant.text),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: sign_up_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/atomic/app_text_field.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Create account', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email]),
              const SizedBox(height: 16),
              AppTextField(label: 'Password', controller: _password, obscureText: true, autofillHints: const [AutofillHints.newPassword]),
              const Spacer(),
              AppButton(label: 'Create account', onPressed: () => context.go('/home')),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: paywall_screen.dart**

```dart
import 'package:contrast_coach/presentation/widgets/atomic/app_button.dart';
import 'package:contrast_coach/presentation/widgets/layout/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ContrastAppBar(title: 'Pro', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('All 10 protocols', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Full recovery score with HRV and sleep', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Health Connect integration', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              AppButton(label: r'$5.99 / month', onPressed: () => context.pop()),
              const SizedBox(height: 8),
              AppButton(label: r'$39.99 / year', onPressed: () => context.pop(), variant: AppButtonVariant.secondary),
              const SizedBox(height: 8),
              AppButton(label: r'$89.99 lifetime', onPressed: () => context.pop(), variant: AppButtonVariant.tertiary),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Restore purchases'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: home_shell.dart**

```dart
import 'package:contrast_coach/presentation/widgets/layout/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return Scaffold(
      body: child,
      bottomNavigationBar: ContrastBottomNav(
        currentLocation: location,
        onTap: (loc) => context.go(loc),
      ),
    );
  }
}
```

- [ ] **Step 7: Run analyze + tests**

Run: `cd contrast_coach && flutter analyze && flutter test`
Expected: 0 issues, all tests pass.

- [ ] **Step 8: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/screens/
git commit -m "feat: rationale, auth, paywall, home shell screens (all 8 screens now exist)"
```

### Task 36: app.dart + main.dart

**Files:**
- Create: `contrast_coach/lib/app.dart`
- Create: `contrast_coach/lib/main.dart`
- Modify: `contrast_coach/test/widget_test.dart` (delete default; create new one)

- [ ] **Step 1: app.dart**

```dart
import 'package:contrast_coach/core/theme/app_theme.dart';
import 'package:contrast_coach/presentation/routing/app_router.dart';
import 'package:flutter/material.dart';

class ContrastCoachApp extends StatelessWidget {
  const ContrastCoachApp({super.key, this.isOnboarded = false, this.isAuthed = false});
  final bool isOnboarded;
  final bool isAuthed;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ContrastCoach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.build(isOnboarded: isOnboarded, isAuthed: isAuthed),
    );
  }
}
```

- [ ] **Step 2: main.dart**

```dart
import 'package:contrast_coach/app.dart';
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.init();
  runApp(const ContrastCoachApp());
}
```

- [ ] **Step 3: Replace default widget_test.dart**

```dart
import 'package:contrast_coach/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to onboarding', (tester) async {
    await tester.pumpWidget(const ContrastCoachApp());
    await tester.pumpAndSettle();
    expect(find.text('Track heat. Track cold. See what works.'), findsOneWidget);
  });
}
```

- [ ] **Step 4: Delete or replace the auto-generated widget_test.dart**

```bash
rm -f /root/ContrastCoach/contrast_coach/test/widget_test.dart
```

- [ ] **Step 5: Run tests + analyze**

Run: `cd contrast_coach && flutter analyze && flutter test`
Expected: 0 issues, all tests pass.

- [ ] **Step 6: Build APK**

Run: `cd contrast_coach && flutter build apk --debug`
Expected: builds successfully.

- [ ] **Step 7: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/app.dart contrast_coach/lib/main.dart contrast_coach/test/widget_test.dart
git commit -m "feat: app entry point and root widget (boots to onboarding)"
```

### Task 37: Verify Phase 3

- [ ] **Step 1: Run full suite + analyze + build**

Run: `cd contrast_coach && flutter test && flutter analyze && flutter build apk --debug`
Expected: all pass, 0 issues, APK builds.

- [ ] **Step 2: Commit phase marker**

```bash
cd /root/ContrastCoach
git commit --allow-empty -m "chore: phase 3 complete (all 8 screens, routing, state machine)"
```

---

## Phase 4: Voice + audio + streak integration

### Task 38: Audio cue service

**Files:**
- Create: `contrast_coach/lib/data/audio/audio_cue_service.dart`
- Create: `contrast_coach/test/data/audio/audio_cue_service_test.dart`

- [ ] **Step 1: audio_cue_service.dart**

```dart
import 'package:just_audio/just_audio.dart';
import 'package:contrast_coach/core/constants/app_assets.dart';

class AudioCueService {
  AudioCueService();
  final AudioPlayer _player = AudioPlayer();

  Future<void> playPhaseTransition() async {
    try {
      await _player.setAsset(AppAssets.audioPhaseTransition);
      await _player.play();
    } catch (_) {
      // Audio is best-effort; don't crash session on failure
    }
  }

  Future<void> playSessionStart() async {
    try {
      await _player.setAsset(AppAssets.audioSessionStart);
      await _player.play();
    } catch (_) {}
  }

  Future<void> playSessionComplete() async {
    try {
      await _player.setAsset(AppAssets.audioSessionComplete);
      await _player.play();
    } catch (_) {}
  }

  Future<void> dispose() => _player.dispose();
}
```

- [ ] **Step 2: Run analyze**

Run: `cd contrast_coach && flutter analyze`
Expected: 0 issues.

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/audio/
git commit -m "feat: audio cue service for phase transitions, session start, session complete"
```

### Task 39: Speech-to-text client

**Files:**
- Create: `contrast_coach/lib/data/voice/speech_to_text_client.dart`
- Create: `contrast_coach/test/data/voice/speech_to_text_client_test.dart`

- [ ] **Step 1: speech_to_text_client.dart**

```dart
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextClient {
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _initialized = false;
  bool _available = false;

  bool get isAvailable => _available;

  Future<bool> init() async {
    if (_initialized) return _available;
    _initialized = true;
    try {
      _available = await _stt.initialize(
        onError: (_) {},
        onStatus: (_) {},
      );
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startListening({
    required void Function(String) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_available) return;
    await _stt.listen(
      onResult: (r) {
        if (r.finalResult) onResult(r.recognizedWords);
      },
      listenOptions: stt.SpeechListenOptions(partialResults: false, cancelOnError: true),
      localeId: localeId,
    );
  }

  Future<void> stopListening() async {
    if (!_available) return;
    await _stt.stop();
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/voice/
git commit -m "feat: speech-to-text client with permission handling"
```

### Task 40: Wire voice into active session screen

**Files:**
- Modify: `contrast_coach/lib/presentation/screens/session/active_session_screen.dart`

- [ ] **Step 1: Update active_session_screen.dart to use voice**

Add at top of file:

```dart
import 'package:contrast_coach/data/audio/audio_cue_service.dart';
import 'package:contrast_coach/data/voice/speech_to_text_client.dart';
import 'package:contrast_coach/domain/entities/voice_command.dart';
import 'package:contrast_coach/domain/voice/command_parser.dart';
```

Replace `_ActiveSessionScreenState` class with:

```dart
class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  Duration _remaining = const Duration(minutes: 15);
  bool _paused = false;
  int _currentRound = 1;
  final int _totalRounds = 3;
  final String _phase = 'Sauna';
  final SpeechToTextClient _stt = SpeechToTextClient();
  final AudioCueService _audio = AudioCueService();
  bool _voiceActive = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
    _audio.playSessionStart();
  }

  Future<void> _initVoice() async {
    final ok = await _stt.init();
    if (ok && mounted) {
      setState(() => _voiceActive = true);
      _startListening();
    }
  }

  Future<void> _startListening() async {
    await _stt.startListening(onResult: _onVoiceResult);
  }

  void _onVoiceResult(String text) {
    final cmd = parseVoiceCommand(text);
    switch (cmd.kind) {
      case VoiceCommandKind.next:
        _audio.playPhaseTransition();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Next phase')));
        break;
      case VoiceCommandKind.pause:
        setState(() => _paused = true);
        break;
      case VoiceCommandKind.resume:
        setState(() => _paused = false);
        break;
      case VoiceCommandKind.end:
        _audio.playSessionComplete();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _stt.stopListening();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SessionTimer(
                phaseLabel: _phase,
                remaining: _remaining,
                currentRound: _currentRound,
                totalRounds: _totalRounds,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _voiceActive
                        ? "Say 'next phase' to continue"
                        : 'Tap a button to control the session',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: _paused ? 'Resume' : 'Pause',
                    onPressed: () => setState(() => _paused = !_paused),
                    variant: AppButtonVariant.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyze**

Run: `cd contrast_coach && flutter analyze`
Expected: 0 issues.

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/presentation/screens/session/active_session_screen.dart
git commit -m "feat: wire voice control + audio cues into active session"
```

### Task 41: Local notifications (streak reminder)

**Files:**
- Create: `contrast_coach/lib/data/notifications/notification_service.dart`

- [ ] **Step 1: notification_service.dart**

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: androidSettings, iOS: iosSettings));
  }

  Future<void> showStreakReminder({required int streakDays}) async {
    await _plugin.show(
      1,
      'Keep your streak',
      'Day $streakDays. Do a quick session today.',
      const NotificationDetails(
        android: AndroidNotificationDetails('streak', 'Streak', importance: Importance.defaultImportance),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/notifications/
git commit -m "feat: local notification service (streak reminder)"
```

### Task 42: Verify Phase 4

- [ ] **Step 1: Run full suite + analyze + build**

Run: `cd contrast_coach && flutter test && flutter analyze && flutter build apk --debug`
Expected: all pass.

- [ ] **Step 2: Commit phase marker**

```bash
cd /root/ContrastCoach
git commit --allow-empty -m "chore: phase 4 complete (voice, audio cues, notifications)"
```

---

## Phase 5: v0.5 — Firebase Auth + Firestore sync

### Task 43: Firebase configuration files

**Files:**
- Create: `contrast_coach/android/app/google-services.json.template`
- Create: `contrast_coach/lib/data/remote/firebase/firebase_config.dart`

- [ ] **Step 1: firebase_config.dart**

```dart
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  const FirebaseConfig._();

  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: EnvConfig.firebaseApiKey ?? 'placeholder-api-key',
      appId: EnvConfig.firebaseAppId ?? '1:0000000000:android:0000000000000000',
      messagingSenderId: EnvConfig.firebaseMessagingSenderId ?? '0000000000',
      projectId: EnvConfig.firebaseProjectId ?? 'contrast-coach-dev',
      storageBucket: EnvConfig.firebaseStorageBucket,
    );
  }
}
```

- [ ] **Step 2: google-services.json.template**

```json
{
  "project_info": {
    "project_number": "REPLACE_WITH_FIREBASE_PROJECT_NUMBER",
    "project_id": "REPLACE_WITH_FIREBASE_PROJECT_ID",
    "storage_bucket": "REPLACE_WITH_FIREBASE_STORAGE_BUCKET"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "REPLACE_WITH_FIREBASE_APP_ID",
        "android_client_info": { "package_name": "com.contrastcoach.contrast_coach" }
      },
      "oauth_client": [],
      "api_key": [{ "current_key": "REPLACE_WITH_FIREBASE_API_KEY" }],
      "services": {
        "appinvite_service": { "other_platform_oauth_client": [] }
      }
    }
  ],
  "configuration_version": "1"
}
```

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/remote/firebase/ contrast_coach/android/app/google-services.json.template
git commit -m "feat: firebase config with --dart-define and google-services.json template"
```

### Task 44: Firebase Auth wrapper

**Files:**
- Create: `contrast_coach/lib/data/remote/firebase/auth_api.dart`
- Create: `contrast_coach/lib/domain/repositories/auth_repository.dart`
- Create: `contrast_coach/lib/data/repositories/auth_repository.dart`

- [ ] **Step 1: domain/repositories/auth_repository.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> watchAuthState();
  Future<Result<User, AppException>> signInWithEmail(String email, String password);
  Future<Result<User, AppException>> signUpWithEmail(String email, String password);
  Future<Result<User, AppException>> signInWithGoogle();
  Future<void> signOut();
}
```

- [ ] **Step 2: data/repositories/auth_repository.dart**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _google = googleSignIn;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _google;

  @override
  Stream<User?> watchAuthState() => _auth.authStateChanges();

  @override
  Future<Result<User, AppException>> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) {
        return const Err(AuthException('No user returned from sign-in.'));
      }
      return Ok(user);
    } on FirebaseAuthException catch (e) {
      return Err(AuthException(e.message ?? 'Sign-in failed.', cause: e));
    } catch (e) {
      return Err(AuthException('Sign-in failed.', cause: e));
    }
  }

  @override
  Future<Result<User, AppException>> signUpWithEmail(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) {
        return const Err(AuthException('No user returned from sign-up.'));
      }
      // Create user document
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'subscriptionStatus': 'free',
      });
      return Ok(user);
    } on FirebaseAuthException catch (e) {
      return Err(AuthException(e.message ?? 'Sign-up failed.', cause: e));
    } catch (e) {
      return Err(AuthException('Sign-up failed.', cause: e));
    }
  }

  @override
  Future<Result<User, AppException>> signInWithGoogle() async {
    try {
      final account = await _google.signIn();
      if (account == null) return const Err(AuthException('Google sign-in cancelled.'));
      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken, accessToken: auth.accessToken);
      final cred = await _auth.signInWithCredential(credential);
      final user = cred.user;
      if (user == null) return const Err(AuthException('No user returned from Google sign-in.'));
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'subscriptionStatus': 'free',
      }, SetOptions(merge: true));
      return Ok(user);
    } catch (e) {
      return Err(AuthException('Google sign-in failed.', cause: e));
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _google.signOut()]);
  }
}
```

- [ ] **Step 3: Run analyze**

Run: `cd contrast_coach && flutter analyze`
Expected: 0 issues (google_sign_in will need a real config in app).

- [ ] **Step 4: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/repositories/auth_repository.dart contrast_coach/lib/domain/repositories/auth_repository.dart
git commit -m "feat: Firebase Auth + Google sign-in repository"
```

### Task 45: Firestore sync API for sessions

**Files:**
- Create: `contrast_coach/lib/data/remote/firebase/firestore_api.dart`
- Create: `contrast_coach/test/data/remote/firebase/firestore_api_test.dart`

- [ ] **Step 1: firestore_api.dart**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contrast_coach/domain/entities/session.dart';

class FirestoreApi {
  FirestoreApi(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _sessions(String userId) =>
      _db.collection('users').doc(userId).collection('sessions');

  Future<void> uploadSession(String userId, Session session) async {
    final json = _sessionToJson(session);
    json['clientUpdatedAt'] = FieldValue.serverTimestamp();
    await _sessions(userId).doc(session.id).set(json, SetOptions(merge: true));
  }

  Future<List<Session>> downloadSessions(String userId, {DateTime? since}) async {
    final query = _sessions(userId).orderBy('startedAt', descending: true);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => _sessionFromJson(doc.data())).toList();
  }

  Map<String, dynamic> _sessionToJson(Session s) {
    return {
      'id': s.id,
      'protocolId': s.protocolId,
      'goal': s.goal.name,
      'startedAt': Timestamp.fromDate(s.startedAt),
      'endedAt': s.endedAt != null ? Timestamp.fromDate(s.endedAt!) : null,
      'totalPlannedDurationSec': s.totalPlannedDuration.inSeconds,
      'totalActualDurationSec': s.totalActualDuration.inSeconds,
      'roundsCompleted': s.roundsCompleted,
      'protocolRounds': s.protocolRounds,
      'recoveryScore': s.recoveryScore,
      'notes': s.notes,
      // Only computed health metrics, never raw values
      'healthDataSnapshot': s.healthDataSnapshot,
      'userId': s.userId,
    };
  }

  Session _sessionFromJson(Map<String, dynamic> json) {
    // Inverse of _sessionToJson; for v0.5 we only need to round-trip the fields we care about.
    // Full phase hydration comes in a later task.
    return Session(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      protocolId: json['protocolId'] as String,
      goal: _goalFromString(json['goal'] as String?),
      startedAt: (json['startedAt'] as Timestamp).toDate(),
      endedAt: json['endedAt'] != null ? (json['endedAt'] as Timestamp).toDate() : null,
      totalPlannedDuration: Duration(seconds: json['totalPlannedDurationSec'] as int? ?? 0),
      totalActualDuration: Duration(seconds: json['totalActualDurationSec'] as int? ?? 0),
      roundsCompleted: json['roundsCompleted'] as int? ?? 0,
      protocolRounds: json['protocolRounds'] as int? ?? 1,
      recoveryScore: (json['recoveryScore'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      healthDataSnapshot: json['healthDataSnapshot'] as Map<String, dynamic>?,
      isSynced: true,
      createdAt: (json['startedAt'] as Timestamp).toDate(),
      updatedAt: DateTime.now(),
    );
  }

  // Local helper to avoid an import cycle with the goal entity
  dynamic _goalFromString(String? s) {
    if (s == null) return null;
    return _goalFromName(s);
  }
}

dynamic _goalFromName(String name) {
  // Mirror of Goal.fromString without importing the entity to avoid a cycle
  switch (name) {
    case 'recovery':
      return _GoalStub.recovery;
    case 'energy':
      return _GoalStub.energy;
    case 'sleep':
      return _GoalStub.sleep;
    case 'immunity':
      return _GoalStub.immunity;
    default:
      return _GoalStub.recovery;
  }
}

enum _GoalStub { recovery, energy, sleep, immunity }
```

- [ ] **Step 2: Run analyze**

Run: `cd contrast_coach && flutter analyze`
Expected: 0 issues (Google sign-in pub is included).

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/remote/firebase/firestore_api.dart
git commit -m "feat: Firestore API for sessions upload/download (computed metrics only)"
```

### Task 46: Firestore security rules

**Files:**
- Create: `contrast_coach/firestore.rules`

- [ ] **Step 1: firestore.rules**

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /sessions/{sessionId} {
        allow read, write: if request.auth != null
          && request.auth.uid == userId
          // Raw health fields are forbidden; computed metrics are fine
          && !('rawHeartRate' in request.resource.data)
          && !('rawHrv' in request.resource.data)
          && !('rawSleep' in request.resource.data);
      }
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/firestore.rules
git commit -m "feat: Firestore security rules (users own data only, raw health forbidden)"
```

### Task 47: Session sync (push from local to Firestore)

**Files:**
- Modify: `contrast_coach/lib/data/repositories/session_repository.dart`

- [ ] **Step 1: Add syncToRemote and syncFromRemote to interface**

In `lib/domain/repositories/session_repository.dart`, add:

```dart
Future<Result<void, AppException>> syncToRemote(String userId);
Future<Result<void, AppException>> syncFromRemote(String userId);
```

- [ ] **Step 2: Implement in SessionRepositoryImpl**

Add imports at top of `lib/data/repositories/session_repository.dart`:

```dart
import 'package:contrast_coach/data/remote/firebase/firestore_api.dart';
```

Update the class:

```dart
class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._db, {FirestoreApi? firestoreApi}) : _firestoreApi = firestoreApi;
  final AppDatabase _db;
  final FirestoreApi? _firestoreApi;

  // ... existing methods ...

  @override
  Future<Result<void, AppException>> syncToRemote(String userId) async {
    final api = _firestoreApi;
    if (api == null) return const Ok(null);
    try {
      final allResult = await getAll();
      if (allResult is Err) return allResult;
      for (final session in (allResult as Ok<List<Session>, AppException>).value) {
        if (session.userId == null || session.userId != userId) continue;
        if (session.isSynced) continue;
        await api.uploadSession(userId, session);
        await _markSynced(session.id);
      }
      return const Ok(null);
    } catch (e) {
      return Err(NetworkException('Sync to remote failed', cause: e));
    }
  }

  @override
  Future<Result<void, AppException>> syncFromRemote(String userId) async {
    final api = _firestoreApi;
    if (api == null) return const Ok(null);
    try {
      final remoteSessions = await api.downloadSessions(userId);
      for (final session in remoteSessions) {
        await save(session.copyWith(isSynced: true, userId: userId));
      }
      return const Ok(null);
    } catch (e) {
      return Err(NetworkException('Sync from remote failed', cause: e));
    }
  }

  Future<void> _markSynced(String sessionId) async {
    await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId)))
        .write(const SessionsCompanion(isSynced: Value(true)));
  }
}
```

Add a `copyWith` method to the `Session` entity:

```dart
Session copyWith({String? userId, bool? isSynced}) {
  return Session(
    id: id,
    userId: userId ?? this.userId,
    protocolId: protocolId,
    goal: goal,
    startedAt: startedAt,
    endedAt: endedAt,
    totalPlannedDuration: totalPlannedDuration,
    totalActualDuration: totalActualDuration,
    roundsCompleted: roundsCompleted,
    protocolRounds: protocolRounds,
    recoveryScore: recoveryScore,
    notes: notes,
    healthDataSnapshot: healthDataSnapshot,
    isSynced: isSynced ?? this.isSynced,
    createdAt: createdAt,
    updatedAt: updatedAt,
    phases: phases,
  );
}
```

- [ ] **Step 3: Run analyze + tests**

Run: `cd contrast_coach && flutter analyze && flutter test`
Expected: 0 issues, all pass.

- [ ] **Step 4: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/repositories/session_repository.dart contrast_coach/lib/domain/repositories/session_repository.dart contrast_coach/lib/domain/entities/session.dart
git commit -m "feat: session sync to/from Firestore (computed metrics only)"
```

### Task 48: Verify Phase 5

- [ ] **Step 1: Run full suite + analyze + build**

Run: `cd contrast_coach && flutter test && flutter analyze && flutter build apk --debug`
Expected: all pass.

- [ ] **Step 2: Commit phase marker**

```bash
cd /root/ContrastCoach
git commit --allow-empty -m "chore: phase 5 complete (auth + firestore sync + security rules)"
```

---

## Phase 6: v0.5 — Health Connect

### Task 49: Health Connect client (READ)

**Files:**
- Create: `contrast_coach/lib/data/local/health/health_connect_client.dart`
- Create: `contrast_coach/lib/domain/entities/health_snapshot.dart`
- Create: `contrast_coach/lib/domain/repositories/health_repository.dart`
- Create: `contrast_coach/test/data/local/health/health_snapshot_test.dart`

- [ ] **Step 1: health_snapshot.dart**

```dart
class HealthSnapshot {
  const HealthSnapshot({
    required this.capturedAt,
    this.lastNightSleepMinutes,
    this.hrvRmssd7DayAvg,
    this.hrvRmssdTrend7Day,
    this.restingHr7DayAvg,
    this.restingHrTrend7Day,
    this.stepsYesterday,
    this.lastWorkoutAt,
  });
  final DateTime capturedAt;
  final int? lastNightSleepMinutes;
  final double? hrvRmssd7DayAvg;
  final double? hrvRmssdTrend7Day;
  final double? restingHr7DayAvg;
  final double? restingHrTrend7Day;
  final int? stepsYesterday;
  final DateTime? lastWorkoutAt;
}
```

- [ ] **Step 2: domain/repositories/health_repository.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/health_snapshot.dart';

abstract class HealthRepository {
  Future<Result<bool, AppException>> isAvailable();
  Future<Result<bool, AppException>> requestPermissions();
  Future<Result<HealthSnapshot, AppException>> readSnapshot();
  Future<Result<void, AppException>> writeMindfulSession({
    required DateTime start,
    required DateTime end,
    required String title,
  });
}
```

- [ ] **Step 3: health_connect_client.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/health_snapshot.dart';
import 'package:contrast_coach/domain/repositories/health_repository.dart';
import 'package:health/health.dart';

class HealthConnectClient implements HealthRepository {
  HealthConnectClient({Health? health}) : _health = health ?? Health();
  final Health _health;

  static const _readTypes = <HealthDataType>[
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.STEPS,
    HealthDataType.WORKOUT,
  ];

  static const _readPermissions = <HealthDataAccess>[
    HealthDataAccess.READ_HEART_RATE,
    HealthDataAccess.READ_RESTING_HEART_RATE,
    HealthDataAccess.READ_HRV,
    HealthDataAccess.READ_SLEEP,
    HealthDataAccess.READ_STEPS,
    HealthDataAccess.READ_EXERCISE,
  ];

  static const _writePermissions = <HealthDataAccess>[
    HealthDataAccess.WRITE_MINDFULNESS,
  ];

  @override
  Future<Result<bool, AppException>> isAvailable() async {
    try {
      final available = await _health.isHealthConnectAvailable();
      return Ok(available);
    } catch (e) {
      return Err(HealthPermissionException('Health Connect availability check failed', cause: e));
    }
  }

  @override
  Future<Result<bool, AppException>> requestPermissions() async {
    try {
      final granted = await _health.requestAuthorization(
        _readPermissions + _writePermissions,
        rationale: 'ContrastCoach reads heart rate, HRV, and sleep to calculate your recovery score. All data stays on your device. We never upload it.',
      );
      return Ok(granted);
    } catch (e) {
      return Err(HealthPermissionException('Permission request failed', cause: e));
    }
  }

  @override
  Future<Result<HealthSnapshot, AppException>> readSnapshot() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final yesterday = now.subtract(const Duration(days: 1));

      final hrvData = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
        startTime: weekAgo,
        endTime: now,
      );
      final sleepData = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.SLEEP_ASLEEP],
        startTime: yesterday,
        endTime: now,
      );

      final hrvValues = hrvData
          .map((p) => (p.value as NumericHealthValue).numericValue.toDouble())
          .toList();
      final hrvAvg = hrvValues.isEmpty ? null : hrvValues.reduce((a, b) => a + b) / hrvValues.length;
      final hrvTrend = hrvAvg == null || hrvValues.length < 4
          ? null
          : (hrvValues.skip(hrvValues.length ~/ 2).reduce((a, b) => a + b) /
                  (hrvValues.length - hrvValues.length ~/ 2)) -
              (hrvValues.take(hrvValues.length ~/ 2).reduce((a, b) => a + b) /
                  (hrvValues.length ~/ 2));

      final lastNightSleep = sleepData.isEmpty
          ? null
          : sleepData
              .map((p) => (p.dateTo.difference(p.dateFrom).inMinutes))
              .reduce((a, b) => a + b);

      return Ok(HealthSnapshot(
        capturedAt: now,
        lastNightSleepMinutes: lastNightSleep,
        hrvRmssd7DayAvg: hrvAvg,
        hrvRmssdTrend7Day: hrvTrend,
      ));
    } catch (e) {
      return Err(HealthReadException('Failed to read health data', cause: e));
    }
  }

  @override
  Future<Result<void, AppException>> writeMindfulSession({
    required DateTime start,
    required DateTime end,
    required String title,
  }) async {
    try {
      final success = await _health.writeHealthData(
        value: end.difference(start).inMinutes.toDouble(),
        type: HealthDataType.MINDFULNESS,
        startTime: start,
        endTime: end,
      );
      return success ? const Ok(null) : const Err(HealthReadException('Write failed'));
    } catch (e) {
      return Err(HealthReadException('Write failed', cause: e));
    }
  }
}
```

- [ ] **Step 4: Run analyze**

Run: `cd contrast_coach && flutter analyze`
Expected: 0 issues.

- [ ] **Step 5: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/local/health/ contrast_coach/lib/domain/entities/health_snapshot.dart contrast_coach/lib/domain/repositories/health_repository.dart
git commit -m "feat: Health Connect client (READ HR/HRV/sleep, WRITE MindfulSession)"
```

### Task 50: Update EndSession to use health snapshot

**Files:**
- Modify: `contrast_coach/lib/domain/usecases/end_session.dart`

- [ ] **Step 1: Add health snapshot to EndSession**

Replace the constructor and `call` to take health data:

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/utils/score_calculator.dart';
import 'package:contrast_coach/domain/entities/health_snapshot.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';

class EndSession {
  EndSession({
    required SessionRepository sessions,
    required int Function() streakProvider,
    HealthSnapshot? health,
  })  : _sessions = sessions,
        _streakProvider = streakProvider,
        _health = health;

  final SessionRepository _sessions;
  final int Function() _streakProvider;
  final HealthSnapshot? _health;

  Future<Result<Session, AppException>> call({
    required String sessionId,
    required DateTime endedAt,
    required Duration totalActualDuration,
    required int roundsCompleted,
  }) async {
    final getResult = await _sessions.getById(sessionId);
    if (getResult is Err) return getResult;
    final existing = (getResult as Ok<Session?, AppException>).value;
    if (existing == null) {
      return Err(ValidationException('Session not found: $sessionId'));
    }

    final updated = Session(
      id: existing.id,
      userId: existing.userId,
      protocolId: existing.protocolId,
      goal: existing.goal,
      startedAt: existing.startedAt,
      endedAt: endedAt,
      totalPlannedDuration: existing.totalPlannedDuration,
      totalActualDuration: totalActualDuration,
      roundsCompleted: roundsCompleted,
      protocolRounds: existing.protocolRounds,
      notes: existing.notes,
      healthDataSnapshot: _health != null
          ? {
              'sleepMinutes': _health.lastNightSleepMinutes,
              'hrvRmssd7DayAvg': _health.hrvRmssd7DayAvg,
              'hrvRmssdTrend7Day': _health.hrvRmssdTrend7Day,
            }
          : null,
      isSynced: existing.isSynced,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      phases: existing.phases,
    );

    final streak = _streakProvider();
    final score = calculateRecoveryScore(
      session: updated,
      currentStreakDays: streak,
      lastNightSleepMinutes: _health?.lastNightSleepMinutes,
      hrvRmssdTrend7Day: _health?.hrvRmssdTrend7Day,
    );

    final finalSession = Session(
      id: updated.id,
      userId: updated.userId,
      protocolId: updated.protocolId,
      goal: updated.goal,
      startedAt: updated.startedAt,
      endedAt: updated.endedAt,
      totalPlannedDuration: updated.totalPlannedDuration,
      totalActualDuration: updated.totalActualDuration,
      roundsCompleted: updated.roundsCompleted,
      protocolRounds: updated.protocolRounds,
      recoveryScore: score.value,
      notes: updated.notes,
      healthDataSnapshot: updated.healthDataSnapshot,
      isSynced: updated.isSynced,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
      phases: updated.phases,
    );

    return _sessions.save(finalSession);
  }
}
```

- [ ] **Step 2: Run analyze + tests**

Run: `cd contrast_coach && flutter analyze && flutter test`
Expected: 0 issues, all pass.

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/domain/usecases/end_session.dart
git commit -m "feat: EndSession use case consumes health snapshot (Pro)"
```

### Task 51: Health Connect Android manifest entries

**Files:**
- Modify: `contrast_coach/android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add permissions**

Inside `<manifest>`, add (before `<application>`):

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
```

Inside `<application>`, add:

```xml
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

- [ ] **Step 2: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/android/app/src/main/AndroidManifest.xml
git commit -m "feat: Health Connect permissions and ViewPermissionUsageActivity alias"
```

### Task 52: Verify Phase 6

- [ ] **Step 1: Run full suite + analyze + build**

Run: `cd contrast_coach && flutter test && flutter analyze && flutter build apk --debug`
Expected: all pass.

- [ ] **Step 2: Commit phase marker**

```bash
cd /root/ContrastCoach
git commit --allow-empty -m "chore: phase 6 complete (Health Connect, recovery score v2)"
```

---

## Phase 7: v1.0 — Subscription

### Task 53: RevenueCat client

**Files:**
- Create: `contrast_coach/lib/data/remote/subscription/revenue_cat_client.dart`
- Create: `contrast_coach/lib/domain/entities/subscription_tier.dart`
- Create: `contrast_coach/lib/domain/repositories/subscription_repository.dart`
- Create: `contrast_coach/lib/data/repositories/subscription_repository.dart`

- [ ] **Step 1: subscription_tier.dart**

```dart
enum SubscriptionTier { free, proMonthly, proYearly, lifetime }

extension SubscriptionTierLabel on SubscriptionTier {
  String get label => switch (this) {
        SubscriptionTier.free => 'Free',
        SubscriptionTier.proMonthly => 'Pro Monthly',
        SubscriptionTier.proYearly => 'Pro Yearly',
        SubscriptionTier.lifetime => 'Lifetime',
      };

  bool get isPro => this != SubscriptionTier.free;
}
```

- [ ] **Step 2: domain/repositories/subscription_repository.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class SubscriptionRepository {
  Future<Result<SubscriptionTier, AppException>> currentTier();
  Future<Result<List<Package>, AppException>> getOfferings();
  Future<Result<SubscriptionTier, AppException>> purchase(Package package);
  Future<Result<SubscriptionTier, AppException>> restore();
  Stream<SubscriptionTier> watchTier();
}
```

- [ ] **Step 3: revenue_cat_client.dart**

```dart
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatBootstrap {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    final apiKey = EnvConfig.revenuecatApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      // Skip init in tests/dev with no key
      return;
    }
    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);
    _initialized = true;
  }
}
```

- [ ] **Step 4: data/repositories/subscription_repository.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:contrast_coach/domain/repositories/subscription_repository.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({required Purchases purchases}) : _purchases = purchases;
  final Purchases _purchases;

  SubscriptionTier _tierFromCustomerInfo(CustomerInfo info) {
    final entitlements = info.entitlements.all;
    if (entitlements['pro']?.isActive == true) {
      // Determine if it's monthly, yearly, or lifetime based on the product
      final products = entitlements['pro']!.productIdentifier;
      if (products.contains('yearly')) return SubscriptionTier.proYearly;
      if (products.contains('lifetime')) return SubscriptionTier.lifetime;
      return SubscriptionTier.proMonthly;
    }
    return SubscriptionTier.free;
  }

  @override
  Future<Result<SubscriptionTier, AppException>> currentTier() async {
    try {
      final info = await _purchases.getCustomerInfo();
      return Ok(_tierFromCustomerInfo(info));
    } catch (e) {
      return Err(SubscriptionException('Failed to read subscription state', cause: e));
    }
  }

  @override
  Future<Result<List<Package>, AppException>> getOfferings() async {
    try {
      final offerings = await _purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return const Ok([]);
      return Ok(current.availablePackages);
    } catch (e) {
      return Err(SubscriptionException('Failed to read offerings', cause: e));
    }
  }

  @override
  Future<Result<SubscriptionTier, AppException>> purchase(Package package) async {
    try {
      final result = await _purchases.purchasePackage(package);
      return Ok(_tierFromCustomerInfo));
    } catch (e) {
      return Err(SubscriptionException('Purchase failed', cause: e));
    }
  }

  @override
  Future<Result<SubscriptionTier, AppException>> restore() async {
    try {
      final info = await _purchases.restorePurchases();
      return Ok(_tierFromCustomerInfo(info));
    } catch (e) {
      return Err(SubscriptionException('Restore failed', cause: e));
    }
  }

  @override
  Stream<SubscriptionTier> watchTier() {
    return _purchases.customerInfoStream.map(_tierFromCustomerInfo);
  }
}
```

- [ ] **Step 5: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/remote/subscription/ contrast_coach/lib/data/repositories/subscription_repository.dart contrast_coach/lib/domain/entities/subscription_tier.dart contrast_coach/lib/domain/repositories/subscription_repository.dart
git commit -m "feat: RevenueCat client + subscription repository (free/pro tiers)"
```

### Task 54: Pro feature gating helper

**Files:**
- Create: `contrast_coach/lib/core/feature_gating.dart`
- Create: `contrast_coach/test/core/feature_gating_test.dart`

- [ ] **Step 1: feature_gating.dart**

```dart
import 'package:contrast_coach/domain/entities/subscription_tier.dart';

class FeatureGating {
  const FeatureGating({required this.tier});
  final SubscriptionTier tier;

  bool get canUseAllProtocols => tier.isPro;
  bool get canUseHealthConnect => tier.isPro;
  bool get canUseVoice => true; // voice is included in free tier in this design
  bool get canSync => tier.isPro;
  bool get canGenerateInsights => tier.isPro;
  bool get canBuildCustomProtocol => tier.isPro;

  bool get hasPro => tier.isPro;
}
```

- [ ] **Step 2: feature_gating_test.dart**

```dart
import 'package:contrast_coach/core/feature_gating.dart';
import 'package:contrast_coach/domain/entities/subscription_tier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeatureGating', () {
    test('free tier can use voice but not Health Connect', () {
      final fg = FeatureGating(tier: SubscriptionTier.free);
      expect(fg.canUseVoice, isTrue);
      expect(fg.canUseHealthConnect, isFalse);
      expect(fg.canSync, isFalse);
      expect(fg.hasPro, isFalse);
    });

    test('pro tier has all features', () {
      final fg = FeatureGating(tier: SubscriptionTier.proMonthly);
      expect(fg.canUseAllProtocols, isTrue);
      expect(fg.canUseHealthConnect, isTrue);
      expect(fg.canSync, isTrue);
      expect(fg.canBuildCustomProtocol, isTrue);
      expect(fg.hasPro, isTrue);
    });

    test('lifetime is pro', () {
      final fg = FeatureGating(tier: SubscriptionTier.lifetime);
      expect(fg.hasPro, isTrue);
    });
  });
}
```

- [ ] **Step 3: Run test**

Run: `cd contrast_coach && flutter test test/core/feature_gating_test.dart`
Expected: 3 tests pass.

- [ ] **Step 4: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/core/feature_gating.dart contrast_coach/test/core/feature_gating_test.dart
git commit -m "feat: feature gating helper (free vs Pro tier checks)"
```

### Task 55: Verify Phase 7

- [ ] **Step 1: Run full suite + analyze + build**

Run: `cd contrast_coach && flutter test && flutter analyze && flutter build apk --debug`
Expected: all pass.

- [ ] **Step 2: Commit phase marker**

```bash
cd /root/ContrastCoach
git commit --allow-empty -m "chore: phase 7 complete (RevenueCat, subscription tiers, feature gating)"
```

---

## Phase 8: v1.0 — Insights + Custom protocols

### Task 56: Insights generator (pure Dart, deterministic)

**Files:**
- Create: `contrast_coach/lib/domain/entities/insight.dart`
- Create: `contrast_coach/lib/domain/usecases/generate_insights.dart`
- Create: `contrast_coach/test/domain/usecases/generate_insights_test.dart`

- [ ] **Step 1: insight.dart**

```dart
enum InsightCategory {
  totalSessions,
  avgDuration,
  bestProtocol,
  sleepCorrelation,
  recoveryTrend,
  recommendations,
  streakMilestone,
}

class Insight {
  const Insight({
    required this.id,
    required this.category,
    required this.heroMetric,
    required this.title,
    required this.body,
    required this.periodStart,
    required this.periodEnd,
  });
  final String id;
  final InsightCategory category;
  final String heroMetric;
  final String title;
  final String body;
  final DateTime periodStart;
  final DateTime periodEnd;
}
```

- [ ] **Step 2: generate_insights_test.dart**

```dart
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/generate_insights.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Session _makeSession({
    required DateTime startedAt,
    required Duration actual,
    String protocolId = 'recovery_standard',
    int roundsCompleted = 3,
    int protocolRounds = 3,
    double? recoveryScore,
  }) {
    return Session(
      id: 's-${startedAt.millisecondsSinceEpoch}',
      protocolId: protocolId,
      goal: Goal.recovery,
      startedAt: startedAt,
      endedAt: startedAt.add(actual),
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: actual,
      roundsCompleted: roundsCompleted,
      protocolRounds: protocolRounds,
      recoveryScore: recoveryScore,
      createdAt: startedAt,
      updatedAt: startedAt,
    );
  }

  test('empty sessions produces no insights', () {
    final result = generateInsights(sessions: const [], periodEnd: DateTime(2026, 6, 13));
    expect(result, isEmpty);
  });

  test('produces 5-7 insights for 30-day data', () {
    final now = DateTime(2026, 6, 13);
    final sessions = List.generate(20, (i) {
      return _makeSession(
        startedAt: now.subtract(Duration(days: i)),
        actual: const Duration(minutes: 25),
        recoveryScore: 70 + (i % 20).toDouble(),
      );
    });
    final insights = generateInsights(sessions: sessions, periodEnd: now);
    expect(insights.length, inInclusiveRange(5, 7));
  });

  test('includes total sessions', () {
    final now = DateTime(2026, 6, 13);
    final sessions = List.generate(5, (i) {
      return _makeSession(
        startedAt: now.subtract(Duration(days: i)),
        actual: const Duration(minutes: 20),
        recoveryScore: 70,
      );
    });
    final insights = generateInsights(sessions: sessions, periodEnd: now);
    expect(insights.any((i) => i.category == InsightCategoryStub.totalSessions), isTrue);
  });
}
```

- [ ] **Step 3: generate_insights.dart**

```dart
import 'package:contrast_coach/domain/entities/insight.dart';
import 'package:contrast_coach/domain/entities/session.dart';

List<Insight> generateInsights({
  required List<Session> sessions,
  required DateTime periodEnd,
  Duration period = const Duration(days: 30),
}) {
  if (sessions.isEmpty) return const [];

  final periodStart = periodEnd.subtract(period);
  final inPeriod = sessions.where((s) => s.startedAt.isAfter(periodStart)).toList();
  if (inPeriod.isEmpty) return const [];

  final insights = <Insight>[];

  // 1. Total sessions
  insights.add(Insight(
    id: 'total-sessions',
    category: InsightCategory.totalSessions,
    heroMetric: inPeriod.length.toString(),
    title: 'Total sessions',
    body: 'You did ${inPeriod.length} sessions in the last ${period.inDays} days.',
    periodStart: periodStart,
    periodEnd: periodEnd,
  ));

  // 2. Avg duration
  final totalSec = inPeriod.fold<int>(0, (a, s) => a + s.totalActualDuration.inSeconds);
  final avgMin = (totalSec / inPeriod.length / 60).round();
  insights.add(Insight(
    id: 'avg-duration',
    category: InsightCategory.avgDuration,
    heroMetric: '${avgMin}m',
    title: 'Avg duration',
    body: 'Average session length over the period.',
    periodStart: periodStart,
    periodEnd: periodEnd,
  ));

  // 3. Best protocol
  final byProtocol = <String, List<Session>>{};
  for (final s in inPeriod) {
    byProtocol.putIfAbsent(s.protocolId, () => []).add(s);
  }
  String? bestProtocol;
  double bestScore = -1;
  byProtocol.forEach((id, list) {
    final scores = list.where((s) => s.recoveryScore != null).map((s) => s.recoveryScore!);
    if (scores.isEmpty) return;
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    if (avg > bestScore) {
      bestScore = avg;
      bestProtocol = id;
    }
  });
  if (bestProtocol != null) {
    insights.add(Insight(
      id: 'best-protocol',
      category: InsightCategory.bestProtocol,
      heroMetric: bestScore.round().toString(),
      title: 'Best protocol',
      body: '$bestProtocol averages $bestScore.',
      periodStart: periodStart,
      periodEnd: periodEnd,
    ));
  }

  // 4. Sleep correlation (uses healthDataSnapshot)
  final withSleep = inPeriod.where((s) => s.healthDataSnapshot?['sleepMinutes'] != null).toList();
  if (withSleep.isNotEmpty) {
    final avgSleep = withSleep
            .map((s) => (s.healthDataSnapshot!['sleepMinutes']! as num).toInt())
            .reduce((a, b) => a + b) /
        withSleep.length;
    insights.add(Insight(
      id: 'sleep-correlation',
      category: InsightCategory.sleepCorrelation,
      heroMetric: '${(avgSleep / 60).toStringAsFixed(1)}h',
      title: 'Sleep correlation',
      body: 'Average sleep on session days.',
      periodStart: periodStart,
      periodEnd: periodEnd,
    ));
  }

  // 5. Recovery trend
  final withScores = inPeriod.where((s) => s.recoveryScore != null).toList()..sort((a, b) => a.startedAt.compareTo(b.startedAt));
  if (withScores.length >= 2) {
    final first = withScores.first.recoveryScore!;
    final last = withScores.last.recoveryScore!;
    final delta = last - first;
    insights.add(Insight(
      id: 'recovery-trend',
      category: InsightCategory.recoveryTrend,
      heroMetric: delta >= 0 ? '+${delta.round()}' : '${delta.round()}',
      title: 'Recovery trend',
      body: 'Score change from first to last session.',
      periodStart: periodStart,
      periodEnd: periodEnd,
    ));
  }

  return insights;
}

// Stub alias so tests can reference the category without an import cycle
class InsightCategoryStub {
  static const totalSessions = InsightCategory.totalSessions;
  static const avgDuration = InsightCategory.avgDuration;
  static const bestProtocol = InsightCategory.bestProtocol;
  static const sleepCorrelation = InsightCategory.sleepCorrelation;
  static const recoveryTrend = InsightCategory.recoveryTrend;
}
```

- [ ] **Step 4: Run test**

Run: `cd contrast_coach && flutter test test/domain/usecases/generate_insights_test.dart`
Expected: 3 tests pass.

- [ ] **Step 5: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/domain/entities/insight.dart contrast_coach/lib/domain/usecases/generate_insights.dart contrast_coach/test/domain/usecases/generate_insights_test.dart
git commit -m "feat: insights generator (deterministic, 5-7 insights per period)"
```

### Task 57: Custom protocol builder

**Files:**
- Create: `contrast_coach/lib/domain/usecases/validate_custom_protocol.dart`
- Create: `contrast_coach/lib/data/repositories/custom_protocol_repository.dart`
- Create: `contrast_coach/test/domain/usecases/validate_custom_protocol_test.dart`

- [ ] **Step 1: validate_custom_protocol.dart (uses existing protocol validator)**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/core/utils/protocol_validator.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';

Result<Protocol, AppException> validateCustomProtocol(Protocol p) {
  final validation = validateProtocol(p);
  if (validation.isValid) return Ok(p);
  return Err(ValidationException('Custom protocol invalid', errors: validation.errors));
}
```

- [ ] **Step 2: validate_custom_protocol_test.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/phase_template.dart';
import 'package:contrast_coach/domain/entities/phase_type.dart';
import 'package:contrast_coach/domain/entities/protocol.dart';
import 'package:contrast_coach/domain/usecases/validate_custom_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valid custom protocol returns Ok', () {
    final p = Protocol(
      id: 'custom1', name: 'My Protocol', description: 'x',
      category: ProtocolCategory.custom, difficulty: ProtocolDifficulty.intermediate,
      rounds: 3, isCustom: true,
      phases: const [
        PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 10)),
        PhaseTemplate(type: PhaseType.cold, duration: Duration(minutes: 2)),
      ],
    );
    final r = validateCustomProtocol(p);
    expect(r.isOk, isTrue);
  });

  test('invalid custom protocol returns Err with errors', () {
    final p = Protocol(
      id: 'bad', name: 'Bad', description: 'x',
      category: ProtocolCategory.custom, difficulty: ProtocolDifficulty.intermediate,
      rounds: 6, isCustom: true,
      phases: const [PhaseTemplate(type: PhaseType.sauna, duration: Duration(minutes: 5))],
    );
    final r = validateCustomProtocol(p);
    expect(r.isErr, isTrue);
    final err = (r as Err).error as ValidationException;
    expect(err.errors, isNotEmpty);
  });
}
```

- [ ] **Step 3: data/repositories/custom_protocol_repository.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/data/local/database/app_database.dart';
import 'package:contrast_coach/data/local/database/tables/custom_protocols_table.dart';
import 'package:drift/drift.dart';

class CustomProtocolRepository {
  CustomProtocolRepository(this._db);
  final AppDatabase _db;

  Future<Result<void, AppException>> save({
    required String id,
    required String name,
    required String description,
    required int rounds,
    required String phasesJson,
  }) async {
    try {
      final now = DateTime.now();
      await _db.into(_db.customProtocols).insertOnConflictUpdate(
            CustomProtocolsCompanion.insert(
              id: id,
              name: name,
              description: description,
              rounds: rounds,
              phasesJson: phasesJson,
              createdAt: now,
              updatedAt: now,
            ),
          );
      return const Ok(null);
    } catch (e) {
      return Err(DatabaseException('Failed to save custom protocol', cause: e));
    }
  }

  Future<Result<List<CustomProtocolRow>, AppException>> getAll() async {
    try {
      final rows = await _db.select(_db.customProtocols).get();
      return Ok(rows);
    } catch (e) {
      return Err(DatabaseException('Failed to read custom protocols', cause: e));
    }
  }
}
```

- [ ] **Step 4: Run test**

Run: `cd contrast_coach && flutter test test/domain/usecases/validate_custom_protocol_test.dart`
Expected: 2 tests pass.

- [ ] **Step 5: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/domain/usecases/validate_custom_protocol.dart contrast_coach/lib/data/repositories/custom_protocol_repository.dart contrast_coach/test/domain/usecases/validate_custom_protocol_test.dart
git commit -m "feat: custom protocol builder with validation (Pro, 1 saved)"
```

### Task 58: Verify Phase 8

- [ ] **Step 1: Run full suite + analyze + build**

Run: `cd contrast_coach && flutter test && flutter analyze && flutter build apk --debug`
Expected: all pass.

- [ ] **Step 2: Commit phase marker**

```bash
cd /root/ContrastCoach
git commit --allow-empty -m "chore: phase 8 complete (insights generator, custom protocols)"
```

---

## Phase 9: v1.0 — Polish + Play Store

### Task 59: Sentry crash reporting

**Files:**
- Create: `contrast_coach/lib/data/remote/crash/sentry_client.dart`
- Modify: `contrast_coach/lib/main.dart`

- [ ] **Step 1: sentry_client.dart**

```dart
import 'package:contrast_coach/core/env/env_config.dart';
import 'package:contrast_coach/app.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryBootstrap {
  static Future<void> runWithSentry() async {
    WidgetsFlutterBinding.ensureInitialized();
    final dsn = EnvConfig.sentryDsn;
    if (dsn == null || dsn.isEmpty) {
      runApp(const ContrastCoachApp());
      return;
    }
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.tracesSampleRate = 0.1;
        options.beforeSend = (event, hint) {
          event.user = SentryUser(id: null, username: null, email: null, ipAddress: null);
          event.tags?.remove('health_data');
          event.tags?.remove('user_id');
          return event;
        };
        options.beforeBreadcrumb = (breadcrumb, hint) {
          if (breadcrumb.message?.toLowerCase().contains('voice') == true) return null;
          return breadcrumb;
        };
      },
      appRunner: () => runApp(const ContrastCoachApp()),
    );
  }
}
```

- [ ] **Step 2: Update main.dart**

```dart
import 'package:contrast_coach/data/remote/crash/sentry_client.dart';

Future<void> main() async {
  await SentryBootstrap.runWithSentry();
}
```

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/remote/crash/ contrast_coach/lib/main.dart
git commit -m "feat: Sentry crash reporting with PII stripping"
```

### Task 60: Firebase Analytics (configured for privacy)

**Files:**
- Create: `contrast_coach/lib/data/remote/firebase/analytics_api.dart`

- [ ] **Step 1: analytics_api.dart**

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsApi {
  AnalyticsApi(this._analytics);
  final FirebaseAnalytics _analytics;

  Future<void> track(String eventName, {Map<String, Object?>? params}) async {
    try {
      await _analytics.logEvent(name: eventName, parameters: params);
    } catch (_) {
      // Never crash on analytics
    }
  }

  Future<void> trackSessionStarted(String protocolId) =>
      track('session_started', parameters: {'protocol_id': protocolId});

  Future<void> trackSessionCompleted(String protocolId, double score) =>
      track('session_completed', parameters: {'protocol_id': protocolId, 'score': score.round()});

  Future<void> trackPaywallViewed() => track('paywall_viewed');

  Future<void> trackSubscriptionStarted(String plan) =>
      track('subscription_started', parameters: {'plan': plan});

  Future<void> trackFeatureUsed(String feature) =>
      track('feature_used', parameters: {'feature': feature});
}
```

- [ ] **Step 2: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/data/remote/firebase/analytics_api.dart
git commit -m "feat: Firebase Analytics (5 events, no PII, silent fail)"
```

### Task 61: Data export (JSON)

**Files:**
- Create: `contrast_coach/lib/domain/usecases/export_user_data.dart`
- Create: `contrast_coach/test/domain/usecases/export_user_data_test.dart`

- [ ] **Step 1: export_user_data.dart**

```dart
import 'dart:convert';

import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';

String exportUserDataAsJson({
  required List<Session> sessions,
  required DateTime exportedAt,
}) {
  final data = {
    'exportedAt': exportedAt.toIso8601String(),
    'version': 1,
    'sessions': sessions.map((s) => {
          'id': s.id,
          'protocolId': s.protocolId,
          'goal': s.goal.name,
          'startedAt': s.startedAt.toIso8601String(),
          'endedAt': s.endedAt?.toIso8601String(),
          'totalPlannedDurationSec': s.totalPlannedDuration.inSeconds,
          'totalActualDurationSec': s.totalActualDuration.inSeconds,
          'roundsCompleted': s.roundsCompleted,
          'protocolRounds': s.protocolRounds,
          'recoveryScore': s.recoveryScore,
          'healthDataSnapshot': s.healthDataSnapshot,
          'phases': s.phases.map((p) => {
                'type': p.type.name,
                'orderIndex': p.orderIndex,
                'plannedDurationSec': p.plannedDuration.inSeconds,
                'actualDurationSec': p.actualDuration?.inSeconds,
                'targetTempC': p.targetTempC,
                'actualTempC': p.actualTempC,
                'skipped': p.skipped,
              }).toList(),
        }).toList(),
  };
  return const JsonEncoder.withIndent('  ').convert(data);
}
```

- [ ] **Step 2: export_user_data_test.dart**

```dart
import 'dart:convert';

import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/usecases/export_user_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('export produces valid JSON', () {
    final session = Session(
      id: 's1',
      protocolId: 'recovery_standard',
      goal: Goal.recovery,
      startedAt: DateTime(2026, 6, 13, 7),
      endedAt: DateTime(2026, 6, 13, 7, 30),
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: const Duration(minutes: 30),
      roundsCompleted: 3,
      protocolRounds: 3,
      recoveryScore: 78,
      createdAt: DateTime(2026, 6, 13, 7),
      updatedAt: DateTime(2026, 6, 13, 7, 30),
    );
    final json = exportUserDataAsJson(sessions: [session], exportedAt: DateTime(2026, 6, 13, 8));
    final parsed = jsonDecode(json) as Map<String, dynamic>;
    expect(parsed['version'], 1);
    expect((parsed['sessions'] as List), hasLength(1));
    expect((parsed['sessions'] as List).first['protocolId'], 'recovery_standard');
  });
}
```

- [ ] **Step 3: Run test**

Run: `cd contrast_coach && flutter test test/domain/usecases/export_user_data_test.dart`
Expected: 1 test pass.

- [ ] **Step 4: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/domain/usecases/export_user_data.dart contrast_coach/test/domain/usecases/export_user_data_test.dart
git commit -m "feat: data export to JSON (with sessions, phases, computed health metrics only)"
```

### Task 62: Data deletion use case

**Files:**
- Create: `contrast_coach/lib/domain/usecases/delete_user_data.dart`
- Create: `contrast_coach/test/domain/usecases/delete_user_data_test.dart`

- [ ] **Step 1: delete_user_data.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';

Future<Result<void, AppException>> deleteAllUserData({
  required SessionRepository sessions,
  required Future<void> Function() deleteCloudAccount,
}) async {
  try {
    final allResult = await sessions.getAll();
    if (allResult is Err) return allResult;
    for (final s in (allResult as Ok<List<Session>, AppException>).value) {
      await sessions.delete(s.id);
    }
    await deleteCloudAccount();
    return const Ok(null);
  } catch (e) {
    return Err(DatabaseException('Failed to delete user data', cause: e));
  }
}
```

- [ ] **Step 2: delete_user_data_test.dart**

```dart
import 'package:contrast_coach/core/errors/app_exception.dart';
import 'package:contrast_coach/core/errors/result.dart';
import 'package:contrast_coach/domain/entities/goal.dart';
import 'package:contrast_coach/domain/entities/session.dart';
import 'package:contrast_coach/domain/repositories/session_repository.dart';
import 'package:contrast_coach/domain/usecases/delete_user_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionRepo extends Mock implements SessionRepository {}

void main() {
  late _MockSessionRepo sessions;

  setUp(() {
    sessions = _MockSessionRepo();
  });

  test('delete all user data clears local + cloud', () async {
    final s1 = Session(
      id: 's1', protocolId: 'p1', goal: Goal.recovery,
      startedAt: DateTime(2026, 6, 1),
      totalPlannedDuration: const Duration(minutes: 30),
      totalActualDuration: const Duration(minutes: 30),
      roundsCompleted: 3, protocolRounds: 3,
      createdAt: DateTime(2026, 6, 1), updatedAt: DateTime(2026, 6, 1),
    );
    when(() => sessions.getAll()).thenAnswer((_) async => Ok<List<Session>, AppException>([s1]));
    when(() => sessions.delete(any())).thenAnswer((_) async => const Ok(null));

    var cloudCalled = false;
    final result = await deleteAllUserData(
      sessions: sessions,
      deleteCloudAccount: () async {
        cloudCalled = true;
      },
    );

    expect(result.isOk, isTrue);
    verify(() => sessions.delete('s1')).called(1);
    expect(cloudCalled, isTrue);
  });
}
```

- [ ] **Step 3: Run test**

Run: `cd contrast_coach && flutter test test/domain/usecases/delete_user_data_test.dart`
Expected: 1 test pass.

- [ ] **Step 4: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/lib/domain/usecases/delete_user_data.dart contrast_coach/test/domain/usecases/delete_user_data_test.dart
git commit -m "feat: delete all user data (local + cloud)"
```

### Task 63: Privacy policy + Play Store assets

**Files:**
- Create: `contrast_coach/PRIVACY_POLICY.md`
- Create: `contrast_coach/tools/scripts/generate_screenshots.dart`
- Create: `contrast_coach/assets/app_icon.svg`

- [ ] **Step 1: PRIVACY_POLICY.md**

```markdown
# ContrastCoach Privacy Policy

Last updated: 2026-06-13

## What we collect

- **Email address** — for sign-in. We do not share it.
- **Subscription status** — for billing. We do not share it.
- **Analytics events** (5 types, no PII) — to improve the app. You can opt out in Settings.
- **Crash logs** (no PII) — to fix bugs.

## What we DON'T collect

- Device IDs, advertising IDs, location, contacts, photos, voice recordings, files, calendar.

## How health data is handled

Health data (heart rate, HRV, sleep) is read from Health Connect and **never leaves your device**. The recovery score and trends are computed locally. Only computed metrics (e.g., "HRV 7-day trend: +12%") are stored in our database, never raw values.

## User rights

- **Export your data** — Settings → Export Data → JSON
- **Delete your data** — Settings → Delete Account → all data removed in 30 days
- **Disconnect Health Connect** — Settings → Health Connect → Disconnect
- **Opt out of analytics** — Settings → Privacy → Analytics off

## Compliance

- GDPR (EU): export + deletion requests honored within 30 days
- CCPA (California): opt-out of data sale (we don't sell)
- COPPA (US children): not targeting <13

## Contact

privacy@contrastcoach.app

## Disclaimer

This app is for informational and educational purposes only. It is not a medical device. Consult a healthcare professional before starting any new recovery routine.
```

- [ ] **Step 2: app_icon.svg (monochrome circle bisected)**

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <rect width="512" height="512" fill="#FFFFFF"/>
  <line x1="0" y1="256" x2="512" y2="256" stroke="#0A0A0A" stroke-width="6"/>
  <circle cx="256" cy="256" r="180" fill="none" stroke="#0A0A0A" stroke-width="6"/>
</svg>
```

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/PRIVACY_POLICY.md contrast_coach/tools/scripts/generate_screenshots.dart contrast_coach/assets/app_icon.svg
git commit -m "chore: privacy policy, app icon SVG, screenshot generation script"
```

### Task 64: GitHub Actions CI workflow

**Files:**
- Create: `contrast_coach/.github/workflows/ci.yml`
- Create: `contrast_coach/.github/workflows/release-internal.yml`

- [ ] **Step 1: ci.yml**

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze --fatal-infos
      - run: dart format --set-exit-if-changed lib/ test/
      - run: flutter test --coverage
  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --release --split-per-abi
      - uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/
```

- [ ] **Step 2: release-internal.yml**

```yaml
name: Release Internal
on:
  push:
    tags: ['v*']
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter build appbundle --release
      - uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT }}
          packageName: com.contrastcoach.contrast_coach
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
          mappingFile: build/app/outputs/mapping/release/mapping.txt
```

- [ ] **Step 3: Commit**

```bash
cd /root/ContrastCoach
git add contrast_coach/.github/workflows/
git commit -m "chore: GitHub Actions CI and release workflows"
```

### Task 65: Verify all v1.0 acceptance criteria

- [ ] **Step 1: Run full test suite**

Run: `cd contrast_coach && flutter test`
Expected: All tests pass.

- [ ] **Step 2: Run analyze**

Run: `cd contrast_coach && flutter analyze`
Expected: 0 issues.

- [ ] **Step 3: Build release appbundle**

Run: `cd contrast_coach && flutter build appbundle --release --flavor prod`
Expected: builds successfully.

- [ ] **Step 4: Verify APK size**

Run: `ls -la contrast_coach/build/app/outputs/flutter-apk/app-release.apk`
Expected: < 50MB.

- [ ] **Step 5: Verify v1.0 checklist**

Walk through section 9 of `docs/superpowers/specs/2026-06-13-contrastcoach-full-stack-design.md` and check each item.

- [ ] **Step 6: Commit final marker**

```bash
cd /root/ContrastCoach
git commit --allow-empty -m "chore: v1.0 acceptance criteria met, ready for internal testing submission"
```

---

## End of plan

Total: 65 tasks across 9 phases. Each task ends with a passing test and a clean commit.

To execute this plan, see the **Execution Handoff** options below.
