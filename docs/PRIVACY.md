# Privacy

## Core principle

**All health data stays on your device.** Period.

## What we collect

| Data | Where | Why | User control |
|---|---|---|---|
| Email | Supabase | Account | Delete account |
| App events (5 types) | Umami (self-hosted) | Improve app | Opt-out in Settings |
| Crash logs | Sentry (self-hostable) | Fix bugs | Cannot opt-out, but no PII |
| Health data | Device only (Drift + SQLCipher) | Recovery score | Disconnect Health Connect |
| Purchase history | RevenueCat | Subscription | Delete account |

## What we DON'T collect

- Device IDs
- Advertising IDs
- Location
- Contacts
- Photos
- Voice recordings (processed, not stored)
- Cross-app tracking

## Third parties

We use:
- **Supabase** (auth + sync) — open source, GDPR-friendly, server in your chosen region
- **RevenueCat** (subscription) — required for Play Store subscriptions
- **Sentry** (crash) — self-hostable, can be removed
- **Umami** (analytics) — self-hosted, no cookies, no PII

No data is sold. No data is shared for advertising. No data is used for user profiling.

## User rights

- **Export:** Settings → Export Data → JSON file
- **Delete:** Settings → Delete Account → all data gone in 30 days
- **Disconnect Health Connect:** Settings → Health Connect → Disconnect
- **Opt out of analytics:** Settings → Privacy → Analytics off

## Compliance

- **GDPR** (EU): export + deletion requests honored within 30 days
- **CCPA** (California): opt-out of data sale (we don't sell anyway)
- **COPPA** (US children): not targeting <13

## Encryption

- In transit: HTTPS/TLS 1.3
- At rest: Drift DB encrypted with SQLCipher, key in flutter_secure_storage
- Backups: Supabase encrypted at rest (provider-managed)

## Disclaimers

- App is not a medical device
- Health insights are for informational purposes only
- Consult a healthcare professional before starting any new recovery routine
