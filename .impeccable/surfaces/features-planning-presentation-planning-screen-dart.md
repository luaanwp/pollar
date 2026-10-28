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

Direction: planning bands. A quiet monthly position leads into chronological commitments, compact category budgets, subscriptions, reminders and management. Agenda comes before budgets on stacked layouts; desktop can pair them in 3:2. The memorable moment is one month reconciled across limit, calendar, and alert state without decorative charts.

Constraints: inherit Pollar's established light/dark visual world, pt-BR copy, exact tabular figures, privacy masking, 200% text reflow, no native OS notification claim, and no cross-feature imports outside app composition.

Unresolved: native operating-system delivery remains a future adapter; V1 reminders live in the app.

## Implemented slice 4C

Authority: `PRODUCT.md`, root `DESIGN.md` and `pollar_design_tokens.json`, with
the first six source comments as the direction contract. Preserve the existing
world. FORM remains “Faixas de planejamento”, sixth structure from the inherited
seed `1f953018`; this slice does not roll or choose another form.

First viewport: month/currency, a single solid `financialSurface` position band,
then adaptive-height create actions. “Disponível no orçamento” uses legacy
`amountHero` 34px; Total orçado, Gasto registrado and Compromissos de saída are
16px. The same four figures remain; no new financial calculation is introduced.
Position is horizontal only at local width ≥820px and text ≤1.3×. Otherwise
available leads, with the first two supports paired only at ≥280px and ≤1.3×.

Operational reading order: agenda, category budgets, subscriptions, local
reminders and management. Agenda/budgets pair 3:2 only at ≥960px of available
content width and text ≤1.3×. Sections are Semantics groups with whitespace and
dividers, without outer cards or borders. Dates, names, kinds and signed amounts
remain complete. Agenda moves amount under identity at <520px locally or text
>1.3×; date width is 48px normally and 64px above 1.3×.

Budgets expose “Gasto registrado” and “Limite”, stacking at <280px locally or
text >1.3×. Percentages and status remain exact/current during the 360ms
`_BudgetUsage` geometry transition (`PollarMotion.focal`, `easeOutCubic`). Privacy
immediately removes transition, proportion, percentage and relative state:
zero-fill track, “—”, neutral “Uso oculto” and hidden-use semantics. Reduced
motion paints the final geometry statically. All money wraps in bounded width
with visible/hidden layout reservation; available alone opts into rolling
between actual states, never synthetic intermediate amounts.

Reflow: section headers stack at <280px, <480px when a trailing amount exists,
or text >1.3×; reminders at <600px and management at <560px also stack above
1.3×. Section, management and confirmation buttons use adaptive height. Forms,
pause/resume, month/currency selection and financial rules remain unchanged.

Evidence: source in `planning_screen.dart`; focused coverage in
`apps/pollar_app/test/features/planning/presentation/planning_redesign_test.dart`
and `apps/pollar_app/test/goldens/planning_redesign_golden_test.dart` alongside
the existing planning tests. `apps/pollar_app/test/goldens/planning_*` includes
320/390/640/1200 layouts, both themes, privacy, empty states, long values and
enlarged text. The fresh finish review verdict is **ship**, with no material
defects. Final suite/build/runtime results are recorded separately by the
coordinator in `docs/redesign-progress.md`; this brief makes no final pass count.
