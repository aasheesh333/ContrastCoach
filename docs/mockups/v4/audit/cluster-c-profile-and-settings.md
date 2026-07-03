# Cluster C Audit — Profile + Settings + Paywall

Mockup ground truth: `/home/ubuntu/ContrastCoach/docs/mockups/v4/index.html` (`:root` CSS tokens + view HTML markup lines 419-556). Screenshots under `/home/ubuntu/ContrastCoach/docs/mockups/v4/screenshots/19-29.png` were inspected for cross-check.

> Image-description tooling (`describe_image_describe_image`) was not exposed in this audit run; the audit relies on the authoritative HTML/CSS source per the task spec: *"HTML mockup is ground truth; describe_image is supplementary."* Screen-by-screen gaps below are derived from comparing exact CSS values to the corresponding Dart source.

---

## Summary table

| # | Mockup view | Flutter file | Severity | One-line biggest gap |
|---|---|---|---|---|
| 1 | `#profile` "You" | `settings/settings_screen.dart` (no dedicated `profile_screen.dart`) | **HIGH** | Profile row of 11 emoji rowlinks (Achievements…Help) does **not exist** — profile is collapsed into a flat settings list without avatar gradient circle, bio, stats trio, or Go-Pro button. |
| 2 | `#editProfile` | `profile/edit_profile_screen.dart` | **HIGH** | Avatar emoji + 5-emoji picker, bio textarea, goal chips, temp unit segmented control, and weekly-session slider are **all missing** — only a display-name input + email label + Save. |
| 3 | `#account` Account & security | (none — partial coverage in settings/privacy/delete screens) | **HIGH** | No `/account` route; Change password, Google-link + Biometric-lock switch absent; Sign out is split into SettingsScreen, Delete is on its own screen with wrong button style. |
| 4 | `#notif` Notifications | (none — inlined into `settings_screen.dart` `_NotifToggle` rows) | **HIGH** | No dedicated Notifications screen; 6 `.set` rows + Active days chip row collapsed to 5 inline toggles under the Notifications switch (no Reminder time sub-row, no Active days Mon–Sun chips, no Daily reminder/Hydration/Product news rows). |
| 5 | `#appearance` Appearance | `settings/appearance_screen.dart` | **HIGH** | Structure differs: mockup shows Dark mode + Match system `.set` rows, 5 round 36px swatches, text-size slider; Flutter shows accent grid + segmented theme selector, no Dark/Match-system toggle rows, no text-size slider, wrong swatch count/colors/shape (squares not circles). |
| 6 | `#health` Health Connect | `settings/health_connect_screen.dart` | **HIGH** | Big ❤️-avatar card with "Smarter recovery score" h2 + Connect button is replaced by a lucide-icon card row; the **Permissions card with 3 ON switches (HRV / Sleep / Resting HR) is entirely missing**; no privacy footnote. |
| 7 | `#widgets` Home-screen widgets | (none) | **HIGH** | No `widgets` route or screen exists; the 3 widget preview cards (warm streak / dark recovery / cold next-session) + "Add to home screen" button are **not implemented anywhere**. |
| 8 | `#sub` Subscription | (none — replaced by `/paywall` push) | **HIGH** | No dedicated Subscription screen with "Current plan · Free" card + 3 plans + Start-trial + Restore-purchases; settings row "Manage subscription" jumps straight to `/paywall` instead. |
| 9 | `#data` Data & backup | `settings/data_export_screen.dart` | **HIGH** | Single "Export (JSON only)" CTA replaces Cloud backup toggle + JSON/CSV/Clear-cache rowlinks + SQLCipher footer; no toggle, no CSV, no clear-cache, no encryption note. |
| 10 | `#help` Help & support | `settings/about_screen.dart` (mapped to "About") | **HIGH** | About is a hero + privacy-policy page; the 4 FAQ rowlinks (cold plunge / sauna / recovery score / subscription mgmt) + Contact support button + "v4.0 · Not a medical device" footnote are **missing**. |
| 11 | `#modal` Paywall sheet | `paywall/paywall_screen.dart` | **HIGH** | Paywall is a **full-screen heat-gradient Scaffold**, not a bottom sheet (no `.sheet` 28/28/44/44 radius, no `.grab` bar, no slide-up animation). Missing: `🔥 CONTRASTCOACH PRO` `.pw-badge`, big "See what actually works" headline, `.trust` row (50k+/4.9★/92%), `.save 50%` badge, 6 ✓ feature chips (replaced by 4 different items), entire `.reviews` carousel with 2 review cards, `.links` row (Restore · Terms · Privacy · Maybe later). |

Cluster-wide headline gaps: (1) The mockup's two-tier "You" profile hub does not exist — Flutter uses a Material Settings list as the profile destination, losing the avatar-bio-stats hero card and all 11 emoji-tile rowlinks. (2) Five of the 11 mockup views (Notifications, Widgets, Subscription, Help, plus dedicated Account & security) have **no Flutter screen at all** — they are either absent, inlined into Settings, or replaced by a different screen. (3) The Paywall is a full-screen layout instead of the spec'd modal bottom sheet, dropping the trust/reviews/save-badge components entirely. (4) Reusable atoms diverge from spec: `AppSwitch` is a stock Material `Switch` (not the custom 46×28 heat-pill `.sw`), `AppButton` uses pill radius 999 + weight w600 (mockup `.btn` is radius 14 / weight 800 / heat shadow `0 14px 26px -12px var(--heat)`), and `SheetContainer` omits the 44px bottom-corner radius the paywall sheet requires.

---

## 1. Profile ("You") — `settings_screen.dart` (serves the `/settings` route = bottom-nav "You")

### Mockup (verified from `index.html` lines 419-443, CSS lines 30-67, 78)
- Title text "You" rendered as `.name`: **28px, weight 800, letter-spacing -.7px**, line-height 1.1, margin-bottom 16px.
- Profile card: `.card` `--r:20px` border `1px var(--line)` shadow `var(--elev) = 0 8px 24px -16px rgba(20,20,45,.28)`; padding `20px 14px`.
- Avatar: `.avatar` **88×88 circle, `linear-gradient(140deg, var(--heat) #FF6B35, var(--cold) #2D7CF1)`**, 34px emoji "🧑" centered, color #fff weight 800, `box-shadow var(--elev)`, `margin: 0 auto`.
- Name: **17px weight 800**, margin-top 10px ("Aasheesh Singh").
- Bio: 12px **weight 600** color `var(--ink3) #9AA0A8` ("Contrast therapy since 2024 · 🇮🇳").
- Edit profile button: `.btn.ghost2` — flat, `var(--ink2)` text, 1px `var(--line)` border, **radius `--r-sm:14px`**, padding 15px, weight 800, margin-top 12px.
- Stats row: 3 flex:1 columns, big number **17px** (no weight declared → 800 inherited), label **11px** color `var(--ink3)`. Values: `7 / Streak`, `21 / Longest`, `48 / Sessions`.
- Rowlink card (margin-top 12px, padding `2px 14px`) containing **11 rowlinks**, each: `.rowlink` flex with gap 13px padding `14px 4px` border-bottom 1px `var(--line)`, font 14px weight 600; emoji tile `.e` **34×34 radius 11px** bg `var(--bg)` font-size 16px; arrow `.ar` 18px `var(--ink3)`; subtext `<small>` 11px-ish weight 500 `var(--ink3)`.
  - 🏅 Achievements (`small`: "Level 4 · 720 XP")
  - 🗓️ History & calendar
  - 📝 Journal
  - 🏆 Challenges
  - 🔐 Account & security
  - 🔔 Notifications
  - 🎨 Appearance
  - ❤️ Health Connect
  - 🧩 Home-screen widgets
  - ⭐ Subscription (`small`: "Free plan")
  - 💾 Data & backup
  - ❓ Help & support
- "Go Pro — 7-day free trial" `.btn`: heat→coral gradient, **radius 14**, weight 800 size 15, shadow `0 14px 26px -12px var(--heat)`, calls `openPay()`.
- Top: there is **no `.appbar`** on this view — first child is the `.name` "You".

### Flutter implementation (source-read findings)
- File `settings_screen.dart:189-361`. AppBar uses `ContrastAppBar(title: 'Profile', showBackButton: true)` — title **not** the mockup's "You" string at 28px w800 (it's "Profile" at 20px w700 per `app_bar.dart:30-34`).
- Loading spinner only when `_loading` (centered `CircularProgressIndicator`).
- `_ProfileCard` (`settings_screen.dart:364-443`): one `AppCard` (radius **24**, padding `AppSpacing.xl=20`) containing a **Row** with `UserAvatar(size: 56)` + name (18px w800) + email-subtext (12px w500) + `PlanBadge` + "`N` sessions tracked" (11px w600).
  - `UserAvatar` (`identity.dart:58-95`): 56×56 **oval** gradient `linear-gradient(topLeft→bottomRight, heat→coral)` showing **initials**, not an emoji; mockup is 88×88 circle gradient heat→**cold** with a 34px **emoji**.
- No stat trio (Streak / Longest / Sessions) anywhere in the card — single text "`{stats.totalSessions} sessions tracked`" is the only number shown.
- No bio line, no "Edit profile" `.btn.ghost2` button on the card.
- Below the card the screen renders grouped settings lists (Appearance / Health / Privacy / Subscription / Help sections) as `_SettingsRow` widgets (`:473-539`) — lucide icons inside **24px circle chip** with 0.12-opacity tint at size 14 — **not** the mockup's emoji 34×34 tile.
  - Flutter rows present: Theme, Accent color (non-tappable! no `location`/`onTap` set, `:229-236` — trailing just a static `_TrailingValue("Orange")`), Health Connect, Voice control, Notifications (+ 5 inline `_NotifToggle` subrows), Privacy, Export data, Delete account, Manage subscription, About, Sign out.
  - **Missing rowlinks vs mockup**: Achievements, History & calendar, Journal, Challenges, Account & security, Home-screen widgets, Data & backup, Help & support are all **absent** from this view. (Achievements/History/Journal/Challenges exist as separate top-level routes but are NOT reachable from this profile screen.)
- `_SettingsRow` row `:523` label font is **15px w600** (mockup `.rowlink` is 14px w600); row vertical padding 16 (`:501`) — mockup is `14px 4px`.
- Mockup's rowlink arrow `.ar` is "›" 18px `var(--ink3)`; Flutter renders `LucideIcons.chevronRight` 18px (`:529`).
- No "Go Pro" `.btn` at the bottom of the profile list — instead the upgrade affordance is the small `PlanBadge` inside the card.

### Gaps (pixel-faithful deltas)
- **G1 (HIGH)**: No "You" 28px w800 negative-LS title — replaced with `ContrastAppBar` chrome at 20px w700 labeled "Profile" and a back chevron (`app_bar.dart:27-58`, `settings_screen.dart:192`).
- **G2 (HIGH)**: Avatar is 56×56 heat→**coral** gradient initials-circle (`identity.dart:74-91`), not 88×88 heat→**cold** gradient **emoji** circle. Mockup CSS line 78 literally mandates `linear-gradient(140deg,var(--heat),var(--cold))`.
- **G3 (HIGH)**: Profile hero card contains no bio line, no Edit-profile `ghost2` button, and no 3-column stats row (Streak/Longest Sessions). The "48 sessions" + "21 longest" + "7 streak" trio is collapsed to a single small `sessions tracked` text.
- **G4 (HIGH)**: Eight of the 11 mockup rowlinks are missing entirely (Achievements, History & calendar, Journal, Challenges, Account & security, Home-screen widgets, Data & backup, Help & support). They are not navigable from the "You" tab at all (routes exist for some — `/achievements`, `/journal`, `/referral` — but no rowlink points to them).
- **G5 (MED)**: Every rowlink uses a Lucide outline icon inside a 24px chip (`:504-513`) instead of the mockup's 34×34 emoji square (`border-radius:11`, bg `--bg`).
- **G6 (MED)**: Accent-color row is a single non-tappable stub labelled "Orange" (`settings_screen.dart:229-236`) — no `onTap`/`location` set, so tapping does nothing; mockup routes to `#appearance` view.
- **G7 (HIGH)**: **Missing "Go Pro — 7-day free trial" `.btn`** at the bottom of the profile (`index.html:442`). The card's small `PlanBadge` is the only upgrade entry-point.
- **G8 (LOW)**: Card radius is 24 (`settings_screen.dart:380`) vs mockup `.card` radius 20 (`--r`); spec is off by 4px.

### Severity
**HIGH** — structural divergence: the mockup's hub-style "You" view (avatar-bio-stats card + 11 rowlinks + Go-Pro CTA) does not exist. Flutter substitutes a Material "Profile" settings list with ~9 rows, losing the avatar gradient, the 3-stat row, the Edit-profile button, 8 of the 11 rowlinks, and the Go-Pro CTA.

---

## 2. Edit profile (`#editProfile`) — `edit_profile_screen.dart`

### Mockup (verified `index.html` lines 446-456)
- App bar: `.appbar` back "‹" square (36×36, radius 12, 1px `var(--line)` border) + `<h2>` "Edit profile" **19px w800 ls -.4**.
- `.avatar` 88×88 heat→cold gradient circle, 34px emoji "🧑", box-shadow `var(--elev)`.
- Emoji picker row: 5 spans, each **font-size 22px**, `margin: 0 3px`, `cursor: pointer`; emoji set in source: `🧑 🧔 👩 🧊 🔥`. Tapping calls `pickAvatar(e)` which updates the avatar text.
- Field "Name" (`.field label` 12px w700 ls .1): single-line input, border 1px `var(--line)` radius **12** padding 13px font 14px weight 600, focus shadow `0 0 0 3px color-mix(in srgb,var(--heat) 18%,transparent)`. Value "Aasheesh Singh".
- Field "Bio" (`<textarea rows="2">`, same border style) value "Contrast therapy since 2024 · 🇮🇳".
- Field "Primary goal": 4 chips `.chip` (radius 20, padding `8px 13px`, 12px w700). "Recovery" `.on` (heat bg, white text, heat border) + "Energy / Sleep / Focus" off.
- Field "Temperature units": `.seg` segmented control — bg `var(--line)` radius **14** padding 4; two `.seg span` flex:1 padding 9 radius 11, ".on" gets `var(--card)` bg + `var(--ink)` text + shadow `0 3px 8px -3px rgba(0,0,0,.2)`. Values `°C` / `°F`; `°C` preselected.
- Field "Weekly session goal": `<input type="range" value="70">`; subtitle 12px w600 `var(--ink2)` "5 sessions / week".
- Save changes `.btn` (heat→coral gradient, radius 14, weight 800).

### Flutter implementation (source-read findings)
- `edit_profile_screen.dart:80-148`: Scaffold + default `AppBar(title: Text('Edit profile'))` (no custom ContrastAppBar, no chip-style back button — uses stock Material back arrow).
- Body: a `Padding` container with a single `TextField` (display name) + a 13px "Email" label + email-as-plain-`Text` + "Sign in required" hint when nullable + a `FilledButton` "Save changes" at the bottom (`:133-142`).
- `_onSave` (`:47-77`) only calls `user.updateDisplayName(...)` — never touches bio, goal, temp unit, weekly goal, or avatar.

### Gaps (pixel-faithful deltas)
- **G1 (HIGH)**: **Avatar gradient circle is missing.** The body starts directly with the display-name `TextField` — no 88×88 heat→cold gradient avatar with 34px emoji at the top.
- **G2 (HIGH)**: **5-emoji picker row is missing** (no `🧑 🧔 👩 🧊 🔥` row, no `pickAvatar` equivalent).
- **G3 (HIGH)**: **Bio `<textarea>` is missing** — only the display-name input exists; bio is not even a model field in this screen.
- **G4 (HIGH)**: **Primary-goal `.chip` row (Recovery/Energy/Sleep/Focus)** is missing.
- **G5 (HIGH)**: **Temperature-units `.seg` control (°C / °F)** is missing.
- **G6 (HIGH)**: **Weekly-session-goal slider + "5 sessions / week" caption** is missing.
- **G7 (MED)**: Save button uses Material `FilledButton` (`:133`) instead of the spec'd `.btn` heat→coral gradient, radius 14, weight 800. The default `FilledButton` is a flat pill (radius 999 by default per Material 3, weight w600) — wrong radius, wrong weight, wrong bg.
- **G8 (MED)**: Name field uses default `OutlineInputBorder` (`:100`) — focus state will render as Material's default doubly-drawn border, not the mockup's 1px `var(--line)` radius-12 border with ring-shadow `0 0 0 3px color-mix(heat 18%)`.
- **G9 (LOW)**: Email is exposed as an editable-but-disabled-looking `Text` row (`:113-119`); mockup's edit-profile has no email field at all.
- **G10 (LOW)**: AppBar back button is stock Material arrow, not the mockup's 36×36 radius-12 bordered "‹" chip (`app_bar.dart` style is only used on screens that import `ContrastAppBar`).

### Severity
**HIGH** — 6 of the 7 mockup controls are missing; the Flutter screen is essentially a "rename only" page that touches only `displayName`, while the mockup defines a full identity editor (avatar, bio, goal, temp unit, weekly goal). This is a wholesale feature gap, not a styling delta.

---

## 3. Account & security (`#account`) — no Flutter route

### Mockup (verified `index.html` lines 459-465)
- App bar `.appbar` "Account & security" 19px w800.
- Email field `.field` with input "aasheesh333@gmail.com".
- Card with 3 rowlinks/sets:
  - 🔑 `.rowlink` Change password (arrow ›)
  - 🔗 `.rowlink` Google · `<small>connected</small>` (arrow ›)
  - 🔒 `.set` with `.sw` switch (toggleable) — "Biometric lock"
- Two CTAs:
  - `.btn.ghost2` "Sign out" (flat, 1px `var(--line)` border, ink2 text).
  - `.btn` with inline style `background: linear-gradient(120deg,#E53935,#ff6b68); box-shadow: none` "Delete account".

### Flutter implementation (source-read findings)
- `app_router.dart` defines **no `/account` route** (only `/settings`, `/settings/health`, `/settings/privacy`, `/settings/export`, `/settings/delete`, `/settings/about`).
- Closest analogs:
  - `settings_screen.dart:343-354` exposes a Lucide `logOut` row labeled "Sign out" inside the settings list (calls `_signOut` → dialog confirm → `auth.signOut()` → `context.go('/sign-in')`).
  - `settings_screen.dart:328-333` exposes a `trash2` row "Delete account" routing to `/settings/delete`.
  - `delete_account_screen.dart:104-170` shows a hero card + a single `AppButton` labeled "Delete account" with `AppButtonVariant.secondary` (flat white, `cs.outline` border) — **not** the mockup's red gradient button with `box-shadow: none`.
  - `privacy_screen.dart` covers an Analytics toggle — not a Change-password / Google-link / Biometric-lock surface.
- Biometric lock, Change password, and Google link status are **nowhere** in the codebase (grep across routing/screens returns no matches for biometric lock or change password UI).
- Sign-out styled as a settings row with a red `LucideIcons.logOut` (`:329-354`), not as the mockup's full-width `.btn.ghost2`.

### Gaps (pixel-faithful deltas)
- **G1 (HIGH)**: No `/account` route exists — the "Account & security" rowlink in the profile mockup has no Flutter destination.
- **G2 (HIGH)**: **Change-password row is missing entirely** (no UI to update the user's Firebase password).
- **G3 (HIGH)**: **Google link status row is missing** ("Google · connected" inspectable state is not surfaced anywhere).
- **G4 (HIGH)**: **Biometric-lock `.sw` toggle is missing** — no local-authentication / biometric-lock UI exists.
- **G5 (HIGH)**: **Email field at the top of the view is missing** (mockup shows a focused-style black email field).
- **G6 (HIGH)**: Sign Out is a small row in the settings list (`settings_screen.dart:349-353`), not a full-width `.btn.ghost2` CTA.
- **G7 (HIGH)**: Delete-account button on `delete_account_screen.dart:158-164` is `AppButtonVariant.secondary` (white card with `cs.outline` border) — mockup mandates `linear-gradient(120deg,#E53935,#ff6b68)` with **no shadow**, visible as the destructive gradient pill from any account screen.

### Severity
**HIGH** — five of the screen's six UI elements are absent; the closest Flutter surface (Privacy screen + Delete-account screen) covers < 10% of the mockup, and the destructive CTA is the wrong color.

---

## 4. Notifications (`#notif`) — no Flutter route (inlined into SettingsScreen)

### Mockup (verified `index.html` lines 468-480)
- App bar `.appbar` "Notifications" 19px w800.
- One `.card` (padding `2px 14px`) with **6 `.set` rows** in order:
  1. ⏰ Daily reminder — `.sw.on` (heat bg)
  2. Reminder time — static value "7:00 AM" (w800, no switch)
  3. 🔥 Streak at risk — `.sw.on`
  4. 💧 Hydration nudges — `.sw` (off)
  5. 🏆 Challenge updates — `.sw.on`
  6. 📣 Product news — `.sw` (off)
- `.sec-t` "Active days" header, then a 7-chip `.row` of weekday `.chip`s: Mon-Fri `.on` (heat), Sat/Sun off.

### Flutter implementation (source-read findings)
- No `/notif` route in `app_router.dart`.
- `settings_screen.dart:255-312` renders a single "Notifications" `_SettingsRow` with an `AppSwitch`, and when `_notifications == true` shows **5 inline `_NotifToggle` subrows** (`:264-311`):
  1. "Streak reminders" (maps `_notifsStreak`)
  2. "Optimal timing" (maps `_notifsTiming`)
  3. "Sleep insights" (maps `_notifsInsight`)
  4. "Subscription alerts" (maps `_notifsSubscription`)
  5. "Health Connect status" (maps `_notifsHealth`)
- `_NotifToggle` (`:541-572`) is a plain text-only row with an `AppSwitch` — no emoji prefix, no separate `.set` upper row.
- `AppSwitch` (`app_switch.dart:11-20`) is a stock Material `Switch` with `activeTrackColor: AppColors.brandWarm` — i.e. a Material-size track (~52×32 with M3 defaults) and Material thumb, **not** the mockup's custom **46×28** height-pill with 22×22 circle and `box-shadow:0 1px 3px rgba(0,0,0,.3)` and `cubic-bezier(.3,1.4,.5,1)` slide.
- No weekday chip row anywhere in the codebase (grep for Mon/Tue/…/Sun chips returns nothing).
- No "Daily reminder" top row, no static "Reminder time → 7:00 AM" value row, no "Hydration nudges", no "Product news", no "Challenge updates" row.

### Gaps (pixel-faithful deltas)
- **G1 (HIGH)**: **No standalone Notifications screen** (no `/notif` route). The 6-row + Active-days mockup is collapsed into a flat expandable list under the Settings "Notifications" row.
- **G2 (HIGH)**: 5 inline toggles use only 5 of the mockup's 6 `.set` rows; row labels differ ("Streak reminders" vs "Streak at risk", "Optimal timing" vs "Daily reminder", "Sleep insights" vs "Hydration nudges", etc.). "Challenge updates" and "Product news" have no analog at all.
- **G3 (HIGH)**: Static "Reminder time — 7:00 AM" sub-row is missing (no time-picker hint anywhere).
- **G4 (HIGH)**: **Active days Mon-Sun chip row is entirely missing.**
- **G5 (HIGH)**: `AppSwitch` is a stock Material `Switch` (`app_switch.dart:11-20`), not the mockup's pixel-defined `.sw` (46×28, radius 16, inner 22×22 with shadow + cubic-bezier thumb slide). Visual mismatch on every toggle in the app.
- **G6 (MED)**: Toggles inherit no row-level emoji prefix (mockup `.set` rows carry ⏰ 🔥 💧 🏆 📣); Flutter rows are bare text.

### Severity
**HIGH** — the dedicated 6-row + 7-chip notifications screen does not exist; replaced with 5 inline toggles using a Material-native switch instead of the custom `.sw` pill.

---

## 5. Appearance (`#appearance`) — `appearance_screen.dart`

### Mockup (verified `index.html` lines 483-496)
- App bar `.appbar` "Appearance" 19px w800.
- Card with **2 `.set` rows**:
  1. 🌙 Dark mode — `.sw` (off)
  2. 🧩 Match system — `.sw.on`
- `.sec-t` "Accent color" header.
- `.swatches` row gap 12, with **5 `.swatch` circles 36×36 radius 50%**, `border: 3px solid transparent`; `.on` → `border-color var(--ink)` + `scale(1.08)`:
  - `#FF6B35` (heat) — default on
  - `#2D7CF1` (cold)
  - `#7A5BFF` (purple)
  - `#33C27F` (ok)
  - `#E5397D` (pink)
- `.sec-t` "Text size" header.
- `<input type="range" value="50">` slider.

### Flutter implementation (source-read findings)
- `appearance_screen.dart:39-83` Scaffold + `AppBar(title: 'Appearance')` (no chip back button; uses default Material back arrow).
- Body: a column with two sections:
  1. `_SectionLabel('Accent color')` (`:59`, 11px w700 ls 1.2, uppercased). Then `_AccentPalette` (`:105-176`).
  2. `_SectionLabel('Theme mode')` (`:69`) + `_ThemeModeSelector` (Material `SegmentedButton<ThemeMode>` with Light/Dark/System, `:178-227`).
- `_AccentPalette` (`:118-176`): **GridView crossAxisCount: 3**, items rendered as **squares radius 16** (not 50% circles) sized by grid cell — they fill a square cell, not a 36×36 circle. Border is `selected ? Border.all(onSurface, 3) : Border.all(transparent, 3)`. Selected item shows a check icon (`:167`).
- Palette `_kAccentPalette` (`:11-18`): `heat, coral, cold, cold2, purple, ok` — **6 colors** including `coral` and `cold2`, missing `#E5397D` (pink). Wrong set and wrong count (6 vs 5).
- No "Dark mode" `.set` row, no "Match system" `.set` row, and no `.sw` switches.
- No "Text size" slider anywhere (grep returns no `Slider` in this file).
- `_ThemeModeSelector` uses Material `SegmentedButton`, which renders as Material's own rounded-pill segment (not the mockup's flat `.seg` with `bg var(--line)` radius 14 padding 4 and tab-on with `0 3px 8px -3px rgba(0,0,0,.2)` shadow).

### Gaps (pixel-faithful deltas)
- **G1 (HIGH)**: **Dark mode + Match system `.set` toggle rows are missing.** Mockup's first card has only these two rows; Flutter omits the card entirely.
- **G2 (HIGH)**: Swatch count is **6** (`appearance_screen.dart:11-18`) vs mockup's **5**; swatch set differs (Flutter includes `coral` & `cold2` and `ok` — the mockup palette is `heat / cold / purple / ok / pink #E5397D`).
- **G3 (HIGH)**: Swatches are rendered as **rounded squares** (`_AccentPalette` uses `GridView` with `borderRadius.circular(16)`, `:149`) — mockup's `.swatch` is explicitly a 36×36 **circle** `border-radius:50%`. This is a shape mismatch, not a tint delta.
- **G4 (HIGH)**: Selected-state lacks `transform: scale(1.08)` (mockup `.swatch.on`); Flutter uses a check-icon + colored box-shadow instead (`:156-167`).
- **G5 (HIGH)**: **Text size slider section is entirely missing.** Mockup's `<input type="range" value="50">` has no Flutter equivalent in this file.
- **G6 (MED)**: Theme mode uses Material `SegmentedButton` (`:206-225`) instead of the mockup's `.seg` (flat `var(--line)` track radius-14 padding-4, on-tab card-colored + shadow `0 3px 8px -3px rgba(0,0,0,.2)`).
- **G7 (LOW)**: `_SectionLabel` is uppercased weight 700 ls 1.2 (`:99`) — mockup `.sec-t` is 15px w800 ls -.2 with an action link slot, not an uppercase tiny label.
- **G8 (LOW)**: Section ordering differs: mockup is Dark/Match rows → Accent → Text size; Flutter is Accent → Theme mode (text size missing).

### Severity
**HIGH** — two of the three spec'd sections (Dark/Match toggles + Text size) are missing, and the accent picker's shape (squares vs circles), palette (6 vs 5), and selected/scale state are all wrong.

---

## 6. Health Connect (`#health`) — `health_connect_screen.dart`

### Mockup (verified `index.html` lines 499-505)
- App bar `.appbar` "Health Connect" 19px w800.
- Hero card centered: 34px emoji **"❤️"**, h2 "Smarter recovery score" (`font-weight:800`), subtext 13px `var(--ink2)` "Connect Health Connect to factor in your HRV, sleep and resting HR.", `.btn` "Connect Health Connect" (heat→coral gradient, radius 14, weight 800, shadow).
- `.sec-t` "Permissions" header.
- `.card` (padding `2px 14px`) with **3 `.set` rows all `.sw.on`**:
  1. ❤️ Heart rate variability
  2. 😴 Sleep
  3. 💓 Resting heart rate
- Footer 11px `var(--ink3)`: "🔒 Processed on-device · never uploaded."

### Flutter implementation (source-read findings)
- `health_connect_screen.dart:118-274`: Scaffold + SafeArea, body is a scroll view with ONE container (radius **24**, padding 24, surfaceContainerLow bg, `cardSoftFor` shadow).
- Hero container (`:127-179`): a Row with a 44×44 rounded-rectangle icon-chip (radius 14, `AppColors.heat.withOpacity(0.12)` bg) containing `LucideIcons.heart` 20px (`:138-150`), alongside a 14px w500 text "Health data stays on your device. We never upload it." (`:153-164`). No big centered emoji, no "Smarter recovery score" heading.
- A sub-paragraph "Read: heart rate, HRV, sleep, steps, workouts. Write: MindfulSession." (`:168-176`) — informative but not the mockup's hero + button layout.
- Optional `_snapshot != null` container (`:180-230`) renders an HRV/Sleep/RestingHR/Steps snapshot card — this is driven by real Health data after the user connects. Mockup does not depict post-connect data; it depicts a pre-connect hero. Functionally overlapping but structurally different.
- Bottom CTA is a single `AppButton` `variant: warm` labeled "Connect to Health Connect" (`:259-267`) — Material pill (radius 999, w600) instead of mockup's `.btn` (radius 14, weight 800, heat shadow).
- No "Permissions" `.sec-t` header.
- No `.card` with the 3 (HRV/Sleep/Resting HR) `.sw.on` rows.
- No `🔒 Processed on-device · never uploaded` footnote.
- No top AppBar at all (the file uses `Scaffold(body: SafeArea(...))` without an `appBar:` field — back navigation relies on Android system back gesture).

### Gaps (pixel-faithful deltas)
- **G1 (HIGH)**: Top app bar (`.appbar` with back chevron chip) is missing — the screen has no `appBar:` (`:118-122`).
- **G2 (HIGH)**: Hero is a 44×44 lucide-icon chip + side paragraph (`:138-164`), not a centered big 34px `❤️` + "Smarter recovery score" h2 w800 + 13px subtext + `.btn` (`index.html:501`).
- **G3 (HIGH)**: **Permissions card with 3 `.sw.on` `.set` rows (HRV / Sleep / Resting HR) is entirely missing** — no UI surfaces the granular permission toggles the mockup depicts.
- **G4 (HIGH)**: **Privacy footnote "🔒 Processed on-device · never uploaded." is missing** (mockup `index.html:504`).
- **G5 (MED)**: CTA is `AppButton` pill (radius 999 w600) not the mockup's `.btn` (radius 14, weight 800, heat gradient shadow).
- **G6 (MED)**: The mockup Connect button lives inside the hero card; Flutter places it as a full-width standalone CTA below (`:259-267`), separated by an `if (_error...)` branch.

### Severity
**HIGH** — the small-grained "Permissions card with 3 ON switches" + "on-device" footnote are entirely absent (security/privacy copy and granular consent UI are missing); the hero is restructured as a Lucide icon row rather than the centered ❤️ + h2.

---

## 7. Widgets (`#widgets`) — no Flutter route

### Mockup (verified `index.html` lines 508-514, CSS lines 175-179)
- App bar `.appbar` "Home-screen widgets" 19px w800.
- **3 `.widget` cards** (radius **22**, padding 16, color #fff, margin-bottom 12, `box-shadow var(--elev)`):
  1. `.wst` `linear-gradient(120deg, var(--heat), var(--coral))` — tag "STREAK" (11px w700 opacity .85), value **"🔥 7 days" 26px w800**, subtext "Tap to start today's session" 12px opacity .85.
  2. `.wsm` `linear-gradient(140deg, #12121a, #25252f)` — tag "RECOVERY" (11px w700 opacity .7), value **"82 · Strong" 26px w800**, subtext "Go hard today" opacity .7.
  3. `.wcl` `linear-gradient(120deg, var(--cold), var(--cold2))` — tag "NEXT SESSION", value **"Standard · 26 min" 20px w800**, subtext "Recommended for mornings".
- Bottom `.btn` "Add to home screen" (heat gradient).

### Flutter implementation (source-read findings)
- `app_router.dart` defines **no widgets route**. Search for `widget` in routing and screen files found only the generic atomic widgets directory `lib/presentation/widgets/`, no widget-config / widget-preview screen.
- No `WidgetScreen` / `WidgetsScreen` / `HomeWidgetsScreen` class exists anywhere in `lib/presentation/screens` (grep returns only the `Widget` Flutter built-in).
- No `.wst/.wsm/.wcl` gradient cards exist in the codebase (grep across `lib/` for "STREAK", "RECOVERY", "wst", "wsm", "wcl" returns no production matches).

### Gaps (pixel-faithful deltas)
- **G1 (HIGH)**: **Entire screen is missing** — no route, no screen file, no widget-preview cards, no "Add to home screen" CTA.

### Severity
**HIGH** — wholly unimplemented. The "🧩 Home-screen widgets" rowlink in the mockup profile (line 437) points to a screen the Flutter app does not have.

---

## 8. Subscription (`#sub`) — no Flutter route (replaced by `/paywall`)

### Mockup (verified `index.html` lines 517-526, CSS lines 205-209)
- App bar `.appbar` "Subscription" 19px w800.
- Current-plan card: h2 "Current plan · Free" (16px w800) + subtext 12px `var(--ink3)` "$3 protocols · basic score · local only".
- `.sec-t` "Upgrade" header.
- Three `.plan` cards (border **1.5px** `var(--line)`, radius **16**, padding `13px 15px`, margin-bottom 9):
  1. **Yearly preselected** (`.plan.sel` heat-border, 6% heat tint bg) with `.save` badge absolutely positioned `top:-9px right:14px` — heat→coral gradient, 10px w800, padding `2px 8px`, radius 8 — label "SAVE 50% · FREE TRIAL"; inner: `.t "Yearly"` 14px w800, `.d "$2.50/mo · 7-day free trial"` 11px ink3 w600; `.p "$29.99"` 15px w800.
  2. Monthly — `.t "Monthly"`, `.d "Billed monthly"`, `.p "$4.99"`.
  3. Lifetime — `.t "Lifetime"`, `.d "One-time"`, `.p "$79.99"`.
- `.btn` "Start free trial" (calls `openPay()`).
- `.btn.ghost2` "Restore purchases".

### Flutter implementation (source-read findings)
- `app_router.dart` defines **no `/sub` route** and there is **no SubscriptionScreen** class.
- Settings row "Manage subscription" routes directly to `/paywall` (`settings_screen.dart:334-340`).
- The paywall page is the only subscription surface — see screen #11 below.

### Gaps (pixel-faithful deltas)
- **G1 (HIGH)**: No SubscriptionSettings page exists. Mockup profile rowlink "⭐ Subscription · Free plan" has no destination.
- **G2 (HIGH)**: No "Current plan · Free" hero card with subtext copy ("3 protocols · basic score · local only").
- **G3 (HIGH)**: No `.sel` preselected "Yearly" plan card with `.save` badge.
- **G4 (HIGH)**: "Start free trial" `.btn` does not exist on a sub screen (mockup uses it as a soft CTA that opens the modal paywall — Flutter bypasses the sub screen, jumping straight to `/paywall`).
- **G5 (HIGH)**: ".btn.ghost2 Restore purchases" is not on a subscription screen (the only "Restore" link is buried on the paywall, see #11).

### Severity
**HIGH** — the entire dedicated subscription-management screen is missing; the user lands on the paywall modal as if starting a fresh purchase, with no "Current plan" status.

---

## 9. Data & backup (`#data`) — `data_export_screen.dart`

### Mockup (verified `index.html` lines 529-533)
- App bar `.appbar` "Data & backup" 19px w800.
- One `.card` (padding `2px 14px`) with:
  1. `.set` "☁️ Cloud backup `<small>(Pro)</small>`" + `.sw` (off, onclick=`openPay()`).
  2. `.rowlink` "📄 Export data (JSON)" (arrow ›, onclick toast "Exported JSON").
  3. `.rowlink` "📊 Export data (CSV)" (arrow ›, onclick toast "Exported CSV").
  4. `.rowlink` "🧹 Clear cache" (arrow ›, onclick toast "Cache cleared").
- Footer 11px `var(--ink3)`: "Local data is encrypted with SQLCipher."

### Flutter implementation (source-read findings)
- `data_export_screen.dart:62-156`: Scaffold + SafeArea (no `appBar:` — back is system-only).
- Single container radius 24 padding 24, surfaceContainerLow bg (`:72-78`) — contains: a 64×64 heat-tinted download icon-chip (`:81-93`), title "Export your data" (`titleLarge` w700), body text "Download all your sessions as a JSON file." (`:104-111`).
- A "Saved to: $_filePath" green-tinted success card appears post-export (`:112-139`).
- Bottom CTA: `AppButton` "Export" / "Export again" (variant `warm`, `fullWidth`, `size: large`, `:144-151`).
- Logic (`:30-60`): exports JSON only via `exportUserDataAsJson(...)` to `getApplicationDocumentsDirectory()`, then triggers `Share.shareXFiles`.

### Gaps (pixel-faithful deltas)
- **G1 (HIGH)**: No top app bar with chip-style back button (`:64-66` uses `Scaffold(body:)` with no `appBar:`).
- **G2 (HIGH)**: Dashboard layout replaces the settings-list layout — the mockup uses a card of `.set`/`.rowlink` rows (Cloud backup toggle + JSON + CSV + Clear cache), not a hero-card + CTA pattern.
- **G3 (HIGH)**: **Cloud backup `.sw` toggle (calling `openPay()` when Pro-locked) is missing.**
- **G4 (HIGH)**: **CSV export rowlink is missing** — only JSON is supported (`:39, :49`).
- **G5 (HIGH)**: **Clear cache rowlink is missing.**
- **G6 (HIGH)**: **`<small>(Pro)</small>` Pro-gating text on cloud backup is missing** (no Pro gating exists anywhere on this screen).
- **G7 (HIGH)**: **"Local data is encrypted with SQLCipher" footer is missing.** This is a privacy-critical copy item that exists in mockup (`index.html:532`).
- **G8 (MED)**: CTA is `AppButton` warm (pill radius 999, w600, surface yellow) instead of mockup's `.btn` (radius 14, weight 800, heat gradient + heat shadow). The mockup does not have a primary `.btn` here at all — it has rowlink arrow chevrons.

### Severity
**HIGH** — three of the four setting rows are missing (Cloud backup, CSV export, Clear cache), the SQLCipher encryption footnote is absent, and the screen is structured as a hero-CTA instead of a setting-list.

---

## 10. Help & support (`#help`) — `about_screen.dart` (mapped to the "About" route)

### Mockup (verified `index.html` lines 536-540)
- App bar `.appbar` "Help & support" 19px w800.
- One `.card` (padding `2px 14px`) with **4 `.rowlink` FAQ entries**:
  1. ❄️ "How cold should the plunge be?"
  2. 🌡️ "How long in the sauna?"
  3. 📊 "How is my Recovery Score calculated?"
  4. 💳 "Manage or cancel subscription"
- `.btn.ghost2` "Contact support".
- Footer (11px `var(--ink3)`, centered, margin-top 14): "ContrastCoach v4.0 · Not a medical device."

### Flutter implementation (source-read findings)
- `app_router.dart:230-234` routes `/settings/about` → `AboutScreen`. The settings list labels this the "About" row (`settings_screen.dart:342-347`).
- `about_screen.dart:32-193`: Scaffold + SafeArea (no `appBar:`), ScrollView with:
  - Hero column: 96×96 gradient icon-tile (`LinearGradient(heat→coral)` radius 28) with `LucideIcons.thermometer` 48px (`:48-61`), app name + tagline (text styles `headlineLarge` w800 + body 15px `onSurfaceVariant`).
  - Version text "Version $_appVersion" (`:81-91`).
  - "MEDICAL DISCLAIMER" card with `LucideIcons.shield` chip + disclaimer text (`:96-146`).
  - "PRIVACY" card with `LucideIcons.shield` chip + "Your health data stays on your device" copy (`:148-179`).
  - Bottom `AppButton` "Open privacy policy" (`variant: text`, `:182-186`).

### Gaps (pixel-faithful deltas)
- **G1 (HIGH)**: The 4 FAQ rowlinks (cold plunge / sauna / recovery-score / subscription mgmt) are **entirely missing**.
- **G2 (HIGH)**: **"Contact support" `.btn.ghost2` button is missing** (no mailto: or mail intent exists in this screen).
- **G3 (HIGH)**: Mockup's footer is "ContrastCoach v4.0 · Not a medical device." — short and trust-relevant. Flutter shows "Version $_appVersion" alone (`:81-91`) and a separate "MEDICAL DISCLAIMER" card; the compact footer line is absent.
- **G4 (HIGH)**: The About screen's content (hero icon + headline + tagline + medical disclaimer card + privacy card) is not requested by the mockup #help view; the closest mockup anchor for About content is missing entirely — i.e. About in Flutter is a bespoke page with **no analog in the cluster-C mockup**.
- **G5 (MED)**: The "Help & support" route does not exist; settings row "About" routes to `/settings/about` (`settings_screen.dart:343`), so from the user-facing label "Help & support" in the profile mockup (`index.html:441`) there is no Flutter counterpart.

### Severity
**HIGH** — the help-rowlink-style FAQ list and Contact-support CTA are entirely absent; About is a bespoke privacy/disclaimer page unrelated to the mockup's `#help` view.

---

## 11. Paywall modal sheet — `paywall_screen.dart` (`/paywall`)

### Mockup (verified `index.html` lines 544-556, CSS lines 192-219)
- Rendered as `.modal` overlay (`background: rgba(8,8,12,.5); backdrop-filter: blur(6px)`) containing a **`.sheet`** bottom sheet:
  - `width:100%`, `background var(--card)`, color `var(--ink)`,
  - **`border-radius: 28px 28px 44px 44px`** (top corners 28, bottom corners 44),
  - `padding: 22px 18px 28px`,
  - **`transform: translateY(100%)`** + animation `up .45s cubic-bezier(.2,.8,.2,1) forwards` to translateY(0),
  - `max-height: 92%`, `overflow-y: auto`, hidden scrollbar.
- `.grab` bar: 40×4, `var(--line)` bg, radius 3, margin `0 auto 14px`.
- `.pw-badge` (inline-flex, gap 6, bg `#fff2ec`, color `var(--heat)`, w800, 11px, padding `5px 10px`, radius 20) with text "🔥 CONTRASTCOACH PRO".
- `.pw-h` headline "See what actually works for you": **21px w800 ls -.5**, margin `12px 0 2px`.
- `.pw-s` sub "Unlock HRV insights, all protocols, breathwork & cloud backup.": 13px `var(--ink2)` w500, margin-bottom 14.
- `.trust` row (flex, justify-around, text-center, bg `var(--bg)`, radius 14, padding 12, margin-bottom 14):
  - 50k+ / athletes — `<b>` 15px w800, `<small>` 10px `var(--ink3)` w600
  - 4.9★ / 12k ratings
  - 92% / keep the streak
- Three `.plan` cards (CSS lines 205-209): border 1.5px `var(--line)`, radius 16, padding `13px 15px`, margin-bottom 9, `display:flex justify-between`; `.sel` heat-border 1.5px + heat-tint bg.
  - Monthly (`$4.99`), **Yearly preselected** with `.save` badge "SAVE 50% · FREE TRIAL" (gradient heat→coral, 10px w800, padding `2px 8px`, radius 8, top:-9 right:14), `"$2.50/mo · 7-day free trial"` desc, `"$29.99"` price, Lifetime (`$79.99`).
- `.feat` flex-wrap (gap `8px 14px`): 6 spans each with `::before content:'✓' var(--ok)` — "All protocols / HRV insights / Breathwork / Cloud backup / Custom protocols / Analytics".
- `.reviews` horizontal scroll (gap 10, hidden scrollbar): 2 `.rev` cards (flex none, width **200px**, bg `var(--bg)`, radius 14, padding 12, 12px font):
  - ★★★★★ (gold `#FFB020`, 11px w700), quote "Finally a recovery app that gets it.", "— Marco, 🇮🇹"
  - ★★★★★, quote "The HRV score keeps me honest.", "— Dana, 🇺🇸"
- `.btn` "Start 7-day free trial" heat gradient.
- `.links` centered (11px `var(--ink3)`, w600, margin-top 10): "Restore · Terms · Privacy · Maybe later".

### Flutter implementation (source-read findings)
- `paywall_screen.dart:111-434`: `Scaffold(body: Container(decoration: BoxDecoration(gradient: AppGradients.heat)))` — full-screen heat→coral gradient Scaffold with a top-right circular close button (`LucideIcons.x` in a 40px circle, `:127-144`).
- Title "UPGRADE" (12px w700 ls 2.0, white, `:148-160`).
- Headline **"ContrastCoach Pro"** 36px w800 ls -.5 h1.0 white (`:162-173`), centered — this is NOT the mockup's 21px "See what actually works for you" headline.
- Feature list (`:174-208`): **4 hard-coded items** (All 10 protocols, Health Connect & HRV tracking, Unlimited cloud sync, Voice control in any language), each rendered as a 24×24 white-circle check + 15px w500 white text — not the mockup's 6-item `.feat` chip-row with ✓.
- Pricing section (`:210-300`):
  - Fallback when `_packages.isEmpty` (no RevenueCat): 3 `_PriceCard`s Monthly $5.99 / Yearly **$39.99 save 44%** / Lifetime $89.99 (`:258-283`).
  - With RevenueCat: dynamic cards from real products.
- `_PriceCard` (`:473-592`): **radius 20** (mockup plan radius 16), **2.5px heat border** for "best" (mockup is 1.5px `var(--line)` for unselected, 1.5px heat for `.sel`), padding `20 18 20 18` (mockup `13 15`), single radio dot 22×22 (mockup `.plan` has no radio dot — it's just label + price).
- "BEST VALUE" pill (`:540-557`) — heat bg, white text, 9px w800 ls .6, radius 999, padding `8 2` — not the mockup's `.save` "SAVE 50% · FREE TRIAL" positioned `top:-9 right:14` with radius 8.
- CTA is a **white pill** of radius 999 height 56 containing "Continue with {Yearly}" (`:302-354`) — not the mockup's heat-gradient ".btn" "Start 7-day free trial" (the mockup `.btn` is heat→coral gradient white-text, radius 14, w800).
- "Restore purchases" link: 12px w500 underline, white (`:356-368`) — closer to mockup's `.links` "Restore".
- "Cancel anytime. Not a medical device." 10px w400 (`:370-384`).
- "Terms of Service" + "Privacy Policy" links row (`:386-423`) — matches part of mockup `.links`, but missing "Maybe later".
- **No bottom-sheet chrome at all**: no `.modal` scrim, no `.sheet` radius 28/28/44/44, no `.grab` bar, no `translateY` slide-up animation.
- No 🔥 `CONTRASTCOACH PRO` `.pw-badge`.
- No `21px "See what actually works for you"` headline.
- No `.trust` row (50k+ / 4.9★ / 92%).
- No `.save` "SAVE 50% · FREE TRIAL" badge in correct positioning.
- No 6-item `.feat` ✓ chip wraps — replaced by 4 white-circle feature rows on a colored background.
- **No `.reviews` carousel** — the entire 2-card review bank (5-star gold #FFB020 quotes + attribution) is missing.
- No combined `.links` "Restore · Terms · Privacy · Maybe later" footer row — links are split into separate widgets.
- The Flutter layout puts pricing on a heat-gradient background with white-overlaid white cards; mockup puts everything on a `var(--card)` (white) sheet, dark text.

### Gaps (pixel-faithful deltas)
- **G1 (HIGH)**: **Not a bottom sheet** — full-screen Scaffold (`:112-115`) wrapped in `AppGradients.heat`. Mockup CSS line 192-194 mandates `.modal` overlay + `.sheet` `transform: translateY(100%) → 0` with `border-radius:28px 28px 44px 44px` and slide-up `.45s cubic-bezier(.2,.8,.2,1)` animation. The Flutter `SheetContainer` widget (`sheet_container.dart:11-45`) exists with the correct top-28 radius + 40×4 grab bar but is **not used by PaywallScreen**.
- **G2 (HIGH)**: **`.grab` bar missing** (mockup line 197).
- **G3 (HIGH)**: **🔥 `CONTRASTCOACH PRO` `.pw-badge` (#fff2ec bg, heat text, w800, 11px) missing** (mockup line 198, 545).
- **G4 (HIGH)**: **`21px "See what actually works for you"` headline missing** — Flutter shows "ContrastCoach Pro" at 36px instead (`:162-173`).
- **G5 (HIGH)**: **`.trust` row (50k+ / 4.9★ / 92%) removed entirely** (mockup line 202, 548).
- **G6 (HIGH)**: **`.save` badge "SAVE 50% · FREE TRIAL" not present** in correct position (mockup CSS line 209 — absolute `top:-9 right:14`, gradient heat→coral, radius 8). Flutter uses a wrongstyled "BEST VALUE" pill (`:540-557`).
- **G7 (HIGH)**: Feature list is **4 items with white circles** (`:174-208`); mockup is **6 ✓-prefixed chips** ("All protocols / HRV insights / Breathwork / Cloud backup / Custom protocols / Analytics") using `var(--ok)` green ✓.
- **G8 (HIGH)**: **`.reviews` carousel entirely missing** — no horizontal-scroll 200px `.rev` cards, no `★★★★★` in `#FFB020` 11px w700, no quotes from Marco/Dana (mockup lines 213-218, 553).
- **G9 (HIGH)**: **`.links` row reduced** — only Terms + Privacy + Restore as separate inline links, missing the spec'd single centered "Restore · Terms · Privacy · Maybe later" cluster footer.
- **G10 (HIGH)**: CTA button is **white pill radius 999** ("Continue with Yearly", `:302-354`); mockup `.btn` is heat→coral **gradient**, radius 14, weight 800, "Start 7-day free trial" label.
- **G11 (HIGH)**: Card `_PriceCard` shape diverges: radius 20 (`:494`) vs mockup 16; 2.5px border (`:496-498`) vs mockup 1.5px; padding `20 18` vs mockup `13 15`; **radio dot** (`:507-521`) is not in mockup (mockup plans show label-left, price-right, no radio).
- **G12 (MED)**: Card spacing is 12 (`:266, :275, :296`); mockup `.plan` margin-bottom is 9.
- **G13 (MED)**: Price label "$39.99 · save 44% — save 50% in the mockup" — value mismatch with mockup's stated "$29.99 / $2.50/mo" pricing.
- **G14 (LOW)**: A crash path error card (`:215-256`) replaces the price card list when RevenueCat errors — the mockup has no error state defined; this is an implementation detail.

### Severity
**HIGH** — the paywall is the most divergent screen: the entire modal bottom-sheet chassis, trust row, save badge, feature chips, and review carousel are missing; the screen is structured as a full-screen heat-gradient page with different copy, prices, and CTA styling.

---

## Missing Screens in Flutter

The mockup v4 defines **10 views** for cluster C plus a paywall **modal** view (#11 is system-defined). Four of these have **no dedicated Flutter route**:

| Mockup view | Mockup anchor | Flutter route | Status |
|---|---|---|---|
| `#notif` Notifications | `index.html:468` | (none) | **MISSING** — inlined into `SettingsScreen` as 5 `_NotifToggle` subrows;失利 Daily reminder / Reminder time / Hydration / Product news rows are absent; Active-days chip row is absent. |
| `#widgets` Home-screen widgets | `index.html:508` | (none) | **MISSING** — no widgets route, no WidgetsScreen file. The 3 widget preview gradient cards (wst/wsm/wcl) + "Add to home screen" CTA are not implemented anywhere. |
| `#sub` Subscription | `index.html:517` | (none) | **MISSING** — no `/sub` route. Settings "Manage subscription" row (`settings_screen.dart:335-340`) routes directly to `/paywall`. No "Current plan · Free" status card. |
| `#help` Help & support | `index.html:536` | (none; closest is `/settings/about` = `AboutScreen`) | **MISSING** — `AboutScreen` is unrelated to the spec's help view (no 4 FAQ rowlinks, no Contact-support button, no v4.0 footer). The "About" route has **no analog mockup** in cluster C. |
| `#account` Account & security | `index.html:459` | (none) | **MISSING** — Change-password, Google-link status, Biometric-lock do not exist anywhere in the codebase. Sign-out lives on SettingsScreen; Delete lives on its own route with the wrong button style. |
| `#profile` You hub | `index.html:419` | `/settings` (SettingsScreen, the bottom-nav "You" target per `bottom_nav.dart:25`) | **STRUCTURALLY PRESENT but not faithful** — `SettingsScreen` is re-purposed as the profile destination; see screen #1 above for the long list of missing rowlinks / card structure. |

### Notes
- The closest analogs to mockup `#account` are piecemeal across three unrelated Flutter screens (`SettingsScreen` for sign-out, `PrivacyScreen` for analytics, `DeleteAccountScreen` for deletion); none of them together reconstruct the mockup's single `#account` view.
- The `about_screen.dart` route is labelled "About" in the Settings list (`settings_screen.dart:342-347`) but is functionally a privacy/disclaimer page — there is no Flutter file that matches the mockup's "Help & support" FAQ rowlink list, so users have no in-app help center.
- The `appearance_screen.dart` exists but covers only 2 of the 3 mockup sections; the missing pieces are Dark/Match `.set` toggle rows and the Text-size slider.
- Even where screens exist, the reusable atoms diverge from spec at scale:
  - `AppSwitch` (`app_switch.dart`) is a Material `Switch` — does not match the `.sw` (46×28 pill, 22×22 inner circle with shadow, cubic-bezier slide).
  - `AppButton` (`app_button.dart:54`) uses **pill radius 999 + weight 600** — mockup `.btn` is **radius 14 + weight 800 + heat shadow `0 14px 26px -12px var(--heat)`**.
  - `AppCard` radius defaults to 20 (correct) but `settings_screen.dart:380` overrides to 24 (wrong) — 4px excess.
  - `ContrastAppBar` title is 20px w700 (`app_bar.dart:30-34`) — mockup `.appbar h2` is **19px w800 ls -.4** (`index.html:28`).
  - `SheetContainer` (`sheet_container.dart:14`) uses `BorderRadius.vertical(top: Radius.circular(28))` (top 28 only) — the paywall mockup requires **asymmetric `28 28 44 44`** (bottom corners also 44). SheetContainer's grab bar margins (10 above, 20 below) also differ from mockup's `0 auto 14` (no top margin, 14px bottom only).
