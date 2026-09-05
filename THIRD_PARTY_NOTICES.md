# Third-Party Notices

Pollar bundles and depends on third-party software. Their licenses are reproduced
or referenced below. This file must be kept up to date as dependencies change.

## Fonts

### Inter
- Author: The Inter Project Authors (https://github.com/rsms/inter)
- License: SIL Open Font License 1.1 (OFL-1.1)
- Redistribution: permitted, including bundling inside applications.
- Bundled weights (optical size 18pt): Regular 400, Medium 500, SemiBold 600, Bold 700.
- Location in repo: `apps/pollar_app/assets/fonts/inter/` (full license in `OFL.txt`).

## Icons

### Lucide (via `lucide_icons_flutter`)
- Icon set: Lucide (https://lucide.dev) — a fork of Feather Icons.
- Icon license: ISC License.
- Feather (original) license: MIT License.
- Delivered as a pinned Flutter package dependency (`lucide_icons_flutter: ^3.0.0`);
  no runtime CDN is used.

## Flutter package dependencies

The following direct dependencies are used under their respective open-source
licenses (predominantly BSD-3-Clause / MIT). Full texts are available via
`flutter pub deps` and each package page on pub.dev.

| Package | Purpose | License |
|---|---|---|
| flutter_riverpod | State management / DI | MIT |
| go_router | Navigation | BSD-3-Clause |
| drift, sqlite3_flutter_libs | Local SQLite database | MIT / BSD-3-Clause |
| path_provider | Filesystem paths | BSD-3-Clause |
| freezed_annotation, json_annotation | Immutable models / serialization | BSD-3-Clause / MIT |
| uuid | Client-generated UUIDs | MIT |
| flutter_secure_storage | Secure token storage | BSD-3-Clause |
| intl | Localization / formatting | BSD-3-Clause |
| meta | Annotations | BSD-3-Clause |

Dev-only tooling (build_runner, drift_dev, freezed, json_serializable, mocktail,
flutter_lints) is not shipped in the application binary.
