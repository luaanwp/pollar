# Pollar — Development Setup

## Toolchain (provisioned, isolated — no global installs)

| Tool | Version | Location |
|---|---|---|
| Flutter (stable) | 3.47.2 | `C:\Users\luanl\orca\tools\pollar\flutter` |
| Dart (bundled) | 3.13.2 | via Flutter |
| Supabase CLI | 2.116.0 | `C:\Users\luanl\orca\tools\pollar\supabase` (SHA-256 verified) |

These are not on the global PATH. Prepend them per shell:

```bash
export PATH="/c/Users/luanl/orca/tools/pollar/flutter/bin:$PATH"
export PATH="/c/Users/luanl/orca/tools/pollar/supabase:$PATH"
```

## Current toolchain status (`flutter doctor`)

- ✅ Flutter, Dart, web — operational.
- ✅ `flutter test`, `flutter analyze`, `dart format` — operational.
- ⚠️ Windows desktop build: Visual Studio Build Tools present but the **C++
  (Desktop development with C++) workload is incomplete**. Completing it needs
  the Visual Studio Installer and administrator rights.
- ⚠️ Windows plugin build additionally needs **Developer Mode** enabled
  (symlink support) — `start ms-settings:developers`.
- ⚠️ Android: SDK not installed yet.

Until the native toolchains are complete, work runs through unit/widget tests,
static analysis, and (optionally) the web target. No native build is required
for the domain and data layers.

## Common commands

```bash
cd apps/pollar_app
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Code generation (Drift / Freezed / json_serializable), once generated files exist:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Accounts are persisted in `pollar.sqlite` under the platform application-support
directory. Native persistence is currently composed for Windows, Android and
iOS; browser storage remains outside the V1 target.

## Supabase (local only)

A remote Supabase project must NOT be created or connected without explicit
authorization. Local development uses Docker:

```bash
supabase start   # prints API URL + anon key for .env
supabase stop
```

Copy `apps/pollar_app/.env.example` to `.env` and fill values. Never commit `.env`.

## Repository layout

```
apps/pollar_app/        Flutter application (Windows, Android, iOS)
  lib/app/              Composition root, routing, theme, global UI state
  lib/core/money/       Money + Currency value objects (integer minor units)
  lib/core/ledger/      Centralized balance invariants (status/type rules)
  lib/shared/           Reusable UI and cross-feature adapters
  lib/features/         Independent product capabilities
docs/                   Architecture, setup, domain, sync, security notes
supabase/               SQL migrations, RLS policies, tests (added in sync slice)
.codex/skills/pollar-design/   Design-system reference (visual/behavioral only)
```

Dependency rules and the path for evolving features are documented in
[`docs/architecture.md`](architecture.md) and enforced by architecture tests.
