---
version: 1
slug: "statements-presentation-card-statement-screen-dart"
primary_target: "apps/pollar_app/lib/features/statements/presentation/card_statement_screen.dart"
related_targets: ["apps/pollar_app/lib/features/transactions/presentation/transaction_form_screen.dart"]
---

Scope: statement detail for one configured credit-card account, plus the purchase-installment and payment tasks that feed it.

Mode: Operate.

Audience and job: a person checking what is due, which purchases compose the bill, what remains committed in future months, and recording a full or partial payment without duplicate expense.

Primary actions: add a card purchase, inspect its installment schedule, and pay the selected statement from an eligible cash account.

Proof and content: exact statement period, closing and due dates, status, total, amount paid, outstanding balance, utilization, purchases grouped by date, compact installment position, and future commitments.

Constraints: derive cycles from the card closing/due terms; clamp short months and leap years; isolate currencies; preserve payment as a transfer to the card liability; never store full card number; responsive Flutter layout, privacy mode, dark mode and 200% text.

Direction: extend the established “livro-caixa sereno” with the canonical Pollar statement hierarchy. The memorable moment is the explicit reconciliation from outstanding balance down to dated purchases and forward to the remaining installments.

Unresolved: export, refunds, fees, chargebacks, anticipation and minimum payment remain later capabilities, not synthetic controls.
