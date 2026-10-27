---
version: 1
slug: "features-overview-presentation-overview-screen-dart"
primary_target: "apps/pollar_app/lib/features/overview/presentation/overview_screen.dart"
related_targets:
  - "apps/pollar_app/lib/features/overview/presentation/widgets/overview_metrics.dart"
  - "apps/pollar_app/lib/features/overview/presentation/widgets/overview_monthly_flow.dart"
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

“Fechamento de caixa imediato”: one static teal tonal field spans the content width and leads with confirmed cash at 48/40px, selected at 600px of real balance-block width by `positionDisplayForWidth`, then projected cash and separately labelled card debt. The existing-palette `financialHeroStart`/`End`/`Foreground`/`Secondary` roles define the field in both themes; a local Theme supplies audited contrast to MoneyText and privacy masks. Solid `financialSurface` and 40/34px balance roles remain for other consumers. Monthly result follows below at 22px without a competing outline. Two bars compare existing projected monthly income/expense totals on one scale relative to the larger total; zero has zero fill. Exact labelled amounts provide the accessible evidence, with decorative bars excluded from semantics. Flat account and transaction lists explain the position, using dividers and 18px headings. Exact tabular amounts, semantic states and existing teal remain authoritative; no historical series, invented financial values or insights.

In stacked layouts, confirmed/projected and monthly context precede Nova transação. Wide layouts retain the action in the header. Layout uses actual component width and stacks evidence columns above 1.3× text. Values wrap without shrinking and reserve both visible/hidden geometry. Recent rows use the shared TransactionTile with opt-in content-aware reflow; other product rows retain their defaults.

The field uses a 6:4 balance/projection split only at 880px of available width and text up to 1.3×, with 32px insets; otherwise it stacks with 20px insets. Monthly result/comparison and evidence columns also require 880px and text up to 1.3×. The header action requires 960px and text up to 1.3×. Comparison lanes stack below 320px locally or above 1.3× text.

Bar geometry transitions last 360ms (`PollarMotion.focal`, `easeOutCubic`). Privacy removes proportions immediately and keeps neutral tracks; reduced motion renders final fractions without a Tween. Recent rows use PollarReveal keyed by transaction identity with stagger bounded to five 20ms steps; ordinary theme/privacy rebuilds do not replay arrival. The gradient remains static. Financial calculations, currencies, routes and states are preserved.

## Memorable moment

Confirmed and projected totals share a full-width tonal field; the two real monthly bars below explain flows without confusing future commitments with cleared money.

## Constraints

The overview feature cannot import accounts or transactions. Cross-feature mapping belongs to app composition. Currency totals stay separated; cards remain liabilities and are not folded into cash balance. Archived accounts remain preserved but do not enter active balance cards; canceled transactions remain visible in recent history and affect no totals.

## Unresolved

Period switching, historical trend charts, budgets, statement summaries, and export wait for their owning slices.

## Verification boundary

Focused widget tests verify monthly proportions, zero totals, immediate privacy
removal and reduced-motion fallback, alongside exact balances, currency separation, real create routes,
320px/2× large positive/negative amounts and complete names, privacy geometry,
stacked desktop evidence and a reachable first-account action in a short
window. Goldens cover 320/390/800/1200/1440/1920px, themes and text scaling.
Contrast tests sample 21 positions along the tonal field per theme for AA.
Final validation reports 380 passing tests, clean analysis and a completed
Windows Release build, with its executable opened. These are Flutter renders,
automated checks and simulated input, not physical-device, assistive-technology
or FPS acceptance. Authentication/synchronization behavior is not changed.
