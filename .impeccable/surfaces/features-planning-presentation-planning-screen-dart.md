---
version: 1
slug: "eatures-planning-presentation-planning-screen-dart"
primary_target: "apps/pollar_app/lib/features/planning/presentation/planning_screen.dart"
related_targets: ["apps/pollar_app/lib/features/planning/presentation/planning_forms.dart"]
---

Scope: PlanningScreen and its budget/recurring creation dialogs. Mode: Operate.

Audience and job: a person planning a Brazilian household month who needs to see category limits, due commitments, subscriptions, and timely reminders without confusing plans with posted ledger facts.

Primary tasks: move between months; add a category budget; add an income, expense, or subscription rule; pause a plan; understand exact totals and due dates.

Proof and content: real persisted budgets and rules, actual categorized ledger spending, deterministic calendar occurrences, and reminders derived from due dates. Empty states explain the next action.

Direction: planning bands. A quiet monthly position leads into distinct horizontal bands for budgets, chronological commitments, subscriptions, and reminders. On desktop the first operational bands pair; on mobile they become a single ordered ledger. The memorable moment is one month reconciled across limit, calendar, and alert state without decorative charts.

Constraints: inherit Pollar's established light/dark visual world, pt-BR copy, exact tabular figures, privacy masking, 200% text reflow, no native OS notification claim, and no cross-feature imports outside app composition.

Unresolved: native operating-system delivery remains a future adapter; V1 reminders live in the app.
