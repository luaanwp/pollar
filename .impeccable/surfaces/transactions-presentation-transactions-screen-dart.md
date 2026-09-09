---
version: 1
slug: "transactions-presentation-transactions-screen-dart"
primary_target: "apps/pollar_app/lib/features/transactions/presentation/transactions_screen.dart"
related_targets: ["apps/pollar_app/lib/features/transactions/presentation/transaction_form_screen.dart"]
---

## Scope and mode

`/transactions` and `/transactions/new`, Operate.

## Audience, job and action

People managing personal finances in pt-BR scan, search, register and inspect
income, expenses and transfers. The primary action is “Nova transação”.

## Content and constraints

Exact minor-unit money, account names, fixed transaction statuses, privacy mode,
keyboard/touch accessibility and responsive Flutter behavior. Mobile groups by
day; desktop uses a dense ledger and 360 px contextual detail panel.

## Direction and memorable moment

The serene ledger: selected movement and detail panel share one horizontal read,
while compact layouts preserve the same information in a day-grouped list and
native bottom sheet.

## Unresolved decisions

Bulk selection, split transactions, attachments and recurring entries belong to
later slices.
