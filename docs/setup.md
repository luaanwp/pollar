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
- ⚠️ Windows desktop build: Visual Studio Build Tools are present but the **C++
  (Desktop development with C++) workload and ATL headers are incomplete**
  (`atlstr.h` is absent). Completing them needs the Visual Studio Installer and
  administrator rights.
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
supabase start   # prints API URL + publishable key
supabase stop
```

Run the client with compile-time values (a remote project still requires explicit
authorization):

```bash
flutter run \
  --dart-define=SUPABASE_URL=http://127.0.0.1:54321 \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-local-publishable-key
```

Without both values the app intentionally starts in local-only mode. Never put
the `service_role` key in a client command or file.

The configured sign-in is passwordless: the local Auth email template sends a
six-digit OTP, followed by TOTP enrollment/verification in an authenticator
app. Local messages appear in Mailpit at `http://127.0.0.1:54324`. The app
requires a new email OTP after ten days and a TOTP code on a fresh launch; a
previously verified device may alternatively unlock with OS biometrics/PIN
(Windows Hello on Windows), including offline. A new device must enroll TOTP
online. Native OS unlock was not yet exercised on physical devices.

For a remote Supabase project, apply both new migrations, enable TOTP enroll
and verify, set the Magic Link and confirmation email templates to show
`{{ .Token }}`, configure production SMTP, and supply only the project URL and
publishable key to the app. Do not reuse local keys or send `service_role` to a
client. The project must be explicitly selected/authorized before linking it.

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
