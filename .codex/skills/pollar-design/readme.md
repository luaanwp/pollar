# Pollar Design System

Implementation-ready design language for a **personal-finance product** (Flutter desktop + mobile), reconstructed as a web design system: CSS tokens, React primitives and two full UI-kit recreations.

Pollar is the official product name. Brand personality: private, composed, dependable, intelligent, precise, contemporary. Product principles: calm clarity, financial precision, trust through restraint, progressive disclosure, accessible by default, cross-platform familiarity. Default locale **pt-BR** (BRL), and all product copy in this system is written in Portuguese.

## Sources

Everything here derives from two files the user supplied — there was **no codebase, no Figma file, no screenshots and no decks**:

- `uploads/pollar_design_system.md` — canonical human-readable specification (15 sections: principles, color, type, layout, shape, icons, motion, components, financial display rules, page patterns, accessibility, Flutter mapping).
- `uploads/pollar_design_tokens.json` — machine-readable token source (`$schema: design-tokens.github.io`, v1.0.0, baseUnit 4, defaultLocale pt-BR).

Where the two disagree, the spec's prose wins and the difference is noted. No values were invented, rounded or snapped to a grid.

### Substitutions and gaps (please confirm)
- **Fonts.** The spec names **Inter** with fallbacks `SF Pro Text, Segoe UI, Roboto`. No font binaries were supplied, so `tokens/fonts.css` loads Inter from Google Fonts, plus JetBrains Mono for token/code specimens only (never product UI). Send licensed `.woff2` files and this becomes self-hosted `@font-face`.
- **Icons.** The spec asks for "a single rounded-outline icon family; Lucide-style geometry". No icon assets were supplied, so the `Icon` component pulls **Lucide** (`lucide-static@0.462.0`) from unpkg and tints it with `currentColor` via a CSS mask. Substitution flagged — swap the CDN base for a local sprite when you have one.
- **No logo.** The sources contain no logo or brand mark, so none was drawn. Wherever a mark belongs, the wordmark "Pollar" is set in plain Inter 650; the small rounded square in `Sidebar`/thumbnail is an explicit placeholder for the "abstract ledger/flow mark" the spec calls for, not a logo. See `guidelines/brand-wordmark.card.html`.
- **No imagery.** No photography, illustration or background art exists in the sources. The spec restricts illustration to onboarding and significant empty states, so `assets/` holds no imagery and screens use none.
- **Reports screen.** The desktop kit leaves `Relatórios` intentionally blank — the spec defines no reports layout.

## Content fundamentals

Product copy is **Portuguese (pt-BR)**, calm, plain and specific. The register is that of a careful bank statement, not a coach.

- **Person.** Address the user as *você*, sparingly; most UI text is impersonal and label-like (*Saldo total*, *Compras da fatura*, *Limite utilizado*). The product never speaks as "eu/nós".
- **Casing.** Sentence case everywhere — labels, buttons, headings, badges (*Nova transação*, *Pagar fatura*, *Parcialmente paga*). No Title Case, no ALL CAPS except the 11px uppercase eyebrow used for table headers and sidebar section dividers (`letter-spacing: .06em`).
- **Punctuation.** No exclamation marks. Full stops in sentences and banner bodies; none on labels, buttons or badges. Middle dot `·` separates metadata (*Alimentação · Cartão Ouro*). True minus `−` for negative amounts, en dash for ranges (*1–30 set 2026*).
- **Buttons** are verb-first and name the object: *Pagar fatura*, *Excluir cartão*, *Revisar conflitos*, *Tentar novamente* — never *OK*, *Sim*, *Enviar*.
- **Errors** say what happened and how to fix it: "Informe um e-mail válido, como nome@dominio.com". Not "Campo inválido".
- **Destructive confirmations** name the object and explain the impact: "Excluir o cartão Ouro? As 47 transações vinculadas continuarão no histórico, mas a fatura em aberto de R$ 4.123,90 deixará de ser acompanhada."
- **Status vocabulary is fixed** (pt-BR): statements — *Aberta, Fechada, Parcialmente paga, Paga, Vencida*; sync — *Offline, Sincronizando, Conflito*; transactions — *Previsto, Pendente, Compensado, Conciliado*. Do not paraphrase these.
- **Numbers are never softened.** No "cerca de", no rounding in totals, no abbreviating to "1,8 mil". Charts may abbreviate axis ticks but the value table stays exact.
- **No emoji, no gamification, no praise.** "Transação salva." — not "Boa! Transação salva 🎉". No streaks, badges of achievement, or motivational nudges.
- **Empty and offline states describe state plus next step**, e.g. "As alterações ficam salvas neste dispositivo e serão sincronizadas quando a conexão voltar."

## Visual foundations

**Palette.** One brand hue: a deep desaturated teal (`#087F6B`) with a pale mint tint (`#EAF8F4`) for selection. Neutrals are green-leaning greys (`#F7F9F8 → #13201D`), so the whole UI reads slightly cool and clinical. Four semantic colors only — positive `#16834F`, negative `#C53B3B`, warning `#A86508`, info `#2667C9` — each with a derived soft fill for badges/banners. Dark theme flips to a lighter teal (`#5ED3B8`) on near-black greens. Max two background values on any screen: `--surface-background` behind, `--surface-canvas` for cards.

**Type.** Inter throughout, no second product face. Tight weights rather than sizes carry hierarchy (650/700 for display and amounts, 600 for labels, 400 body). Display and H1 get slight negative tracking (−0.015 to −0.02em); body gets none. **Tabular numerals on every figure** (`.fin-tnum`) so columns align — non-negotiable for money, dates in tables, percentages and installment counts.

**Spacing & layout.** Base 4, rhythm 8; scale 0–80. 24px page gutters on desktop, 32 wide, 16 mobile. 12/8/4-column grid with 16/24px gutters. Content caps: 1600 overall, 1280 for dashboard reading columns, 360px contextual panel, 256/72px sidebar. Fixed elements: sidebar, 60px top bar, mobile bottom nav (64px) and its 56px floating quick-add — everything else scrolls.

**Backgrounds.** Flat surfaces only. **No gradients, no glassmorphism, no textures, no patterns, no full-bleed imagery, no hand-drawn illustration.** The spec explicitly rules out noisy gradients and glass; the only "decoration" is a 1px border and a tint change.

**Cards.** `--surface-canvas` fill, 1px `--border`, 14px radius, 20px padding, **no shadow at rest**. Interactive cards gain `--elevation-1` and `--border-strong` on hover. Never nested.

**Borders & shadows.** 1px borders do the structural work. Shadows are reserved for layers that genuinely float: elevation 1 hover, 2 menus/popovers/toasts, 3 dialogs/sheets — all low-alpha near-black-green, no colored shadows, no inner shadows anywhere.

**Radii.** 6 chips, 10 inputs/buttons/tables, 14 cards/dialogs, 999 **badges only**. A pill-shaped button would be off-brand.

**Transparency & blur.** Blur is never used. Transparency appears in exactly three places: the modal scrim (`rgba(19,32,29,.36)`), chart area fills (10% of the line color), and shadow alphas. No protection gradients — overlaid text always sits on an opaque capsule or surface instead.

**Animation.** 100ms fast feedback, 180ms standard state change, 240ms panels/dialogs/sheets. Emphasized decelerate on entry, accelerate on exit, standard ease for state changes. Movement is small: 6–16px translate, no bounce, no spring, no scale-up entrances beyond 0.985→1 on dialogs. Financial values never animate their digits. `prefers-reduced-motion` zeroes every duration via the token file.

**Hover / press / focus / disabled.** Hover: primary → `--primary-700`; secondary/ghost → `--surface-alt` fill with text darkening to `--text-primary`; rows and list items → `--surface-alt`. Press: same fill plus a 0.5px downward nudge — no shrink, no ripple. Focus: 2px `--info` outline at 2px offset, always visible. Selected: `--primary-soft` surface **plus** `--primary` text/icon, never color alone. Disabled: 50–60% opacity, cursor not-allowed. Weight is never used to signal an interactive state.

**Imagery vibe.** None shipped. If imagery is ever added, the spec's direction is abstract and calm — cool, low-saturation, no grain, no faces, used only for onboarding and significant empty states.

## Iconography

- **Family:** Lucide, rounded-outline, ~2px stroke — one family, no mixing. Delivered from `https://unpkg.com/lucide-static@0.462.0/icons/<name>.svg` and tinted with `currentColor` through a CSS mask by the `Icon` component. **Flagged substitution:** the sources shipped no icon assets; Lucide is the spec's own stated reference geometry.
- **Sizes:** 16 (dense rows, compact buttons), 20 (default, desktop nav, inline field icons), 24 (mobile bottom nav, section leads). No other sizes.
- **Color:** inherits text color; semantic tints only where the icon is the status cue.
- **Every unlabeled icon control carries a tooltip and an accessible name** — `IconButton` requires `label`.
- **Status is icon + text, never color alone**: `check` Paga · `clock` Previsto/Parcialmente paga · `circle-alert` Vencida · `triangle-alert` Conflito · `refresh-cw` Sincronizando · `wifi-off` Offline · `link` Conciliado.
- **Money semantics:** `arrow-up-right` income, `arrow-down-left` expense, `arrow-left-right` transfer, `credit-card` card payment.
- **No emoji as product icons. No unicode glyphs as icons** — the only non-Lucide marks in the UI are the bullet `•` in privacy masks, the middle dot `·` in metadata, and `⌘K`/`⌘P` in shortcut hints.
- **No icon font, no sprite sheet** in the sources; `assets/` is therefore empty of icon binaries.

## Index

Root:
- `styles.css` — the single entry point consumers link; `@import` list only.
- `tokens/` — `fonts.css`, `colors.css`, `typography.css`, `spacing.css`, `shape.css`, `elevation.css`, `motion.css`, `layout.css`, `base.css`.
- `guidelines/` — 19 specimen cards (Colors, Type, Spacing, Brand) including financial formatting, interaction states, motion and iconography.
- `thumbnail.html` — homepage tile. `SKILL.md` — Agent Skills wrapper.
- `assets/` — intentionally empty: no logo, icon or image binaries existed in the sources.

### Components (28 exports across 6 groups)

`components/core/` — **Icon**, **Button**, **IconButton**
`components/forms/` — **Input**, **CurrencyInput**, **Select**, **Checkbox**, **Switch**
`components/data/` — **MoneyText**, **PrivacyAmount**, **StatusBadge**, **TransactionTile**, **DataTable** (+ `money.js` formatters: `formatMoney`, `maskMoney`, `formatDateShort`, `formatInstallment`)
`components/surfaces/` — **Card**, **MetricCard**, **StatementSummary**, **BudgetProgress**
`components/charts/` — **TrendChart**, **ComparisonBars**, **CategoryDonut**, **ProgressMeter**
`components/feedback/` — **Banner**, **Toast**, **Dialog**, **BottomSheet**

Each directory has a `*.card.html` specimen; each component has a `.d.ts` props contract and a `.prompt.md` usage note.

**Mapping to the spec's Flutter widget list.** `MoneyText`, `PrivacyAmount`, `StatusBadge`, `TransactionTile`, `StatementSummary`, `BudgetProgress` map 1:1. `SyncBanner` is generalised as **Banner** (offline / sync error / conflict / info tones). `ResponsiveScaffold` is not a component here — its behavior lives in the two UI kits' shells, since breakpoint switching is a page concern in HTML.

**Intentional additions** (not enumerated in the source, added because the spec's own behaviors require them): `Icon` — a wrapper for the required single icon family; `Select` — the filter and column pickers in §9 Tables; `Checkbox` — row selection in §9 Tables; `Switch` — privacy mode and reduced-motion settings in §10/§12; `DataTable` — the desktop table described in §9; `MetricCard` — the dashboard card anatomy in §9 Cards; `Toast`/`Dialog`/`BottomSheet` — §9 Dialogs and sheets, Toasts and banners; the four chart components — §9 Charts.

### UI kits
- `ui_kits/desktop/` — 1440-wide app: Visão geral, Transações (table + 360px detail panel), Cartão Ouro (statement), Orçamentos, Preferências. Click-through with privacy mode (⌘P), quick add (⌘J), offline banner, sortable/selectable rows, dialogs, undo toast, dark theme.
- `ui_kits/mobile/` — 430-wide compact app: Início, Transações (day-grouped list + filter chips), Cartão, Orçamentos, detail page, Mais. Bottom nav with quick-add sheet, currency input with installment preview, payment sheet, dark theme.

## Accessibility rules that are part of the design, not an afterthought
WCAG AA in both themes; visible 2px focus rings; keyboard operation and logical focus order; status conveyed by icon + text + color; screen-reader amount labels include polarity and currency (`MoneyText` emits *entrada/saída*); charts ship a value table or caption; 44×44 minimum mobile targets; text scaling to 200%; destructive actions kept away from primary ones; reduced motion honoured.
