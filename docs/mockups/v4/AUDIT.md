# ContrastCoach v4 — Visual Gap Audit

**Date:** 2026-07-03
**Auditor:** opencode (explorer subagents × 3, in parallel)
**Mockup ground truth:** `docs/mockups/v4/index.html` (single HTML file with 29 views)
**Mockup screenshots:** `docs/mockups/v4/screenshots/01-splash.png` … `29-paywall.png` (344×740 each, rendered via chrome-devtools)
**Flutter source:** `contrast_coach/lib/presentation/screens/**/*_screen.dart` (28 screen files)
**Cluster reports:**
- `audit/cluster-a-boot-and-primary.md` (394 lines) — splash, signin, onboarding, home, explore, builder, insights, history, detail (9 screens)
- `audit/cluster-b-session-and-coach.md` (510 lines) — session, summary, share, coach, journal, achievements, challenges, referral, + breathwork (missing) (9 screens)
- `audit/cluster-c-profile-and-settings.md` (486 lines) — profile, editProfile, account, notif, appearance, health, widgets (missing), sub (missing), data, help (missing), paywall (11 screens)

**Method:** Each subagent read the screen's dart source + compared against the mockup HTML's CSS (the ground truth) + cross-checked via describe_image on the rendered mockup PNG where available (note: explore-type task agents may not have vision tool access — all hex/weight/radius figures were quoted directly from mockup HTML/CSS which is more authoritative than vision transcription anyway). Per-screen gaps cite both `filename:line` and `index.html:line` for every claim.

---

## Consolidated severity table

Sorted by severity, then by mockup view order. Severity = plot-faithful-criticality: HIGH = signature visual/structural element missing or wrong; MED = component exists but diverges on shape/color; LOW = minor variances.

| # | View | Flutter file | Sev | One-line biggest gap |
|---|---|---|---|---|
| 1 | `#splash` | `splash_screen.dart` | **HIGH** | Static Lucide flame + 1900ms Timer; missing 96×96 frosted logo tile, `pop cubic-bezier(.2,1.3,.4,1)` 700ms entry, 120×4 sliding loader, 3-stop gradient verified-by-describe_image (#FF6B35→#7A2AA8 58%→#2D7CF1) |
| 2 | `#signin` | `sign_in_screen.dart` | **HIGH** | No OAuth (Google/Apple) row, no `.divider` "OR", no `--bg` light bg (uses dark hero), no `--r-sm=14` radius on inputs |
| 3 | `#onboard` | `onboarding_screen.dart` | **HIGH** | Top-anchored illustration pager (`'HEAT.\nCOLD.\nREPEAT.'` 56px ls -1.5) instead of bottom-anchored bottom-up layout "Heat. / Cold. / Recover smarter." (33px ls -1px) + white-on-heat CTA + skip link |
| 4 | `#home` | `home_screen.dart` | **HIGH** | Missing the `linear-gradient(140deg,#12121a,#25252f)` dark hero with 100×100 SVG gauge, `.pill` (streak/avg), and heat/cold radial blobs (`+::before/+::after`) with `0 22px 42px -20px rgba(255,107,53,.55)` shadow |
| 5 | `#explore` | `explore_screen.dart` | **HIGH** | No filter chips row (5), no 30-day-program hero, no per-protocol `.ic` colored emoji tiles. Uses translucent 999-radius pill instead of the 7-radius heat→coral "PRO" lock badge |
| 6 | `#builder` | `custom_protocol_builder_screen.dart` | **MED** | See cluster-a report |
| 7 | `#insights` | `insights_screen.dart` | **HIGH** | No `.seg` segmented control (Week/Month/Year), no cold-gradient `.trend` + sparkline, no 14-col `.heat` grid (5 tints), no Best/sleep-corr cards, no sessions-per-week `.bars` |
| 8 | `#history` | `streak_calendar_screen.dart` | **HIGH** | Renders a "Streak" dashboard (48px heat streak) instead of the month calendar with `.done`/`.cold`/`.today` tints + recent-sessions rowlink list |
| 9 | `#detail` | `session_detail_screen.dart` | **HIGH** | Renders `_HeroCard` + 2×2 stat-grid + recoveryRow (32px score) instead of the 70px heat→cold gradient "82" with green strapline + 5-row `.card.list` + 6-cell `.bars` breakdown |
| 10 | `#session` | `active_session_screen.dart` + `session_timer.dart` | **HIGH** | Background uses 2-stop linear gradient; correct `AppGradients.sessionWarm/sessionCold` radials (radial-gradient 120% 80% at 50% 0%, #7a2a0e/#0d3a7a → #0c0c0e) are unused (`session_timer.dart:360-383`) |
| 11 | `#summary` | `session_summary_screen.dart` + `recovery_score.dart` | **HIGH** | Big score is 96px w200, mockup spec is 70px w800 with heat→cold text-clip gradient. "STRONG" label missing "RECOVERY" word. 4-row insight list-card replaced with 3 generic AppCard rows |
| 12 | `#share` | `share_card_screen.dart` + `share_card_painter.dart` | **HIGH** | "82" rendered flat-white 96px w800 instead of heat→cold2 (#FF6B35→#5B9CFF) gradient text-clip 60px w800. Card uses `heroDark` (#12121A→#25252F) instead of `linear-gradient(150deg, #12121a, #3a1e12)`. No Instagram/WhatsApp split buttons |
| 13 | `#coach` | `coach_screen.dart` | **HIGH** | Me bubble solid `AppColors.heat` instead of heat→coral linear-gradient. AI bubble has no 1px line border, no `bottom-left 5px` asymmetric corner, uses `surfaceContainerHigh` not card bg. No "Start recommended"/"Why?" chips below AI replies. Seed AI message content differs from v4 spec |
| 14 | `#journal` | `journal_screen.dart` | **MED** | Card close to spec (radius 20, missing 1px `line` border). Date/mood header format differs ("MM/DD 13px" + "Mood 13px" side-by-side vs spec "TODAY · 9:12 AM" 11px Ink3 w700). Missing the "🙌 Felt amazing" emoji+title row pattern. "+ New entry" is a FAB not a heat-gradient full-width `.btn` |
| 15 | `#achieve` | `achievements_screen.dart` | **HIGH** | Level 4 card entirely missing. 2-col grid (not 3). Locked badge uses `Theme.of(context).colorScheme.outline` text color swap instead of spec `opacity:.4; filter:grayscale(1)`. Badge emojis 36px left-aligned instead of 26px centered |
| 16 | `#community` | `challenges_screen.dart` | **MED** | Hero uses `AppGradients.splashBg` (3-stop heat→purple→cold) instead of `.hero` cold/dark with `0 20px 40px -18px rgba(45,124,241,.5)` cold-blue shadow. Leaderboard format diverges. "🔥 You" heat accent + "Invite friends →" cold-gradient `btn.cold` missing |
| 17 | `#referral` | `referral_screen.dart` | **HIGH** | Referral code: `CC-XXXX` hash format instead of literal `AASHEESH50` demo. JetBrains Mono 30px w800 ls 1.5 instead of spec 26px w500 ls 2 color `#FF6B35`. 1.5px solid heat border on Card instead of spec **2px DASHED** heat border radius 14 padding 14 — the dashed-border visual hook is missing. Header card uses `_HeroHeader` gradient strip instead of centered "🎁 / Give a month, get a month" layout |
| 18 | `#breath` | *(no Flutter file)* | **HIGH** | **Missing screen** — mockup `#breath`: deep-blue `linear-gradient(160deg, #0a2a5c, #0c0c0e)` bg, 170px breathing orb radial-gradient(40%/35%/60%, #8fc0ff/#2D7CF1/#1a4fa0) with 8s scale .65↔1 animation + 60px box-shadow rgba(45,124,241,.6), "INHALE/HOLD/EXHALE" 22px w800 ls 1, "BOX BREATHING" 13px w800 ls 3, Round 2 of 5 subtext |
| 19 | `#profile` "You" | `settings_screen.dart` (no dedicated profile screen) | **HIGH** | The avatar-bio-stats hub (88×88 gradient avatar, 17px name, 12px bio, 7/21/48 stats row, 11 emoji rowlinks, "Go Pro — 7-day free trial" CTA) doesn't exist — profile is collapsed into a Material Settings list |
| 20 | `#editProfile` | `edit_profile_screen.dart` | **HIGH** | 6 of 7 controls missing: no avatar emoji, no 5-emoji picker row, no bio textarea, no goal chips, no °C/°F segmented control, no weekly-session slider. Rename-only page |
| 21 | `#account` | *(no dedicated route)* | **HIGH** | Missing: Change password, Google-link status, Biometric-lock switch, Sign-out ghost2 button, red-gradient Delete-account button. Currently split across `SettingsScreen` + `delete_account_screen.dart` |
| 22 | `#notif` | *(inlined into SettingsScreen)* | **HIGH** | No dedicated Notifications screen. 6 `.set` rows (Daily reminder ON, Reminder time 7:00 AM, Streak at risk ON, Hydration OFF, Challenge updates ON, Product news OFF) + Active days Mon-Sun chip row collapsed to 5 inline toggles |
| 23 | `#appearance` | `appearance_screen.dart` | **HIGH** | Missing Dark mode + Match system `.set` rows. 5 round 36px swatches (heat, cold, purple, ok-green, pink #E5397D) shown as wrong shape (squares not circles) + wrong count. No text-size slider. Uses grid + segmented theme selector instead |
| 24 | `#health` | `health_connect_screen.dart` | **HIGH** | Big `❤️`-avatar card with "Smarter recovery score" h2 + Connect button replaced by a lucide-icon card row. **Permissions card with 3 ON switches (HRV / Sleep / Resting HR) entirely missing**. No privacy footnote ("🔒 Processed on-device · never uploaded.") |
| 25 | `#widgets` | *(no Flutter file)* | **HIGH** | **Missing screen** — 3 widget preview cards (warm streak gradient, dark recovery gradient, cold next-session gradient) + "Add to home screen" button not implemented anywhere |
| 26 | `#sub` | *(no Flutter file — replaced by /paywall push)* | **HIGH** | **Missing screen** — "Current plan · Free" card + 3 plans with yearly preselected + SAVE 50% badge + Start-trial + Restore-purchases not built |
| 27 | `#data` | `data_export_screen.dart` | **HIGH** | Single "Export (JSON only)" CTA replaces Cloud backup toggle (Pro-gated) + JSON/CSV/Clear-cache rowlinks + SQLCipher footer ("Local data is encrypted with SQLCipher.") |
| 28 | `#help` | `about_screen.dart` (mapped to "About") | **HIGH** | About is hero + privacy-policy. The 4 FAQ rowlinks (cold plunge / sauna / recovery score calc / subscription mgmt) + Contact support button + "v4.0 · Not a medical device" footnote missing |
| 29 | `#modal` Paywall | `paywall_screen.dart` | **HIGH** | Paywall is a **full-screen heat-gradient Scaffold** instead of a modal bottom sheet. Missing entirely: 28/28/44/44 sheet radius, `.grab` bar, slide-up animation, `🔥 CONTRASTCOACH PRO` `.pw-badge`, "See what actually works" h2, `.trust` row (50k+/4.9★/92%), `.save 50%` badge, 6 ✓ feature chips (replaced by 4 different items), `.reviews` carousel (2 cards, ★★★★★ gold #FFB020), `.links` row (Restore · Terms · Privacy · Maybe later) |

---

## Headline findings (top 10)

1. **4 mockup views have NO Flutter screen at all:** `#widgets`, `#sub` (Subscription), `#help`, `#breath` (Breathwork). Account (`#account`) and Notifications (`#notif`) have no dedicated route — they're partially inlined into `SettingsScreen`.

2. **The "You" profile hub doesn't exist as designed.** Flutter routes the bottom-nav "You" tab to `SettingsScreen` (a Material settings list). Mockup calls for an avatar-bio-stats hero card + 11 emoji rowlinks + Go-Pro CTA — none of which exist.

3. **Paywall is full-screen instead of a modal bottom sheet**, dropping the `.sheet` 28/28/44/44 radius, `.grab` bar, slide-up animation, `.trust` row (50k+/4.9★/92%), `.reviews` carousel (#FFB020 gold stars), and `.links` Restore/Terms/Privacy/Maybe-later footer.

4. **All signature gradient surfaces are wrong or missing:**
   - Session bg: 2-stop linear gradient instead of radial `radial-gradient(120% 80% at 50% 0%, #7a2a0e/#0d3a7a → #0c0c0e)` — even though the correct tokens exist as `AppGradients.sessionWarm`/`sessionCold` and are unused
   - Home hero: missing the radial blob overlays and the heat-tinted `0 22px 42px -20px rgba(255,107,53,.55)` box-shadow
   - Challenges hero: uses `AppGradients.splashBg` instead of `.hero` cold/dark with the cold-blue shadow override
   - Share card: uses `heroDark` instead of `linear-gradient(150deg, #12121a, #3a1e12)`
   - Referral code box: solid border instead of the signature **2px dashed** heat border

5. **All the big-recovery-score treatments use wrong typography.** Mockup calls for 70px w800 with `linear-gradient(120deg, heat, cold)` text-clip gradient (summary/detail) and 60px w800 with heat→cold2 gradient (share). Flutter renders 96px w200 flat-white (or 32px recoveryRow on detail), dropping the gradient text-clip entirely.

6. **Reusable atoms diverge from mockup CSS on every dimension:**
   - `AppSwitch`: stock Material `Switch` instead of custom 46×28 heat-pill `.sw` with `cubic-bezier(.3,1.4,.5,1)` thumb slide
   - `AppButton`: pill radius 999 + w600 vs mockup `.btn` radius 14 / w800 / heat shadow `0 14px 26px -12px var(--heat)`
   - `ContrastAppBar`: 20px w700 vs `.appbar h2` 19px w800 ls -.4
   - `SheetContainer`: top-28-only radius instead of the mandatory asymmetric `28 28 44 44`
   - Cards: `surfaceContainerHigh` bg, no 1px `line` border, missing specifically-tinted box-shadows per context

7. **Segmented controls / chips / pills / badges are inconsistent or absent:** Insights uses `AppChip`s instead of `.seg` Week/Month/Year; Explore filter chips absent; protocol `.lock` "PRO" badge replaced with generic pill; onboarding dots row absent; achievements 3-col badge grid wrong (uses 2-col).

8. **The breathing screen is a critical missing flow.** Mockup has a deep-blue breathing modal with a pulsing orb and INHALE/HOLD/EXHALE cycle text. Flutter breathes (if it does) inside the session flow — no dedicated Breathwork screen exists.

9. **Coach chat diverges on every dimension** (bubble gradients, borders, asymmetric corners, text size/weight/line-height, missing trailing chip row, missing seed HRV message).

10. **Edit Profile is rename-only** — 6 of 7 spec'd controls (avatar emoji picker, bio, goal chips, °C/°F segment, weekly-session slider) are missing.

---

## Recommended fix priority (waves)

**Wave 0 — Foundations (must do first)**
- Audit / extend `AppColors`, `AppGradients`, `AppTypography` to ensure every mockup token is present and named.
- Add a custom `AppSwitch` widget matching `.sw` (46×28 heat pill, cubic-bezier thumb slide).
- Refactor `AppButton` to match `.btn` (radius 14, w800, heat shadow `0 14px 26px -12px var(--heat)`); add `.btn.cold` and `.btn.ghost2` variants.
- Add `SheetContainer` with `28 28 44 44` asymmetric radius + grab bar + slide-up animation.
- Add the `.seg` SegmentedControl widget, `.chip` filter chip, `.pill` hero-pill, `.lock` Pro-badge, `.refcode` dashed-border code, `.dot` pulse mic-indicator, `.orb` breathing orb animation as reusable atoms.

**Wave 1 — Boot + Onboarding (high user-facing impact, low complexity)**
- Splash: 3-stop gradient (verify via describe_image of mockup screenshot), frosted logo tile, pop animation, sliding loader.
- Sign in: OAuth Google/Apple rows + `.divider` OR + light `--bg` background.
- Onboarding: bottom-anchored 3-line headline "Heat. / Cold. / Recover smarter." (33px ls -1px), white-on-heat CTA, skip link.

**Wave 2 — Primary tabs (most-trafficked)**
- Home: dark hero card with 100×100 SVG gauge, radial blobs, streak/avg pills, heat-tinted shadow.
- Explore: 5 filter chips row, 30-Day program hero (cold-blue shadow), 6-card protocol grid with per-protocol colored icon tiles + `.lock` PRO badges.
- Insights: `.seg` Week/Month/Year, cold-gradient `.trend` + sparkline, 14-col `.heat` grid (5 tints), 2-card Best-protocol/Sleep-corr row, `.bars` sessions-per-week.

**Wave 3 — Session flow + sharing**
- Session: switch to `AppGradients.sessionWarm`/`sessionCold` radials; verify timer typography (JetBrains Mono w200 56px ls -2, "ROUND 2 / 3" 11px ls 1 opacity .7).
- Summary: 70px w800 heat→cold gradient-clipped score, "STRONG RECOVERY" label, 4-row list-card with the exact 4 items in mockup.
- Share card: rework `ShareCardPainter` — 60px w800 heat→cold2 gradient text-clip, `linear-gradient(150deg, #12121a, #3a1e12)` card bg, Instagram + WhatsApp split buttons.

**Wave 4 — Profile + Settings restructure**
- Build the dedicated Profile ("You") hub screen (avatar-bio-stats card + 11 rowlinks + Go-Pro CTA). Move non-rows to Settings sub-pages.
- Build Edit Profile with all 7 controls.
- Build Notifications screen (6 `.set` rows + Active days chips).
- Build Account & Security screen (3 rowlinks + biometric + Sign out + red Delete).
- Rework Appearance (Dark mode + Match system rows, 5 round swatches in spec colors, text-size slider).
- Rework Health Connect (big ❤️ card + permissions card with 3 ON switches + footnote).
- Build Subscription screen (current plan + 3 plans + yearly preselected + SAVE 50% badge).
- Build Data & Backup (Cloud backup Pro toggle + JSON/CSV/Clear-cache rowlinks + SQLCipher footer).
- Build Help & Support (4 FAQ rowlinks + Contact support + version footnote).

**Wave 5 — Modal/Specialty screens**
- Paywall: convert from full-screen Scaffold to modal bottom sheet (28 28 44 44 radius, .grab bar, slide-up animation). Add `pw-badge`, big headline, `.trust` row, 3 plan cards (incl. `.save 50%` badge), 6 ✓ feature chips, `.reviews` carousel (2 cards, ★★★★★ in #FFB020 gold), `.links` footer.
- Breathwork: build from scratch — deep-blue gradient, 170px breathing orb (radial 40%/35%/60% with 8s scale animation), INHALE/HOLD/EXHALE cycle text.
- Achievements: add Level/XP card (Frostwalker, 720 XP, 72% XP bar), switch to 3-col badge grid, locked badges `opacity:.4 filter:grayscale(1)`.
- Challenges: replace `splashBg` hero with `.hero` cold/dark + cold-blue shadow; build "❄️ Cold Streak Challenge" hero + leaderboard with "🔥 You" heat accent + cold-gradient "Invite friends →" button.
- Referral: build the centered 🎁 card, literal `AASHEESH50`-format code in **2px dashed** heat border.
- History: replace Streak dashboard with the month calendar (`calh` M T W T F S S header + `.cal` 7-col grid with `.done`/`.cold`/`.today` tints) + recent-sessions `.rowlink` list.
- Session detail: replace `_HeroCard` + 2×2 grid + recoveryRow with 70px gradient-clipped score + green strapline + 5-row `.card.list` + 6-cell `.bars` phase breakdown.

---

## Verification after each wave

Per the user constraint: do NOT analyze/test/build locally. Each wave pushes to CI; CI green = wave accepted. The two bookmarks:
- `flutter analyze` clean
- `flutter test` green (existing tests + new smoke tests for new screens)

After waves 0-5, re-render Flutter screens (via the approach we'll agree on for capturing actual Flutter device screenshots — likely a new CI job that uploads integration-test PNGs as artifacts) and re-run `describe_image` against the freshly-rendered Flutter vs mockup PNGs to verify pixel-faithfulness.
