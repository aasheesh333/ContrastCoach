# Design System

## Visual identity

Reference apps: Google Chrome, Amazon Shopping, Linear, Things 3, Apple Notes, Bear, Notion, Kindle.

**Monochrome Material 3 Expressive** — no chromatic accents. State communicated via opacity, weight, or shape.

## Color tokens

| Token | Light | Dark |
|---|---|---|
| surface-0 | #FFFFFF | #0A0A0A |
| surface-1 | #F7F7F7 | #141414 |
| surface-2 | #EDEDED | #1F1F1F |
| surface-3 | #E0E0E0 | #2A2A2A |
| on-surface-primary | #0A0A0A | #F5F5F5 |
| on-surface-secondary | #5C5C5C | #A8A8A8 |
| on-surface-tertiary | #8C8C8C | #6E6E6E |
| divider | #EDEDED | #1F1F1F |
| accent | #0A0A0A | #F5F5F5 |

## Typography

- Display: Inter Tight (200-700)
- Body: Inter (400-600)
- Mono: JetBrains Mono (timer, data)

## Shape

- Cards: 16dp (medium), 28dp (hero)
- Buttons: 12dp (filled), 999dp (FAB pill)
- Sheets: 28dp top corners

## Motion

- All transitions: spring(stiffness: 380, dampingRatio: 0.8)
- Page transitions: shared-element + 240ms fade
- No bouncy overshoots. No flashy animations.

## Rules

- No blue, red, green, orange. Ever.
- No gradients except monochrome tonal.
- No emoji in UI.
- No marketing copy in UI.

## Screen list

1. Onboarding (3 steps)
2. Home (session setup)
3. Active session (timer)
4. Session summary
5. Streak calendar
6. Insights (monthly report)
7. Settings
8. Paywall

See `CONTRASTCOACH_MASTER_PLAN.md` section 1.2 for detailed screen mockups.
