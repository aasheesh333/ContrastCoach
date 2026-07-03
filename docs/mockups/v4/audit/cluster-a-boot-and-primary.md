# Cluster A Audit — Boot flow + Primary tabs

Mockup ground truth: `/home/ubuntu/ContrastCoach/docs/mockups/v4/index.html`.

This audit compares 9 Flutter screens against the v4 HTML/CSS mockup
(`docs/mockups/v4/index.html`). Every claim cites both a Dart source line and the
matching line in `index.html` (or the corresponding CSS rule block when the spec
lives in `<style>` rather than markup).

Design tokens (verified `index.html:9-12`):
- Heat `#FF6B35`, Coral `#FF8A65`, Cold `#2D7CF1`, Cold2 `#5B9CFF`, Purple `#7A5BFF`,
  OK `#33C27F`, Ink `#0C0C0E`, Ink2 `#6B6E76`, Ink3 `#9AA0A8`, BG `#EEF0F5`,
  Card `#FFFFFF`, Line `#ECEEF2`.
- `--r:20px` `--r-sm:14px` `--r-lg:26px`; `--elev:0 8px 24px -16px rgba(20,20,45,.28)`;
  `--elev-lg:0 20px 44px -22px rgba(20,20,45,.4)`.
- Spring transition `.4s cubic-bezier(.22,1,.36,1)` on `.view` (`index.html:22`).

---

## Summary table

| # | Screen | File | Severity | Biggest gap |
|---|---|---|---|---|
| 1 | Splash | splash_screen.dart | HIGH | No 96×96 frosted logo tile, no `pop` spring, no 120×4 loading bar, wrong subtitle wording & gradient stop order |
| 2 | Sign in | sign_in_screen.dart | HIGH | OAuth/Google-Apple row, divider and footer are missing; uses dark `heroDark` bg instead of light mockup; focus ring + heat box-shadow on inputs absent |
| 3 | Onboarding | onboarding_screen.dart | HIGH | Not bottom-anchored; does not render the `Heat. / Cold. / Recover smarter.` headline; white-on-heat CTA replaced by heat-gradient warm button; missing skip link; wrong dot sizes |
| 4 | Home | home_screen.dart | HIGH | No dark hero card, no circular readiness gauge, no streak/avg pills, no emoji icon tiles, no `Resume last session` row; greeting/name typography diverges |
| 5 | Explore | explore_screen.dart | HIGH | No filter chips, no 30-day program hero, no per-protocol colored icon tiles, no `.lock` PRO gradient badges, wrong refresh-text fidelity |
| 6 | Builder | custom_protocol_builder_screen.dart | HIGH | No `Build protocol` h2 appbar, no inline phase cards with ranges for Sauna/Cold/Rest preset, wrong button label and no total summary line styling |
| 7 | Insights | insights_screen.dart | HIGH | Uses chips instead of segmented control; missing recovery-trend gradient card with sparkline, consistency heatmap, sessions-per-week bars, and many sub-cards |
| 8 | History | streak_calendar_screen.dart | HIGH | Renders a “Streak” dashboard with heatmap strip, not a month calendar; no appbar back button; no recent-sessions rowlink list |
| 9 | Detail | session_detail_screen.dart | HIGH | No big 70px score with heat→cold text clip; no `STRONG · Standard Recovery` ok-green strapline; no 5-row listmetrics; no phase-breakdown bars |

Cluster-wide headline gaps (top 5):

1. **Cluster A is not on the v4 design system.** Despite `AppColors`, `AppGradients`,
   `AppTypography` tokens existing for v4, the screens still compose bespoke
   Text/Container widgets inline and route through deprecated shims
   (`AppColors.brandWarm` = `heat`, see `app_colors.dart:29`) instead of the v4 tokens. The
   mockup’s signature hero card, gauge, segmented control, heat grid and calendar are
   entirely absent from the corresponding screens.
2. **The post-session/primary-tab spine is mis-mapped.** `session_detail_screen` (the
   mockup `#detail` view) gives a metric-grid + recovery-row instead of the mockup’s
   big gradient `82` score with ok-green strapline + 5-row `list` + 6-bar phase
   breakdown. `streak_calendar_screen` renders the insights/history heatmapstrip
   story for `#history` rather than a true month calendar with `done`/`cold`/`today`
   spans, missing the entire calendar card.
3. **Bottom-anchored onboarding + spring pop splash are missing.** `splash_screen.dart`
   shows a static Column with a Lucide flame and a `1900ms` Timer; there is no 96×96
   frosted logo tile, no `pop` `cubic-bezier(.2,1.3,.4,1)` 700ms entry, and no
   120×4 sliding loader. `onboarding_screen.dart` renders top-anchored illustration-heavy
   3-step pager with a `'HEAT.\nCOLD.\nREPEAT.'` 56px hero, instead of the bottom-anchored,
   33px / -1px-tracked `Heat. / Cold. / Recover smarter.` headline with a
   white-on-heat CTA.
4. **Home’s hero card is fundamentally different.** Mockup `#home` is a `linear-gradient(140deg,#12121a,#25252f)`
   dark hero with a 100×100 readiness gauge (heat→cold arc), a big readiness headline
   and two streak/avg pills (`index.html:38-45, 267-270`). Flutter renders
   `HeroStartCard` (offloaded to a composite widget) with a near-`flex` `_NoSessionsCard`
   fallback (`home_screen.dart:386-484`); no gauge, no pills, no blobs.
5. **OAuth, segmented control, filter chips, PRO badges, calendar tints — all the
   distinctive v4 controls — are absent across the cluster.** Sign-in has no Google/Apple
   OAuth row, Insights has chips instead of the `.seg` segmented control, Explore has no
   filter-chip row and no `.lock` PRO gradient badges, History has no `done`/`cold`/`today`
   calendar tints. These are reproducible in `_Card`-level Chapters 2/5/7/8 below.

---

## 1. Splash — splash_screen.dart

### Mockup (verified)
- Background `linear-gradient(160deg,#FF6B35,#7A2AA8 58%,#2D7CF1)` 3 stops, purple at 58% (`index.html:87`).
- `.logo`: 96×96, `border-radius:28px`, `background:rgba(255,255,255,.16)`,
  `border:1px solid rgba(255,255,255,.3)`, font 48px (🔥 emoji),
  `pop .7s cubic-bezier(.2,1.3,.4,1) both` from `scale(.4)` → `scale(1)` (`index.html:88, 89`).
- `<h1>` 26px weight 800 letter-spacing `-.5px` margin-top 16 (`index.html:90`, plus `.h` rules at `index.html:15`).
- Subtitle “Heat · Cold · Recover” 13px weight 500 opacity `.85` (`index.html:238` inline rule).
- `.load` 120×4 bg `rgba(255,255,255,.25)` border-radius 3 margin-top 20 overflow hidden;
  inner `<i>` width 40% bg `#fff` `slide 1.4s ease-in-out infinite` from `margin-left:-40%` → `margin-left:120%` (`index.html:91-93`).
- Layout: column centered, text-align center, gap 8 (`index.html:87`).

### Flutter implementation (source-read findings)
- `Container(decoration: BoxDecoration(gradient: AppGradients.splashBg))` (`splash_screen.dart:46-47`).
- `AppGradients.splashBg` = `LinearGradient` colors `[heat, Color(0xFF7A2AA8), cold]`, stops `[0.0, 0.58, 1.0]` (`gradients.dart:46-51`) — matches the 160deg 58% mockup gradient directionally (`-0.4,-1` → `0.4,1`).
- Logo = `Icon(LucideIcons.flame, color: lightInk, size: 96)` (`splash_screen.dart:52`) — raw Lucide flame glyph, no tile container, no frosted background, no border.
- Title `Text('ContrastCoach', fontSize: 28, fontWeight: w700, color: lightInk)` (`splash_screen.dart:54-62`).
- Subtitle `Text('HEAT. COLD. REPEAT.', fontSize: 13, color: lightInk2, letterSpacing: 2)` (`splash_screen.dart:64-72`).
- `Timer(1900ms, _routeNext)` (`splash_screen.dart:23`) — routes to onboarding or home; while waiting shows only the static Column.
- Outer column `mainAxisAlignment: MainAxisAlignment.center` (`splash_screen.dart:50`), with `SizedBox(height: 20)` then `height: 8` between title and subtitle.

### Gaps (pixel-faithful deltas)
- **Logo tile missing** — mockup spec is a 96×96 rounded-28 frosted tile with an emoji flame inside (`index.html:88`); Flutter renders a bare Lucide flame glyph at 96px with no background, border, or radius (`splash_screen.dart:52`). HIGH.
- **No `pop` entry animation** — mockup animates the logo with `cubic-bezier(.2,1.3,.4,1)` over 700ms from scale .4→1 (`index.html:88-89`). Flutter has no `AnimationController`/`ScaleTransition` at all (`splash_screen.dart:17-78`). HIGH.
- **Title typography mismatch** — mockup 26px w800 ls `-.5px` (`index.html:90`); Flutter 28px w700 no letter-spacing (`splash_screen.dart:56-61`). Severity delta: 2px font / -1 weight / no tracking. MED.
- **Subtitle wording & weight** — mockup string “Heat · Cold · Recover”, 500 weight, opacity `.85` (`index.html:238`); Flutter string “HEAT. COLD. REPEAT.”, no explicit weight (defaults w400), `letterSpacing: 2` (`splash_screen.dart:64-72`). MED.
- **No 120×4 sliding loader** — mockup `.load` bar with `slide 1.4s ease-in-out infinite` (`index.html:91-93`); Flutter shows nothing during the 1900ms wait. HIGH.
- **Vertical rhythm** — mockup gap-8 between title/subtitle, margin-top 16 on `<h1>` (`index.html:87, 90`); Flutter uses `height: 20` after icon and `height: 8` between title and subtitle, throwing off the spec ratios (`splash_screen.dart:53, 63`). LOW.

### Severity
- **HIGH** — the splash is a static placeholder missing every animated/visual signature element of the v4 mockup (frosted logo tile + pop spring + sliding loader).

---

## 2. Sign in — sign_in_screen.dart

### Mockup (verified)
- Background: the mockup `#signin` view inherits the screen `--bg` (`#EEF0F5`) (`index.html:19, 95`). Layout: flex column, justify center (`index.html:95`).
- Brand block centered, margin-bottom 26 (`index.html:96`): `.m` emoji 52px (`index.html:97`), `<h1>` “Welcome back” 24px w800 ls `-.5px` margin-top 6 (`index.html:98`), `<p>` “Recover smarter with every session” 13px w500 color Ink2 margin-top 4 (`index.html:99`).
- Two `.oauth` buttons first: Google (🟢) and Apple (🍎), full width, 1px `--line` border, `--card` bg, Ink color, `--r-sm=14px` radius, padding 14, 14px w700, gap 10 icon-label, margin-bottom 10 (`index.html:100, 245-246`).
- `.divider` “OR” 11px w700 Ink3 with flex 1px lines on either side, margin 12 0 (`index.html:102-103`).
- Email & Password `.field` blocks (`index.html:248-249`), label 12px Ink2 w700 mb-7 ls `.1px` (`index.html:69`); input 1px `--line` border, `--card` bg, 12px radius, padding 13, 14px w600 (`index.html:70`); focus → `border-color:heat` + 3px box-shadow `color-mix(heat 18%, transparent)` (`index.html:71`).
- `.btn` “Sign in” heat gradient `linear-gradient(120deg,heat,coral)` `--r-sm=14` padding 15 15px w800, `box-shadow:0 14px 26px -12px var(--heat)`, margin-top 4 (`index.html:55, 250`).
- Footer: “New here? Create account”, 12px Ink3 weight 600, with “Create account” in heat color (`index.html:251`).

### Flutter implementation (source-read findings)
- Body wrapped in `Container(gradient: AppGradients.heroDark)` (`sign_in_screen.dart:124-125`). `heroDark` = `LinearGradient(top→bottom, #12121A → #25252F)` (`gradients.dart:54-58`). That is a **dark hero** background, not the light `#EEF0F5` mockup bg.
- Brand: `Icon(LucideIcons.flame, color: heat, size: 56)` + `Text('ContrastCoach', 24px w700 white)` (`sign_in_screen.dart:133-144`). Mockup has no app-name on this screen, only a 52px emoji.
- Headline `Text('Welcome back', displaySmall w800 height 1.1 white)` (`sign_in_screen.dart:146-153`). `displaySmall` = 28px w700 (`app_typography.dart:36-41`), but only `fontWeight: w800` is overridden here, and size stays at 28 → mockup is 24px (`index.html:98`).
- Subtitle `Text('Sign in to keep your streak going.', 15px onSurfaceVariant)` (`sign_in_screen.dart:155-162`). String and weight (default w400, mockup w500) both wrong.
- No OAuth row of any kind — the first interactive element below the subtitle is an `AppTextField` for Email (`sign_in_screen.dart:164-170`). Mockup places two `.oauth` buttons *above* the email field (`index.html:245-246`).
- No `.divider` “OR” widget. Flutter has a divider + ‘or’ text (`sign_in_screen.dart:223-240`) but it is placed *after* the email/password/“Sign in” button, just before the Google button — inverted order vs mockup.
- Field is `AppTextField(label:'Email', prefixIcon: LucideIcons.mail)` (`sign_in_screen.dart:164-170`). Behaviour & focus ring depend on `AppTextField` internals; no inline proof of a 3px heat box-shadow on focus (mockup `index.html:71`).
- Password field identical with obscure + eye toggle (`sign_in_screen.dart:172-186`).
- “Forgot password?” TextButton aligned right in heat color 13px w600 (`sign_in_screen.dart:187-201`) — **not present in mockup** (`index.html:243-252`).
- Primary CTA `AppButton(label:'Sign in', variant: warm, size: large, fullWidth)` (`sign_in_screen.dart:214-221`). Whether it is the heat 120deg gradient with the heat box-shadow depends on `AppButton`; not verifiable here.
- Google button is `AppButton(label:'Continue with Google', variant: secondary, leadingIcon: LucideIcons.mail)` (`sign_in_screen.dart:242-248`). The leading icon is **mail** (Lucide), not the Google ‘🟢’/Apple ‘🍎’ emoji; there is no Apple button at all.
- Footer row: `Text('New here?', 14px onSurfaceVariant)` + `TextButton('Create account', color heat, w700)` (`sign_in_screen.dart:250-272`). Sizes/weights: 14px (mockup 12px w600) and weight `w700` (mockup 600). MED delta.
- An extra `AppStrings.medicalDisclaimer` line, centered, 11px outline color is appended (`sign_in_screen.dart:273-284`) — **not present in mockup `#signin`**.

### Gaps (pixel-faithful deltas)
- **Background is dark instead of light** — `sign_in_screen.dart:124-125` sets `AppGradients.heroDark` (`gradients.dart:54-58`) where mockup expects light `--bg` (`index.html:19, 95`). This forces all subsequent text to `Colors.white` overrides vs mockup’s `var(--ink)` defaults. HIGH.
- **OAuth order inverted + Apple missing** — mockup has Google then Apple above the divider, then email/password (`index.html:245-249`); Flutter has email/password then a divider+Google only, with `leadingIcon: LucideIcons.mail` instead of an emoji (`sign_in_screen.dart:164-248`). HIGH.
- **Divider placement wrong** — Flutter renders “or” divider after the primary CTA (`sign_in_screen.dart:223-240`); mockup places `.divider` *between* oauth row and email field (`index.html:247`). MED-HIGH.
- **Brand block string changes** — Flutter renders `Icon` + “ContrastCoach” + “Welcome back” + a custom subtitle (`sign_in_screen.dart:133-162`); mockup is just a 52px emoji + “Welcome back” + “Recover smarter with every session” (`index.html:244`). HIGH.
- **Headline size** — 28px (Flutter via `displaySmall`) vs 24px (mockup `index.html:98`). MED.
- **Footer size/weight** — Flutter 14px + w700 (`sign_in_screen.dart:255-270`) vs mockup 12px w600 with bold “Create account” in heat (`index.html:251`). MED.
- **Extra medical disclaimer** — Flutter appends a disclaimer sentence (`sign_in_screen.dart:274-284`) absent in mockup `#signin`. LOW (different domain).
- **“Forgot password?” link** is added by Flutter but not in mockup (`sign_in_screen.dart:187-201`). LOW (functional addition, not a regression in spirit).

### Severity
- **HIGH** — wrong theme (dark vs light), wrong ordering of OAuth/divider/fields, no Apple option, and divergent copy/errors throughout.

---

## 3. Onboarding — onboarding_screen.dart

### Mockup (verified)
- Background `linear-gradient(160deg,#FF6B35,#7A2AA8 60%,#2D7CF1)` — purple at 60% (`index.html:105`).
- `display:flex;flex-direction:column;justify-content:flex-end;padding:40px 26px 46px` — **bottom-anchored** (`index.html:105`).
- `.skip` link absolute top 58 right 22, 13px w700 `rgba(255,255,255,.85)` (`index.html:112`).
- `.dots` flex gap 6, three `<i>`: inactive 7×7 round white-.4 bg; `.on` 24×7 radius-4 white bg, margin-bottom 22 (`index.html:108-110`).
- `<h1>` “Heat. / Cold. / Recover smarter.” 33px w800 line-height 1.12 ls `-1px` (`index.html:106`).
- `<p>` subtitle 15px w500 opacity .9 line-height 1.5, margin 14 0 24 (`index.html:107`).
- Single `.btn` with **white bg + heat-colored text** (`index.html:111`), label “Get started →” (`index.html:260`).

### Flutter implementation (source-read findings)
- `Scaffold(backgroundColor: Colors.transparent, body: Container(gradient: AppGradients.splashBg))` (`onboarding_screen.dart:60-63`). `splashBg` uses stop 0.58 for purple (`gradients.dart:50`), **not** the 60% the onboarding mockup specifies.
- Layout is `SingleChildScrollView(padding: fromLTRB(xxl,xxl,xxl,xxl))` with `Column` of `[SizedBox(md), flame Icon, SizedBox(16), _PageDots, SizedBox(24), AnimatedSwitcher(_StepContent), SizedBox(24), _Tagline, SizedBox(lg), AppButton, ...Back button]` (`onboarding_screen.dart:64-104`). This is top-anchored, not `flex-end`.
- `_PageDots` (`onboarding_screen.dart:114-138`): active dot 24×8 with `BorderRadius.circular(4)` and `AppColors.heat` bg; inactive 8×8 same radius, surfaceContainerHigh bg. Mockup: inactive 7×7 round (`.4` white), active 24×7 radius-4 white (`index.html:108-110`).
- Step header is a `_ThermalIllustration` (220×220 radial + 120×120 radial + 2 pills) (`onboarding_screen.dart:351-400`) followed by an `_StepHero(title:'HEAT.\nCOLD.\nREPEAT.', fontSize:56, w800, ls -1.5, color onSurface)` (`onboarding_screen.dart:147-193`). Mockup headline is 33px ls `-1px` (`index.html:106`), with the wording “Heat. / Cold. / Recover smarter.” — a real sentence, not “REPEAT”.
- Step body subtitle is 18px w500 onSurfaceVariant (`onboarding_screen.dart:198-205`). Mockup is 15px w500 opacity .9 (`index.html:107`).
- No `.skip` link anywhere in the file (`onboarding_screen.dart`全文).
- CTA is `AppButton(label: 'Get started'/'Continue', variant: warm, fullWidth, size: large)` (`onboarding_screen.dart:86-95`). `warm` is the heat gradient button; mockup `.btn` is **white bg with heat-colored text** (`index.html:111`). Inverted colour scheme.
- A second `Back` text button appears when `_step > 0` (`onboarding_screen.dart:96-104`) — no back button in mockup.
- A `_Tagline` (11px w700 outline, letterSpacing 1.4) is rendered under the CTA (`onboarding_screen.dart:330-348`) — not in mockup.
- Steps 1 and 2 render `_SessionReadyIllustration` and `_StepPrivacy` with radial/Privacy-row cards (`onboarding_screen.dart:437-560`); completely different content style than the single bottom-anchored page in mockup `#onboard` (`index.html:255-261`).

### Gaps (pixel-faithful deltas)
- **Bottom-anchoring missing** — mockup pushes everything to `flex-end` (`index.html:105`); Flutter is top-anchored via `SingleChildScrollView` + `Column` (`onboarding_screen.dart:64-72`). HIGH.
- **Wrong headline text + size + tracking** — Flutter “HEAT.\nCOLD.\nREPEAT.” 56px ls -1.5 (`onboarding_screen.dart:147-192`) vs mockup “Heat.\nCold.\nRecover smarter.” 33px ls -1 (`index.html:106`). HIGH.
- **Wrong CTA color** — Flutter uses `AppButtonVariant.warm` (heat gradient, white text) (`onboarding_screen.dart:91`); mockup `.btn` is `background:#fff;color:var(--heat)` (`index.html:111`). High contrast inversion. HIGH.
- **No skip link** — mockup `.skip` top-right (`index.html:112`); Flutter has no skip link anywhere. MED-HIGH.
- **Purple stop position** — `splashBg` stops purple at 0.58 (`gradients.dart:50`); mockup `#onboard` requires 60% (`index.html:105`). LOW (1 stop %).
- **Inactive dot wrong size/shape** — Flutter 8×8 radius-4 `surfaceContainerHigh` (`onboarding_screen.dart:125-133`); mockup 7×7 round `rgba(255,255,255,.4)` (`index.html:109`). MED.
- **Active dot wrong height** — Flutter 24×8 (`onboarding_screen.dart:128-129`); mockup 24×7 (`index.html:110`). LOW.
- **Two extra step pages** — Flutter has a 3-step pager with illustrations, Privacy rows and a Back button (`onboarding_screen.dart:140-328, 437-560`); mockup shows a single bottom-anchored hero. Out of scope per the v4-frame reduction, but objectively HIGH for parity.
- **Tagline + medical disclaimer widgets appended** (`onboarding_screen.dart:84, 330-348`), neither in mockup. LOW.

### Severity
- **HIGH** — the Flutter onboarding is a full multi-step pager with illustrations; the v4 mockup’s single bottom-anchored hero page is not represented at all, and the headline/CTA/skip link are all wrong.

---

## 4. Home — home_screen.dart

### Mockup (verified)
- Greeting “Good morning” 13px Ink2 w600 ls `.2px` (`index.html:31, 265`).
- Name “Aasheesh 👋” 28px w800 ls `-.7px` line-height 1.1 margin-bottom 16 (`index.html:30, 266`).
- `.hero` `linear-gradient(140deg,#12121a,#25252f)`, `--r-lg=26px` radius, padding 20, color `#fff`, `box-shadow:0 22px 42px -20px rgba(255,107,53,.55)` (heat-tinted) (`index.html:38`).
- `.hero::after` top-right blob 220×220 radial `rgba(255,107,53,.55)` transparent 70% (`index.html:39`); `.hero::before` bottom-left blob 200×200 radial `rgba(45,124,241,.5)` transparent 70% (`index.html:40`).
- `.hw` flex gap 16 z-index 2 (`index.html:41`); `.gauge` 100×100 SVG viewBox 0 0 120 120, r=50 stroke-width 11, base stroke `rgba(255,255,255,.12)`, progress stroke `url(#g)` (heat→cold linear-gradient) (`index.html:268`).
- Inner gauge text “82” JetBrains Mono w500 34 fill `#fff`, “RECOVERY” 10px fill `rgba(255,255,255,.6)` (`index.html:268`).
- Right column of `.hw`: `.lbl` “Today’s readiness” 11px w700 ls `.4px` opacity .7 uppercase (`index.html:43, 269`); `.big` “Strong — go hard 🔥” 19px w800 ls `-.3px` margin 3 0 10 (`index.html:44, 269`); two `.pill` items “🔥 7-day streak” and “⏱ 24m avg” — bg `rgba(255,255,255,.14)`, border `rgba(255,255,255,.16)`, radius 11, padding 5 9, 11px w600, margin-right 6 (`index.html:45, 269`).
- `.sec-t` “Quick start” 15px w800 margin 20 2 12 with `<a>` “Explore” 12px heat w700 (`index.html:46-47, 271`).
- `.grid2` 2-col gap 12 (`index.html:48`); two `.proto` cards (`index.html:273-274`): Standard Recovery (ic bg `#fff0ea` color `#FF6B35` emoji 🌡️; h4 13px w700 ls `-.1px`; p 11px Ink3 w500 mt-3) and Breathwork (ic bg `#eaf2ff` color `#2D7CF1` emoji 🫧).
- Resume card: single inline `.card` row, “▸ Resume last session” 13px ~~w700~~, “Standard · 3 rounds” 11px Ink3 mt-2, ⏯️ 20px right (`index.html:276`).
- `.btn` “▶️ Start session” heat gradient (`index.html:55, 277`).

### Flutter implementation (source-read findings)
- `_HomeHeader` builds a horizontal Row with greeting + name + line + optional `_StreakPill` + `UserAvatar` (`home_screen.dart:265-336`). Greeting 13px w600 ls `.4` (`home_screen.dart:291-296`) — matches mockup spec for ls ✓. Name string is `hasName ? '${profile.firstName}.' : 'Welcome.'` (`home_screen.dart:300`) rendered 28px w800 ls `-.5` height 1.1 (`home_screen.dart:301-308`); mockup uses ls `-.7` (`index.html:30`) and the literal string `“Aasheesh 👋”` (`index.html:266`). No waving-hand emoji.
- Below the header the next major block is `_TodayPanel(stats, recommended, onStart)` (`home_screen.dart:198-203`). When `stats.isEmpty` it renders `_NoSessionsCard` (`home_screen.dart:394-484`); otherwise it delegates to `HeroStartCard` (an external composite widget not in the audited files). Neither matches the mockup’s `.hero` dark-card spec at lines `38-45`.
- `_NoSessionsCard`: `AppCard(padding all xxl, radius 28, medium)` with a 999-radius heat-chip “FIRST SESSION”, 28px w800 ls `-.5` body and a 999-radius 56-tall bright heat pill button (`home_screen.dart:400-481`). Has no dark gradient, no gauge, no blobs.
- `QuickStatsRow` is rendered next (`home_screen.dart:205-216`) — a composite row, not the two `.pill` items inside the hero.
- Then `SectionHeader(label:'Pick a goal', trailing: TextButton('Custom'))` + `GoalCardsRow` (`home_screen.dart:218-249`). Mockup has no “Pick a goal” section.
- Protocol-mini row is absent: the mockup’s 2-column `.proto` grid with the 🌡️ / 🫧 tiles at `index.html:273-274` is not present here. Instead `GoalCardsRow` (external widget) is used.
- `_RecentSessionCard` (`home_screen.dart:487-556`) is a card showing goal label + rounds + recovery-score chip in heat bg; alignment and content diverge from mockup “Resume last session” row (`index.html:276`).
- `_StreakPill`: 12×8 padding, 999 radius, surface bg, `LucideIcons.flame` + “${streak} days” (`home_screen.dart:338-369`) — appears next to the avatar in the header, where the mockup has the streak as an in-hero `.pill`.

### Gaps (pixel-faithful deltas)
- **Dark hero card with heat-tinted shadow absent** — mockup `.hero` (`index.html:38`) with `linear-gradient(140deg,#12121a,#25252f)`, radius 26 and heat-tinted `0 22px 42px -20px rgba(255,107,53,.55)` shadow is not present anywhere; Flutter uses `HeroStartCard` (external) or `_NoSessionsCard` with radius 28 (`home_screen.dart:400-407`). HIGH.
- **Circular readiness gauge (100×100 SVG with stroke-width 11, heat→cold gradient arc) is missing** (`index.html:268` vs Flutter has no `CustomPaint`/`SizedBox(100,100)` anywhere). HIGH.
- **Blobs `::after` (heat, 220×220) and `::before` (cold, 200×200) missing** (`index.html:39-40`). HIGH.
- **Streak / avg pills missing** — mockup `.pill` items inside hero (`index.html:45`); Flutter puts streak as `_StreakPill` near the avatar (`home_screen.dart:323-369`) and avg in `QuickStatsRow`. HIGH (no gauge-context pills).
- **Name lacks 👋 and ls** — Flutter shows `'${firstName}.'` 28px ls `-.5` (`home_screen.dart:300-308`); mockup “Aasheesh 👋” ls `-.7` (`index.html:30, 266`). MED.
- **Section header copy/content** — Flutter `'Pick a goal'` + `'Custom'` link (`home_screen.dart:222-234`) instead of mockup `'Quick start' + 'Explore'` link (`index.html:271`). HIGH (different IA).
- **2-col protocol mini-grid absence** — mockup has `.grid2` with Standard Recovery + Breathwork (`index.html:272-275`); Flutter delegates to `GoalCardsRow` with energy/sleep/immunity/recovery goals (`home_screen.dart:240-248`). HIGH.
- **Resume row** — mockup is a slim inline `.card` row labeled “▸ Resume last session” + “Standard · 3 rounds” + ⏯️ (`index.html:276`); Flutter’s `_RecentSessionCard` is goal-named, with a chip-based score on the right (`home_screen.dart:487-556`). HIGH.
- **CTA** — mockup `.btn` “▶️ Start session” (`index.html:277`); no Flutter equivalent visible in `home_screen.dart` (`home_screen.dart:169-262`), `_onStartSession` is wired to the `_TodayPanel` only. MED-HIGH.

### Severity
- **HIGH** — the home screen does not contain the signature dark hero card with readiness gauge, the streak/avg pills, or the Quick-start protocol grid shown in the v4 mockup. The IA is partly different (goal cards instead of mini-grid).

---

## 5. Explore — explore_screen.dart

### Mockup (verified)
- Title “Explore” 28px w800 ls `-.7px` margin-bottom 16 (`index.html:30, 282`).
- `.row` of 5 `.chip` items: All (`.on`), Recovery, Energy, Sleep, Cold. `.chip` radius 20, padding 8 13, 12px w700, card bg, 1px line border; `.on` heat bg white border heat (`index.html:60-62, 283`).
- `.sec-t` “30-Day programs” 15px w800 (`index.html:46, 284`).
- Hero program card: `var(--hero)` dark gradient bg, custom shadow `0 20px 40px -18px rgba(45,124,241,.5)` cold-tint; `.lbl` “Program”; `.big` “❄️ 30-Day Cold Challenge”; `.bar-p` 8px bg `rgba(255,255,255,.2)` inner `i` width 40% heat→coral gradient; Day 12 of 30 — 11px opacity .85 mt-6 (`index.html:285`).
- `.sec-t` “All protocols” (`index.html:286`).
- 6-card `.grid2`: Standard (`#fff0ea`/`#FF6B35` 🌡️), Energy (`#eaf2ff`/`#2D7CF1` ⚡), Sleep-PRO (`#f0ecff`/`#7A5BFF` 🌙 + `.lock` PRO gradient badge), Immunity-PRO (`#eafaf0`/`#33C27F` 🛡️ + `.lock` PRO), Wim Hof-PRO (`#eef1ff`/`#2D7CF1` 🧊 + `.lock`), Custom (`var(--line)`/`var(--ink2)` ➕) (`index.html:287-294`).
- `.lock` PRO badge: absolute top 11 right 11, 10px w800, `linear-gradient(120deg,heat,coral)` bg, white text, radius 7, padding 2 6 (`index.html:54`).

### Flutter implementation (source-read findings)
- `_HeroHeader` is a `Container(gradient: AppGradients.splashBg, padding: pageHoriz + pageTop + xxl, child: Column [Text('Explore', 34px w800 ls -.8 white), Text('Pick a protocol. Tap to start.', 14px w500 white70)])` (`explore_screen.dart:76-114`). This is a **full-width heat→purple→cold** strip across the top of the screen — *not* the mockup’s flat white-page-bg with just `“Explore”` and a chip row (`index.html:281-283`).
- Title 34px w800 ls `-.8` (`explore_screen.dart:90-98`) vs mockup 28px ls `-.7` (`index.html:30`). MED.
- Body is a `_ProtocolGrid` `GridView.builder` with `crossAxisCount: 2`, `mainAxisSpacing: md`, `crossAxisSpacing: md`, `childAspectRatio: 0.86` (`explore_screen.dart:122-141`). That matches the 2-col `.grid2` (mockup `index.html:48`).
- `_ProtocolTile`: `Material(color: surface, radius: 20, elevation: 0)` + `Container(surface, radius 20, border: lineColor, boxShadow: cardSoft)` (`explore_screen.dart:158-171`). Mockup uses `.proto` radius 18 (`index.html:49`). MED.
- Emoji row: `Text(emoji, fontSize: 30)` on the left, `Container` tag pill (tagColor heat or cold, 14% alpha, radius 999, 10px w800 ls .6, “Pro”/“Free”) on the right (`explore_screen.dart:176-200`). **No emoji icon tile** (mockup `.ic` 38×38 radius 12 with custom per-card bg + color, `index.html:51, 273-293`). HIGH.
- Title `protocol.name` 16px w700 height 1.2 onSurface (`explore_screen.dart:203-214`); mockup h4 13px w700 ls `-.1px` (`index.html:52`). MED.
- Subtitle `_difficultyLabel` (`explore_screen.dart:216-224`) — Beginner/Intermediate/Advanced; mockup `p` is a count/duration string like “3× · 26m” (`index.html:288-293`). HIGH.
- Tag badge is heat-or-cold translucent (10/14% alpha) with text “Pro”/“Free” (`explore_screen.dart:180-199`); mockup `.lock` is a heat→coral **gradient filled** badge in white text reading “PRO” (`index.html:54, 290-292`). HIGH.
- No filter-chip row of any kind is rendered in `ExploreScreen.build` (`explore_screen.dart:41-71`). HIGH.
- No “30-Day programs” section + hero program card with progress bar (`index.html:284-285`). HIGH.
- No separate “Custom” tile with `var(--line)` bg and ➕ (`index.html:293`) — Custom is likely part of the loaded protocols; behavior visible only at runtime.
- Empty-state `_EmptyState` shows `🧊` 40px + text + `appName` (`explore_screen.dart:244-286`) — not present in mockup.

### Gaps (pixel-faithful deltas)
- **Screen background** — Flutter wraps a heat→purple→cold gradient header band (`splashBg`) (`explore_screen.dart:79-80`); mockup page is flat `--bg` (#EEF0F5) (`index.html:19`) with only a 28px `“Explore”` title (`index.html:282`). HIGH.
- **No filter chip row** (`index.html:283`); Flutter shows nothing (`explore_screen.dart:41-71`). HIGH.
- **No 30-Day programs section / hero program card with cold-tinted shadow and `.bar-p` progress bar** (`index.html:284-285`); Flutter starts the grid immediately. HIGH.
- **No per-protocol `.ic` 38×38 colored icon tile** (`index.html:51, 288-293`); Flutter renders a free emoji at 30px with no tile (`explore_screen.dart:179`). HIGH.
- **PRO badge wrong shape/color** — Flutter: 999-radius pill, heat-or-cold 14% alpha bg, text-colored, reads “Pro” (`explore_screen.dart:180-199`); mockup: 7-radius rectangle, heat→coral gradient bg, white text, reads “PRO”, positioned absolutely top-right (`index.html:54, 290-292`). HIGH.
- **Tile radius** — 20px Flutter (`explore_screen.dart:160`) vs 18px mockup (`index.html:49`). LOW.
- **Title size/spacing** — 34px / -.8 Flutter (`explore_screen.dart:90-98`) vs 28px / -.7 mockup (`index.html:30`). MED.
- **Subtitle semantics wrong** — difficulty label vs mockup count/duration line (`explore_screen.dart:216-224` vs `index.html:290-292`). MED-HIGH.

### Severity
- **HIGH** — missing the entire filter row, the 30-day program hero, the per-protocol colored icon tiles, and the gradient PRO badges. The screen is structurally a 2-col grid only, not the v4 IA.

---

## 6. Builder — custom_protocol_builder_screen.dart

### Mockup (verified)
- Appbar: `.bk` 36×36 radius 12, 1px line border, card bg, font 18 `‹` + `<h2>` “Build protocol” 19px w800 ls `-.4` (`index.html:26, 28, 299`).
- Three `.card` rows with bold lines (`index.html:300-302`): 🌡️ Sauna · 15 min · 80°C (range value 60); ❄️ Cold · 2 min · 12°C (range value 25); 🙌 Rest · 1 min (range value 15). Each card has a native `<input type=range>` filling 100% width with margin-top 10.
- Summary line: `text-align:center 12px ink2 w6 margin-top 14` “Total · 3 rounds · ~24 min” (`index.html:303`).
- Single `.btn` heat gradient “Save & start” (`index.html:55, 304`).

### Flutter implementation (source-read findings)
- No appbar `.bk` back button or h2 title. The Scaffold body is `SingleChildScrollView(padding: fromLTRB(24,8,24,24))` containing `_sectionTitle('NAME')`, `AppTextField` for name, `_sectionTitle('DESCRIPTION')`, `AppTextField` for description, `_sectionTitle('ROUNDS')`, rounds display, `AppSlider` for rounds, then a custom styled `Add` pill, then `_PhaseEditor` list, then an info Container, then `AppButton('Save protocol')` (`custom_protocol_builder_screen.dart:216-363`).
- No emoji for Sauna 🌡️ / Cold ❄️ / Rest 🙌; phases are addressed by index (`'Phase ${index+1}'`) with a chip row of `PhaseType.values` (`custom_protocol_builder_screen.dart:421-458`).
- Phase duration/temp use `AppSlider` with min 30s max 1800s divisions 59 (`custom_protocol_builder_screen.dart:483-489`), temperature 0–90°C divisions 90 (`custom_protocol_builder_screen.dart:514-521`) — faithful as ranges but the card CSS `.card` radius 20 (`index.html:32`) is rendered as `BorderRadius.circular(20)` for `_PhaseEditor` (`custom_protocol_builder_screen.dart:411-417`) ✓ (this is the only faithful radius in this view).
- A separate info Container with `AppTypography.monoSmall` text “Total: ${minutes}m. Cold 5-20°C. Sauna ≤30 min. ≤60 min total.” (`custom_protocol_builder_screen.dart:311-331`) summarizes differently than mockup “Total · 3 rounds · ~24 min” (`index.html:303`). It lacks rounds info inline and is in a 16-padding container, not centered 12px ink2.
- CTA label is “Save protocol” (or `'Saving…'`) (`custom_protocol_builder_screen.dart:351-358`); mockup label is “Save & start” (`index.html:304`). MED-HIGH.
- A paywall branch renders if `!FeatureGating.canUseCustomProtocols(_tier)` (`custom_protocol_builder_screen.dart:165-214`) — not in mockup.

### Gaps (pixel-faithful deltas)
- **No `Build protocol` appbar** with the 36×36 radius-12 back tile and 19px ls `-.4` h2 (`index.html:299`). Flutter starts the body directly with a text-field NAME block. HIGH.
- **Phase tiles don’t show the emoji + bold composition** (`index.html:300-302`) — Flutter phases are generic “Phase N” labeled cards with chip-row type selectors (`custom_protocol_builder_screen.dart:421-458`). HIGH.
- **Summary line wording/styling** — Flutter mono info card vs mockup centered 12px ink2 w600 line (`custom_protocol_builder_screen.dart:311-331` vs `index.html:303`). HIGH.
- **CTA label** — “Save protocol” Flutter vs “Save & start” mockup (`custom_protocol_builder_screen.dart:353` vs `index.html:304`). MED.
- **Pre-set 3 phases (Sauna/Cold/Rest) absent by default** — Flutter initialises `_phases` as a single sauna phase (`custom_protocol_builder_screen.dart:40`); the mockup ships 3 cards already laid out. MED-HIGH.

### Severity
- **HIGH** — the builder screen does not visually present itself as the mockup `#builder` (no appbar title, no pre-set 3 cards, no total summary line, wrong CTA label).

---

## 7. Insights — insights_screen.dart

### Mockup (verified)
- Title “Insights” 28px w800 ls `-.7` margin-bottom 16 (`index.html:30, 345`).
- `.seg` segmented control: Week / Month / Year, contained in `--line` bg, radius 14, padding 4; each span flex-1 padding 9 radius 11, `.on` card bg ink color `box-shadow:0 3px 8px -3px rgba(0,0,0,.2)` (`index.html:83-85, 346`).
- `.trend` card: `linear-gradient(130deg, var(--cold), var(--cold2))` white text, radius 20, padding 16, `--elev` shadow; `.lbl` “Recovery trend”; `.v` “+12%” 28px w800; `.spark` 6 bars positioned absolute right-bottom (`index.html:143-146, 347`).
- “Consistency · 14 weeks” 12px ink2 w700 (`index.html:348`).
- `.heat` 14-col grid 4px gap of 70 cells, 5 tint levels: `.a=#ffd2bd`, `.b=#ffab84`, `.c=#ff7d47`, `.d=#ff6b35` plus empty `bg:var(--line)` (`index.html:147-149, 349`).
- 2-card bottom row: “Best protocol” → “Standard” w800; “Sleep corr.” → “+0.3” w800; labels 11px ink3 w600 (`index.html:350`).
- `.sec-t` “Sessions per week” with `<a>` “History” (`index.html:47, 351`).
- `.bars` 5 bars heat→coral gradient with heights 35/60/80/45/95% (`index.html:150-151, 352`).
- “ⓘ Not medical advice.” 11px ink3 margin-top 12 (`index.html:353`).

### Flutter implementation (source-read findings)
- `appBar: ContrastAppBar(title:'Insights')` (`insights_screen.dart:120`) — title is delegated to a custom AppBar widget, not the inline `.name` headline from mockup. Style depends on `ContrastAppBar`.
- A range chip row of three `AppChip` items: Week, Month (selected by default), Year (`insights_screen.dart:160-179`). Mockup uses a `.seg` segmented control, not chips; chips here do not match the contained pill-spec (`index.html:83-85`).
- Headline sequence: `Text(_rangeLabel(_range), 13px outline w600 ls .4)` then `Text(_headlineForRange, 24px w800 ls -.4)` (`insights_screen.dart:137-158`) — fabricated headline; not in mockup. HIGH (extra chrome).
- `GradientHeroStat(label:'SESSIONS THIS [WEEK/MONTH/YEAR]', value:_periodSessions, delta:'${streakDays} day streak · ${avgDuration}m avg')` (`insights_screen.dart:182-192`) — replaces the mockup `.trend` cold-gradient card+sparkline + 14-col heatmap. `GradientHeroStat` external; whether it produces the cold-gradient+sparkline is unverifiable from this file alone.
- `_StatGrid` (2×2 grid of TOTAL SESSIONS / AVG DURATION / BEST SCORE / TOTAL MINUTES) (`insights_screen.dart:350-407`) — not present in mockup `#insights`.
- `_PatternSection` “Time-of-day pattern” with three `_BarRow` Morning/Afternoon/Evening bars (`insights_screen.dart:492-536`) — replaces mockup “Consistency · 14 weeks” + `.heat` grid + “Sessions per week” `.bars`. HIGH.
- Better-protocol / Sleep-corr 2-card row missing (`index.html:350`).
- `InsightBlock` list of recommendations (`insights_screen.dart:198-215`) replaces mockup chrome.
- Disclaimer Container `“Not medical advice. For informational purposes only.”` 12px outline italic (`insights_screen.dart:217-232`) — content matches `index.html:353` in spirit but the weight/size/letter-spacing differ.

### Gaps (pixel-faithful deltas)
- **Chips instead of segmented control** (`index.html:83-85, 346`); Flutter `AppChip` row (`insights_screen.dart:160-179`). HIGH.
- **No `.trend` cold-gradient card with sparkline** (`index.html:143-146, 347`) — Flutter delegates to `GradientHeroStat` (`insights_screen.dart:182-192`). Functionality depends on external widget; from this file alone, sparkline at right-bottom + 28px w800 “+12%” pattern is unverifiable. Mark HIGH (deferred verification).
- **No 14-col `.heat` heatmap grid** (`index.html:147-149, 349`); Flutter has no grid of 70 colored cells in `insights_screen.dart`. HIGH.
- **No bottom 2-card row Best protocol / Sleep corr** (`index.html:350`); Flutter has `_StatGrid` 2×2 numeric grid instead (`insights_screen.dart:350-407`). HIGH.
- **No `.bars` sessions-per-week** (`index.html:351-352`); Flutter has `_BarRow` for time-of-day only (`insights_screen.dart:509-531`). HIGH.
- **“History” link absent** — mockup `.sec-t` has `<a onclick="nav('history')">History</a>` (`index.html:351`); Flutter has no link to `/history` here. MED-HIGH.
- **Disclaimer styling** — Flutter 12px italic outline (`insights_screen.dart:225-231`); mockup 11px ink3 (no italic) (`index.html:353`). LOW.
- **Headlines area excess** — Flutter renders a per-range label + headline + ranges above the trend card (`insights_screen.dart:137-180`); mockup condenses that to just the `.seg`. MED.
- **Paywall gate branch** (`insights_screen.dart:239-283`) — not in mockup. LOW (domain addition).

### Severity
- **HIGH** — none of the four signature visual blocks of `#insights` (segmented control, trend card with sparkline, 14-col heatmap, sessions-per-week bars) are reliably rendered by this screen; `GradientHeroStat`/`InsightBlock` may approximate one but the file does not produce the row-by-row mockup spec.

---

## 8. History — streak_calendar_screen.dart

### Mockup (verified)
- Appbar: `.bk` back tile 36×36 radius-12 line border, ink color, font 18 `‹`; `<h2>` “History” 19px w800 ls `-.4` (`index.html:26, 28, 358`).
- Calendar card `.card` radius 20 padding 16 with first line “July 2026” w800 mb-8, a 7-col `.calh` header M T W T F S S (10px w700 Ink3), then a 7-col `.cal` grid 6px gap with cells that are aspect-square radius 10 12px w700 Ink2 `bg:bg`. `.done` is heat→coral gradient bg white text; `.cold` is cold→cold2 gradient bg white text; `.today` is `outline:2px solid var(--ink)` (`index.html:32, 168-174, 359`).
- `.sec-t` “Recent sessions” (`index.html:360`).
- Two `.card.rowlink` rows (`index.html:361-362`): Standard Recovery / Today 26:40 / Score 82, with `.e` 34×34 radius-11 bg-bg emoji 🌡️, “Standard Recovery” bold, “small” subtext `Today · 26:40 · Score 82`, and `›` arrow; second row Morning Energy / Yesterday / Score 77 with ⚡.

### Flutter implementation (source-read findings)
- Scaffold `appBar: ContrastAppBar(title:'Streak')` (`streak_calendar_screen.dart:170`) — **title is “Streak”, not “History”** (`index.html:358`). HIGH.
- Body is a `ListView` of `[_StreakHeader, StreakCalendar, _Legend, _StatsCard, _BestScoreCard, _ProStreakUpsell]` when stats are non-empty (`streak_calendar_screen.dart:184-211`). When (`!_stats.isEmpty`) the calendar widget used is `StreakCalendar(daysWithSessions, intensity, zeroColor, onDayTap)` (`streak_calendar_screen.dart:194-199`) — an external composite. From this file alone, none of the spec’d cells (`done`, `cold`, `today` outline) are provably present.
- `_StreakHeader` renders a giant 48px w800 heat number `${streakDays}` + “days streak” pillars, an encouragement line, and a pill “Last 12 weeks” (`streak_calendar_screen.dart:258-327`) — none of which is in mockup `#history`.
- `_StatsCard` renders a 3-column inline stat At a glance (`streak_calendar_screen.dart:329-372`); mockup has nothing of the sort.
- `_BestScoreCard` (`streak_calendar_screen.dart:411-467`), `_Legend` (`streak_calendar_screen.dart:469-515`), `_ProStreakUpsell` (`streak_calendar_screen.dart:560-626`) — none present in mockup `#history`.
- Calendar card-style `.card` (`index.html:32, 359`) with month header + 7-col + `.calh` headers + `.done`/`.cold`/`.today` tints is *not* produced by this file. The screen offloads to `StreakCalendar` widget — unverified here, content not matching the simulated semantics provable from this file.
- No recent sessions rowlink list (`index.html:360-362`). The file ends after `_BestScoreCard` / `_ProStreakUpsell`; there is no rowlink `.e` 34×34 emoji tile rendering in this file. HIGH.

### Gaps (pixel-faithful deltas)
- **Appbar title wrong** — mockup h2 “History” 19px w800 ls `-.4` (`index.html:358`); Flutter title is `'Streak'` delegated to `ContrastAppBar` (`streak_calendar_screen.dart:170`). HIGH (semantic mismatch — this is supposed to be the `#history` view).
- **No recent sessions rowlink list** (`index.html:360-362`); Flutter has none in `streak_calendar_screen.dart`. HIGH.
- **No `.card` month calendar** (`index.html:359`); Flutter renders `_StreakHeader` + `StreakCalendar` composite (`streak_calendar_screen.dart:192-199`) — header content unrelated to mockup. HIGH.
- **`.done`/`.cold`/`.today` cell tints not produced here** (`index.html:172-174`); `StreakCalendar.zeroColor` param only takes a single color (`streak_calendar_screen.dart:197`). HIGH (assuming delegate doesn’t add tints).
- **Heat style of the streak header** — 48px heat number (`streak_calendar_screen.dart:272-281`); not in mockup. HIGH.
- **No `_Legend` row in mockup** (`streak_calendar_screen.dart:469-515` vs `index.html:357-363` — the only labeled cells are thedow calendar and the rowlist). MED.
- **No upsell card in mockup** (`streak_calendar_screen.dart:560-626`). LOW (functional domain).

### Severity
- **HIGH** — the file is a Streak dashboard, not the mockup `#history` calendar view; it is the wrong view entirely. Title says “Streak”, the calendar semantics (`done`/`cold`/`today`) are not produced here, and the recent sessions rowlink list is absent.

---

## 9. Detail — session_detail_screen.dart

### Mockup (verified)
- Appbar `.bk` + `<h2>` “Session detail” 19px w800 ls `-.4` (`index.html:26, 28, 367`).
- Score block: 70px w800 `linear-gradient(120deg, var(--heat), var(--cold))` text clip (same as summary card), `<div class="s">` 14px w800 color `var(--ok)` (green) letter-spacing .5 reading “STRONG · Standard Recovery” (`index.html:137, 368`).
- List `.card.list` with 5 rows (`index.html:139-140, 369`): ⏱ Duration 26:40; 🔁 Rounds 3; 🌡️ Max heat 82°C; ❄️ Min cold 11°C; ❤️ HRV after 64 ms; gap 10 padding 12 0 border-bottom 1px line, 13px w500.
- `.sec-t` “Phase breakdown” 15px w800 (`index.html:46, 370`).
- `.bars` 6 cells (heights 80/40/75/38/70/35%) heat→coral gradient (`index.html:150-151, 371`).

### Flutter implementation (source-read findings)
- `appBar: ContrastAppBar(title:'Session detail', showBackButton: true)` (`session_detail_screen.dart:93`) — title correct; back button delegated to `ContrastAppBar` not verifiably equal to the `.bk` 36×36 radius-12 line-border char from mockup (`index.html:26, 367`).
- Below appbar: `_HeroCard(title: session.goal.name.toUpperCase(), subtitle: _formatDate(session.startedAt))` (`session_detail_screen.dart:99-102, 127-171`) — a card with `Card(color: lightCard, elevation 0, shape: RoundedRectangleBorder(radius 16, side lightLine))` and 28px w700 ls `-.5` title (`session_detail_screen.dart:148-155`). This **does not** match the mockup’s 70px gradient-text score block + green strapline (`index.html:137-138, 368`).
- A 2-column `_StatGrid` with 4 `_StatTile`s: Hot, Cold, Rounds, Total at `childAspectRatio: 2.2` (`session_detail_screen.dart:104-197`). Mockup has 5 list rows in `.card.list` (`index.html:369`), not a 2×2 grid. HIGH.
- `_StatCard`: `Card(lightCard, radius 12, line border)`, label 11px w600 ls 1.1 lightInk3, value 22px w700 lightInk (`session_detail_screen.dart:199-244`). Mockup list rows are 13px w500 (`index.html:139`); label/value layout differs.
- If `session.recoveryScore != null`, an extra `_RecoveryRow(score: ...)` is rendered with `ShaderMask(shader: AppGradients.scoreText, blendMode: srcIn, child: Text('$score', 32px w700 white))` (`session_detail_screen.dart:112-115, 246-291`). `AppGradients.scoreText` is `LinearGradient(centerLeft→centerRight, [heat, cold])` (`gradients.dart:100-104`) — matches the mockup 120deg heat→cold clip *directionally* but the Flutter text size is 32px (mockup 70px) (`index.html:137`). HIGH.
- `_NoteCard` rendered if `session.notes` is non-empty (`session_detail_screen.dart:116-119, 293-336`) — not present in mockup `#detail`. LOW (addition).
- The `.sec-t` “Phase breakdown” section + the 6-cell `.bars` (`index.html:370-371`) are entirely missing from `session_detail_screen.dart`. HIGH.
- No `BestProtocol` / `SleepCorr` 2-card row should appear here (those are `#insights`); Flutter correctly omits those. ✓

### Gaps (pixel-faithful deltas)
- **Big gradient score block missing** — mockup 70px w800 heat→cold text-clipped `82` (`index.html:137, 368`); Flutter only renders a 32px score within `_RecoveryRow` (and only if recoveryScore is set) (`session_detail_screen.dart:273-285`). HIGH.
- **Green OK strapline missing** — mockup `.s` “STRONG · Standard Recovery” 14px w800 `var(--ok)` (`index.html:138, 368`); not present in `session_detail_screen.dart`. HIGH.
- **List `.card.list` 5 rows missing** — Duration / Rounds / Max heat / Min cold / HRV after with `border-bottom` dividers (`index.html:139-140, 369`); Flutter renders `_HeroCard` + `_StatGrid` 4 tiles + `_RecoveryRow` + `_NoteCard` (`session_detail_screen.dart:99-119`). HIGH.
- **No `.sec-t` “Phase breakdown”** (`index.html:370`); not in `session_detail_screen.dart`. HIGH.
- **No `.bars` 6-cell breakdown** (`index.html:371`); not in `session_detail_screen.dart`. HIGH.
- **Hero card radius** — Flutter `_HeroCard` radius 16 with 1px line (`session_detail_screen.dart:137-140`); mockup `.card` is `var(--r)=20px` (`index.html:32`). MED.
- **Title style** — Flutter hero title 28px w700 ls `-.5` lightInk (`session_detail_screen.dart:148-155`) ≠ mockup score 70px w800 ls implied 0 with gradient fill (`index.html:137`). Reiterating HIGH.
- **Stat label/value sizes** — Flutter label 11px w600 ls 1.1 + value 22px w700 (`session_detail_screen.dart:218-237`) vs mockup 13px w500 list atom (`index.html:139`). MED-HIGH.

### Severity
- **HIGH** — the detail screen does not match the `#detail` mockup structure at all: it omits the large 70px gradient score with the green strapline, the 5-row listmetrics, the `.sec-t` heading, and the 6-bar phase breakdown. The `_HeroCard` + `_StatGrid` 2×2 layout is a completely different IA.

