---
version: 1
slug: "accounts-listing"
primary_target: "apps/pollar_app/lib/features/accounts/presentation/accounts_screen.dart"
related_targets:
  - "apps/pollar_app/lib/shared/presentation/pollar_button.dart"
---

## Scope and mode

Operate. Phase 4A of the user's pinned redesign, plus the existing motion
addendum. This updates Accounts/Credit Cards, not forms, statements, transactions
or planning. Keep typography, palette and all registered financial data.

## Spatial thesis

Regular accounts are compact rows with identity, exact opening value and archive
control. Credit cards remain distinct interactive entities with tilt, explicit
flip and morph to their actual statement. Archived accounts are separate rows
with restoration and real terms preserved. Grouping and dividers replace tall,
equivalent boxes. Two reading zones exist only with enough local width and
normal text scale. Enlarged copy stacks without losing values or controls.

## Constraints

Continue reading openingBalance; never claim current cash or aggregate currency
totals. Preserve lifecycle methods, history and real statement route. Monetary
values wrap and reserve privacy geometry on both faces. Large create/archive
labels may grow through opt-in adaptiveHeight; other buttons retain defaults.
Only-archived state must identify absence of active accounts accurately.

## Verification boundary

Widget tests cover first-viewport statement access at 390×844, rail width,
large-text create action, currency and amount extremes, complete names,
privacy geometry, archive restoration and card flip/statement route. Goldens
cover light/dark, 320/390/800/1440px and 1.3×/2×. These are simulated Flutter
renders/input, not physical-device, screen-reader or performance acceptance.
