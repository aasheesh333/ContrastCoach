# Architecture

ContrastCoach uses a clean 3-layer architecture with offline-first design.

## High-level

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

## Folder structure

See `CONTRASTCOACH_MASTER_PLAN.md` section 2.3 for the complete folder structure.

## Key design decisions

1. **Riverpod over Bloc/Provider** — type-safe, no codegen errors, easier to vibe-code
2. **Drift over Isar/Hive-only** — type-safe SQL, easier migrations, exports to JSON cleanly
3. **Supabase over Firebase** — no vendor lock-in, open source, generous free tier, GDPR-friendly
4. **Health Connect READ-only** — minimum permissions, clear user benefit
5. **SQLCipher encryption** — health data at rest is encrypted with key in secure storage
6. **Last-write-wins sync** — simpler than CRDT, sufficient for solo-user apps

## Data flow

1. User starts session → `SessionController` updates UI immediately
2. Session data writes to local Drift DB
3. Background worker syncs to Supabase when online
4. Health Connect data is read on-demand, never auto-synced
5. Recovery score computed on-device from local data

## Privacy architecture

- All health data stays on-device
- Cloud sync only contains computed metrics, not raw values
- User can export all data (JSON) and delete all data (one tap)
- No device IDs, no advertising IDs, no cross-app tracking
- Umami analytics (self-hosted) tracks 5 events, no PII

See `docs/PRIVACY.md` for the full privacy architecture.
