# Cluster B Audit — Session flow, Coach, Journal, Achievements, Challenges, Referral

**Scope:** 8 Flutter screens in cluster B audited against the v4 HTML mockup at `docs/mockups/v4/index.html` (lines 113–416) and tokens defined at `docs/mockups/v4/index.html:9-12`. The HTML mockup is treated as the **ground truth** per task spec; `describe_image` is supplementary and was not invoked in this environment (the `describe_image_describe_image` MCP tool was not exposed here), so all hex/weight/radius figures below are quoted directly from the mockup CSS and the linked Dart source lines.

**Convention:** `filename:line` references point at the Flutter source. Mockup CSS line numbers are quoted as `index.html:NN`. All colors are hex; weights are Flutter `FontWeight.w###` (200=UltraLight, 500=Medium, 600=Semibold, 700=Bold, 800=ExtraBold).

---

## Summary table

| # | Screen | File | Severity | Biggest gap |
|---|---|---|---|---|
| 1 | Active Session | `active_session_screen.dart` + `session_timer.dart` | **HIGH** | Background is a 2-stop linear gradient, not the radial-gradient(120% 80% at 50% 0%, #7a2a0e→#0c0c0e) warm / #0d3a7a cold spec — `ActiveSessionBackground._gradientForPhase` (session_timer.dart:360-383) ignores `AppGradients.sessionWarm/sessionCold`. |
| 2 | Session Summary | `session_summary_screen.dart` + `recovery_score.dart` | **HIGH** | Score typography is wrong (96px w200 vs spec 70px w800), score label "STRONG" is missing the literal "RECOVERY" from "STRONG RECOVERY" (recovery_score.dart:11-15), and the 4-row insight list-card (HRV/trend/Best time/Heat target/New record) is replaced with 3 generic `AppCard` insight rows. |
| 3 | Share Card | `share_card_screen.dart` + `share_card_painter.dart` | **HIGH** | Big "82" is rendered as flat `Colors.white` 96px w800 text, not the heat→cold2 gradient text-clip spec (#FF6B35→#5B9CFF, 60px w800). Card uses `heroDark` (#12121A→#25252F) instead of `share` spec `linear-gradient(150deg, #12121a, #3a1e12)`. No Instagram/WhatsApp buttons — replaced by one generic `FilledButton` "Share to...". |
| 4 | Coach | `coach_screen.dart` | **HIGH** | Me bubble is solid `AppColors.heat` (#FF6B35) not the heat→coral linear-gradient(120deg, var(--heat), var(--coral)) (#FF6B35→#FF8A65) spec — coach_screen.dart:96. AI bubble has no border, no `bottom-left 5px` corner, and uses `surfaceContainerHigh` (= #ECEEF2) instead of card bg + 1px line border. No "Start recommended" / "Why?" chips below AI messages. App bar uses generic `titleLarge` 20/700, not appbar h2 19/800 spec. |
| 5 | Journal | `journal_screen.dart` | **MED** | Entry card uses generic `Card(color: surfaceContainerHigh, radius 20, elevation 0)` — close to spec (radius 20, 1px line border) but missing the explicit 1px `line` border. Date/mood header formats differ: mockup says "TODAY · 9:12 AM" 11px ink3 w700 — Flutter renders `MM/DD` 13px outline w700 + `Mood` 13px outline w600 side by side. No "🙌 Felt amazing"-style emoji+title row; the entry is one Row(emoji | column). "+ New entry" is a FAB, not a `.btn` heat-gradient full-width button. Empty-state uses "📝" instead of the share/inbox icon system; mockup has no journal empty-state. |
| 6 | Achievements | `achievements_screen.dart` | **HIGH** | Level card is entirely missing (mockup index.html:377 — "Level 4 · Frostwalker … 720 XP" + 8px XP bar 72% heat→coral). Grid is 2-col, not the 3-col spec. Locked badge uses `Theme.of(context).colorScheme.outline` for both emoji+name (achievements_screen.dart:167-171) instead of the spec `opacity:.4; filter:grayscale(1)` (index.html:155). Badge emoji is 36px w700-aligned left vs mockup 26px centered. No `.e` 26px emoji block + 10px w700 label `.small` pattern. |
| 7 | Challenges/Community | `challenges_screen.dart` | **MED** | Hero uses `AppGradients.splashBg` (heat→purple→cold 3-stop) not the mockup `.hero` cold/dark pattern (#12121a→#25252f) with the cold-blue box-shadow `0 20px 40px -18px rgba(45,124,241,.5)` override at index.html:391. Mockup's "❄️ Cold Streak Challenge · 1,240 people joined · 3 days left" weekly hero is replaced with a generic favorited-tile list rendered from `assets/challenges.json`. Leaderboard row format diverges ("#N displayName N pts" vs "N emoji Name … N") and the "🔥 You" heat accent + "Invite friends →" cold-gradient `btn.cold` are missing. |
| 8 | Referral | `referral_screen.dart` | **HIGH** | Referral code box is wrong on multiple dimensions: (a) `CC-XXXX` computed hash format, not literal `AASHEESH50` mockup demo; (b) JetBrains Mono 30px w800 letterSpacing 1.5, but mockup calls for JetBrains Mono 26px w500 letterSpacing 2 color #FF6B35 (index.html:166); (c) code renders inside a `Card` with solid 1.5px heat `side`, but spec is `2px dashed var(--heat)` border-radius 14px padding 14 (the dashed style is the dominant visual hook and is missing). Header card also lacks the 34px "🎁" emoji + "Give a month, get a month" centered layout spec; it uses a left-aligned `_HeroHeader` gradient strip instead. |
| — | Breathwork | (no Flutter file) | **HIGH** | **Missing screen.** Mockup view `#breath` (index.html:318-324) — deep-blue gradient (160deg #0a2a5c→#0c0c0e), 170px breathing orb (radial-gradient at 40% 35%, #8fc0ff→#2D7CF1 60%→#1a4fa0, 8s scale .65↔1, 60px box-shadow rgba(45,124,241,.6)), "INHALE/HOLD/EXHALE" 22px w800, "Box breathing" 13px w800 letterSpacing 3 — has no corresponding Flutter screen. |

---

## 1. Active Session — `active_session_screen.dart`

### Mockup (verified — `index.html:113-130, 308-315`)
- Bg `.session` = `radial-gradient(120% 80% at 50% 0%,#7a2a0e,#0c0c0e)` (warm); `.session.cold` = `radial-gradient(120% 80% at 50% 0%,#0d3a7a,#0c0c0e)`; 1.1s bg transition.
- Phase label: `letter-spacing:5px`, `font-weight:800`, `font-size:20px`, content "SAUNA" / "COLD PLUNGE".
- Phase sub: `font-size:12px;opacity:.6;font-weight:600;margin-top:4px`, content "Phase 2 of 6".
- Timer ring: 228×228 SVG, viewBox 0 0 228 228, `r=103`, `stroke-width=10`, base ring stroke `rgba(255,255,255,.14)`, progress ring stroke `#fff`, `stroke-linecap:round`, `stroke-dasharray:647`, `stroke-dashoffset` animates with progress, SVG rotated -90deg via `.ringwrap svg{transform:rotate(-90deg)}`.
- Timer number `.tnum .t` = JetBrains Mono weight 200, font-size 56px, letter-spacing -2px.
- Round indicator `.tnum .r` = 11px, opacity .7, weight 600, letter-spacing 1px, content "ROUND 2 / 3".
- Controls `.ctrls` = flex gap 12, width 82%, two buttons. `.cbtn` (cold/default) = `flex:1`, radius 15, padding 14, weight 800, size 14, `border:1px solid rgba(255,255,255,.35)`, `background:rgba(255,255,255,.12)`, color #fff. `.cbtn.warm` = `background:#fff;color:var(--heat);border:none;` — warm phase toggles cbtn to white-bg heat-color.
- Buttons labeled "Pause" + "Next phase" (warm phase = `cbtn.warm`).
- Mic indicator `.mic` = `gap:8;font-size:13px;opacity:.85`, `.dot` = 9×9 white circle, `pulse` animation 1.6s box-shadow 0→13px rgba(255,255,255,.5)→0.
- Exit button `.exit` = absolute top 56 right 18, white-14% bg, 34×34, border-radius 50%, font 16, content "✕".
- Phase pills at top: not in the mockup HTML — the mockup shows only phase label + psub centered; no SAUNA/COLD/REST/ACTIVE pill row.

### Flutter implementation (source-read findings)
- `active_session_screen.dart:499-501` wraps a transparent Scaffold in `ActiveSessionBackground(phaseType: ..., child: Scaffold(backgroundColor: Colors.transparent, body: SafeArea(child: Stack(...))))`.
- `session_timer.dart:344-358` `ActiveSessionBackground` builds `AnimatedContainer(duration: 800ms, decoration: BoxDecoration(gradient: _gradientForPhase))`.
- `session_timer.dart:360-383` `_gradientForPhase` returns **LinearGradient topLeft→bottomRight**:
  - saona: `[AppColors.brandWarm (#FF6B35), AppColors.brandCoral (#FF8A65)]` — NOT radial, NOT #7a2a0e→#0c0c0e.
  - cold: `[Color(0xFF2D7CF1), Color(0xFF64B5F6)]` — NOT radial, NOT #0d3a7a→#0c0c0e.
  - rest: `[midGray (#9AA0A8), warmBeige (#EEF0F5)]`.
  - custom: `[brandWarm, #2D7CF1]`.
- The dedicated `AppGradients.sessionWarm` / `AppGradients.sessionCold` radials (gradients.dart:82-97) with the correct colors #7A2A0E/#0D3A7A and `AppColors.lightInk` base **are defined but not used by `ActiveSessionBackground`** — a real regression.
- Top row `active_session_screen.dart:507-521` renders a `PhasePill` per `PhaseType` (sauna/cold/rest — `where((t) => t != PhaseType.custom)`) horizontally centered. Mockup shows no pill row at all.
- Center `:523-539` wraps `SessionTimer` in `BreathingCircle(size: 240, color: phase==cold?cold:heat)` — a circular breathing-scale widget (animation_utils.dart:114-184) with `color.withOpacity(0.15)` fill. Not in mockup; mockup shows a thin SVG ring with no breathing circle behind it.
- `SessionTimer` (session_timer.dart:9-262) renders:
  - Phase label: 13px w700 letterSpacing 2 (`:107-114`) — mockup is 20px w800 letterSpacing 5.
  - Target temp row: `'Target ${target}°C'` 13px w500 opacity .75 (`:117-128`) — not in mockup.
  - Timer number: `AppTypography.timerHero.copyWith(color: white)` — `timerHero` is JetBrains Mono 200px w100 letterSpacing -4 (app_typography.dart:158-165), NOT 56px w200 letterSpacing -2. The `copyWith` doesn't override size — it inherits 200px. Looks like a leftover from a different layout (the `size` is 200 in typography but the parent `SizedBox(width:240)` and the breathing circle clamp may shrink it visually — but the typestyle still says 200 w100 w/ -4 letter-spacing).
  - Phase progress: a 240-wide horizontal mini-bar (`SizedBox(width:240, ClipRRect radius 999, height 4, FractionallySizedBox)`) gradient phase-tint→white (`:135-162`) — not in mockup (mockup shows a circular SVG ring).
  - Round indicator `'Round ${currentRound} of ${totalRounds}'` 13px w500 letterSpacing 0.4 opacity .75 (`:164-173`) — mockup content is "ROUND 2 / 3" (uppercase + slash), 11px w600 opacity .7 letterSpacing 1.
  - "Session" label + percentage + horizontal 3px overall progress bar (`:174-232`) — not in mockup.
  - Two `_RoundIconButton`s (pause + mic), 72×72, white-16% bg, Icon size 28 (`:234-286`) — mockup's mic is a small `9×9` pulsing dot inline with "Say next phase" captioned text; mockup has no ring icon button row.
  - Caption "Say 'next phase' or tap pause" 12px w500 (`:249-257`) — differs from mockup's `'Say next phase'` (no "or tap pause").
- Bottom row `active_session_screen.dart:541-610`:
  - Phase indicator text "'Phase ${n} of ${n} · Round ${n} of ${n}'"` 12px w600 letterSpacing 0.5 opacity .7 (`:548-556`) — mockup shows phase label + psub split, not this combined string.
  - Three buttons: Pause/Resume (`AppButtonVariant.secondary` = surface bg + outline border), "Skip", "+30s" (`:559-594`) — mockup has 2 buttons "Pause" + "Next phase" (warm = white-bg heat-color, cold = white-12%-bg + 1px white-35% border). No "Skip" or "+30s" in mockup.
  - "End session" `TextButton` 14px w600 letterSpacing 0.5 (`:596-607`) — mockup exit is the top-right 34×34 ✕ button, not a bottom text button.
- Exit (top-right 34×34 white-14% 50%-radius ✕ button) is **not implemented** — mockup `:130, 309`.

### Gaps (pixel-faithful deltas)
1. **HIGH** — Bg gradient is a 2-stop linear gradient, not radial-gradient(120% 80% at 50% 0%, #7a2a0e, #0c0c0e); cold phase uses blue→lighter-blue not #0d3a7a→#0c0c0e radial. `AppGradients.sessionWarm/sessionCold` already match the spec but are unused (session_timer.dart:360-383 vs gradients.dart:82-97).
2. **HIGH** — Timer number typestyle is `timerHero` = JetBrains Mono 200px w100 letterSpacing -4, not spec 56px w200 letterSpacing -2 (session_timer.dart:132 + app_typography.dart:158-165).
3. **HIGH** — Timer is a horizontal 240-wide 4px progress bar, not a 228×228 circular SVG ring with r=103, stroke-width 10, dasharray 647, rotated -90deg (session_timer.dart:135-162 vs index.html:118-122).
4. **HIGH** — Phase label is 13 w700 letterSpacing 2, not 20 w800 letterSpacing 5 (session_timer.dart:107-114).
5. **HIGH** — Round indicator content "Round N of N" + 13 w500 vs spec "ROUND N / N" + 11 w600 letterSpacing 1 opacity .7 (session_timer.dart:164-173).
6. **HIGH** — Control buttons: there are 3 secondary-style buttons (Pause/Resume, Skip, +30s) with surface bg + outline border, instead of 2 `.cbtn` buttons (Pause + Next phase) with warm-phase variant: white-bg, heat-color text, no border; cold-phase variant: white-12% bg, white-35% 1px border, white text (active_session_screen.dart:559-594 vs index.html:124-126, 313).
7. **HIGH** — Mic component is a 72×72 white-16%bg ring icon-button (Icon `Icons.mic_none_rounded` 28px), not the inline 9×9 pulsing white dot captioned `'Say next phase'` with 1.6s box-shadow pulse animation (session_timer.dart:234-247 vs index.html:127-129).
8. **HIGH** — Exit button (top-right 34×34 white-14% 50%-radius ✕) is missing — instead there's a bottom "End session" TextButton + a confirm dialog (active_session_screen.dart:596-607, 404-428 vs index.html:130, 309).
9. **MED** — `PhasePill` row at top (sauna/cold/rest pills) is not in mockup (active_session_screen.dart:507-521 vs index.html:308-315).
10. **MED** — Extra "Target ${temp}°C", "Session" row + overall % progress bar, and "Say 'next phase' or tap pause" caption are all present in Flutter but absent in mockup (session_timer.dart:117-128, 174-232, 249-257).
11. **MED** — `BreathingCircle` 240px breathing scale wrapper behind the timer has no mockup equivalent — mockup timer ring does not breathe (active_session_screen.dart:524-538 vs index.html:312).
12. **LOW** — Phase label content `Switch (_phaseLabel)` includes "COLD PLUNGE" + "REST" + "CUSTOM" — mockup only ever renders "SAUNA" (HTML is hard-coded). Minor diff for cold phase, expected.

### Severity
**HIGH** — Background, timer typestyle, timer shape (linear bar vs SVG ring), control button count/style, mic component, and exit button all diverge materially from the mockup. This screen needs the most rework of cluster B.

---

## 2. Session Summary — `session_summary_screen.dart`

### Mockup (verified — `index.html:136-141, 327-334`)
- Top text "🎉 Complete · 26:40 · 3 rounds" — 13px var(--ink2) weight 600, centered.
- Score `.score .n` = 70px weight 800, `background:linear-gradient(120deg,var(--heat),var(--cold))` text-clip (color transparent), line-height 1.
- Score sub `.score .s` = `color:var(--ok)` (#33C27F) weight 800 size 14, letterSpacing .5, margin 6/0/14. Content "STRONG RECOVERY".
- List `.card .list` = 4 rows:
  - "📈 `7-day HRV trend +12%`" (the "7-day HRV trend +12%" is bold)
  - "⏰ Best time: `mornings`"
  - "🌡️ Heat target hit this week"
  - "🏅 New record: longest sauna phase"
  - Each row `.list div { display:flex; gap:10px; align-items:center; padding:12px 0; border-bottom:1px solid var(--line); font-size:13px; font-weight:500 }`; last row no border.
- Journal card `.card` (margin-top:12px): "📝 How did it feel?" bold 13px, then a row with 3 `.chip`s: "😩 Tough" / "🙌 Great" (selected `.chip.on` heat bg) / "😌 Calm". Chip default `.chip = card bg, 1px line border, radius 20, padding 8/13, size 12 w700`; `.chip.on = heat bg, white text, heat border`.
- Primary "Save session" `.btn` (heat→coral gradient, white text).
- Row of two `.ghost` buttons beneath: "Share card 📤" + "Start another". `.ghost = flex:1, radius 14, padding 13, weight 800, size 13, 1px line border, card bg, ink text`.
- No app bar (this is a "view" not a routed screen).
- No Recovery Score card elevation/shadow.

### Flutter implementation (source-read findings)
- `session_summary_screen.dart:107-108` Scaffold uses `Theme.of(context).colorScheme.surfaceContainer` (= #ECEEF2 light line in light_theme.dart:19) — light-bg screen, not the white card-on-bg look of mockup.
- Top of body `:158-193`:
  - `_Celebration()` = 80×80 successSoft (#D7F2E3) filled circle with 40px check icon (`_Celebration` widget at `:277-295`) — not in mockup.
  - "Session complete." text 32px w800 letterSpacing -0.5 height 1.1 center (`:171-182`) — mockup's top text is "🎉 Complete · 26:40 · 3 rounds" 13px w600.
  - Subtext `${duration} · ${roundsCompleted}/${protocolRounds} rounds` 15px w500 onSurfaceVariant (`:184-193`) — mockup combines time + rounds into the same 13px ink2 line.
- `RecoveryScoreCard` (`recovery_score.dart:7-74`):
  - Score number `:27-41`: `ShaderMask` w/ `AppGradients.scoreText` (heat→cold horizontal, gradients.dart:99-104) → heat→cold text-clip — *correct colors & gradient orientation, but*: fontSize **96**, fontWeight **w200** (`:33-40`). Mockup = 70px w800.
  - 48×2px onSurface-colored divider bar (`:43-47`) — not in mockup.
  - Band label `LOW`/`MODERATE`/`STRONG` (`:11-21`) — that's just "STRONG", not "STRONG RECOVERY" as mockup has. Color for strong = `AppColors.success` (= #33C27F, matches --ok), 12px w700 letterSpacing 1.4 (`:49-58`). Mockup = 14px w800 letterSpacing .5.
  - Insight text `score.insight` 14px w500 height 1.45 center (`:60-70`) — not in mockup (mockup has no insight paragraph).
- Three insight rows (AppCard radius 20) `:197-218`:
  - LucideIcons.check (heat color) + "Plan adherence" + `% of planned rounds completed`
  - LucideIcons.flame (coral) + streak banner + streak subtitle
  - LucideIcons.timer (cold) + total time tracked + `${minutes} minutes across ${sessions} sessions`
  - Each row is a rounded AppCard with a 48×48 icon-tinted container at radius 14 (`_InsightRow` `:297-357`).
  - Mockup rows are *flat* list rows inside a card (12px vertical padding, 1px line border-bottom) with emoji prefixes (📈 ⏰ 🌡️ 🏅), not standalone icon-cards. The Flutter content and styling are entirely different.
- Buttons row `:220-241`: `Share` (secondary variant = surface bg, outline border, with `LucideIcons.share2` leading icon) + `Done` (warm variant = heat bg, white text, fullWidth). Mockup has primary `Save session` (heat gradient) + two ghost buttons "Share card 📤" + "Start another".
- `CelebrationOverlay` confetti behind the body `:244-248` — not in mockup.
- `_formatDuration` returns "Xm Ys" (`:93-98`) — mockup uses "26:40" mm:ss format.

### Gaps (pixel-faithful deltas)
1. **HIGH** — Score number fontSize 96 w200 (recovery_score.dart:33-40) ≠ spec 70 w800 (index.html:137). The weight is *ultralight* vs spec *extrabold* — opposite extremes.
2. **HIGH** — Score band label "STRONG" (recovery_score.dart:11-15) ≠ spec "STRONG RECOVERY" (index.html:329). Missing the literal word "RECOVERY". Also fontSize 12 w700 letterSpacing 1.4 vs spec 14 w800 letterSpacing .5 (recovery_score.dart:49-58 vs index.html:138).
3. **HIGH** — Insight list-card with 4 rows (HRV / Best time / Heat target / New record) is entirely missing. Replaced with 3 generic icon+titled AppCards ("Plan adherence" / streak / "Total time tracked"). Content, layout, and styling all diverge (session_summary_screen.dart:197-218 vs index.html:330).
4. **HIGH** — Journal "📝 How did it feel?" + 3 mood chips ("😩 Tough" / "🙌 Great" `.on` / "😌 Calm") is missing. There's no journal chip row on this screen at all (mockup index.html:331). Mood selection on this screen is entirely absent.
5. **HIGH** — Buttons row is wrong: Flutter = `Share` (secondary) + `Done` (warm), 2 buttons. Mockup = `Save session` (primary heat-gradient .btn) + 2 ghost buttons `Share card 📤` + `Start another`, 3 buttons total (session_summary_screen.dart:220-241 vs index.html:332-333).
6. **HIGH** — Top text `🎉 Complete · 26:40 · 3 rounds` (13px ink2 w600) is missing. Flutter has "Session complete." 32px w800 + a 15px w5 subtext as two separate lines (session_summary_screen.dart:171-193 vs index.html:328).
7. **MED** — `_Celebration` (80×80 successSoft circle with check icon) at the top has no mockup equivalent (session_summary_screen.dart:278-295). Likewise `CelebrationOverlay` confetti (`:244-248`).
8. **MED** — Duration format "Xm Ys" vs mockup "26:40" mm:ss (`_formatDuration` session_summary_screen.dart:93-98 vs index.html:328).
9. **MED** — Recovery score insight paragraph (14px w500) is present but not in mockup (recovery_score.dart:60-70).
10. **LOW** — Scaffold bg uses `surfaceContainer` (#ECEEF2 in light theme) but mockup implied `var(--bg)` (#EEF0F5) — close, off by a few hex (light_theme.dart:19).

### Severity
**HIGH** — The screen captures the *idea* of the summary (score + insights + share/save) but renders the wrong score typography, wrong score label, wrong insight content, missing journal chip row, missing `🎉 Complete…` header, and wrong button trio. A near-complete redesign is needed for parity.

---

## 3. Share Card — `share_card_screen.dart`

### Mockup (verified — `index.html:181-182, 337-341`)
- Mobile app bar `.appbar`: `.bk` = 36×36 radius 12, 1px line border, card bg, center `‹` 18px; `h2` "Share card" 19 w800 letterSpacing -.4.
- Share card container `.share`:
  - `border-radius:24px; padding:26px 22px; background:linear-gradient(150deg,#12121a,#3a1e12); color:#fff; text-align:center; box-shadow:var(--elev)` (var(--elev) = `0 8px 24px -16px rgba(20,20,45,.28)` in light).
  - Top tiny label "CONTRASTCOACH" 12px opacity .7 letterSpacing 2 weight 700.
  - Big number `.share .n` = `font-size:60px; font-weight:800; background:linear-gradient(120deg,var(--heat),var(--cold2))` text clip → #FF6B35→#5B9CFF. Content "82".
  - "Recovery · Strong 🔥" 700 weight centered.
  - "26:40 · 3 rounds · 7-day streak" `.8 opacity 13px, margin-top:8px`.
  - `🌡️❄️🌡️❄️` 22px emoji row margin-top 16px.
- Two buttons side-by-side in `.row` margin-top 14: `.btn` "Instagram" (heat→coral gradient, heat shadow) + `.btn.cold` "WhatsApp" (cold→cold2 gradient, cold shadow).
- No "Done" text-button in mockup.

### Flutter implementation (source-read findings)
- `share_card_screen.dart:131-191`:
  - `Scaffold(appBar: ContrastAppBar(title: 'Share', showBackButton: true), body: Center(Padding(horizontal 24 vertical 32 Column(center)))`.
  - `ContrastAppBar.title = 'Share'` not `'Share card'` (app_bar.dart:7-62 — title fontSize 20 w700 vs appbar h2 19 w800; back button is CircleBorder round not 12px square radius).
- Renders `ShareCardPainter` (share_card_painter.dart:8-102):
  - `Container(width: 320, height: 480, decoration: BoxDecoration(gradient: AppGradients.heroDark, borderRadius: BorderRadius.circular(26)), padding: EdgeInsets.all(24))`.
  - `AppGradients.heroDark` = `LinearGradient(topCenter→bottomCenter, [#12121A, #25252F])` (gradients.dart:54-58) — direction is vertical 90deg, *not* 150deg, and stop #2 is `#25252F` not `#3a1e12` as mockup demands.
  - Border radius 26 vs spec 24.
  - Padding `EdgeInsets.all(24)` (symmetric 24) vs spec `26 22` (asymmetric).
  - Top row: left "ContrastCoach" 16 w700 white (`:48-58`) + right `Icons.local_fire_department` heat 22px — mockup is centered "CONTRASTCOACH" 12 w700 letterSpacing 2 opacity .7 in caps.
  - Big number `AppTypography.titleLarge.copyWith(fontSize: 96, fontWeight: w800, color: Colors.white)` (`:62-72`) — flat white 96px text, NOT 60px heat→cold2 gradient text clip.
  - "RECOVERY SCORE" label `AppTypography.labelMediumV4?.copyWith(color: heat, letterSpacing: 2)` (`:74-81`) — but mockup line is "Recovery · Strong 🔥" (700 weight, no uppercase, no letterSpacing 2).
  - Below: 4 `_Row` label/value rows (Goal / Duration / Rounds / Streak) each label bodyLargeV4 13 white70 + value bodyLargeV4 w600 white (`:84-122`) — mockup shows "26:40 · 3 rounds · 7-day streak" as a single 13px line, not a 4-row table.
  - No `🌡️❄️🌡️❄️` emoji row.
- Below the painter (`share_card_screen.dart:159-186`):
  - 52-tall `FilledButton.icon(buttons background: heat, foreground: white, radius 16)` "Share to..." or "Sharing…" with spinner — single button. Mockup has 2 buttons: "Instagram" (heat gradient) + "WhatsApp" (cold gradient).
  - `TextButton` "Done" (`:183-186`) — not in mockup.
- The screen does have a functional PNG-share path (capturePng + shareXFiles, `:114-128`) which the mockup's "Shared to Instagram/WhatsApp" toasts imply — the implementation plumbs the system share sheet, which is reasonable, but visually the in-app presentation diverges.

### Gaps (pixel-faithful deltas)
1. **HIGH** — Big "82" is flat `Colors.white` 96 w800 text, not `linear-gradient(120deg, var(--heat), var(--cold2))` text-clip (`#FF6B35→#5B9CFF`) at 60px w800 (share_card_painter.dart:62-72 vs index.html:182). Both the size (96 vs 60) and color treatment (flat vs gradient-clip) are wrong.
2. **HIGH** — Card gradient is `heroDark` (top→bottom 90deg, #12121A→#25252F), not `linear-gradient(150deg, #12121a, #3a1e12)` (share_card_painter.dart:38 vs index.html:181). Direction and stop-2 color both wrong.
3. **HIGH** — Card radius 26 vs spec 24 (share_card_painter.dart:39 vs index.html:181).
4. **HIGH** — Card padding symmetric 24 vs spec 26/22 vertical/horizontal (share_card_painter.dart:41 vs index.html:181).
5. **HIGH** — Top-left brand "ContrastCoach" 16 w700 white + fire icon ≠ centered "CONTRASTCOACH" 12 w700 letterSpacing 2 opacity .7 (share_card_painter.dart:48-58 vs index.html:339).
6. **HIGH** — "RECOVERY SCORE" caption 13 w600 + heat color letterSpacing 2 ≠ mockup "Recovery · Strong 🔥" 700 weight (share_card_painter.dart:74-81 vs index.html:339).
7. **HIGH** — 4-row label/value table (Goal / Duration / Rounds / Streak) ≠ mockup single 13px ".8 opacity" caption "26:40 · 3 rounds · 7-day streak" (share_card_painter.dart:84-97 vs index.html:339).
8. **HIGH** — `🌡️❄️🌡️❄️` 22px emoji row is missing (share_card_painter.dart, no equivalent; index.html:339).
9. **HIGH** — Bottom buttons: Flutter renders one `FilledButton.icon` "Share to..." (heat 16-radius 52-tall) + a "Done" TextButton. Mockup has 2 side-by-side `.btn` buttons: "Instagram" (heat→coral gradient) + "WhatsApp" (cold→cold2 gradient), no "Done" (share_card_screen.dart:159-186 vs index.html:340).
10. **MED** — App bar title "Share" vs spec "Share card"; title 20 w700 + round 36×36 back btn vs appbar h2 19 w800 + 12px-radius square back bk (app_bar.dart:7-66 vs index.html:26, 28, 338).
11. **LOW** — Card width 320 / height 480 are fixed and may not match the mockup's fluid card width — mockup doesn't constrain pixel width, so 320 is plausible but the 480 fixed height forces a tall portrait aspect not present in mockup.

### Severity
**HIGH** — Both the in-card visuals (gradient direction/color, big-number gradient clip, brand line, subtext, emoji row, button pair) and the action button row diverge significantly. The screen functionally shares but looks nothing like the v4 share card.

---

## 4. Coach — `coach_screen.dart`

### Mockup (verified — `index.html:163-165, 404-410`)
- No app bar header in mockup — `.name` "Coach" 28 w800 letter-spacing -.7 margin-bottom 16 line-height 1.1 (`.name` class index.html:30).
- AI message `.msg.ai`:
  - `max-width:80%; padding:11px 14px; border-radius:16px; font-size:13px; font-weight:500; margin-bottom:10px; line-height:1.5; background:var(--card) (#FFFFFF); border:1px solid var(--line) (#ECEEF2); border-bottom-left-radius:5px`.
  - First AI message: "Morning! Your HRV is up 12% — a great day for a full 3-round Standard Recovery. Want me to start it?"
- Me message `.msg.me`:
  - `background:linear-gradient(120deg,var(--heat),var(--coral))` (#FF6B35→#FF8A65); `color:#fff; margin-left:auto (right aligned); border-bottom-right-radius:5px`.
  - Same padding/radius/value size as `.msg.ai` minus border.
  - User message: "How long should I stay in the cold?"
- Second AI message: "For your level, 90–120s at ~12°C per round is ideal. I'll cue you when to get out. ❄️"
- Chip row below messages `:409` `.row{margin-top:6px;flex-wrap:wrap}` containing `.chip` "Start recommended" + `.chip` "Why?" — default chip style = card bg, 1px line border, radius 20, padding 8/13, size 12 w700.
- No text input field is shown in the mockup view (the mockup is a static snapshot — it shows a conversation, not the composer, but conceptually the composer is implied).

### Flutter implementation (source-read findings)
- `coach_screen.dart:142-205` Scaffold: `appBar: ContrastAppBar(title: 'Coach', showBackButton: true)`, body `Column[ Expanded(ListView.builder) + SafeArea(bottom composer) ]`.
- `ContrastAppBar` title 20 w700 (app_bar.dart:30-34) — mockup `.name` "Coach" is 28 w800 letter-spacing -.7 (index.html:30, 405). Different size, weight, no app bar in mockup.
- Bubble widget `_bubble(message)` (coach_screen.dart:91-138):
  - `align = isUser ? end : start`
  - `bg = isUser ? AppColors.heat (solid #FF6B35) : Theme.of(context).colorScheme.surfaceContainerHigh` (= #ECEEF2 in light_theme.dart:19). Mockup: me = heat→coral *gradient*; ai = `var(--card)` (#FFFFFF) + `1px var(--line)` border.
  - `fg = isUser ? Colors.white : AppColors.lightInk` — correct for both.
  - `radius = isUser ? topLeft 16 + topRight 16 + bottomLeft 16 + bottomRight 4 : topLeft 4 + topRight 16 + bottomLeft 16 + bottomRight 16`. Mockup: me = radius 16 with bottom-right 5px; ai = radius 16 with bottom-left 5px. So:
    - me: Flutter bottomRight = 4 (close to mockup 5)
    - ai: Flutter bottomLeft = 16, missing the spec `5px` corner — Flutter gives topLeft 4 instead. The "asymmetric corner" is on the wrong side for AI bubbles.
  - Container: no border on either bubble (no `BoxDecoration.border`). Mockup requires 1px line border on `.msg.ai` only.
  - Padding `EdgeInsets.symmetric(horizontal 14, vertical 10)` — mockup is `11 14` (horizontal 14, vertical 11). Off by 1 on vertical.
  - Text style `TextStyle(color: fg, fontSize: 15, height: 1.4)` — mockup is `font-size:13px; font-weight:500; line-height:1.5`. Wrong size (15 vs 13), missing weight 500 (default 400), wrong line-height (1.4 vs 1.5).
  - ConstrainedBox `maxWidth: 0.75 * width` — mockup `.msg` max-width 80%.
- No "Start recommended" / "Why?" chip row beneath any AI message.
- Composer `:154-202`: container with surface bg + top divider line (not in mockup), text field `OutlineInputBorder` w/ hint "Ask your coach...", send `IconButton(Icons.send, color: heat)` — functional but mockup-style composer is implied not shown.
- Initial seed message `_messages.add(CoachMessage(...'Hi! I\'m your contrast therapy coach. Ask me about heat, cold, recovery, or sleep protocols.'))` (`:30-37`) — content differs from mockup AI seed "Morning! Your HRV is up 12% — a great day for a full 3-round Standard Recovery. Want me to start it?"

### Gaps (pixel-faithful deltas)
1. **HIGH** — Me bubble is solid `AppColors.heat` #FF6B35, not `linear-gradient(120deg, #FF6B35, #FF8A65)` (heat→coral) (coach_screen.dart:95-96 vs index.html:165). The horizontal heat→coral gradient is a core v4 token and is missing.
2. **HIGH** — AI bubble has no border (coach_screen.dart:122-126 has no `Border` on `BoxDecoration`) — mockup requires `1px var(--line)` (#ECEEF2) border on `.msg.ai` only (index.html:164).
3. **HIGH** — AI bubble uses `surfaceContainerHigh` (#ECEEF2) not `var(--card)` (#FFFFFF) (coach_screen.dart:96, light_theme.dart:19 vs index.html:164).
4. **HIGH** — Asymmetric corner is on the wrong side for AI bubbles: Flutter gives AI `topLeft:4`, mockup gives AI `bottom-left:5px`. Flutter gives me `bottomRight:4` (close to spec 5). The mockup intent is "flat corner toward the speaker" — for AI that's bottom-left, for me that's bottom-right. Flutter has it inverted for AI (coach_screen.dart:99-111 vs index.html:164-165).
5. **HIGH** — Bubble text style 15/400/1.4 vs spec 13/500/1.5 (coach_screen.dart:129-132 vs index.html:163). Size, weight, line-height all wrong.
6. **HIGH** — No "Start recommended" + "Why?" chip row beneath AI replies (index.html:409 entirely absent).
7. **HIGH** — Initial AI seed message content differs — Flutter "Hi! I'm your contrast therapy coach…" vs mockup "Morning! Your HRV is up 12% — a great day for a full 3-round Standard Recovery. Want me to start it?" (coach_screen.dart:33-34 vs index.html:406).
8. **HIGH** — App bar present with title "Coach" 20 w700 + round back button; mockup has no app bar, just `.name` "Coach" 28 w800 (coach_screen.dart:143 + app_bar.dart vs index.html:30, 405).
9. **MED** — Bubble maxWidth 0.75 width vs mockup 80% (coach_screen.dart:120 vs index.html:163).
10. **MED** — Bubble padding 14/10 vs spec 14/11 (coach_screen.dart:128 vs index.html:163).
11. **MED** — Composer is a styled Material text field with OutlineInputBorder; mockup doesn't show a composer at all (the snapshot is conversation-only). Verdict: functionally reasonable but visually unverified.

### Severity
**HIGH** — The me-bubble gradient, AI-bubble border, AI-bubble bg color, asymmetric-corner orientation, text typography, absence of chip suggestions, and app-bar presence all diverge from the v4 coach mockup.

---

## 5. Journal — `journal_screen.dart`

### Mockup (verified — `index.html:399-400`)
- App bar `.appbar`: `.bk` 36×36 radius 12 1px line border + `‹`; `h2` "Journal" 19 w800 letter-spacing -.4.
- One `.card` margin-bottom 10:
  - Header line "TODAY · 9:12 AM" — 11px var(--ink3) (#9AA0A8) weight 700.
  - Title line "🙌 Felt amazing" — 14 weight 700, margin 4 0.
  - Body "Cold plunge cleared my head before work." — 13px var(--ink2) (#6B6E76).
- Below the card, `.btn` (heat-gradient full-width) "+ New entry" with onclick `toast('New entry')`.
- The `.card` class (index.html:32) is `background:var(--card) (#FFFFFF); border:1px solid var(--line) (#ECEEF2); border-radius:var(--r)=20px; padding:16px; box-shadow:var(--elev)`.

### Flutter implementation (source-read findings)
- `journal_screen.dart:84-124` Scaffold:
  - `backgroundColor: surface` (= #EEF0F5) — close to mockup's var(--bg) #EEF0F5. ✓
  - `appBar: ContrastAppBar(title: 'Journal')` — title 20 w700, no `showBackButton` (no back button rendered at all, default false). Mockup has `‹` back button.
  - `floatingActionButton: FloatingActionButton.extended(icon: add, label: 'Add')` — replaces the mockup's primary `.btn"+ New entry" with a Material FAB. Different visual position (bottom-right floating) and styling (FAB default vs heat-gradient full-width button).
  - Body: `FutureBuilder<List<JournalEntry>>` → either `_emptyState()` or `RefreshIndicator(ListView.builder)`.
- `_JournalRow` (`:152-242`):
  - `Card(margin: bottom md, color: surfaceContainerHigh (#ECEEF2), elevation: 0, shape: RoundedRectangleBorder(borderRadius: 20))` — using Material `Card` instead of mockup `.card` which has var(--card)=(#FFFFFF) bg + 1px var(--line) border + box-shadow.
  - Border radius 20 ✓ matches mockup radius.
  - Padding `EdgeInsets.all(AppSpacing.lg)` (likely 16) — matches.
  - Row: `Text(emoji, fontSize 24)` + SizedBox(width md) + `Expanded(Column)`:
    - Row 1: date `MM/DD` (e.g. "07/15") 13 w700 outline color + mood label e.g. "Great" 13 w600 outline color, with SizedBox(width sm) between.
    - `if note.isNotEmpty`: note 14 w500 onSurface height 1.3 maxLines 3 ellipsis.
  - Emoji set is generic mood (`'Great': '🟢', 'Good': '🙂', 'OK': '😐', 'Bad': '😕', 'Terrible': '😣'`) (`:157-163`) — mockup uses `'🙌'` emoji in the title card and the journal hero's content "Felt amazing" suggests mood="Great" maps to `'🙌'` style, not `'🟢'` shape.
- `_AddEntrySheet` (`:244-333`): a Material `showModalBottomSheet` with `DropdownButtonFormField` mood dropdown + `TextField` note + `FilledButton` "Save entry". Reasonable functional flow.

### Gaps (pixel-faithful deltas)
1. **MED** — Entry card uses Material `Card` w/ `surfaceContainerHigh` bg (#ECEEF2) elevation 0 no border (journal_screen.dart:172-178). Mockup `.card` = white (#FFFFFF) bg + 1px #ECEEF2 line border + elev shadow. The bg should be white not the line color, and the explicit 1px border is missing (Material Card with elevation 0 + color has no border).
2. **HIGH** — Header line "TODAY · 9:12 AM" 11px ink3 (#9AA0A8) w700 is missing. Flutter renders `MM/DD` (e.g. "07/15") 13px outline w700 + space + mood label "Great" 13px outline w600 (journal_screen.dart:193-216 vs index.html:399). Different text content, font size (13 vs 11), and color (outline = #ECEEF2 light + #24252C dark, vs ink3 = #9AA0A8).
3. **HIGH** — No "🙌 Felt amazing" title row present. The mockup card title is a 14 w700 line containing the emoji + a free-text title ("Felt amazing"); the Flutter layout separates emoji (left avatar-like) + mood label beside date + note below. The mockup's title-as-emoji-prefixed-line pattern is missing.
4. **MED** — Body text 14 w500 onSurface height 1.3 vs spec 13 ink2 (#6B6E76) (journal_screen.dart:222-228 vs index.html:399). Size and color diverge.
5. **HIGH** — "+ New entry" is rendered as a `FloatingActionButton.extended` (bottom-right floating Material FAB with default theming), not a full-width `.btn` heat-gradient (heat→coral) button below the entry card (journal_screen.dart:88-92 vs index.html:400). The mockup's "Add CTA" is a primary inline button, not a FAB.
6. **MED** — App bar "Journal" 20 w700 with no back button (journal_screen.dart:87). Mockup appbar has `‹` back bk 36×36 radius 12 1px line border (app_bar.dart vs index.html:26, 398).
7. **MED** — Mood emoji mapping uses generic shapes (🟢🙂😐😕😣) (journal_screen.dart:157-163) — mockup uses celebration-style "🙌" in the demo card and "😌"/"😩" in summary chips; the v4 design language uses expressive hand/face emoji rather than color circles.
8. **LOW** — Empty-state uses "📝" 40px emoji + "No journal entries yet…" 15 w6 (journal_screen.dart:133-145) — no journal empty-state in mockup to compare against, but the mockup `.empty` class (index.html:187-189) implies a centered 40px padding ink3 empty-state; close enough.
9. **LOW** — RefreshIndicator + pull-to-refresh wrapper is added (functional, not visual gap).

### Severity
**MED** — The journal screen has the right *shape* (one card per entry + an add CTA) but the entry card's body uses the wrong bg color and lacks the spec 1px line border; the date header content/size/color is wrong; there's no emoji-prefixed title row; and the add-CTA is a FAB not a heat-gradient inline button. Mid-impact cosmetic rework needed.

---

## 6. Achievements — `achievements_screen.dart`

### Mockup (verified — `index.html:152-156, 161-162, 375-386`)
- App bar `.appbar`: `.bk` 36×36 radius 12 1px line border + `‹`; `h2` "Achievements" 19 w800 letterSpacing -.4.
- Level 4 card `.card` margin-bottom 14:
  - Row "Level 4 · Frostwalker" left + "720 XP" right — 13 w700 (`font-size:13px; font-weight:700`)
  - `.bar-p { height:8px; background:var(--line); border-radius:5px; overflow:hidden; margin-top:8px }` with inner `<i style="width:72%">` — inner `display:block; height:100%; background:linear-gradient(120deg,var(--heat),var(--coral))` (heat→coral).
- `.badges` grid = `grid-template-columns:1fr 1fr 1fr` (3 columns) gap 12.
- `.badge` = `text-align:center; background:var(--card); border:1px solid var(--line); border-radius:16px; padding:14px 6px; box-shadow:var(--elev)`.
- `.badge .e` = `font-size:26px` (the emoji, centered).
- `.badge.locked` = `opacity:.4; filter:grayscale(1)`.
- `.badge small` = `display:block; font-size:10px; font-weight:700; margin-top:6px` (the label under emoji).
- 6 badges:
  1. 🔥 "7-Day Streak"
  2. ❄️ "Ice Breaker"
  3. 🌅 "Early Bird"
  4. 💯 "100 Sessions"
  5. `locked` 🏆 "30-Day King"
  6. `locked` 👑 "Sauna Master"

### Flutter implementation (source-read findings)
- `achievements_screen.dart:79-101` Scaffold: `backgroundColor: surface` (#EEF0F5) ✓; `appBar: ContrastAppBar(title: 'Achievements')` — title 20 w700, no back bk shown (default `showBackButton: false`). Mockup has `‹` back bk.
- Body: `FutureBuilder<List<Achievement>>` → either `_emptyState()` or `_AchievementsGrid`.
- **Level 4 card is entirely missing.** `_AchievementsGrid` (132-155) goes straight to `GridView.builder`; no level/XP bar at all.
- `_AchievementsGrid` (132-155):
  - `padding: fromLTRB(pageHorizontal, lg, pageHorizontal, sectionGap)` ✓ reasonable.
  - `gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: md, crossAxisSpacing: md, childAspectRatio: 0.82)` — **2 columns** vs mockup 3.
- `_AchievementTile` (157-230):
  - `Container(padding: all lg, decoration: BoxDecoration(color: surfaceContainerHigh, borderRadius: 20))` — using `surfaceContainerHigh` (#ECEEF2 in light) bg, no 1px line border, radius 20 (mockup badge radius is 16, not 20).
  - `Column(crossAxisAlignment: start)`:
    - Emoji `Text(achievement.emoji, style: TextStyle(fontSize 36, color: emojiColor, height 1.0))` — emoji 36px vs mockup 26px; color-conditional (heat or muted) vs mockup no color on emoji (emoji renders in native colors), left-aligned vs centered.
    - Title 15 w700 maxLines 1 ellipsis (`:187-198`) — mockup `.badge small` is 10 w700 centered.
    - Description 12 w500 outline height 1.3 maxLines 2 ellipsis (`:200-211`) — not in mockup (badges have only emoji + small label, no description text).
    - Spacer + status line "Unlocked ${date}" / "Locked" 11 w600 heat-or-muted letterSpacing 0.3 (`:213-225`) — not in mockup (no status line beneath the label).
- Locked state at `:163-171`:
  - `unlocked = achievement.isUnlocked`
  - `mutedColor = Theme.of(context).colorScheme.outline`
  - `emojiColor = unlocked ? AppColors.heat : mutedColor`
  - `nameColor = unlocked ? onSurface : mutedColor`
  - There's a comment `_AchievementsTile.164-166` explicitly admitting "Spec said AppColors.ink3 — that token does not exist in AppColors (only lightInk3/darkInk3 do). Use colorScheme.outline".
  - Locked badge in mockup uses `.badge.locked { opacity:.4; filter:grayscale(1) }` — i.e. a 40% opacity *and* CSS greyscale filter on the whole badge tile. Flutter does *neither*: it just changes text colors to outline and never reduces opacity or desaturates.
- Achievement evaluation is dynamic via `evaluateAchievements(sessions)` (`:56`) so the badge set is data-driven, not hard-coded to the 6 mockup badges. Could include other badges. The screen comment says "comment in source notes AppColors.ink3 missing — that flags a token-mapping bug to fix."

### Gaps (pixel-faithful deltas)
1. **HIGH** — Level 4 + XP card (13 w700 row "Level 4 · Frostwalker" + "720 XP" + 8px XP bar w/ heat→coral at 72%) is **entirely missing**. There's no level/XP concept rendered (achievements_screen.dart:79-155 vs index.html:377).
2. **HIGH** — Badge grid is 2 columns vs mockup 3 (achievements_screen.dart:146 `crossAxisCount:2` vs index.html:152 `1fr 1fr 1fr`).
3. **HIGH** — Badge tile bg is `surfaceContainerHigh` (#ECEEF2) not `var(--card)` (#FFFFFF) (achievements_screen.dart:175-177 vs index.html:153). Also missing 1px line border (`border:1px solid var(--line)`) and box-shadow (`var(--elev)`).
4. **HIGH** — Badge tile radius 20 vs spec 16 (achievements_screen.dart:178 vs index.html:153).
5. **HIGH** — Locked badge styling is wrong: Flutter just swaps text colors to `colorScheme.outline`; mockup applies opacity .4 + CSS greyscale filter to the whole tile (achievements_screen.dart:163-171 vs index.html:155). Flutter viable would be `Opacity(0.4)` + `ColorFiltered(colorFilter: ColorFilter.matrix(grayscale))`.
6. **HIGH** — Emoji size 36 vs spec 26, and layout is left-aligned with `mainAxisAlignment crossAxisAlignment: start` vs mockup centered (`text-align:center`, `.badge .e` block) (achievements_screen.dart:182-185 vs index.html:153-154).
7. **HIGH** — Title label 15 w700 left-aligned vs mockup `.badge small` 10 w700 centered block (`display:block`) (achievements_screen.dart:187-198 vs index.html:156). Size 15 vs 10 is a huge delta.
8. **MED** — Description text (12 w500 outline) is added per badge — not in mockup (achievements_screen.dart:200-211).
9. **MED** — Status line "Unlocked MM/DD/YYYY" / "Locked" 11 w600 heat-or-muted is added — not in mockup (achievements_screen.dart:213-225).
10. **MED** — App bar title 20 w700 no back button (achievements_screen.dart:82 + app_bar.dart default) vs mockup appbar h2 "Achievements" 19 w800 + `‹` 36×36 radius-12 back bk (index.html:376).
11. **LOW** — Badge content is dynamic from `evaluateAchievements` so the visible 6-badge set may not match the mockup's exact 6. The mockup's specific locked badges (🏆30-Day King / 👑Sauna Master) depend on the evaluator's definitions, which would need to be verified against `domain/usecases/evaluate_achievements.dart`.

### Severity
**HIGH** — The entire level/XP card is missing, the grid is 2-col instead of 3-col, badge bg color / radius / border / shadow are wrong, locked state styling is wrong (text-color swap vs opacity+grayscale), title typography is wrong (15 w700 left vs 10 w700 centered), and there is extra description/status text not in mockup. Highest rework surface in cluster B.

---

## 7. Challenges/Community — `challenges_screen.dart`

### Mockup (verified — `index.html:157-160, 388-394`)
- `.name` "Challenges" 28 w800 letter-spacing -.7 margin-bottom 16 (top of screen, no app bar).
- Hero `.hero` with **inline override** `style="box-shadow:0 20px 40px -18px rgba(45,124,241,.5);margin-bottom:14px"`:
  - `.hero` base (index.html:38-40) = `background:linear-gradient(140deg,#12121a,#25252f); border-radius:var(--r-lg)=26px; padding:20px; color:#fff; position:relative; overflow:hidden; box-shadow: 0 22px 42px -20px rgba(255,107,53,.55)` (default is heat-tinted shadow — overridden here to a *cold-blue* rgba(45,124,241,.5) shadow).
  - ::after radial heat bg 220px right-top; ::before radial cold bg 200px left-bottom are still present.
  - Inner div `.lbl` "This week" (11px, opacity .7, w700, letterSpacing .4, uppercase) + `.big` "❄️ Cold Streak Challenge" (19 w800 letterSpacing -.3 margin 3 0 10) + 12px opacity .85 "1,240 people joined · 3 days left".
- Leaderboard `.card.leader` containing 4 rows `:.leader div`:
  - `display:flex; align-items:center; gap:10px; padding:10px 0; border-bottom:1px solid var(--line); font-size:13px; font-weight:600` — last row no border.
  - Row "1 🥇 Priya S. `<b style="margin-left:auto">21</b>`"
  - Row "2 🥈 Marcus `<b>19</b>`"
  - Row `class="me"`"7 🔥 You `<b>14</b>"` — `.leader .me{color:var(--heat)}`
  - Row "8 Dana `<b>13</b>`"
  - `.leader .rk` = `width:22px; font-weight:800; color:var(--ink3)` (the "1/2/7/8" rank number).
- Below leaderboard, `.btn.cold` "Invite friends →" (cold→cold2 gradient, cold shadow).

### Flutter implementation (source-read findings)
- `challenges_screen.dart:60-127` Scaffold: `backgroundColor: cs.surface` (#EEF0F5) ✓; no app bar (CustomScrollView starts with `_HeroHeader` sliver). Mockup has `.name` "Challenges" 28 w800 — Flutter hero has "Challenges" 34 w800 letterSpacing -.8 #fff (challenges_screen.dart:148-156). Different size (34 vs 28) and the title is white-on-gradient inside the hero, not a stand-alone `.name` line above the hero.
- `_HeroHeader` (132-169):
  - `Container(decoration: BoxDecoration(gradient: AppGradients.splashBg))`. `AppGradients.splashBg` = `LinearGradient(begin Alignment(-0.4,-1), end Alignment(0.4,1), colors [heat, #7A2AA8, cold], stops [0.0, 0.58, 1.0])` (gradients.dart:46-51) — a 3-stop heat→purple→cold 160deg gradient.
  - Mockup `.hero` = `linear-gradient(140deg, #12121a, #25252f)` — a near-black 2-stop dark gradient, NOT heat→purple→cold. Both the base color and gradient direction are completely different.
  - No `box-shadow` at all (Container has no shadow). Mockup has `0 20px 40px -18px rgba(45,124,241,.5)` cold-blue-tinted shadow — a key v4 visual hook missing.
  - No `::after` heat radial blob + no `::before` cold radial blob overlays — the Flutter hero is a flat gradient.
  - Padding `fromLTRB(20, pageTop+xxl, 20, xxl)` — vertical includes status-bar-safe top inset; reasonable but differs from mockup `padding:20px` ≈ symmetric 20.
- Inner hero text:
  - "Challenges" 34 w800 letterSpacing -.8 #fff (`:148-156`) — content matches mockup `.name` only in label; mockup hero has `.big` "❄️ Cold Streak Challenge" NOT "Challenges" inside the hero (that lives above as `.name`).
  - "Compete. Stay consistent." bodyMedium w500 white70 (`:158-164`) — not in mockup; mockup subtext is "1,240 people joined · 3 days left" with the "❄️ Cold Streak Challenge" big text.
- Below hero, a `_SectionHeading` "Challenges" + a `SliverList.separated` of `_ChallengeTile`s loaded from `assets/challenges.json` (`:88-94`). Mockup has no "Challenges" heading + a list of generic challenge tiles; mockup only shows the weekly-hero + leaderboard + invite button — no favorited-tile list.
- `_ChallengeTile` (`:185-256`):
  - `Container(padding: all lg, color: cs.surfaceContainerHigh, radius: 20, border: 1px ext.lineColor)` with emoji 28px + title + `$participants joined` + description + ClipRRect LinearProgressIndicator 6-tall heat-filled + "0 / $goal" caption.
  - This tile pattern doesn't match the mockup at all (the weekly hero IS the challenge card in mockup, not a tile list).
- `_SectionHeading` "Leaderboard" (`:95-105`) + `_LeaderboardRow` list (`:106-121`).
- `_LeaderboardRow` (`:258-313`):
  - `Container(padding: symmetric lg/md, color: isYou ? heat10% : surfaceContainerHigh, radius: 16, border: 1px heat50%/line)` — has colored bg + border on the "You" row.
  - Row contents: `SizedBox(width:28, Text('#$rank'))` + Expanded(displayName) + `$points pts`.
  - Mockup leaderboard row is just `flex` rows with rank + medalEmoji or 🔥 + name + `<b>points</b>` — medial/you emoji decorator inline with rank, no "pts" suffix on the points, and no per-row card background or border.
  - Flutter's "#1 / displayName / pts" formatting + per-row card is materially different from the mockup's flat list rows inside one card.
- No `.btn.cold` "Invite friends →" button anywhere in the file — mockup has it as the only primary CTA beneath the leaderboard (index.html:393).
- `_ErrorState` shows "🧊" emoji 40 + "Unable to load challenges." (315-339) — no mockup error state to compare against.
- Static JSON asset dependency: `assets/challenges.json` is the data source — not visually a gap, but worth noting that the leaderboard rank/name/points structure must mirror the mockup's (emoji medals, the 🔥 "You" decorator) to match.

### Gaps (pixel-faithful deltas)
1. **HIGH** — Hero gradient is `splashBg` (heat→purple→cold 3-stop 160deg) not mockup `.hero` `linear-gradient(140deg, #12121a, #25252f)` (dark 2-stop). Different direction and colors (challenges_screen.dart:138 + gradients.dart:46-51 vs index.html:38).
2. **HIGH** — Hero box-shadow `0 20px 40px -18px rgba(45,124,241,.5)` (cold-blue tinted) override is missing (challenges_screen.dart `_HeroHeader` has no `boxShadow` in its BoxDecoration; index.html:391).
3. **HIGH** — Hero `::after` heat radial blob + `::before` cold radial blob (220/200px absolute radial-gradient) decorations are missing (index.html:39-40 absent in `_HeroHeader.build`).
4. **HIGH** — Hero content is wrong: Flutter renders "Challenges" 34 w800 + "Compete. Stay consistent." BodyMed w500. Mockup hero content is `.lbl` "This week" + `.big` "❄️ Cold Streak Challenge" + "1,240 people joined · 3 days left" (challenges_screen.dart:148-164 vs index.html:391). No "This week" label, no "❄️ Cold Streak Challenge" big text, no participants/days-left line at all.
5. **HIGH** — Challenge tiles list (`_ChallengeTile` × N from `challenges.json`) replaces the mockup's single weekly-hero challenge module. Mockup has no favorited-tile grid below the hero — only the leaderboard + invite button (challenges_screen.dart:88-94 vs index.html:388-394).
6. **HIGH** — `.btn.cold` "Invite friends →" button (cold→cold2 gradient with cold box-shadow) below the leaderboard is entirely missing (mockup index.html:393 vs challenges_screen.dart — no equivalent button rendered).
7. **HIGH** — Leaderboard rows are rendered as individual cards (Container w/ bg/border per row) with "#N / displayName / N pts" format. Mockup rows are flat rows inside ONE `.card.leader`, format "N emoji Name `<b>N</b>"` with rank `:.rk` 22-wide w800 ink3. Differences: per-row card vs single shared card; "#" prefix on rank (Flutter) vs bare number (mockup); medal/🔥 emoji decorator inline (mockup 🔥=You, 🥇=rank1, 🥈=rank2) is absent in Flutter; "pts" suffix on points (Flutter) vs bare bold number (mockup); rank w800 ink3 (mockup) vs labelMedium (Flutter, 12 w600 letterSpacing 0.5); 13 w600 row baseline vs labelMedium/titleMedium mixed (challenges_screen.dart:258-313 vs index.html:157-160).
8. **MED** — Two `_SectionHeading` ("Challenges", "Leaderboard") use `titleHero` 19 w700 onSurface — mockup has no section headings at all (challenges_screen.dart:85-86, 102-103 vs index.html:388-394).
9. **MED** — App-bar: none in both, OK. But the mockup's `.name` "Challenges" 28 w800 (above hero) is implicit; Flutter's hero title is "Challenges" 34 w800 inside-hero, conflating the `.name` and the hero into one block (challenges_screen.dart:148-156 vs index.html:30, 390).
10. **LOW** — `_ErrorState` shows "🧊" 40px + title muted. No mockup error state to compare.

### Severity
**MED** — Despite being labeled "Challenges/Community," the Flutter screen diverges on every visual layer: hero gradient direction/color, hero content (no "This week" / "Cold Streak Challenge" / "1,240 joined · 3 days left"), missing hero radial blobs, leaderboard row format + per-row card vs single shared card, missing medal/🔥 emoji decorators, missing `.btn.cold` "Invite friends →" CTA, and an extra challenge-tile list that doesn't exist in mockup. Mid-to-high rework.

---

## 8. Referral — `referral_screen.dart`

### Mockup (verified — `index.html:166, 413-416`)
- App bar `.appbar`: `.bk` 36×36 radius 12 1px line border card bg + `‹`; `h2` "Invite friends" 19 w800 letterSpacing -.4.
- A single centered `.card` content:
  - `text-align:center; padding:20px`.
  - 🎁 emoji 34px (`font-size:34px`).
  - "Give a month, get a month" weight 800 (`font-weight:800`), margin-top 8px. No size override → inherits whatever; mockup section text generally 14–16px.
  - Subtext "Both you and your friend get 1 month of Pro free." 13px var(--ink2) (#6B6E76), margin-top 4px.
  - `.refcode` = `font-family:'JetBrains Mono'; font-size:26px; font-weight:500; letter-spacing:2px; background:var(--card); border:2px dashed var(--heat) (#FF6B35 dashed); border-radius:14px; padding:14px; margin:16px 0; color:var(--heat); text-align:center`. Content "AASHEESH50" (the literal demo code).
  - `.btn` "Share invite link" (heat→coral gradient) full-width with onclick `toast('Invite link copied')`. The `.btn` default styles (index.html:55): `width:100%; border:none; border-radius:var(--r-sm)=14px; padding:15px; font-size:15px; font-weight:800; color:#fff; background:linear-gradient(120deg,var(--heat),var(--coral)); box-shadow:0 14px 26px -12px var(--heat); margin-top:16px; letter-spacing:-.2px`. The inline override `style="margin-top:4px"` tightens top margin.
- No header gradient strip in mockup — the `.card` itself is the page content, beneath the appbar.

### Flutter implementation (source-read findings)
- `referral_screen.dart:13-110` is a `StatelessWidget`:
  - `_referralCode(uid)` (`:16-20`) computes `'CC-${hash.substring(0,4)}'` from Firebase UID hash, or `'GUEST0'` if null. So for an authenticated user the displayed code is e.g. "CC-A1B2", NOT the mockup's literal "AASHEESH50" demo. (Functionally reasonable, visually demonstrates identical formatting on screen renders different content.)
  - `Scaffold(backgroundColor: cs.surface, body: Column[ _HeroHeader(), Expanded(SingleChildScrollView(Column(Card(...))) ) ])`.
- `_HeroHeader` (`:113-146`): `Container(decoration: BoxDecoration(gradient: AppGradients.splashBg), padding: fromLTRB(20, 60, 20, 24))` with:
  - "Invite friends, earn Pro" 30 w800 letterSpacing -.8 #fff
  - "Share your code. When a friend joins, you both unlock Pro rewards." 14 w500 white70
  - **The mockup has no such hero gradient strip.** Mockup only has an `.appbar` "Invite friends" h2 + the centered card.
- Card (`:42-101`):
  - `Card(shape: RoundedRectangleBorder(borderRadius: 20, side: BorderSide(color: heat, width: 1.5)), elevation: 0, color: cs.surface, padding: EdgeInsets.all(20))`.
  - Card has a solid 1.5px heat border (not dashed) — mockup card has NO border at all; only the inner `.refcode` box has the dashed heat border.
- Inside card (`:50-100`):
  - "Your referral code" label 13 w600 heat letterSpacing 0.4 (`:54-63`) — not in mockup.
  - `SelectableText(code, style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 30, fontWeight: w800, letterSpacing: 1.5))` (`:65-73`):
    - fontFamily `PlusJakartaSans` ≠ JetBrains Mono spec.
    - fontSize 30 ≠ 26 spec.
    - fontWeight w800 ≠ w500 spec.
    - letterSpacing 1.5 ≠ 2 spec.
    - No background color (mockup `var(--card)` #FFFFFF).
    - No `2px dashed var(--heat)` border (the *defining* visual hook of the refcode box, index.html:166).
    - No border-radius:14, no padding:14.
    - Color: defaults (no color set) — uses card color? Actually no `color` in TextStyle → defaults to `Theme.of(context).textTheme.bodyMedium.color` = onSurface ink (#0C0C0E light / #F4F5F7 dark). Mockup is heat-colored text (#FF6B35). **Text color is wrong**.
  - Row below: two buttons side-by-side (`:75-97`):
    - `FilledButton.icon(icon: Icons.copy_rounded 18, label: 'Copy')` — default FilledButton (heat-themed) 18-icon "Copy" — not in mockup.
    - `OutlinedButton.icon(icon: Icons.share_outlined 18, label: 'Share')` — default OutlinedButton — not in mockup.
    - Mockup has no copy button (sharing is the toast on `.btn` press).
    - Mockup's single `.btn` "Share invite link" (heat→coral gradient + heat shadow radius-14 padding-15 15 w800 letterSpacing -.2) is fully absent.
- No "🎁" 34px emoji block anywhere in Flutter (`🎁` does not appear in referral_screen.dart).
- No "Give a month, get a month" title.
- No "Both you and your friend get 1 month of Pro free." subtext.

### Gaps (pixel-faithful deltas)
1. **HIGH** — `_HeroHeader` splash-gradient strip ("Invite friends, earn Pro" + subtext) is added at the top; mockup has no hero strip (mockup only has an appbar "Invite friends" h2) (referral_screen.dart:113-146 vs index.html:414).
2. **HIGH** — The 🎁 34px emoji block at the top of the card is missing (referral_screen.dart:50-100 has no `🎁` Text) — mockup index.html:415.
3. **HIGH** — "Give a month, get a month" 800-weight centered title is missing — Flutter has no equivalent label (referral_screen.dart:50-100 has only "Your referral code" 13 w600 heat, which is a different label).
4. **HIGH** — "Both you and your friend get 1 month of Pro free." 13px ink2 subtext is missing.
5. **HIGH** — Referral code box: (a) fontFamily Plus Jakarta Sans vs JetBrains Mono; (b) size 30 vs 26; (c) weight w800 vs w500; (d) letterSpacing 1.5 vs 2; (e) default ink color vs heat color (#FF6B35); (f) no 2px dashed heat border (the dashed border is the dominant visual hook); (g) no border-radius:14, no padding:14, no card bg. All 7 dimensions wrong (referral_screen.dart:65-73 vs index.html:166).
6. **HIGH** — The single heat-gradient `.btn` "Share invite link" (full-width, radius 14, padding 15, 15 w800, heat shadow) is entirely missing. Flutter replaces it with two side-by-side standard `FilledButton.icon('Copy')` + `OutlinedButton.icon('Share')` (referral_screen.dart:75-97 vs index.html:415).
7. **HIGH** — Card has a 1.5px solid heat border (`side: BorderSide(color: heat, width: 1.5)`) that the mockup card does not have. Mockup `.card` only has bg + 1px line border + box-shadow (referral_screen.dart:43-46 vs index.html:32). Also mockup card has a 1px line border + elev shadow that Flutter omits (Flutter uses Card with `elevation: 0`).
8. **HIGH** — Referral code content is `CC-${hash}` (computed) or "GUEST0", not the mockup's literal "AASHEESH50". For the gap-audit purpose this is content drift; functionally reasonable for production. Flag as a demo content mismatch.
9. **MED** — App bar: mockup uses standard `.appbar` `.bk` 36×36 radius-12 + `h2` "Invite friends" 19 w800 letterSpacing -.4. Flutter uses no app bar at all (relies on the hero strip instead). The ContrastAppBar widget isn't even imported here.
10. **MED** — "Your referral code" label 13 w600 heat letterSpacing 0.4 (referral_screen.dart:54-63) is added — not in mockup (mockup goes straight from subtext to refcode box).

### Severity
**HIGH** — The page is structurally a different layout: a hero gradient strip replaces the appbar; the card has the wrong border; the refcode box is missing the dashed heat border, JetBrains Mono font, heat text color, and correct dimensions; the 🎁 emoji + give-a-month title + subtext + heat-gradient "Share invite link" button trio is entirely absent; and two Material icons (Copy/Share) replace the v4 primary CTA. Highest single-screen rework of cluster B.

---

## Screens Not Yet Built in Flutter

### `#breath` — Breathwork screen (no corresponding Flutter file)

**Mockup view** (`index.html:131-135, 318-324`):
- `#breath` view: `background:linear-gradient(160deg,#0a2a5c,#0c0c0e); color:#fff; flex column centered text-align center`.
- Tiny "BOX BREATHING" label: `font-weight:800; letter-spacing:3px; opacity:.7; font-size:13px`.
- Breathing orb `.orb`: `width:170px; height:170px; border-radius:50%; background:radial-gradient(circle at 40% 35%, #8fc0ff, #2D7CF1 60%, #1a4fa0); margin:24px 0; animation:breathe 8s ease-in-out infinite; box-shadow:0 0 60px rgba(45,124,241,.6)`.
- `@keyframes breathe{0%,100%{transform:scale(.65)}50%{transform:scale(1)}}` — 8s Неем-curve breathe scale 0.65↔1.
- State text `.bstate` "INHALE" (or HOLD/EXHALE): `font-size:22px; font-weight:800; letter-spacing:1px`.
- Subtext "Round 2 of 5 · tap anywhere to pause": `opacity:.6; font-size:13px; margin-top:8px; font-weight:600`.
- Top-right `.exit` ✕ (the shared exit class — `position:absolute;top:56px;right:18px;color:#fff;background:rgba(255,255,255,.14);width:34px;height:34px;border-radius:50%;font-size:16px`).

**No Flutter screen exists.** A `find` for `**/breath*.dart` returned nothing (confirmed via glob on `lib/`). The `BreathingCircle` widget at `animation_utils.dart:114-184` is a generic breathing-scale wrapper used by the active-session screen, but there is no dedicated breathwork route/screen that matches `#breath`. `go_router` likely doesn't have a `/breath` route (would need a `grep` of router config — but the absence of a screen file is the primary flag).

**Reputed placeholder asset:** none.

**Migration cost:** A brand-new screen would need: (a) the `#0a2a5c→#0c0c0e` 160deg gradient background, (b) a 170px orb with the 3-stop radial-gradient at 40%/35%/60%, (c) the 8s breathe animation scale .65↔1 with 60px box-shadow rgba(45,124,241,.6), (d) INHALE/HOLD/EXHALE state machine text 22 w800, (e) round counter subtext, (f) the shared `.exit` top-right ✕ button. The existing `BreathingCircle` widget could *partially* power (b-c) but its current color|0.15 fill + animation profile (controlled by `AnimationUtils.createBreathingController` + `breathingAnimation`) would need to be replaced with the spec radial-gradient fill + 8s ease-in-out scale .65↔1.

### `#summary` — Session summary view

Mockup's `#summary` corresponds to `session_summary_screen.dart`, which IS built. The mockup's `#breath` has no Flutter counterpart, and the `#summary` view (mockup `index.html:327-334`) maps to Flutter's `session_summary_screen.dart` albeit with the dozens of gaps documented in §2 above. So the only truly "unbuilt" cluster-B view is `#breath`.

---

## Cross-screen observations (applicable to multiple screens)

1. **App bar pattern** is consistent in Flutter via `ContrastAppBar` (app_bar.dart:7-66): title is `AppTypography.titleLarge?.copyWith(fontWeight: w700, fontSize: 20)`, leading `bk` is a CircleBorder (round) `InkWell` with 1px line border `AppIcon(LucideIcons.chevronLeft, size 20)`, width/height 36. The mockup `.appbar h2` (index.html:28) is **19 w800 letterSpacing -.4** and the `.bk` (index.html:26) is **36×36 border-radius:12** (square corner radius 12, NOT round), background `var(--card)`, `font-size:18px`. So **every** cluster-B routed screen using `ContrastAppBar` (Share, Journal, Achievements — Coach uses it but mockup has no appbar at all on coach; Referral does NOT use it; Challenges does NOT use it) inherits a wrong app bar: title weight 700 vs 800, title size 20 vs 19, letterSpacing missing, back button is round vs 12px-radius square. This is a single shared widget gap worth fixing at the source (`app_bar.dart`).

2. **`AppGradients.splashBg`** (gradients.dart:46-51 — heat→#7A2AA8→cold 3-stop splash gradient) is the recurring "hero" gradient used by Challenges (`_HeroHeader`) and Referral (`_HeroHeader`), but mockup never uses this gradient as a screen header. Mockup headers are either (a) no header at all (Coach, Challenges, Summary — `.name` text only), (b) standard `.appbar` (Share, Journal, Achievements, Referral), or (c) dark hero gradient `.hero` (Challenges uses `#12121a→#25252f`, not heat→purple→cold). So the splash-derived hero strip is a Flutter-only invention on at least 2 cluster-B screens.

3. **JetBrains Mono** is used only for the timer number text — but the typography tokens give it as 200px w100 letterSpacing -4 (`timerHero`, app_typography.dart:158-165). Mockup requires JetBrains Mono only at `font-size:56px; font-weight:200; letter-spacing:-2px` (timer) and JetBrains Mono `26px w500 letterSpacing 2` for the referral code (no Plus Jakarta Sans). The `timerHero` token's size 200 / letterSpacing -4 is a leftover from another design — `RecoveryScoreCard` and `SessionTimer` both inherit broken spec.

4. **`AppGradients.heroDark`** (gradients.dart:54-58, `linear-gradient(topCenter→bottomCenter, #12121A, #25252F)`) is the dark hero approximation used by `ShareCardPainter`, but mockup `.share` calls for `linear-gradient(150deg, #12121a, #3a1e12)` — direction 150deg and stop-2 `#3a1e12` differ. The Flutter `heroDark` is *closer* to the mockup `.hero` (#12121a→#25252f, 140deg) gradient used by the challenges/community screen, but that screen uses `splashBg` instead. So we have a token swap mismatch.

5. **Locked/disabled visual language:** mockup uses **`opacity:.4; filter:grayscale(1)`** for locked badges (achievements). Flutter's `AchievementsScreen` swaps the *text colors* to `colorScheme.outline` instead of controlling opacity+grayscale on the tile. Correct Flutter equivalent: `Opacity(0.4, child: ColorFiltered(colorFilter: ColorFilter.matrix(grayscaleMatrix), child: ...))`.

6. **`AppColors.ink3` token is missing** — explicitly flagged in `achievements_screen.dart:164-166` ("Spec said AppColors.ink3 — that token does not exist in AppColors. Only lightInk3/darkInk3 do."). The mockup uses `var(--ink3)` for many tertiary text colors (ink3 = #9AA0A8 light per index.html:10; #7B7F8A dark per index.html:12). Flutter's `AppColors` only exposes `lightInk3` and `darkInk3` (app_colors.dart:16, 23). A theme-aware single `ink3` accessor would converge the dozens of `Theme.of(context).colorScheme.outline` / `.extension<AppColorsExtension>()!.textMuted`/`AppColors.midGray` workarounds. This is a token-architecture gap worth surfacing.

7. **Text input / chip visual hook:** the mockup defines `.chip` (`card bg`, 1px line border, radius 20, padding 8/13, 12 w700, `.on` heat-bg+white-text) reused on summary, coach, and (implicitly) anywhere with selectable tags. Flutter's chip implementations on Summary (missing entirely) and Coach (missing entirely) don't reuse a shared `AppChip` widget. Building one in `presentation/widgets/atomic/` would close the chip-related gaps on Summary, Coach, and Journal.

---

## End of report — cluster B
