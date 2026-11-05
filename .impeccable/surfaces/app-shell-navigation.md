---
version: 1
slug: "app-shell-navigation"
primary_target: "apps/pollar_app/lib/app/routing/app_shell.dart"
related_targets:
  - "apps/pollar_app/lib/app/routing/pollar_top_navigation.dart"
  - "apps/pollar_app/lib/app/routing/app_destination.dart"
  - "apps/pollar_app/lib/features/settings/presentation/more_screen.dart"
  - "apps/pollar_app/lib/app/routing/app_router.dart"
  - "apps/pollar_app/lib/shared/presentation/pollar_motion.dart"
---

## Scope and mode

Operate: a narrow local layout refinement of the existing Pollar shell.
Replace the desktop side navigation within the current brand, route map and
motion vocabulary. This is not a replacement visual world or a new page concept.

## Job and direction

People navigate the same five destinations: Visão geral, Transações, Contas,
Planejamento and Mais. The wide shell gives the financial workspace its full
available width. Pollar's existing mark, Inter, Lucide, solid canvas and teal
selection identify the shell. Privacy and theme remain global utilities.
More keeps its grouped analysis and application rows.

## Implemented layout

Below 600px, retain the existing five labelled bottom destinations, compact
toolbar and native bottom safe area. Compact Transactions keeps its sole page
heading in that toolbar, growing with enlarged text.

At 600px and above, `PollarTopNavigation` places the brand left, five labelled
destinations between brand and utilities, and privacy/theme controls right,
with 24dp horizontal gutters. It measures actual text using the current font,
weight 600, text direction and text scaler. Brand, menu and utilities occupy
one row when they fit; otherwise the brand/utilities precede a second menu row.
There is no fixed breakpoint for this row change. The brand row is at least
72dp and the menu at least 56dp, growing with text. Navigation never becomes
an icon-only rail, and the removed collapse preference has no replacement.

The menu keeps complete labels, 20dp icons, accessible selected state, tooltips
and 2dp informational focus outlines. When it exceeds the available width it
scrolls horizontally and shows a scrollbar. Selection changes and width changes
schedule `Scrollable.ensureVisible` for the selected destination. The wide
shell's `SafeArea` wraps navigation and content.

## Preserved state and motion

Keep `StatefulNavigationShell`, the route map and branch navigators. Selecting
the current destination retains the existing return-to-initial-route behavior.
Changing shell composition does not reset drafts, search or detail stacks.

The top menu's teal 2dp underline moves over 240ms with `easeOutCubic`; revealing
the selected item also uses 240ms. Reduced motion sets both durations to zero.
Text direction governs the row and directional underline. The compact bottom
indicator keeps its native 240ms animation, zero with reduced motion.

`PollarBranchStack` keeps the IndexedStack and each branch navigator mounted.
Only the current branch arrives horizontally, up to 24dp over 240ms with
`easeOutCubic`; destination order sets the side and RTL reverses it. Full
opacity and shell clipping keep one current surface. There is no outgoing
screen duplicate or snapshot. Inactive branches are offstage, excluded from
focus/semantics and have tickers disabled. Reduced motion or accessible
navigation ends arrival immediately, including mid-transition, without a
remount. Returning to a branch retains search, drafts and navigation state.

All five More subroutes keep the existing `pollarMotionPage`. iOS/macOS retain
MaterialPage for native back behavior; other platforms keep the custom page.
More rows reveal by identity with indices 0–4; ordinary theme/privacy rebuilds
do not replay. Authentication, financial rules and synchronization are outside
this layout refinement.

## More child return

The compact utility bar omits duplicate route names and their broad tooltip
targets. Transactions retains its only compact page heading. Navigation hints
remain attached to the actual destination button; the shared tooltip theme
waits two seconds on hover and prefers a position below the control.

Only `/more/*` routes expose “Voltar para Mais”. The compact toolbar retains
its accessible icon action; the wide shell shows a text-and-icon button below
the top navigation. Pop the existing stack when possible; otherwise open
`/more`. Keep the existing theme/privacy controls and route/branch motion.

## Verification boundary

Reference goldens in `apps/pollar_app/test/goldens/` include
`overview_1440x900.png`, `more_800_light_1x.png`, `more_800_dark_2x.png` and
`more_320_dark_2x.png`: wide content, intermediate width, enlarged dark text
and the retained compact shell. Source and automated capture evidence do not
constitute physical Android/iOS acceptance, a hardware back-gesture test,
a screen-reader session or a frame-rate measurement. Execution/build results
and remaining acceptance belong in `docs/redesign-progress.md`.
