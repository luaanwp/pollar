---
version: 1
slug: "accounts-listing"
primary_target: "apps/pollar_app/lib/features/accounts/presentation/accounts_screen.dart"
related_targets:
  - "apps/pollar_app/lib/shared/presentation/pollar_button.dart"
  - "apps/pollar_app/lib/shared/presentation/pollar_credit_surface.dart"
  - "apps/pollar_app/lib/shared/presentation/pollar_motion.dart"
---

## Scope and mode

Operate. Phase 4A of the user's pinned redesign, plus the existing motion
addendum and the implemented credit identity refinement. This surface records
Accounts/Credit Cards; the connected statement has its own brief. Keep the
existing palette, typography and all registered financial data. Ordinary and
archived rows remain established; the credit face applies only to active cards.

## Spatial thesis

Regular accounts are compact rows with identity, exact opening value and archive
control. Credit cards remain distinct interactive entities with tilt, explicit
flip and morph to their actual statement. Archived accounts are separate rows
with restoration and real terms preserved. Grouping and dividers replace tall,
equivalent boxes. Two reading zones exist only with enough local width and
normal text scale. Enlarged copy stacks without losing values or controls.

## Implemented credit identity

Use a solid blue band on each active face, with no gradient: `creditSurface`
derives from existing light `info` / dark `infoSoft`; foreground derives from
canvas / text-primary. Secondary is a 96% mix toward foreground and hover an 8%
mix. `PollarCreditSurface` supplies local money, mask, icon and focus contrast.
This bounded credit identity leaves the Overview teal 48/40px field and mint
foundation/library defaults intact.

The front shows the full registered name, type/currency and archive control,
then registered limit at 34px and initial debt. Its neutral footer shows closing
and due days, followed by “Ver fatura” and “Virar cartão”. The reverse shows real
card conditions, initial debt, limit and cycle, followed by “Ver fatura” and
“Voltar à frente”. Do not invent bank branding, a card number, PAN or CVV.

Face actions opt into adaptive height and stack below 300px of local width or
above 1.3× text. Flip passes the existing face FocusNodes through optional
`PollarButton.focusNode`, restoring focus on the visible face; hidden content
receives no focus, touch or semantics. The real card/statement route opts into
`creditIdentity: true` on both endpoints. Its neutral Hero shuttle contains only
blue surface and a foreground icon, without retained values. Reduced motion
removes Hero and keeps direct flip access.

Accounts/cards share columns at 980px locally, text up to 1.3× and content in
both groups. Credit cards use two columns only at 1000px inside their section
and text up to 1.3×; otherwise each card is at most 640px wide.

## Constraints

Continue reading openingBalance; never claim current cash or aggregate currency
totals. Preserve lifecycle methods, history and real statement route. Monetary
values wrap and reserve privacy geometry on both faces. Large create/archive
labels may grow through opt-in adaptiveHeight; other buttons retain defaults.
Only-archived state must identify absence of active accounts accurately.

## Verification boundary

Widget tests cover first-viewport statement access at 390×844, rail width,
large-text create action, currency and amount extremes, complete names,
privacy geometry, archive restoration and card flip/statement route. Goldens
cover light/dark, 320/390/800/1440px and 1.3×/2×. These are simulated Flutter
renders/input, not physical-device, screen-reader or performance acceptance.

Credit-specific coverage includes two-theme foreground contrast, keyboard flip
and face focus restoration, privacy activated during flip, neutral real-route
Hero flight and reduced-motion removal. Reference captures under
`apps/pollar_app/test/goldens/` include `accounts_390x900.png`,
`accounts_credit_back_390.png` and `accounts_credit_back_1440_dark.png`.
Final suite/analysis/build outcomes belong in `docs/redesign-progress.md`.
