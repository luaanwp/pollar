---
version: 1
slug: "app-shell-navigation"
primary_target: "apps/pollar_app/lib/app/routing/app_shell.dart"
related_targets:
  - "apps/pollar_app/lib/app/routing/navigation_preferences.dart"
  - "apps/pollar_app/lib/features/settings/presentation/more_screen.dart"
  - "apps/pollar_app/lib/app/routing/app_router.dart"
  - "apps/pollar_app/lib/shared/presentation/pollar_motion.dart"
---

## Scope and mode

Operate: phase 2 of UI_UX_REDESIGN_POLLAR.md, within the existing Pollar brand.

## Job and direction

People navigate the same five destinations on desktop and mobile. Desktop users
can recover content width without losing the current branch, draft or detail.
The toolbar supplies quiet route context and global privacy/theme controls.
More prioritizes analyses, followed by application controls, using grouped rows.

## Constraints

Keep StatefulNavigationShell and the route map; the rail preference is session
presentation state only. At 600–1023px use a 72px rail; below 600px use five
labelled bottom destinations. Scroll the rail on short windows, retain 48px
targets and accessible names. Preserve the compact transaction list heading:
its body has no duplicate title. Reflow large text rather than hiding content.
No domain, money, authentication, synchronization or account data changes.

## Implemented motion

`PollarBranchStack` keeps the IndexedStack and each branch navigator mounted.
Only the current branch arrives horizontally, up to 24dp over 240ms with
`easeOutCubic`; destination order sets the side and RTL reverses it. Full
opacity and shell clipping keep one current surface. There is no outgoing
screen duplicate or snapshot. Inactive branches are offstage, excluded from
focus/semantics and have tickers disabled. Reduced motion or accessible
navigation ends arrival immediately, including mid-transition, without a
remount. Returning to a branch retains search, drafts and navigation state.

The bottom indicator uses native 240ms animation, zero with reduced motion;
the rail keeps native behavior. All five More subroutes use the existing
`pollarMotionPage`, including Data, Sync and Preferences. iOS/macOS keep
MaterialPage for native back behavior; other platforms keep the custom page.
The route map and authentication redirect rules are unchanged. More rows reveal
by identity with indices 0–4; ordinary theme/privacy rebuilds do not replay.

## Verification boundary

Widget and golden tests cover navigation state, keyboard, themes, text scaling,
short-height scroll and simulated system inset. These do not constitute a
physical Android/iOS test or screen-reader session, native back-gesture test on
hardware or FPS measurement. Branch and route tests cover direction, reduced
motion, interrupted arrival and state retention. Navigation goldens capture
`navigation_390_light_frame40.png`, `navigation_1440_dark_frame40.png`,
`navigation_390_dark_reduced.png` and `navigation_320_dark_2x_frame40.png` in
`apps/pollar_app/test/goldens/`. Execution/build results belong in
`docs/redesign-progress.md`; this slice preserves existing page composition.
