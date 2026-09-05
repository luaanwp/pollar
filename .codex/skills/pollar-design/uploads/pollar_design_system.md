# Pollar Design System

Implementation-ready design language for Flutter desktop and mobile applications. This file is the canonical human-readable specification. Machine-readable values live in `pollar_design_tokens.json`.

## 1. Product principles

1. **Calm clarity:** Reduce anxiety. Show the next useful action without flooding the screen.
2. **Financial precision:** Money, dates, statements, and installment status must be unambiguous.
3. **Trust through restraint:** Avoid playful gamification, noisy gradients, glassmorphism, and ornamental charts.
4. **Progressive disclosure:** Show summaries first and details on demand.
5. **Accessible by default:** WCAG AA contrast, keyboard navigation, semantic labels, scalable text, and non-color status cues.
6. **Cross-platform familiarity:** Share the visual language while respecting desktop density and mobile ergonomics.

## 2. Brand personality

Keywords: private, composed, dependable, intelligent, precise, contemporary.

Product name: **Pollar**. Use an abstract ledger/flow mark rather than currency symbols so the identity works internationally.

## 3. Color system

### Light theme

| Role | Token | Value | Use |
|---|---|---:|---|
| Primary | `color.primary.600` | `#087F6B` | Primary actions, selected navigation |
| Primary hover | `color.primary.700` | `#066858` | Hover and pressed emphasis |
| Primary soft | `color.primary.50` | `#EAF8F4` | Selected surfaces, gentle highlights |
| Canvas | `color.neutral.0` | `#FFFFFF` | Main content surface |
| App background | `color.neutral.25` | `#F7F9F8` | Page background |
| Surface alt | `color.neutral.50` | `#F1F4F3` | Secondary panels and controls |
| Border | `color.neutral.200` | `#D8DEDC` | Standard boundaries |
| Border strong | `color.neutral.300` | `#B9C3C0` | Active or emphasized boundaries |
| Text primary | `color.neutral.950` | `#13201D` | Main text and amounts |
| Text secondary | `color.neutral.650` | `#52615D` | Supporting text |
| Text muted | `color.neutral.500` | `#74827E` | Metadata and placeholders |
| Positive | `color.success.600` | `#16834F` | Income, success, positive movement |
| Negative | `color.danger.600` | `#C53B3B` | Expenses, destructive actions, overdue |
| Warning | `color.warning.600` | `#A86508` | Attention and nearing limits |
| Information | `color.info.600` | `#2667C9` | Informational status and links |

### Dark theme

| Role | Value |
|---|---:|
| Primary | `#5ED3B8` |
| Primary hover | `#80DEC9` |
| Primary soft | `#153B34` |
| Canvas | `#121A18` |
| App background | `#0C1211` |
| Surface alt | `#1A2522` |
| Border | `#2D3B37` |
| Border strong | `#40514C` |
| Text primary | `#EEF4F2` |
| Text secondary | `#B5C3BF` |
| Text muted | `#8B9B96` |
| Positive | `#55CF91` |
| Negative | `#FF8585` |
| Warning | `#F3B85D` |
| Information | `#80AEFF` |

### Color rules

- Never communicate status by color alone. Pair it with an icon and text.
- Expenses may be red in summaries, but normal transaction rows should favor neutral text plus a minus sign to avoid visual alarm fatigue.
- Income uses a plus sign and positive semantic color.
- Transfers use the information color and a bidirectional arrow.
- Card payments use a neutral or informational style; never present them as a second expense.
- Charts use the categorical palette in the token file and must also expose labels, legends, values, and a table/text alternative.

## 4. Typography

Primary family: **Inter**. Fallbacks: `SF Pro Text`, `Segoe UI`, `Roboto`, sans-serif.

Use tabular numerals for amounts, percentages, dates in tables, and installment counts.

| Style | Desktop | Mobile | Weight | Line height |
|---|---:|---:|---:|---:|
| Display | 32 | 28 | 650/700 | 1.20 |
| H1 | 26 | 24 | 650/700 | 1.25 |
| H2 | 22 | 20 | 650 | 1.30 |
| H3 | 18 | 18 | 600 | 1.35 |
| Body large | 16 | 16 | 400 | 1.50 |
| Body | 14 | 14 | 400 | 1.50 |
| Label | 13 | 13 | 550/600 | 1.35 |
| Caption | 12 | 12 | 400/500 | 1.40 |
| Amount hero | 34 | 30 | 650 | 1.15 |
| Amount standard | 16 | 16 | 600 | 1.30 |

Do not use font weight alone to distinguish interactive states. Never shrink financial content below 12 px logical size.

## 5. Layout and spacing

Base unit: 4. Primary rhythm: 8.

Spacing scale: `0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80`.

Responsive breakpoints:

| Name | Range | Navigation | Content behavior |
|---|---|---|---|
| Compact | `< 600` | Bottom navigation | One column, bottom sheets |
| Medium | `600–1023` | Navigation rail | One or two columns |
| Expanded | `1024–1439` | Collapsible sidebar | Multi-column workspace |
| Wide | `≥ 1440` | Expanded sidebar | Max-width content + detail panel |

Desktop content maximum width: 1600. Dashboard reading columns should generally remain within 1280. Use 24 px page gutters on standard desktop, 32 px on wide screens, and 16 px on mobile.

Grid: desktop 12 columns, tablet 8, mobile 4; 16 px gutters compact and 24 px gutters medium/expanded.

## 6. Shape, borders, and elevation

- Radius small: 6 (chips, compact controls).
- Radius medium: 10 (inputs, buttons, table containers).
- Radius large: 14 (dashboard cards, dialogs).
- Radius pill: 999 (status badges only).
- Standard border: 1 px.
- Focus ring: 2 px information/primary color with 2 px outer offset.
- Use shadows sparingly. Prefer border and surface contrast.
- Elevation 1: floating toolbar/card hover. Elevation 2: menu/popover. Elevation 3: dialog/bottom sheet.

## 7. Icons and imagery

- Use a single rounded-outline icon family; Lucide-style geometry is suitable.
- Standard sizes: 16, 20, 24. Navigation icons: 20 desktop, 24 mobile.
- Always add semantic tooltips to unlabeled desktop icons.
- Do not use emoji as product icons.
- Use illustrations only for onboarding or significant empty states; keep them abstract and calm.

## 8. Motion

- Fast feedback: 100 ms.
- Standard transition: 180 ms.
- Panel/dialog transition: 240 ms.
- Curves: emphasized decelerate for entry, accelerate for exit, standard ease for state changes.
- Respect reduced-motion preferences. Never animate financial values in a way that delays comprehension.

## 9. Core components

### Buttons

Variants: primary, secondary, tertiary/ghost, danger, icon-only. Heights: 32 compact desktop, 40 standard, 48 mobile prominent. Minimum mobile touch target is 44×44 even if the visual control is smaller.

Primary is reserved for the single main action in a region. Destructive actions require explicit labels; do not use an unlabeled trash icon as the final confirmation.

### Inputs

States: default, hover, focus, filled, disabled, read-only, error, success. Labels remain visible above the input; placeholders are examples, never replacements for labels. Errors state what happened and how to fix it.

Currency input behavior:

- Show locale-aware currency prefix/suffix.
- Keep an integer minor-unit model beneath formatting.
- Support keyboard entry and paste safely.
- Right-align amounts in dense desktop forms; keep labels left aligned.
- Provide a textual preview for installment calculations.

### Cards

Use cards only to group related information, not for every piece of content. Dashboard cards have a title, optional helper/action, primary metric, supporting comparison, and optionally a compact visualization. Avoid nested cards.

### Tables and lists

Desktop tables support sorting, filtering, column selection, row selection, keyboard navigation, sticky headers, and a contextual detail panel. Amounts are right-aligned. Dates, status, and identifiers remain scannable.

Mobile converts table rows into structured list items; do not add horizontal scrolling for primary transaction experiences.

Transaction row anatomy: icon/category, payee/title, category/account metadata, date/status, amount, and optional installment label. Preserve a consistent alignment column for amounts.

### Status badges

Variants: neutral, info, success, warning, danger. Every badge includes a text label and may include a leading icon. Examples: Open, Closed, Partially paid, Paid, Overdue, Offline, Syncing, Conflict.

### Navigation

Desktop sidebar widths: 256 expanded, 72 collapsed. Mobile bottom navigation shows no more than five destinations. The quick-add action may be visually prominent but must not obscure navigation.

### Dialogs and sheets

Use dialogs for focused desktop decisions and bottom sheets/full-screen flows on mobile. Destructive confirmation must name the object and explain impact. Prefer undo for reversible operations.

### Toasts and banners

Toasts confirm low-risk success. Inline banners communicate offline state, sync errors, conflicts, or information that remains relevant. Never place critical recovery instructions only in a disappearing toast.

### Charts

- Line/area: cash flow or balance over time.
- Bars: income vs. expenses, budget vs. actual.
- Donut: category composition only when there are few categories; otherwise use sorted bars.
- Progress bar: card utilization, budget, goal.
- Always include exact values, accessible labels, legend toggle where relevant, and a text/table alternative.
- Zero baselines are mandatory for bar charts.

## 10. Financial display rules

- Brazilian example: `R$ 1.234,56`; negative: `−R$ 123,45`; positive where comparison matters: `+R$ 123,45`.
- Privacy hidden: `R$ ••••••` while preserving approximate layout width.
- Installment: `3 de 12` in prose; `3/12` in compact rows.
- Credit available: pair amount with utilization percentage.
- Dates in pt-BR: `1 set 2026` in compact UI; full form for critical due dates.
- Never show a statement payment as an expense if purchases were already recorded as expenses.
- Use “Previsto”, “Pendente”, “Compensado” and “Conciliado” as distinct transaction states in pt-BR.

## 11. Page patterns

### Desktop shell

Left sidebar + top utility bar + main workspace + optional 360 px contextual panel. Primary page action lives in the header. Filters sit below the title or in a collapsible toolbar. Preserve keyboard shortcuts for quick add, global search, and privacy mode.

### Mobile shell

Top app bar + scrollable content + bottom navigation + quick-add action. Details use a full page or bottom sheet depending on complexity. Financial forms with multiple steps should show progress and preserve drafts.

### Dashboard hierarchy

1. Total balance/net worth and monthly result.
2. Cash-flow trend and open card statements.
3. Budgets, upcoming bills, and credit utilization.
4. Recent transactions and secondary insights.

### Credit-card statement hierarchy

1. Card identity, statement period, status.
2. Total, amount paid, outstanding, due date.
3. Pay/partial-payment actions.
4. Purchases grouped by date.
5. Future installments and statement history.

## 12. Accessibility checklist

- WCAG AA contrast in both themes.
- Complete keyboard operation and logical focus order.
- Visible focus rings.
- Semantic headings and landmark regions.
- Screen-reader labels for amounts include polarity and currency.
- Charts have non-visual alternatives.
- Dynamic updates announce sync success/failure without stealing focus.
- Minimum 44×44 mobile target; adequate spacing between destructive and primary actions.
- Support text scaling to at least 200% without clipping essential controls.
- Respect reduced motion and high contrast preferences where the platform exposes them.

## 13. Flutter mapping

- Map primitives into `ColorScheme`, `TextTheme`, and custom immutable `ThemeExtension` classes.
- Suggested extensions: `PollarSemanticColors`, `PollarSpacing`, `PollarRadii`, `PollarElevation`, `PollarChartColors`, and `PollarComponentSizes`.
- Components consume semantic tokens, never raw hexadecimal values.
- Keep light/dark values in one theme module and test both with golden tests.
- Use adaptive composition, not platform checks scattered through widgets. Centralize breakpoints and layout decisions.
- Use tabular numeral font features for `MoneyText`.
- Create reusable `MoneyText`, `StatusBadge`, `TransactionTile`, `StatementSummary`, `BudgetProgress`, `SyncBanner`, `PrivacyAmount`, and `ResponsiveScaffold` widgets.

## 14. Claude Code implementation prompt

```text
You are implementing the Pollar Flutter design system. Treat pollar_design_system.md as the canonical behavioral and visual specification and pollar_design_tokens.json as the canonical machine-readable token source.

First inspect the existing Flutter project and preserve its architecture and working behavior. Then:

1. Create typed, immutable theme tokens mapped into Flutter ColorScheme, TextTheme, and ThemeExtension classes.
2. Implement light and dark themes without hard-coded colors or spacing inside feature widgets.
3. Create the reusable primitives and components specified in the design-system document, starting with ResponsiveScaffold, MoneyText, PrivacyAmount, StatusBadge, TransactionTile, StatementSummary, BudgetProgress, SyncBanner, buttons, inputs, and dialogs/sheets.
4. Implement compact, medium, expanded, and wide responsive behavior centrally.
5. Add a design-system catalog/gallery route showing all tokens, components, variants, financial formatting, responsive states, loading/empty/error/offline/sync/conflict states, and accessibility behavior.
6. Add widget tests, semantics tests, theme tests, responsive tests, and golden tests for light and dark themes at 390×844 and 1440×900.
7. Validate keyboard navigation, focus order, text scaling to 200%, WCAG AA contrast, and reduced motion.
8. Never use float/double for financial values. UI formatting must consume the project's integer-minor-unit Money value object.

Work incrementally. Before editing, report the files and architecture you found and propose the smallest safe implementation sequence. After each slice, run formatting, static analysis, and tests. Do not replace working domain logic, synchronization, or data access merely to implement styling. If the two design-system files conflict, stop and identify the conflict rather than silently inventing a third rule.
```

## 15. Definition of done

- Every feature uses semantic tokens rather than raw visual constants.
- Light and dark themes cover all interactive and financial states.
- Desktop and mobile layouts are intentionally composed.
- Core components have loading, disabled, error, offline, and privacy variants where relevant.
- Component catalog is runnable.
- Golden and semantics tests cover critical components.
- Amounts remain exact and correctly localized.
- No duplicate accounting semantics are introduced through visual presentation.

