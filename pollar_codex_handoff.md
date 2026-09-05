# Pollar — Codex Handoff for the Exported Design System

Use this file together with `Pollar Design System.zip`, `pollar_prompts_finance_app.md`, `pollar_design_system.md`, and `pollar_design_tokens.json`.

## What the ZIP actually contains

The export already includes functional mockup-level UI kits, despite being described as only a design-system export:

- Desktop UI kit at `ui_kits/desktop/` targeting 1440×900.
- Mobile UI kit at `ui_kits/mobile/` targeting 430×900.
- 28 React components across charts, core, data, feedback, forms, navigation, and surfaces.
- CSS tokens for color, typography, spacing, shape, elevation, motion, and layout.
- Component prop contracts (`.d.ts`) and per-component prompt notes.
- Interactive examples for privacy mode, dark theme, offline state, synchronization, quick add, statement payment, transaction details, conflict state, and undo toast.
- Realistic pt-BR mock data stored as integer minor units.

The ZIP is a design reference and optional Codex project skill. It is not a Flutter package and must not be copied into application runtime code.

## Recommended location

If using it as a project-specific Codex skill, extract the ZIP without changing its internal structure to:

```text
.codex/skills/pollar-design/
```

Its root `SKILL.md` will then describe how agents should use the design reference. Keep Flutter production assets separately under the normal application asset directories.

## Reuse classification

### Canonical or directly reusable

- `uploads/pollar_design_system.md`: human-readable source specification.
- `uploads/pollar_design_tokens.json`: source values to map into typed Flutter tokens.
- CSS token files: secondary cross-check for semantic aliases and theme behavior.
- `.d.ts` component contracts: useful input when defining Dart widget APIs.
- `.prompt.md` notes: component intent and behavioral guidance.
- pt-BR labels, fixed status vocabulary, and mock financial data.

### Visual/behavioral references only

- All `.jsx` components.
- `_ds_bundle.js`.
- Desktop and mobile HTML entry points.
- Inline CSS layouts and HTML specimen cards.
- React interaction implementations.

Reimplement these idiomatically in Flutter. Do not mechanically translate JSX or inline CSS.

### Do not ship as application dependencies

- React, ReactDOM, and Babel loaded from unpkg.
- Lucide SVGs loaded dynamically from unpkg.
- Inter and JetBrains Mono loaded from Google Fonts.

For Flutter, use pinned package dependencies and bundle required fonts/assets locally where licensing permits. Use one pinned, rounded-outline Flutter icon family or checked-in SVG assets. Do not depend on a runtime icon CDN.

## Coverage already present

### Desktop

- Overview/dashboard.
- Transactions table, filters, selection, and contextual detail panel.
- Credit-card statement and partial-payment presentation.
- Budgets.
- Basic preferences.

### Mobile

- Home/dashboard.
- Day-grouped transactions.
- Transaction details and conflict banner.
- Credit-card statement.
- Budgets.
- More/preferences.
- Quick-add and statement-payment bottom sheets.

## Important gaps

The following requested product areas are absent or incomplete and require future mockups/implementation decisions:

- Onboarding, registration, sign-in, and initial setup.
- Accounts overview, account detail, and reconciliation.
- Complete credit-card management and card creation/editing.
- Full add-card-purchase flow with statement selection and an exact installment schedule.
- Future statements, refunds, fees, adjustments, chargebacks, and early installment payoff.
- Goals.
- Recurring transactions and subscriptions.
- Calendar/upcoming bills.
- Debts and assets.
- Reports: the desktop export deliberately leaves this screen blank.
- Notifications, devices, sync management, data export/import, backup, and account deletion.
- Tablet/medium breakpoint compositions.
- Complete empty/loading/error/stale/conflict-resolution variants across all screens.
- A real reconciliation of every mock dashboard total across all screens.

## Issues to correct during Flutter implementation

1. **Installment remainder:** `CurrencyInput.jsx` previews every installment using `Math.round(total / count)`. This can display a schedule whose installments do not add exactly to the purchase total. Implement deterministic minor-unit remainder distribution. For example, split 10,000 cents into 3 installments as 3,334 + 3,333 + 3,333, according to a documented rule.
2. **Formatting implementation:** the JavaScript display formatter divides cents by 100 using a JavaScript number. Keep the Dart domain representation as integer minor units and use a formatting path that cannot change the stored amount.
3. **External dependencies:** replace runtime CDNs with pinned Flutter dependencies or bundled assets.
4. **Reports coverage:** do not preserve the intentionally blank screen. Design the reports requested by the product specification.
5. **Responsive coverage:** the export provides separate 430 and 1440 examples, not a complete adaptive implementation. Centralize compact, medium, expanded, and wide layout rules.
6. **Mock interactions:** offline/sync toggles, payments, deletion, and undo are visual simulations. Connect them only after domain/application use cases exist.
7. **Accessibility verification:** treat accessibility claims as requirements to test, not proof that the generated components pass. Add semantics, keyboard, focus, contrast, text-scale, and golden tests.
8. **Design-system inventory wording:** the README says “28 components across 6 groups,” but the manifest contains 28 components across 7 directories/groups when navigation is included. Use the manifest as the inventory source.

## Codex implementation instruction

```text
Act as a senior Flutter engineer and product-focused software architect working on Pollar.

Inspect the existing repository before making changes. Read, in this order:

1. pollar_prompts_finance_app.md
2. pollar_design_system.md
3. pollar_design_tokens.json
4. pollar_codex_handoff.md
5. .codex/skills/pollar-design/SKILL.md and its referenced README

Treat pollar_design_system.md as the canonical visual and behavioral prose specification and pollar_design_tokens.json as the canonical source of token values. Treat the exported React/HTML UI kits as visual and interaction references only.

Do not mechanically translate JSX, inline CSS, `_ds_bundle.js`, or web-specific interaction code into Flutter. Do not add React, Babel, Tailwind, a webview, or runtime CDN dependencies to the Flutter application.

First report:

- The existing application architecture and files.
- Which exported design assets are directly reusable.
- Which files are reference-only.
- Conflicts, missing screens, and risks.
- A small, dependency-aware implementation sequence.

Then implement in vertical slices:

Slice 1 — Foundations
- Typed light/dark semantic colors, typography, spacing, radii, elevation, motion, breakpoints, and component sizes.
- Flutter ThemeData, ColorScheme, TextTheme, and immutable ThemeExtension classes.
- Locally available/pinned fonts and icons with verified licenses.
- ResponsiveScaffold and central adaptive-layout policy.

Slice 2 — Core components
- Buttons, icon buttons, inputs, CurrencyInput, select/dropdown, checkbox, switch, cards, status badges, banners, dialogs, sheets, toasts, and empty/error/loading states.
- MoneyText and PrivacyAmount must consume an integer-minor-unit Money value object.

Slice 3 — Financial components
- TransactionTile, DataTable/table composition, MetricCard, StatementSummary, BudgetProgress, InstallmentIndicator, and accessible chart wrappers.
- Implement deterministic installment remainder distribution and test that every schedule sums exactly to the original amount.

Slice 4 — Catalog
- A development-only design-system gallery showing all components, themes, financial states, privacy mode, offline/sync/conflict states, and responsive layouts at 390×844, 430×900, 1024-wide, and 1440×900.

Slice 5 — Reference screens
- Recreate the exported dashboard, transactions, statement, budgets, and preferences screens using the production Flutter components.
- Preserve the exported information hierarchy, not its web implementation details.
- Add semantic navigation and keyboard behavior.

Slice 6 — Missing product screens
- Implement only after defining their UX: authentication/onboarding, accounts and reconciliation, full card purchase/installment flow, reports, goals, recurring/subscriptions, calendar, debts/assets, notifications, sync/devices, and data management.

After every slice run formatting, static analysis, unit/widget/semantics tests, and relevant golden tests. Test light/dark themes, text scaling to 200%, keyboard focus order, reduced motion, compact/medium/expanded/wide behavior, and exact money handling.

Do not alter working domain, database, authentication, or synchronization behavior merely to reproduce a mockup. Do not connect simulated UI actions until the relevant application use case and repository interface exist. Stop and report conflicts instead of silently inventing financial rules.
```

## Recommended immediate next milestone

Build only the Flutter design-system foundations, component catalog, and the two responsive app shells first. This gives a stable visual base while the missing product screens are designed later, without blocking database and synchronization architecture work.
