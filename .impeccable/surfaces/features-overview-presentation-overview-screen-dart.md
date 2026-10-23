---
version: 1
slug: "features-overview-presentation-overview-screen-dart"
primary_target: "apps/pollar_app/lib/features/overview/presentation/overview_screen.dart"
related_targets:
  - "apps/pollar_app/lib/features/overview/presentation/widgets/overview_metrics.dart"
  - "apps/pollar_app/lib/features/overview/presentation/widgets/overview_account_positions.dart"
  - "apps/pollar_app/lib/features/overview/presentation/widgets/overview_recent_transactions.dart"
---

## Scope and mode

Overview route at `apps/pollar_app/lib/features/overview/presentation/overview_screen.dart`. Mode: Operate.

## Audience and job

People checking personal finances on desktop or mobile need to understand their current and projected position immediately, then inspect the movements that explain it.

## Primary task and content

Show balances derived from account opening values and the canonical ledger rules: confirmed balance, projected balance, current-month result, account positions, and recent transactions. Privacy mode must hide every amount without moving the layout. Empty, loading, and recoverable error states are required.

## Direction

“Fechamento de caixa imediato”: one solid financial surface leads with confirmed cash at 40/34px, then projected cash and separately labelled card debt. Monthly result supports it at 22px without a competing outline. Flat account and transaction lists explain the position, using dividers and 18px headings. Exact tabular amounts, semantic states and existing teal remain authoritative; no invented charts or insights.

In stacked layouts, confirmed/projected and monthly context precede Nova transação. Wide layouts retain the action in the header. Layout uses actual component width and stacks evidence columns above 1.3× text. Values wrap without shrinking and reserve both visible/hidden geometry. Recent rows use the shared TransactionTile with opt-in content-aware reflow; other product rows retain their defaults.

## Memorable moment

Confirmed and projected totals sit as a deliberate pair, making future commitments visible without confusing them with cleared money.

## Constraints

The overview feature cannot import accounts or transactions. Cross-feature mapping belongs to app composition. Currency totals stay separated; cards remain liabilities and are not folded into cash balance. Archived accounts remain preserved but do not enter active balance cards; canceled transactions remain visible in recent history and affect no totals.

## Unresolved

Period switching, historical trend charts, budgets, statement summaries, and export wait for their owning slices.

## Verification boundary

Widget tests verify exact balances, currency separation, real create routes,
320px/2× large positive/negative amounts and complete names, privacy geometry,
stacked desktop evidence and a reachable first-account action in a short
window. Goldens cover 320/390/800/1200/1440/1920px, themes and text scaling.
These are Flutter renders and simulated input, not physical device or assistive
technology acceptance. Authentication/synchronization behavior is not changed.
