# ContrastCoach v2 — Warm & Cool UI/UX Redesign

**Date:** 2026-06-16
**Designer:** Hired UI/UX designer (Stitch AI assisted)
**Stitch Project:** `projects/5351357224953719532` — "ContrastCoach - Warm Cool v2"
**Design System:** `assets/14861106834359915697` — "ContrastCoach Warm Cool"

---

## Design Philosophy

A bold departure from monochrome restraint — this is a premium, energetic, **contrast-themed** app where the two core elements (heat + cold) are expressed directly in the color palette. The warm orange represents sauna/heat/recovery. The cool blue represents cold plunge/focus/discipline. Together they tell the brand story instantly.

The design should feel like a $50M-funded wellness startup — confident, modern, playful but serious, with deep attention to typography hierarchy and whitespace.

---

## Design Tokens

### Color Palette

| Token | Value | Use |
|---|---|---|
| Brand Primary (Warm) | `#FF6B35` | Primary CTAs, sauna, recovery |
| Brand Secondary (Cool) | `#2D7CF1` | Cold plunge, focus, secondary actions |
| Charcoal | `#1A1A1A` | Primary text, dark surfaces |
| Off-white | `#FAFAF7` | Light background |
| Warm Beige | `#F5F0E8` | Soft surface background (Home) |
| Dark Gray | `#4A4A4A` | Secondary text |
| Mid Gray | `#6B6B6B` | Tertiary text |
| Light Gray | `#F0F0F0` | Disabled, dividers, empty states |
| Accent Green | `#4CAF50` | Success, trend up |
| Accent Red | `#E53935` | Destructive actions (delete) |
| Soft Green | `#D7E8D7` | Success backgrounds |

### Gradients

| Name | From | To | Use |
|---|---|---|---|
| Heat Gradient | `#FF6B35` | `#FF8A65` | Paywall, hero celebration |
| Contrast Gradient | `#FF6B35` | `#2D7CF1` | Active session background, progress bars, insight hero card |
| Coral Pop | `#FF8A65` | `#FF6B9D` | Premium badges |

### Typography

**Font family:** Plus Jakarta Sans (single typeface for everything)

| Token | Size | Weight | Use |
|---|---|---|---|
| Display Hero | 56sp | 800 | Onboarding impact text |
| Display | 36-40sp | 800 | Paywall, section titles |
| Headline 1 | 28-32sp | 700 | Screen titles, hero numbers |
| Headline 2 | 22-24sp | 600 | Card titles, sub-sections |
| Title | 18sp | 600 | Button text, key labels |
| Body Large | 16sp | 500 | Primary body text |
| Body | 14sp | 400 | Secondary body text |
| Caption | 12-13sp | 500 | Captions, helper text |
| Label | 11sp | 600 | UPPERCASE letter-spaced labels (always +0.5 to +2 letter-spacing) |
| Timer | 200sp | 100 | Active session countdown (ultra-thin) |

### Shape

| Token | Value | Use |
|---|---|---|
| Card Small | 12dp | Inline cards, mini stats |
| Card Medium | 16-20dp | Most cards, insights |
| Card Large | 24-28dp | Hero cards, primary surfaces |
| Button Pill | 999dp | All primary buttons (fully rounded pill) |
| Button Standard | 16dp | Secondary buttons |
| Avatar | 50% (circle) | User avatars, icon circles |
| Heatmap Cell | 8dp | Streak grid cells |

### Elevation / Shadows

- `0 2px 8px rgba(0,0,0,0.04)` — subtle card lift
- `0 8px 24px rgba(0,0,0,0.08)` — hero cards
- No harsh shadows anywhere

### Spacing

- Screen padding: 24dp horizontal
- Section gaps: 16-24dp
- Card internal padding: 16-20dp
- Button height: 56dp (primary), 48dp (secondary)
- Tap target minimum: 44dp (we use 56dp buttons for primary actions)

---

## Screen Specifications

### 1. Onboarding — Step 1: HEAT. COLD. REPEAT.
- **Background:** Off-white `#FAFAF7`
- **Top:** 3 page indicator dots, first filled orange
- **Center:** Massive 56sp weight 800 headline, each word on its own line, charcoal
- **Subtitle:** 18sp gray
- **Tagline above button:** tiny uppercase letter-spaced "NO ACCOUNT • NO CLOUD • NO BS"
- **Primary CTA:** Full orange pill button "Get Started", white text, 56dp tall

### 2. Onboarding — Step 2: Your sauna. Your plunge. Your data.
- Same layout
- Minimal CSS geometric illustration (circles in orange/blue representing thermal contrast)
- Two pill badges: "Voice control" and "Health sync"

### 3. Onboarding — Step 3: Private by default.
- Shield icon in orange (CSS shape)
- 3 trust rows with icon + title + subtitle:
  - "Stays on device" / "Nothing leaves your phone without permission"
  - "Health data local" / "Heart rate and HRV never reach our servers"
  - "Delete anytime" / "One tap and everything is gone"

### 4. Home — Session Setup
- **Background:** Warm beige `#F5F0E8` (the unique home-only background)
- **Top header:** Greeting + name + 40dp orange avatar (initials)
- **Streak pill:** Flame icon + "12 day streak"
- **Hero card (28dp, white, soft shadow):**
  - Orange uppercase label "TODAY'S SESSION"
  - Bold title "Standard Recovery" 28sp
  - Stats row: "25 min · 3 rounds · 78% effort"
  - Orange-to-blue gradient progress bar (8dp tall)
  - Massive orange pill button "Start session" full width
- **Goal cards row (horizontal scroll):** Recovery, Energy, Sleep, Immunity with colored circle icons
- **Bottom tab bar:** Home, History, Insights, Profile (4 items, 64dp tall)

### 5. Active Session — Immersive Full-Screen
- **Background:** Vertical gradient from orange `#FF6B35` (top, sauna) to blue `#2D7CF1` (bottom, cold plunge)
- **Phase label:** Tiny uppercase white label at top
- **Timer:** Massive 200sp weight 100 ultra-thin countdown, white, perfectly centered
- **Progress:** Thin white bar with "Round 2 of 3" caption
- **Phase pills:** SAUNA / COLD (active) / REST in a row
- **Controls:** Two 72dp round buttons side-by-side: pause + mic, semi-transparent white
- **Footer:** "Say 'next phase' or tap" subtle hint

### 6. Session Summary — Celebration
- **Background:** Warm beige
- **Top:** 80dp soft green circle with charcoal checkmark — celebration
- **Headline:** "Session complete!" 32sp weight 800
- **Subtitle:** "25 min · 3 rounds · Strong effort"
- **Hero score:** Massive "87" 96sp weight 200 with "RECOVERY SCORE" label
- **3 insight cards:** "Stuck to plan", "Sleep boost", "Streak" — each with colored circle icon
- **Bottom actions:** "Share" (outlined) + "Done" (orange filled)

### 7. Streak History — Heatmap Calendar
- **Background:** Off-white
- **Header:** "Your streak" 28sp + "12 days" in orange
- **12×7 heatmap grid (84 cells):**
  - 4 intensity levels of orange (light `#FFE0CC` to deep `#FF6B35`)
  - Empty cells light gray
  - 28dp cells with 4dp gaps, 6dp corner radius
- **Legend:** "Less" → "More" gradient indicator
- **Recent sessions scroll:** Cards with session type, duration, score
- **Tab bar:** History active

### 8. Monthly Insights — Data Visualization
- **Background:** Off-white
- **Header:** "Insights" + "June 2026" date
- **Time chips:** Week / Month (active filled) / Year
- **Hero stat card:** Blue-to-orange gradient, white text, "AVERAGE EFFORT" 78 + "+12% from last month"
- **2x2 metric grid:** Total sessions, Avg duration, Best protocol, Sleep impact
- **Patterns section:** 2 horizontal bar charts (Morning 64% orange, Evening 36% blue)
- **Tab bar:** Insights active

### 9. Settings
- **Background:** Off-white
- **Header:** "Settings" 28sp
- **Profile card (20dp, white):** 56dp orange avatar + name + "Free plan" + orange "Upgrade to Pro" pill on right
- **Sectioned list with uppercase group titles:**
  - **APPEARANCE:** Theme, Accent color
  - **HEALTH:** Health Connect, Voice control (toggle), Notifications (toggle)
  - **DATA:** Export data, Delete account (red)
- **Row style:** 56dp tall, left icon in 24dp colored circle, right chevron or toggle
- **Tab bar:** Profile active

### 10. Paywall — Pro Upgrade
- **Background:** Full gradient orange to coral
- **Top:** White X close button (top right)
- **Header:** "UPGRADE" small label + "ContrastCoach Pro" 36sp white bold
- **4 features with white check circles:**
  - All 10 protocols + custom
  - Health Connect & HRV
  - Unlimited cloud sync
  - Voice control
- **3 pricing cards stacked:**
  - Monthly: $5.99
  - **Yearly: $39.99 (recommended — 2px orange border + "BEST VALUE" orange pill)**
  - Lifetime: $89.99
- **Primary CTA:** White pill button "Continue with Yearly", charcoal text
- **Footer:** "Restore purchases" white link

---

## Screens Generated (Reference IDs)

| # | Screen | Screen ID |
|---|--------|-----------|
| 1 | Onboarding — Step 1 (HEAT. COLD. REPEAT.) | `047a0607e0e1400084c14681f62d72e3` |
| 2 | Onboarding — Step 2 | `06a640cca16648f6b4365b8020c318d0` |
| 3 | Onboarding — Step 3 (Privacy) | `44257296d0e242b9817e97bc68b54a44` |
| 4 | Home — Session Setup | `3170a3acaac3475f99e679c538cca3d6` |
| 5 | Active Session — Immersive | `0318580812e04d81b8154d4d90fb9211` |
| 6 | Session Summary — Celebration | `7d6a8dc5bbf04b2783a4abbcebc32ff2` |
| 7 | Streak History — Heatmap | `3893209c347b481e9a38d5fea33e801a` |
| 8 | Monthly Insights | `c13adcdb18944b58a673085be5ffd4ec` |
| 9 | Settings | `4a2ec2a825a748ef9f9b72530811ee3e` |
| 10 | Paywall — Pro | `8ef9078ac3bb41eb9b336726c4c627c4` |

Open in Stitch UI: `https://stitch.withgoogle.com/project/5351357224953719532`

---

## Key Design Decisions

1. **Color = meaning.** Orange = heat/recovery. Blue = cold/focus. The user instantly understands the contrast therapy concept through color alone.

2. **Warm beige Home.** A unique `#F5F0E8` background on Home only makes it feel inviting, like a warm towel after a sauna. All other screens use off-white for consistency.

3. **Gradient progress bar on Home.** The orange-to-blue gradient bar in the hero card visually previews the active session gradient — it primes the user.

4. **Active session = full immersion.** The vertical orange-to-blue gradient on the active session screen is the climax of the visual language. The phase determines where on the gradient the experience sits.

5. **Heatmap with 4 intensity levels.** Far more informative than a binary on/off grid. Lets users see at a glance which days were intense vs light.

6. **Insight hero card is a gradient.** The "Average Effort" stat is the single most important data point. Putting it on a gradient background makes it the visual anchor of the screen.

7. **Pill buttons everywhere.** 999dp radius for primary actions. They're friendlier and more modern than the standard 8/12dp radius used in Material 3 default.

8. **Bottom tab bar = 4 items.** Home, History, Insights, Profile. (The old monochrome design had 3 items. 4 is more standard for a tracking app.)

9. **Plus Jakarta Sans for everything.** Single typeface, multiple weights. Looks intentional and premium. Used at 200 weight for the timer (ultra-thin tall) and 800 weight for headlines (bold impactful).

10. **The paywall is the only screen with a colorful gradient background.** It's the only place where the brand is "selling" — the gradient creates energy and urgency (in a tasteful, non-manipulative way).

---

## What's Different from v1 (Monochrome)

| Aspect | v1 (Monochrome) | v2 (Warm & Cool) |
|---|---|---|
| Color | Black/white/gray only | Orange + Blue + warm beige |
| Personality | Restrained, Linear-like | Energetic, Notion-meets-Whoop |
| Home background | White | Warm beige `#F5F0E8` |
| Buttons | 12dp corners | Full pill (999dp) |
| Bottom nav | 3 items | 4 items |
| Streak grid | Binary filled/empty | 4 intensity levels |
| Insight screen | Typography only | Includes charts + gradients |
| Active session | Pure black | Orange-to-blue gradient |
| Paywall | White with cards | Orange-coral gradient |
| Font | Inter + Inter Tight + JetBrains Mono | Plus Jakarta Sans (single family) |
| Hero treatment | Single number | Big celebration moment |
| Tab bar | 56dp | 64dp with bold active state |

---

## Next Steps (Implementation in Flutter)

This is a complete design overhaul. Implementation would require:

1. **Replace `lib/core/constants/app_colors.dart`** with new palette
2. **Replace `lib/core/constants/app_typography.dart`** with Plus Jakarta Sans
3. **Update `lib/core/constants/app_shapes.dart`** — change to 12-28dp standard + 999dp pill
4. **Update each screen widget** to use new tokens
5. **Replace fonts** in `pubspec.yaml` (remove Inter/InterTight/JetBrainsMono, add Plus Jakarta Sans)
6. **Update assets** — no SVG icons needed, use Material Icons with new color tokens
7. **Update theme** in `app_theme.dart`, `light_theme.dart`, `dark_theme.dart`
8. **Update bottom navigation** from 3 to 4 items
9. **Streak calendar widget** — replace binary grid with intensity heatmap
10. **Insight screen** — add the bar charts and gradient hero

Estimated implementation time: 2-3 days for full visual overhaul across all 10 screens.
