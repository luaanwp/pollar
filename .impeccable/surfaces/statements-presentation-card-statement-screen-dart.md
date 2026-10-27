---
version: 1
slug: "statements-presentation-card-statement-screen-dart"
primary_target: "apps/pollar_app/lib/features/statements/presentation/card_statement_screen.dart"
related_targets:
  - "apps/pollar_app/lib/features/transactions/presentation/transaction_form_screen.dart"
  - "apps/pollar_app/lib/features/statements/presentation/widgets/statement_summary.dart"
  - "apps/pollar_app/lib/features/statements/presentation/widgets/statement_purchases.dart"
  - "apps/pollar_app/lib/features/statements/presentation/widgets/future_installments.dart"
  - "apps/pollar_app/lib/shared/presentation/pollar_credit_surface.dart"
---

Scope: statement detail for one configured credit-card account, plus the purchase-installment and payment tasks that feed it.

Mode: Operate.

Audience and job: a person checking what is due, which purchases compose the bill, what remains committed in future months, and recording a full or partial payment without duplicate expense.

Primary actions: add a card purchase, inspect its installment schedule, and pay the selected statement from an eligible cash account.

Proof and content: exact statement period, closing and due dates, status, total, amount paid, outstanding balance, utilization, purchases grouped by date, compact installment position, and future commitments.

Constraints: derive cycles from the card closing/due terms; clamp short months and leap years; isolate currencies; preserve payment as a transfer to the card liability; never store full card number; responsive Flutter layout, privacy mode, dark mode and 200% text.

Direction: extend the established “livro-caixa sereno” with the canonical Pollar statement hierarchy. The memorable moment is the explicit reconciliation from outstanding balance down to dated purchases and forward to the remaining installments.

Unresolved: export, refunds, fees, chargebacks, anticipation and minimum payment remain later capabilities, not synthetic controls.

## Implemented hierarchy and identity

Period and status remain outside the solid-blue band. “Saldo da fatura” shows
the actual `outstanding` at 34px, followed by due date. The blue identity reuses
light `info` and dark `infoSoft`; foreground uses canvas / text-primary, secondary
mixes toward foreground by 96%, and hover by 8%. `PollarCreditSurface` applies a
local Theme to money, privacy masks, icons and focus. No gradient, new brand hue,
bank branding or synthetic card number is introduced. The Overview's teal
48/40px opening and library mint defaults remain separate established roles.

When payments are pending, “Pagamento pendente” and “Disponível para pagar” are
explicitly separate from paid and outstanding. The financial logic is unchanged:
pending is not paid, payment eligibility/ceiling uses `availableToPay`, and a
payment is a same-currency transfer rather than a second expense.

Total, paid and available limit remain below the band, with exact bounded values,
wrapping and visible/hidden geometry reservation. Metrics stack when the local
width cannot hold their measured full numeric tokens and masks, or above 1.3×
text. Utilization follows, then the eligible payment action. The 360ms focal
transition changes only utilization geometry; privacy removes fill immediately
and keeps a fixed neutral track with hidden semantics. Reduced motion renders
the final fraction without a Tween.

Purchases and future installments use flat groups. Preserve daily grouping,
subtotals, category, signed purchase values, complete names, installment
positions, all future rows and the complete committed total. Every amount wraps
within bounded width and reserves visible/hidden geometry; enlarged text stacks
identity and amount without reducing type.

## Reflow and continuity

Summary and future installments share the first row only at 820px locally with
text up to 1.3×; purchases follow at full width. In compact windows below 600px,
order is summary, purchases, future. Larger windows without room for the pair
stack summary and future before purchases, preserving the established order.
The header places “Adicionar compra” below identity at local
width below 700px or text above 1.3×. This action and payment controls opt into
adaptive height, keeping complete labels.

The real statement and source card opt into `PollarCardMorph.creditIdentity`.
The neutral Hero shuttle paints only blue and a foreground icon, with no retained
financial copy or accessible value. Reduced motion removes Hero entirely.

## Verification boundary

Focused widget coverage includes privacy geometry across three widths,
utilization interrupted mid-transition, reduced-motion static output, pending
payments, enlarged text, exact extreme values and complete purchase/future
content. Credit-route tests cover neutral flight and immediate reduced-motion
removal. Captures in `apps/pollar_app/test/goldens/` include
`statement_1200x900.png`, `statement_pending_390x844.png`,
`statement_privacy_1200_dark.png`, `statement_390_2x.png` and
`statement_320_130pct.png`. Final suite, analysis and build status belongs in
`docs/redesign-progress.md`. These Flutter renders and simulated inputs do not
establish physical-device, assistive-technology or FPS acceptance.
