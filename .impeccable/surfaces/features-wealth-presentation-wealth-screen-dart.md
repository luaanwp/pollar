---
version: 1
slug: "features-wealth-presentation-wealth-screen-dart"
primary_target: "apps/pollar_app/lib/features/wealth/presentation/wealth_screen.dart"
related_targets: ["apps/pollar_app/lib/features/wealth/presentation/wealth_forms.dart"]
---

Scope: WealthScreen and its goal, asset, and debt creation forms. Mode: Operate.

Audience and job: a person maintaining a Brazilian household ledger who needs to understand current net worth, see what composes it, and keep one financial goal actionable without confusing manually valued property with account balances.

Primary tasks: choose a currency; inspect net worth and its asset/debt composition; add and update goals, manual assets, and debts; pause or complete records without deleting their history.

Proof and content: confirmed account positions from the ledger, exact manually entered valuations and outstanding debt, deterministic goal progress, explicit last-updated dates, and recoverable lifecycle states.

Direction: goal dossier. The first viewport pairs a net-worth balance sheet with the priority goal as a concrete case file. Supporting registers of assets, debts, and other goals explain the headline. The memorable moment is tracing one exact net-worth figure from accounts through property and obligations while seeing the next goal gap.

Constraints: inherit Pollar's flat teal-and-neutral world, pt-BR copy, exact tabular figures, privacy masking, light/dark themes, 200% text reflow, Android 48dp targets, no market-price claims, and no cross-feature imports outside app composition.

Unresolved: market feeds, amortization schedules, collateral links, shared goals, and historical valuation charts remain future adapters or later slices.
