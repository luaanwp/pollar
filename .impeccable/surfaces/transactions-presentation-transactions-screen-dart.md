---
version: 1
slug: "transactions-presentation-transactions-screen-dart"
primary_target: "apps/pollar_app/lib/features/transactions/presentation/transactions_screen.dart"
related_targets: ["apps/pollar_app/lib/features/transactions/presentation/transaction_form_screen.dart", "apps/pollar_app/lib/shared/presentation/transaction_tile.dart", "apps/pollar_app/lib/shared/presentation/pollar_form_controls.dart"]
---

## Scope and mode

`/transactions` and `/transactions/new`, Operate.

## Audience, job and action

People managing personal finances in pt-BR scan, search, register and inspect
income, expenses and transfers. The primary action is “Nova transação”.

## Content and constraints

Exact minor-unit money, account names, fixed transaction statuses, privacy mode,
keyboard/touch accessibility and responsive Flutter behavior. Mobile groups by
day; desktop uses a dense ledger. The 360 px contextual detail panel requires
1020 px after rail and gutters, leaving 640 px for the ledger and 20 px between.
Otherwise details use the root modal, with a bounded scrolling viewport on
desktop. Forms and persistence rules remain unchanged.

## Direction and memorable moment

The serene ledger: selected movement and detail panel share one horizontal read,
while compact layouts preserve the same information in a day-grouped list and
native bottom sheet. Search and type combine, with a result count and one clear
action. Wide controls use four chips; narrower controls use a labeled native
selector. Large text, short windows and narrow containers scroll the controls
with the list while preserving focused search. Complete identity and exact
money reflow. Modal privacy observes the current setting and reserves amount
geometry. Selection outside the filtered result does not retain a detail panel.

Expense filters include card purchases and transfer filters include statement
payments. Canceling retains history. Existing reveal motion and reduced-motion
support stay in place; no new financial calculation is introduced.

## Unresolved decisions

Bulk selection, split transactions, attachments and recurring entries belong to
later slices.
