# ContrastCoach App — Project Memory

> **User-stated creative task (do not do):** Play Store listing — screenshots, feature graphic, store description, Data Safety form, Health Apps Declaration submission. The user is doing this themselves.

---

## What is done (this session + earlier)

### Code shipped this session
| Area | Files |
|------|-------|
| **RevenueCat** | `lib/domain/entities/subscription_tier.dart`, `lib/domain/repositories/subscription_repository.dart`, `lib/data/remote/subscription/revenue_cat_client.dart`, `lib/data/repositories/subscription_repository.dart` |
| **Feature gating** | `lib/core/feature_gating.dart` (6 flags: all protocols, HC, voice, sync, insights, custom) + 3 tests |
| **Paywall wired** | `lib/presentation/screens/paywall/paywall_screen.dart` (loads offerings, purchase, restore) |
| **Insights generator** | `lib/domain/entities/insight.dart`, `lib/domain/usecases/generate_insights.dart` (5-7 deterministic insights) + 3 tests |
| **Custom protocols** | `lib/domain/usecases/validate_custom_protocol.dart`, `lib/data/repositories/custom_protocol_repository.dart`, `lib/presentation/screens/custom_protocol/custom_protocol_builder_screen.dart` + 2 tests |
| **Screens wired to real data** | Home, Streak, Insights, Summary, DataExport, DeleteAccount, HealthConnect — all load from Drift |
| **ActiveSessionScreen** | Real protocol loading, ticker-based countdown, voice control, saves session with recovery score |
| **HeroStartCard** | 2x2 goal grid (Refresh/Focus/Sleep/Immunity) + custom protocol button |
| **Notifications** | 5 types: streak, optimal timing, sleep insight, subscription renewal, HC revoked |
| **Workmanager** | `lib/data/background/sync_worker.dart` — 15-min periodic sync |
| **Sentry** | `lib/data/remote/crash/sentry_client.dart` + wired in main.dart |
| **Deep links** | `contrastcoach://*` and `https://contrastcoach.app/*` in AndroidManifest |
| **Custom protocol builder UI** | Full screen with phase editor (type chips, duration slider, temp slider, add/remove phases) |
| **protocols.json** | 6 protocols tagged `isPro: true`, 3 free, custom |
| **README + Privacy policy** | Real content, not boilerplate |

### Code shipped in earlier sessions
- Phase 1-6: Foundation, domain, screens, voice, audio, auth, sync, Health Connect
- 103 unit/widget tests passing

---

## What is INCOMPLETE per master plan

### Critical (blocks app from working in production)

| Task | Plan ref | Status | File |
|------|----------|--------|------|
| **Audio assets** | T5 | ❌ Missing — `assets/audio/` directory does not exist. `AudioCueService` references `.ogg` files that aren't there. App will fail silently in production. | Create `assets/audio/{session_start,phase_transition,session_complete}.ogg` |
| **Health Connect manifest entries** | T51 | ❌ Missing — AndroidManifest needs `<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>` and Health Connect intent filter for permission resolution activity | `android/app/src/main/AndroidManifest.xml` |
| **Firebase real config** | T43 | ⚠️ Placeholders only — `firebaseConfig.dart` returns placeholder apiKey/appId. App will boot but auth/sync will fail | Need `google-services.json` or `flutterfire configure` |
| **Analytics API not called** | T60 | ⚠️ `AnalyticsApi` class exists but no screen calls `trackSessionStarted/Completed/PaywallViewed/SubscriptionStarted` | Wire calls in `active_session_screen`, `paywall_screen`, `subscription_repository` |
| **Google Sign-In** | Plan section 3 | ❌ No `google_sign_in` integration in sign-in screen | `lib/presentation/screens/auth/sign_in_screen.dart` |
| **Restore purchases on cold start** | Plan section 8 | ⚠️ `restore()` exists on repo, never called automatically at app start | Call in `main.dart` after `RevenueCatBootstrap.init` |
| **Paywall gate on Home** | Plan section 8 | ❌ No gate — HomeScreen never checks if user is Pro before showing Pro features | Add `FeatureGating` checks |
| **Streak / Insights / Custom protocol — Pro gates** | Plan section 8.2 | ❌ Free user can see Pro streak calendar, Pro insights, build custom protocol | Add gating logic |
| **Health Connect permission flow** | Plan T49 | ⚠️ `health_connect_screen.dart` has "Connect" button but never calls `requestPermissions()` then `readSnapshot()` | Wire to call client |
| **Sentry beforeSend strips PII** | T59 | ⚠️ `beforeSend` is empty — no PII stripping. Plan says strip user, health tags | Add PII stripping |
| **Sentry beforeBreadcrumb** | T59 | ❌ Plan says "drop voice breadcrumbs" — not implemented | Add |
| **Workmanager workmanager.dart dependency missing from pubspec** | T41 | ⚠️ Plan requires `workmanager` — pubspec has it. ✓ Actually checked: it's in pubspec. OK. | (Done) |
| **Voice "Hey Coach" wake word** | Plan section 3.4 | ❌ Master plan calls for wake-word listening. We only do push-to-listen. | Would need additional package — likely skip, mark as not implemented |
| **`safeArea` 88dp voice button fallback** | Plan section 3.4 | ❌ ActiveSessionScreen shows voice prompt text but no 88dp manual button. | Add manual control buttons |
| **Integration tests** | Plan section 5 | ❌ Only unit/widget tests. Plan calls for Patrol integration tests for core flows. | `integration_test/` |
| **Audio assets themselves** | T5 | ❌ Plan calls for 3 audio files | Generate or source |
| **Voice response audio** | Plan section 3.4 | ❌ TTS confirmation when voice command recognized. | Add TTS |
| **Background sync via workmanager** | T41-42 | ⚠️ `syncCallback` defined but never registered in `main.dart` via `Workmanager().initialize(syncCallback, ...)` | Wire init in main |
| **Hydrated session start button** | Plan T29 | ❌ Home should show last protocol + quick resume, not just 2x2 grid | Enhance HomeScreen |
| **Auth sign-in with email/password** | Plan section 3 | ⚠️ `sign_in_screen.dart` exists, content not checked — may be stub | Verify |
| **Restore purchases call** | Plan section 8 | ❌ Never called on app start | Add to main.dart |
| **Health Connect revoke detection** | Plan section 3.5 | ❌ Plan requires detecting when user revokes HC permissions in Android settings | Subscribe to `HealthConnectClient.permissionsRevokedStream` |
| **Account deletion cancels sync** | Plan section 6 | ⚠️ `deleteAllUserData` calls `deleteCloudAccount` — need to verify this includes Firestore cleanup | Verify |
| **HC rate-limit detection** | Plan section 3.5 | ❌ No retry/backoff logic if HC throttles | Add |
| **Migrations** | Plan section 2.4 | ⚠️ Drift `migration` callback has empty `onUpgrade`. Plan says "Future migrations here" — OK for v1.0 but document | Document |
| **App icon adaptive background** | T63 | ❌ `app_icon.svg` exists but not converted to PNG mipmaps. Android still uses default Flutter icon. | Convert SVG → mipmaps |
| **Notification channels registered at startup** | T41 | ❌ Plan says channels registered on init. We have them inline per call. | Refactor: register once in `init()` |

### Lower priority
- No iOS scheme (intentional — Android first per plan)
- No Wear OS, no B2B features (intentional — v2+ per plan)
- No AI insights (intentional — algorithmic only per plan)

### What user is doing themselves (DO NOT TOUCH)
- **Play Store listing** — screenshots, feature graphic, store description, app icon variants
- **Data Safety form** (Play Console)
- **Health Apps Declaration** (Play Console)
- **App Store submission**
- **Marketing** — Reddit, YouTube, Twitter, Discord, Product Hunt, Hacker News

---

## Plan phase/task status

| Phase | Tasks | Status |
|-------|-------|--------|
| **Phase 1: Foundation** | 1-15 | Mostly done. T1 (toolchain) skipped by user. T5 audio assets missing. |
| **Phase 2: Domain** | 16-25 | ✅ Done |
| **Phase 3: State machine + screens** | 26-37 | ✅ Done |
| **Phase 4: Voice + audio + streak** | 38-42 | ⚠️ Audio assets missing. Manual voice button missing. TTS missing. |
| **Phase 5: Auth + Firestore sync** | 43-48 | ⚠️ Firebase config is placeholder. Auth sign-in not verified. Sync works. |
| **Phase 6: Health Connect** | 49-52 | ⚠️ Manifest entries missing. Permission flow not fully wired. |
| **Phase 7: Subscription** | 53-55 | ✅ Done |
| **Phase 8: Insights + Custom** | 56-58 | ✅ Done |
| **Phase 9: Polish + Play Store** | 59-65 | ⚠️ Sentry PII strip missing. Analytics not wired. Store assets skipped (user task). Integration tests missing. App icon not converted. |

---

## Architecture summary

3-layer Flutter app:
- `lib/domain/` — pure Dart entities, abstract repos, use cases (no Flutter or third-party deps)
- `lib/data/` — Drift database, Firebase, HC, RevenueCat, Sentry, audio, voice, notifications, workmanager
- `lib/presentation/` — Flutter widgets, screens, go_router, theme

Stack: Flutter 3.24+, Dart 3.5+, Riverpod 2.6, Drift 2.20 + SQLCipher, Firebase Auth + Firestore + Analytics, Health Connect, RevenueCat 8.2, Sentry 8.9, workmanager 0.5, speech_to_text 7.4, just_audio 0.9, flutter_local_notifications 17.2.

103 tests passing. No compile errors (only info-level lints).

---

## Files that exist
(Abbreviated — full list at `contrast_coach/lib/`)

**Domain:** session, phase, protocol, goal, phase_template, phase_type, voice_command, recovery_score, score_band, score_factor, insight, subscription_tier, session_state, session_state_machine. Repos: auth, session, protocol, health, subscription. Use cases: start_session, end_session, export_user_data, delete_user_data, generate_insights, validate_custom_protocol.

**Data:** Local: app_database (Drift), 6 tables (sessions, phases, streaks, settings, health_snapshots, custom_protocols), sqlcipher_key_provider, health_connect_client. Repos: auth, session, protocol, custom_protocol, subscription. Remote: firebase_config, firestore_api, analytics_api, crash/sentry_client, subscription/revenue_cat_client. Services: audio_cue_service, speech_to_text_client, notification_service (5 types), background/sync_worker.

**Presentation:** Routing: app_router, route_names. Atomic widgets: app_button, app_card, app_chip, app_divider, app_icon, app_slider, app_switch, app_text_field. Composite: hero_start_card (2x2 goal grid), insight_block, progress_bar, quick_stats_row, recovery_score, session_timer, streak_calendar. Layout: app_bar, bottom_nav, sheet_container. Dialogs: medical_disclaimer_dialog. Screens: onboarding, home, active_session, session_summary, streak_calendar, insights, settings (5 sub-screens), auth (sign-in, sign-up), health_rationale, voice_rationale, paywall, custom_protocol_builder, shell (home_shell).

**Tests:** 103 tests across core/utils, core/feature_gating, core/env, core/theme, data/repositories, data/local/database, data/local/encryption, data/notifications, domain/entities, domain/usecases, domain/voice, presentation/routing, presentation/widgets.

---

## Next session priorities (in order)
1. **Add Health Connect manifest entries** (T51) — 5 min fix
2. **Wire `AnalyticsApi` calls** in ActiveSessionScreen + Paywall + SubscriptionRepo (T60) — 15 min
3. **Add Sentry PII stripping** (T59) — 5 min
4. **Wire `HealthConnectClient.requestPermissions` + `readSnapshot` in HC screen** — 10 min
5. **Add manual control buttons (88dp) in ActiveSessionScreen** (plan 3.4) — 15 min
6. **Add Pro feature gating in HomeScreen, Streak, Insights, Custom builder** (plan 8.2) — 20 min
7. **Generate or source 3 audio files** (T5) — depends on user
8. **Call `restorePurchases()` on app start** (plan 8) — 5 min
9. **Convert `app_icon.svg` to mipmaps** (T63) — 5 min
10. **Register notification channels on init** (T41) — 5 min
11. **Add `Workmanager().initialize(syncCallback, ...)` in main.dart** — 5 min
12. **Verify `sign_in_screen.dart` actually signs in via Firebase** — 5 min
13. **Add `google_sign_in` integration if missing** — 20 min

Then build APK + verify.

---

## What user does NOT want me to do
- Play Store listing (screenshots, store description, feature graphic, app icon variants, store submission)
- Data Safety form (Play Console)
- Health Apps Declaration (Play Console)
- Marketing channels
