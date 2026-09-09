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

“Fechamento de caixa imediato”: a compact financial summary leads, account positions explain the total, and recent movements provide evidence. The established Pollar world remains unchanged: flat bordered surfaces, restrained teal, exact tabular amounts, semantic status labels, no invented historical charts.

## Memorable moment

Confirmed and projected totals sit as a deliberate pair, making future commitments visible without confusing them with cleared money.

## Constraints

The overview feature cannot import accounts or transactions. Cross-feature mapping belongs to app composition. Currency totals stay separated; cards remain liabilities and are not folded into cash balance. Archived accounts remain preserved but do not enter active balance cards; canceled transactions remain visible in recent history and affect no totals.

## Unresolved

Period switching, historical trend charts, budgets, statement summaries, and export wait for their owning slices.
