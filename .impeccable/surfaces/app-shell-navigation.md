---
version: 1
slug: "app-shell-navigation"
primary_target: "apps/pollar_app/lib/app/routing/app_shell.dart"
related_targets:
  - "apps/pollar_app/lib/app/routing/navigation_preferences.dart"
  - "apps/pollar_app/lib/features/settings/presentation/more_screen.dart"
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

## Verification boundary

Widget and golden tests cover navigation state, keyboard, themes, text scaling,
short-height scroll and simulated system inset. These do not constitute a
physical Android/iOS test or screen-reader session. Page composition follows
in subsequent phases. No new product package is produced in this phase.
