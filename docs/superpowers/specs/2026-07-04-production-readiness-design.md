# Production-Readiness Design Spec

## Goal

Eliminate ~33 concrete UX/runtime bugs across the v4 Flutter port so the app is shippable, without changing visual design language or scope.

## Architecture (current)

- GoRouter with one `ShellRoute` (bottom-nav host) wrapping 4 tab routes (`/home`, `/explore`, `/coach`, `/insights`).
- All other routes (including `/settings` and Settings sub-screens) are top-level `GoRoute`s.
- Bottom-nav `You` item does `context.go('/settings')`.
- Sub-screens (`/account`, `/notifications`, etc.) are reached from Settings via `context.push(...)`.
- Each sub-screen renders `ContrastAppBar` with `showBackButton: true` and `onBack: Navigator.maybePop`.

## Root causes targeted

1. **Navigation trap**: `/settings` is a top-level route, not under the shell. Tapping `You` removes the bottom nav. No AppBar on Settings screen → no escape.
2. **Empty-stack pops**: Sub-screens' `maybePop` runs against an empty navigator stack because `/settings` was navigated with `go()` not `push()`.
3. **Misrouted pushes**: `/share/{id}` route does not exist; active-session completion stacks instead of replaces.
4. **Mid-flow `go()`**: Active session uses `context.go('/paywall')` mid-session, abandoning the running session.
5. **Hidden AppBar-less screens**: Privacy, About, Delete Account, Custom Protocol Builder have no visible AppBar.
6. **Stale state**: Splash reads prefs before init; onboarding `_skip` ignores `setOnboardingComplete` result.
7. **Tap-target gaps**: Multiple bare `GestureDetector`s without `behavior: HitTestBehavior.opaque`.
8. **Dark-mode regressions**: Hardcoded light-mode token colors used in Coach bubble, Account sublabels, chevrons in Help/Data export.
9. **Fake data presented as real**: 5 places fabricate metrics (HRV trend, 24m avg, weekly bars, you@example.com email, mock empty bars).
10. **Dead Snackbars**: 3 buttons only show "Done" Snackbars without the actual action.
11. **Layout bombs**: Insights `sublist` RangeError; Explore GridView under-nav overlap.

## Approach

Three waves, small enough to bisect if CI goes red:

- **Wave A — Navigation & Routing (P0/P1, ~10 bugs)**: Move `/settings` under the shell; add `go()`/`push` discipline; fix share route; fix session-completion `pushReplacement`; fix paywall mid-session `push`; remove dead coach back button; fix sign-out direct-go; fix delete-account permissions request; guard Edit-profile pop with `canPop`.
- **Wave B — AppBars, hit-test, stale-state, layout, dark-mode (P2, ~15 bugs)**: Add `ContrastAppBar(showBackButton: true)` to Privacy, About, Delete account, Custom protocol builder; de-dupe StreakCalendar route; await `AppPreferences.init` in splash; clamp insights `sublist`; add `behavior: HitTestBehavior.opaque` to common GestureDetectors; replace hardcoded gray with theme tokens.
- **Wave C — Polish (P3, ~8 bugs)**: Remove fake-data mocks (HRV trend, 24m avg weekly bars, you@example.com); wire or relabel dead Snackbars (Contact support, Export JSON/CSV, Clear cache); swap bottom-nav filled icon for selected; remove dup import in active_session_screen.

## Verification strategy

Per user's hard constraint: **no local build/test/analyze.** Every wave ships as one push, CI runs `flutter analyze` + `flutter test` (268 tests at last green) + debug APK build. Wave is accepted only when CI run is green and uploaded.

## Out of scope

- v4 mockup pixel-fidelity polish (tracked separately).
- New features (no new screens, services, or tables).
- Test-suite rewrites except where tests asserted on now-removed fake data.
- Performance work.
- Real platform integration (Health Connect revoke API, RevenueCat offer purchase flow) beyond what shipped in Wave 5/6.

## Success criteria

1. CI green on `feature/v4-ux-port` for all three waves.
2. No screen can trap the user without a visible back-action.
3. No screen shows fake data presented as a real recovery / health / usage metric.
4. No hardcoded light-mode color token in any screen (all flow through `Theme.of(context)`).
5. Tag `v4.0.2` released from the final green commit.
