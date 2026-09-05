# Pollar — Mobile UI kit

Recreation of the compact (`< 600`) shell from `pollar_design_system.md` §11: top app bar + scrollable content + bottom navigation + prominent quick-add action. Design width 430, 16px gutters.

## Screens (`MobileScreens.jsx`)
1. **MobileHome** — balance hero, entradas/saídas pair, balance trend, open statement with utilization meter, budgets, recent transactions.
2. **MobileTransactions** — filter chips, day-grouped `TransactionTile` list (no horizontal scrolling, per §9).
3. **MobileStatement** — statement summary, purchases grouped by date, future installments.
4. **MobileBudgets** — budget lines and category composition.
5. **MobileDetail** — full-page transaction detail with 48px stacked actions and the sync-conflict banner.
6. **MobileMore** — privacy mode, dark theme, reduced motion and settings list rows.

## Interactions
Bottom-nav tabs, back navigation into transaction detail, privacy toggle, offline/sync toggle, quick-add bottom sheet with currency input + installment preview, statement payment sheet, undo toast, light/dark theme.

Shares fake data with the desktop kit (`../desktop/data.js`).
