# Personal Finance App — Architecture and AI Prompts

This document contains a recommended technical direction and two ready-to-use English prompts:

1. A software-engineering prompt to begin building the product.
2. A UI/UX prompt for creating a responsive mockup in Claude Design.

---

## Recommended stack

- **Client applications:** Flutter + Dart, targeting Windows, Android, and iOS from one codebase. Add macOS later if needed.
- **State management:** Riverpod.
- **Navigation:** go_router.
- **Local database and offline cache:** Drift on SQLite.
- **Backend and synchronization:** Supabase with PostgreSQL, Auth, Row Level Security, Realtime, Storage, and Edge Functions where server-side logic is necessary.
- **Data serialization/models:** Freezed + json_serializable.
- **Charts:** fl_chart.
- **Secure local secrets:** flutter_secure_storage.
- **Biometric access on mobile:** local_auth.
- **Testing:** flutter_test, integration_test, mocktail, and PostgreSQL/Supabase integration tests.
- **CI/CD:** GitHub Actions; Flutter build pipelines; Supabase CLI migrations.
- **Observability:** Sentry, with financial values and personal data removed from logs.

### Why this stack

Flutter provides a strong shared codebase for a Windows PC program and mobile apps while still allowing responsive, platform-aware interfaces. PostgreSQL is a better fit than a document database because financial data has strong relationships among accounts, transactions, cards, installments, and statements. Supabase provides authentication, database security, migrations, and synchronization infrastructure without requiring a large custom backend for a personal project.

### Non-negotiable engineering rules

- Store money as integer minor units, such as cents, or as PostgreSQL `NUMERIC`; never use binary floating-point.
- Store timestamps in UTC and retain the user's time zone for calendar-based reporting and statement boundaries.
- Use UUIDs generated on the client so records can be created offline.
- Treat financial records as auditable data. Prefer soft deletion, change history, and reversible operations.
- Enforce access with PostgreSQL Row Level Security, not only in the UI.
- Never store bank credentials. A future bank-integration feature must use a regulated Open Finance provider and token-based authorization.
- Encrypt transport with TLS, keep tokens in secure device storage, redact logs, and support biometric/PIN app locking.
- Use an offline-first outbox/inbox synchronization model with idempotent mutations, record versions, tombstones, retry handling, and deterministic conflict rules.
- Recurring transactions are templates that generate occurrences; generated transactions must remain independently editable.
- A credit-card purchase creates one or more installment records. Each installment belongs to exactly one card statement according to the card's closing date and due-date rules.

---

# Prompt 1 — Begin coding the product

Copy everything inside the following block into your coding assistant.

```text
Act as a senior software engineer, solution architect, database designer, security engineer, and pragmatic product engineer. Build the foundation of a production-quality personal finance application named "Pollar". This is initially a private personal project, but the architecture must be maintainable, secure, testable, and capable of supporting multiple users later.

PRODUCT GOAL
Create a Windows desktop application that synchronizes with Android and iOS mobile applications. The product must let a user manage their complete personal financial life: accounts, balances, income, expenses, transfers, credit cards, installments, card statements, budgets, goals, recurring payments, subscriptions, debts, assets, reports, and reminders. It must remain useful offline and synchronize safely when connectivity returns.

MANDATORY STACK
- Flutter and Dart for Windows, Android, and iOS from a shared codebase.
- Riverpod for dependency injection and state management.
- go_router for typed/declarative navigation.
- Drift with SQLite for the offline local database.
- Supabase: PostgreSQL, Auth, Row Level Security, Realtime where appropriate, Storage, and Edge Functions only for trusted server-side work.
- Freezed and json_serializable for immutable domain models and DTOs.
- flutter_secure_storage for tokens/secrets and local_auth for optional biometric unlocking.
- fl_chart for charts.
- GitHub Actions and Supabase CLI migrations.
- Sentry-compatible observability, but never send monetary values, descriptions, account names, tokens, or personal information to telemetry.

ARCHITECTURE
Use a feature-first Clean Architecture structure with presentation, application, domain, and data boundaries. Keep domain logic independent of Flutter, Supabase, and Drift. Use repository interfaces in the domain/application layer and implementations in the data layer. Prefer simple, explicit code over unnecessary abstraction.

Suggested repository layout:
- apps/finance_app/ for the Flutter application
- supabase/migrations/ for versioned SQL migrations
- supabase/functions/ for any Edge Functions
- docs/ for architecture decisions, data model, security, sync protocol, and setup

Inside Flutter, organize by feature: auth, onboarding, dashboard, accounts, transactions, credit_cards, statements, budgets, goals, recurring, subscriptions, debts, investments/assets, reports, notifications, settings, sync, and shared/core.

FINANCIAL DOMAIN REQUIREMENTS
1. Accounts
   - Checking, savings, cash wallet, investment, digital wallet, loan/debt, and custom types.
   - Institution, opening balance, current calculated balance, currency, color/icon, active/archived state.
   - Balance must be derived reliably from opening balance and posted transactions, with reconciliation support.

2. Transactions
   - Income, expense, and transfer.
   - Amount, currency, account, category, subcategory, date/time, status (planned, pending, cleared, reconciled), payee, description, notes, tags, attachments, location optional, and created/updated metadata.
   - Split transactions across multiple categories.
   - Transfers must be represented atomically as linked entries and must not inflate income or expense reports.
   - Duplicate, edit, archive/soft-delete, search, filters, bulk categorization, CSV import/export, and receipt attachment.

3. Credit cards
   - Card name, issuer, last four digits only, brand, color, credit limit, available limit, statement closing day, due day, default payment account, active/archived state.
   - Never store a full card number, CVV, or banking password.
   - Purchases may be one-time or split into N installments.
   - Display installment number in the format "3/12", original purchase total, installment amount, remaining balance, upcoming installments, and early payoff/anticipation where supported manually.
   - Support interest-bearing installment plans and fees as explicit financial entries rather than hidden calculations.
   - Handle refunds, partial refunds, chargebacks, card fees, cash advances, and statement adjustments.

4. Card statements
   - Generate statements from closing-date rules and assign each card transaction/installment to one statement.
   - States: open, closed, partially paid, paid, overdue.
   - Show opening/closing dates, due date, purchases, installments, refunds, fees, payments, total, amount paid, outstanding amount, and minimum payment entered by the user if desired.
   - Paying a statement creates a linked transfer from a bank account to the card liability. Partial and multiple payments must be supported without double-counting expenses.
   - Closing-day and due-day behavior must work correctly for short months, leap years, time zones, and purchases made near the closing boundary.

5. Planning
   - Monthly/category budgets with rollover optional.
   - Savings goals with target amount/date and linked contributions.
   - Recurring transaction templates with frequency, start/end dates, reminders, automatic generation option, and exception editing.
   - Subscription tracking with price-change history and renewal reminders.
   - Bills calendar, upcoming cash-flow forecast, and low-balance/limit alerts.

6. Reports
   - Net worth, cash flow, income versus expense, spending by category, monthly trends, budget versus actual, account evolution, credit utilization, statement forecast, debt payoff, and subscription totals.
   - Filters by period, account, card, category, tag, payee, and status.
   - Reports must exclude transfers from income/expense totals and avoid double-counting card purchases when card statements are paid.

7. Settings and data ownership
   - Currency and locale, first day of week, time zone, theme, privacy lock, notification preferences, categories, tags, export, backup, account deletion, and full data deletion.
   - Initial locales: pt-BR and en-US. Initial currency: BRL, but do not hard-code it.
   - Prepare the model for multiple currencies; clearly distinguish transaction currency, account currency, exchange rate, and base/reporting currency.

DATA MODEL
Design and document a normalized PostgreSQL schema. At minimum evaluate these entities:
profiles, devices, institutions, accounts, account_balances/reconciliations, categories, tags, transactions, transaction_splits, transaction_tags, transfer_links, attachments, credit_cards, card_purchases, installments, card_statements, statement_payments, budgets, budget_periods, goals, goal_contributions, recurring_rules, subscriptions, debts, assets, exchange_rates, notifications, sync_mutations, audit_events, and user_preferences.

Do not blindly create every table if a simpler normalized model is more correct. Explain important choices. Define primary keys, foreign keys, unique constraints, check constraints, indexes, ownership fields, created_at, updated_at, deleted_at/tombstones, and version fields. Provide Row Level Security policies ensuring users can access only their own rows, including through child tables. Add SQL tests or a documented verification script for RLS isolation.

MONEY, DATES, AND CALCULATIONS
- Never use float/double for money. In Dart use an integer minor-unit value object; in PostgreSQL use BIGINT minor units consistently, with an explicit currency code.
- Create tested Money, Currency, LocalDate, BillingCycle, and InstallmentPlan domain concepts.
- Store instants in UTC. Preserve user time zone and use date-only types for due dates and statement dates.
- Define deterministic rounding and remainder distribution for installments. Example: BRL 100.00 in 3 installments must sum exactly to BRL 100.00.
- Centralize calculations and test them thoroughly.

OFFLINE-FIRST SYNCHRONIZATION
Implement a documented synchronization design rather than relying blindly on Realtime:
- Local SQLite is the responsive source for UI reads.
- Client-generated UUIDs allow offline creation.
- Every mutation enters an outbox with operation ID, entity ID, base version, timestamp, and payload.
- Server mutations are idempotent.
- Pull remote changes using a monotonic cursor or server change log and tombstones.
- Retry with exponential backoff and surface sync status without blocking normal use.
- Define conflicts per entity. Use automatic field-level/last-write rules only for low-risk metadata. For conflicting financial amounts, accounts, dates, card/statement assignments, or deletions, preserve both versions and request user resolution.
- Test offline create/edit/delete, concurrent device edits, retries, duplicate delivery, clock skew, and interrupted synchronization.

SECURITY AND PRIVACY
- Email/password and optionally magic-link authentication; design an interface for future passkeys.
- Row Level Security is mandatory on all user data.
- Store session material only in secure storage.
- Optional biometric/PIN app lock is local defense-in-depth, not a replacement for server authentication.
- TLS only. No secrets committed to source control. Provide .env.example with placeholders.
- Sanitize filenames and validate attachment MIME/size.
- Redact application logs and crash reports.
- Add export and permanent account deletion flows.
- Do not claim regulatory compliance; document security assumptions and threat model.

UX REQUIREMENTS FOR IMPLEMENTATION
- Adaptive desktop and mobile navigation.
- Desktop: collapsible left sidebar, content workspace, optional right contextual panel, keyboard shortcuts, dense tables where useful.
- Mobile: bottom navigation, concise cards/lists, floating quick-add action, thumb-friendly controls.
- Fast global quick-add for expense, income, transfer, and card purchase.
- Dashboard includes total balance/net worth, current-month income and expenses, cash-flow trend, budgets, upcoming bills, open card statements, card utilization, and recent activity.
- Loading, empty, error, offline, stale-data, syncing, and conflict states must be designed—not added later.
- Accessibility: semantic labels, keyboard navigation, focus states, scalable text, screen-reader support, and WCAG AA contrast.

DELIVERY METHOD
Work incrementally. Do not attempt to generate the entire application in one response. First produce:
1. A concise architecture decision record, including why Flutter + Supabase + Drift is suitable and its tradeoffs.
2. The repository/folder structure.
3. A domain glossary and core invariants.
4. An ER diagram in Mermaid and a first-pass PostgreSQL schema plan.
5. The offline sync protocol and conflict matrix.
6. A phased roadmap: Foundation, MVP, Credit Cards/Statements, Planning/Reports, Hardening.
7. Clear MVP scope and explicitly deferred features.
8. Then scaffold only the Foundation and first vertical slice: authentication, local database, remote profile/RLS, account creation, expense creation, local display, sync, and tests.

For every phase:
- Show changed files and explain significant decisions.
- Provide runnable commands.
- Add migrations and tests together with implementation.
- Run formatter, static analysis, unit tests, widget tests, and relevant integration tests.
- Do not leave silent TODOs in critical financial or security paths.
- If a requirement is ambiguous, state a reasonable assumption and continue unless it would create irreversible architectural risk.

ACCEPTANCE CRITERIA FOR THE FIRST VERTICAL SLICE
- A user can register/sign in, create an account, add an expense offline, see it immediately, reconnect, synchronize it exactly once, and see it on a second authenticated device.
- Another user cannot read or modify the first user's records, verified by an RLS test.
- Monetary values round-trip exactly.
- Repeated sync requests do not duplicate transactions.
- Deleting an offline transaction syncs a tombstone and does not resurrect on another device.
- The app clearly displays offline/sync/error status.
- Setup documentation allows a new developer to run the project locally.

Begin now with items 1 through 7. Stop for review before scaffolding the code unless the environment explicitly supports creating and testing the repository immediately; if it does, proceed through the first vertical slice and report test results.
```

---

# Prompt 2 — Create the UI mockup in Claude Design

Copy everything inside the following block into Claude Design.

```text
Act as a senior product designer specializing in fintech, responsive desktop software, mobile apps, design systems, and accessible data visualization. Create a high-fidelity, implementation-ready UI mockup and clickable prototype for a personal finance product named "Pollar". It consists of a Windows desktop application synchronized with Android and iOS apps.

PRODUCT CHARACTER
Pollar should feel calm, trustworthy, private, precise, and modern—not playful, gamified, crypto-oriented, or visually noisy. The interface should reduce anxiety around money and make complex credit-card and installment information easy to understand. Use realistic Brazilian Portuguese content and BRL values in the mockups, while designing the system for localization. Do not use lorem ipsum.

VISUAL DIRECTION
- Clean contemporary fintech aesthetic with generous spacing and strong information hierarchy.
- Light and dark themes.
- Neutral surfaces with one restrained primary accent (deep emerald or refined teal), semantic green for positive values, red for expenses/overdue states, amber for warnings, and blue for informational states.
- Avoid excessive gradients, glassmorphism, oversized rounded cards, decorative charts, and color-only status communication.
- Use a readable modern sans-serif such as Inter or a close system-compatible equivalent.
- Use tabular numerals for financial values.
- 8-point spacing system; consistent radius, elevation, border, and icon tokens.
- Meet WCAG AA contrast. Include visible keyboard focus, large touch targets, semantic labels, and scalable type considerations.

RESPONSIVE STRUCTURE
Desktop (1440×900 primary frame):
- Collapsible left navigation sidebar.
- Top bar with global search, date/period selector, privacy mode to hide balances, sync state, notifications, and profile.
- Main content area optimized for dashboards, tables, filters, charts, and forms.
- Optional right contextual drawer for transaction/card details.
- Keyboard shortcut discoverability and command/quick-add palette.

Mobile (390×844 primary frame):
- Bottom navigation with Home, Transactions, Planning, Reports, and More.
- Prominent quick-add action for expense, income, transfer, and card purchase.
- Thumb-friendly forms, bottom sheets, progressive disclosure, and concise cards.
- Preserve the same data hierarchy as desktop without shrinking desktop tables into unreadable mobile layouts.

INFORMATION ARCHITECTURE
- Overview
- Transactions
- Accounts
- Credit Cards
- Budgets
- Goals
- Recurring & Subscriptions
- Debts & Assets
- Reports
- Calendar
- Settings

CREATE A UI MOCKUP WITH THESE CORE SCREENS
1. Onboarding and sign-in
   - Welcome, email/password or magic link, privacy explanation, locale/currency/time-zone setup, optional biometric lock, and initial account creation.

2. Dashboard / Overview
   - Net worth or total balance with privacy toggle.
   - Income, expenses, and monthly result.
   - Cash-flow line/area chart with accessible labels.
   - Spending by category.
   - Budget progress.
   - Upcoming bills and subscriptions.
   - Open credit-card statements with due dates and status.
   - Credit utilization.
   - Recent transactions.
   - Sync/offline status that is noticeable but unobtrusive.

3. Transactions
   - Desktop data table and mobile transaction list.
   - Search; filter by period, account/card, type, category, tag, payee, and status.
   - Group by date and show income/expense/transfer/card-purchase distinctions clearly.
   - Add/edit flow for expense, income, transfer, split transaction, recurring transaction, and receipt attachment.
   - Include planned, pending, cleared, reconciled, and archived states.

4. Accounts
   - Account cards/list for checking, savings, cash, digital wallet, investment, and debt.
   - Account detail with balance trend, transactions, reconciliation action, and account settings.

5. Credit Cards overview
   - Each card shows issuer/name, masked last four digits, current/open statement total, available limit, utilization, closing date, due date, and payment status.
   - Include multiple cards and an archived-card state.

6. Credit Card detail and statement
   - Tabs or segmented views for Current Statement, Future Statements, Purchases, Installments, and Settings.
   - Statement summary: period, closing date, due date, total, amount paid, outstanding amount, and status (open, closed, partially paid, paid, overdue).
   - Group purchases by date and optionally by cardholder/tag.
   - Make refunds, fees, adjustments, and payments visually distinct.
   - Actions: pay statement, record partial payment, add purchase, export, and inspect future installments.
   - Include an installment purchase detail showing original total, installment value, current installment (for example 3/12), paid amount, remaining amount, schedule, and early-payment action.

7. Add credit-card purchase flow
   - Card, merchant, category, purchase date, total amount, one-time versus installments, number of installments, first statement, interest/fees optional, tags, notes, and attachment.
   - Show a live installment preview whose values always add up exactly to the purchase total.

8. Budgets and Goals
   - Category budgets with spent, remaining, forecast, percentage, rollover state, and warning states.
   - Savings goals with target amount/date, progress, contribution history, and add-contribution flow.

9. Calendar / Upcoming
   - Monthly and agenda views for bills, recurring income/expenses, subscriptions, statement closing dates, due dates, and reminders.

10. Reports
   - Net worth, cash flow, income vs. expense, category spending, budget vs. actual, account evolution, credit utilization, future statement forecast, and subscriptions.
   - Clear date controls and filters.
   - Every chart needs a text summary or accessible data alternative; transfers and statement payments must not appear as duplicated expenses.

11. Settings
   - Profile, currency/locale/time zone, categories/tags, cards/accounts management, notifications, theme, privacy lock, sync/devices, data export/import, backups, and delete account/data.

REQUIRED STATES AND EDGE CASES
For important components, create variants for loading, skeleton, empty, populated, validation error, network error, offline with queued changes, synchronizing, conflict requiring review, stale data, success, archived, disabled, overdue, partially paid, and privacy-hidden balances. Include confirmation and undo patterns for destructive actions. Do not rely only on color for any status.

DESIGN SYSTEM DELIVERABLES
- Foundations: color tokens for light/dark, typography scale, spacing, grid, radii, elevation, icon rules, and motion guidance.
- Components with variants: buttons, icon buttons, fields, currency input, date picker, select, chips, filters, tabs, navigation, cards, tables, lists, progress indicators, status badges, dialogs, bottom sheets, toasts, banners, empty states, charts, and skeletons.
- Financial formatting rules for positive/negative values, BRL, hidden values, percentages, dates, and installment labels.
- Responsive behavior and breakpoints for desktop, tablet, and mobile.
- Component names and reusable design tokens that map cleanly to Flutter widgets and ThemeExtensions.

PROTOTYPE FLOWS
Create clickable paths for:
A. First-time setup → create checking account → arrive at dashboard.
B. Quick add → add an expense offline → see queued sync state → synchronization success.
C. Add a credit-card purchase in 12 installments → inspect installment schedule → see it in the correct statement.
D. Open an overdue statement → record a partial payment → view remaining balance.
E. Create a monthly category budget → receive an 80% warning → inspect related transactions.
F. Review a synchronization conflict between desktop and phone → compare versions → choose/merge safely.

MOCK DATA
Use coherent, realistic Brazilian sample data throughout all screens, such as salary, rent, electricity, groceries, streaming subscriptions, pharmacy, transport, emergency fund, Nubank/Inter-style generic institutions without copying their trade dress, and credit purchases with installments. Ensure all dashboard totals, statement totals, budgets, and installment schedules reconcile mathematically across screens.

OUTPUT
1. Start with a compact sitemap and the key user journeys.
2. Define the visual foundations and component system.
3. Create high-fidelity desktop and mobile mockups for all core screens.
4. Show responsive adaptations, not merely scaled copies.
5. Connect the six prototype flows.
6. Add concise annotations for behavior, validation, accessibility, and developer handoff.
7. Provide a final screen inventory and component inventory.

Prioritize the dashboard, transaction flow, credit-card statement, installment flow, and responsive navigation first. The result must be detailed enough for a Flutter developer to implement without guessing interaction rules.
```

---

## Suggested MVP order

1. Authentication, privacy, local database, synchronization, and account management.
2. Income, expenses, transfers, categories, search, and monthly dashboard.
3. Credit cards, installments, statement generation, and statement payments.
4. Budgets, recurring payments, subscriptions, calendar, and notifications.
5. Goals, debts, assets, advanced reports, imports, exports, and backups.
6. Hardening: conflict resolution, reconciliation, accessibility audit, security review, and end-to-end testing.

Features such as automatic bank synchronization, investment market feeds, shared household finances, and financial advice should be deferred until the core ledger, statement logic, privacy model, and synchronization are proven reliable.
