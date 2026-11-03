---
version: 1
slug: "pollar-brand"
primary_target: "apps/pollar_app/lib/shared/presentation/pollar_brand.dart"
related_targets:
  - "apps/pollar_app/lib/shared/presentation/pollar_brand_geometry.dart"
  - "apps/pollar_app/lib/features/auth/presentation/sign_in_screen.dart"
  - "apps/pollar_app/lib/app/routing/app_shell.dart"
  - "apps/pollar_app/tool/brand_geometry.json"
  - "apps/pollar_app/assets/brand/README.md"
---

## Mode and authority

Refine the existing Inter/teal/mint world using the user's approved logo
references: solid colors, identical P geometry across variants, transparent
true-vector exports and a lighter name. The later request centers the desktop
login group. Financial and authentication rules remain unchanged.

## Brand contract

One canonical P contour retains its proportions and diagonal counter.
`tool/brand_geometry.json` drives the generated Dart path, SVGs and Android
vectors; reuse it rather than drawing per-context approximations. Wordmarks
use actual bundled Inter SemiBold glyph outlines (600), and `PollarBrand`
uses Inter at the same weight. The mark/name use solid teal or mint. Symbol
and wordmark SVG/PNG exports have transparent backgrounds; launcher artwork
uses mint on solid dark. Preserve negative space and the documented clear
space; do not inherit texture, gradients, shadows or background rectangles
from reference images. The reference geometry was reconstructed manually.

The sign-in screen and expanded rail use the shared signature; the collapsed
rail uses the shared symbol. Generated platform assets include Android legacy,
adaptive (26+) and monochrome (33+) icons, Windows ICO and web icons. Presence
of web icons does not change the product's supported-platform commitment.

## Entry composition

The safe-area viewport centers the login group on both axes when it fits.
`LayoutBuilder`, a scroll view and viewport minimum height preserve access
when content exceeds the available height. The group is at most 980px wide;
desktop retains introduction beside a 430px form, while compact stacks them.
Auth actions opt into adaptive height for complete labels with enlarged text.
Email-code and authenticator behavior remain the existing flow.

## Evidence and limits

`test/features/auth/presentation/sign_in_screen_test.dart` checks desktop
centering at 1920×1080 and 1280×720, plus compact scrolling with a simulated
keyboard and 2× text. `test/goldens/brand_route_golden_test.dart` captures the
1440px login in both themes and compact keyboard/2× text; representative
artifact: `test/goldens/brand_login_1440_dark.png`. Asset reproduction and font
licensing live in `assets/brand/README.md`. Final validation and package
results belong to `docs/redesign-progress.md`; screenshot/widget evidence
does not claim hardware assistive-technology or performance acceptance.
