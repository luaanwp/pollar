# Pollar — Desktop UI kit

Recreation of the desktop shell described in `pollar_design_system.md` §11 (Page patterns) and §5 (Expanded/Wide breakpoints). Design width 1440.

## Shell
Left sidebar (256 expanded / 72 collapsed) + 60px top utility bar + main workspace (24px gutters, content capped at 1280 for reading columns) + optional 360px contextual detail panel on the transactions screen.

## Screens (`DesktopScreens.jsx`)
1. **DashboardScreen** — the mandated dashboard hierarchy: balance/result metrics → cash-flow trend and open statements → budgets and category composition → recent transactions.
2. **TransactionsScreen** — sortable, selectable table with filter toolbar, bulk actions and the 360px detail panel (including a sync-conflict case).
3. **StatementScreen** — credit-card statement in the mandated order: identity/period/status → totals → pay actions → purchases grouped by date → future installments.
4. **BudgetsScreen** — budget tracking with escalating warning tones.
5. **SettingsScreen** — privacy mode, dark theme, reduced motion, currency and date format.

`reports` is intentionally left blank: the source specification does not define a reports layout.

## Interactions
Sidebar navigation, sidebar collapse, privacy mode (⌘P), quick add (⌘J), offline/sync toggle with banner, sortable + selectable table rows, detail panel, new-transaction dialog, statement payment confirmation, undo toast, light/dark theme switch in Preferências.

## Data
`data.js` holds fake pt-BR data in integer minor units. No real account data.
