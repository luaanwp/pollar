# Welcome — approved kinetic ledger

Target: apps/pollar_app/lib/features/auth/presentation/welcome_screen.dart
Mode: Operate. New surface within the established Pollar identity.

## Confirmed behavior
User chose welcome only when disconnected. Saved sessions retain the existing email renewal, authenticator / Windows Hello, and identity checks. No animation may delay the entry action.

## Surface structures
Candidate structures considered: (1) centered brand stage; (2) financial-day timeline without example balances; (3) fullheight brand field; (4) kinetic ledger converging into the canonical P; (5) abstract workbench; (6) typographic introduction; (7) optional swipe presentation.
The concept seed already returned assignment 4, key 8cc36f0b. The invocation printed its assignment before a Node/libuv shutdown assertion; no reroll.
The three comps explore composition within the assigned kinetic ledger concept, preserving the existing identity.

## Comps
A: .impeccable/mocks/welcome-a-centered.png — centered mark and horizontal bands.
B: .impeccable/mocks/welcome-b-ledger.png — asymmetric flowing ledger, recommended for mobile and desktop adaptation.
C: .impeccable/mocks/welcome-c-split.png — solid mint upper field and dark action region.
User explicitly approved B on 2026-11-05. Approved comp: .impeccable/mocks/welcome-b-ledger.png. Its prompt sidecar records approved:true. A and C remain unapproved.

## Fidelity inventory
| Ingredient | Implementation commitment |
| --- | --- |
| Header | Existing PollarBrand, bundled Inter SemiBold, canonical vector P |
| Ledger stage | Three flat, progressively drawn paths arriving at the left edge of the canonical P; upper mobile stage, right desktop stage; no container |
| Dominant mark | Existing 603:668 vector path; no generated logo geometry |
| Headline | Semantic Inter Bold, 36px stacked / 32px below 360px viewport / 54px expanded, line height 1.16 and tracking -0.7px, with adaptive wrapping |
| Body | Semantic Inter 16px; readable secondary text |
| Primary action | Native full-width semantic button, label left / Lucide arrow right, existing 10px radius, 56px minimum, keyboard focus |
| Footer | Native readable wrapping text; no raster text |
| Theme / material | Existing light/dark solid tokens, no gradients, shadows or blur |
| Motion | One finite 800ms ledger convergence, no entry delay; reduced motion immediately settled |

Independent asset-producer review confirmed an empty raster-production manifest. No new image assets are required. The approved comp is a composition reference, never a runtime UI image.

## Quality bar
The asymmetrical ledger/P stage and clear entry action must survive both phone and desktop. No overlap or overflow at 320px/200% text; scroll when short. Saved-session gates and account identity isolation remain enforced. Entry is usable on frame zero and motion stops after its entrance.

## Implementation boundaries
Native semantic Flutter typography/actions, existing canonical vector P, finite geometric animation, visible action from frame zero, reduced-motion support, responsive layout and large text. No invented balances, remote data, Open Finance functionality or new typography/palette. Generated gradients, logo inaccuracies or tiny footer type are defects to correct using production identity assets and accessible type. Light theme inherits the existing light palette.

## Built surface — 2026-11-11

The implementation retains the opening contract's five sections (THESIS, OWN-WORLD, STORY, FIRST VIEWPORT and FORM) plus FINISH, structure 4 and seed `8cc36f0b`. The November 5 approval of B remains the visual authority; this record documents the build rather than a new identity decision.

### Responsive geometry

- All dimensions are Flutter logical pixels. A `SafeArea` contains a vertically scrollable composition with minimum height equal to the available viewport and maximum content width 1280. The brand has a 32px top inset.
- Expanded layout requires local width at least 1024 and `textScaler.scale(16) <= 24`. Equal expanded columns place copy left and artwork right, separated by 48px. Copy starts 48px from the content edge; the row starts 48px below the brand and has 64px bottom padding. The ledger stage is 65% of available height, clamped to 420–600px.
- Otherwise, brand, ledger and copy stack in that order. The ledger stage is full width and 38% of available height, clamped to 220–400px. Copy has 24px side gutters and 32px bottom padding. Its title is 36px, or 32px with viewport width below 360; the expanded title is 54px. Text scales and wraps without a fixed copy height; short windows scroll.
- Headline → body → action → footer gaps are 20/40/32px. Body is Inter 16px; footer is Inter 14px. The action fills the copy column with a 56px minimum height, 16px padding, 10px radius, 16px/600 label, 16px gap and decorative 24px arrow. Native focus/activation remain available from frame zero.

### Vector and motion inventory

The runtime artwork is the existing canonical 603:668 P path plus three native ledger paths, inside an isolated decorative `CustomPaint`/`RepaintBoundary`. The P height is the smaller of 60% of stage height and 44% of stage width; its right inset is 5% of stage width, and it is vertically centered. Path levels are 10/45/83% of mark height, stroke width is 9% and the outer bends are 14% of mark height. The paths stop at the mark's left edge, preserving its outline and counter. Paint uses solid theme `primary`, primary at 65% opacity and `primarySoft`.

Only path length animates, once over 800ms. Each path uses `easeOutCubic` with progress `clamp((t - index * .12) / .76, 0, 1)`; the P is fully present throughout. `PollarMotion.reduced` immediately sets the controller to its settled state for disabled animations, accessible navigation or disabled ticker mode. The entry action has no animation dependency.

Independent media review returned an empty raster-production manifest: no new production image asset is required. The approved PNG remains reference material. Header branding, headline, body, footer and the native button remain independent semantic content; the decorative ledger and arrow are excluded from semantics.

### Route and authentication rules

With configured authentication, a missing session redirects protected destinations to `/welcome`, while `/welcome` and `/sign-in` remain reachable. “Entrar no Pollar” pushes `/sign-in`, so returning from the form can reveal welcome. A saved session bypasses welcome and retains the existing recent-email-code requirement, second-factor verification, local unlock/Windows Hello and account-identity binding before `/overview`; mismatches retain `/account-mismatch`. The asynchronous identity check rechecks the current session and gates before completing the redirect. Unconfigured authentication retains its existing local-mode behavior without an automatic welcome redirect. “Disconnected” means no saved session, not network unavailability.

### Finish review and verification boundary

The fresh finish review returned **ship**, with no material findings and all five opening-contract promises passing. The empty media manifest and built geometry above were checked against the implementation. The quality bar still includes phone/desktop hierarchy, narrow 320px layout, 200% text, short-window scroll, first-frame entry, finite motion, reduced-motion settlement and saved-session isolation. After review, local verification on 2026-11-11 completed 600 general Flutter tests and all three isolated native Windows update-process tests; static analysis reported no issues. The native Windows release executable compiled successfully with remote configuration and product version `1.0.0+1015`. This record does not claim physical Windows/Android device acceptance, physical assistive-technology testing or publication.

