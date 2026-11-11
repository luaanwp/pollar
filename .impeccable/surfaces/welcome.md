# Welcome — approved kinetic ledger

Target: apps/pollar_app/lib/features/auth/presentation/welcome_screen.dart
Related: app/routing/app_router.dart and auth/presentation/sign_in_screen.dart
Mode: Operate. Public app entry within the established Pollar identity.

## Current user decision
Composition B was approved on 2026-11-05: .impeccable/mocks/welcome-b-ledger.png,
with approved:true sidecar. The user amended its behavior on 2026-11-11:
welcome also for saved sessions awaiting biometrics, with Entrar and Cadastrar.
This supersedes the disconnected-only choice without replacing composition B.

## Fidelity inventory
| Ingredient | Production commitment |
| --- | --- |
| Header/P | Existing canonical vector and PollarBrand |
| Ledger | Three native paths into the canonical P; upper phone stage, right desktop stage |
| Typography | Semantic Inter, 36px title / 32px below 360px / 54px expanded, 16px body, 14px footer |
| Entrar | Native 56px-min full-width button, label left / arrow right, 10px radius, keyboard focus |
| Cadastrar | Shared secondary button, 48px minimum, userPlus, 12px below Entrar |
| Material | Existing solid light/dark tokens; no UI raster, gradient, shadow or blur |

The approved comp's inaccurate logo, gradients, oversized corners and small
footer are corrected using production authority. Independent media review
confirmed an empty raster manifest. Decorative artwork repaints independently.
Its entrance draws once over 800ms; reduced motion settles immediately. Both
actions are available on frame zero. Expanded layout requires 1024px locally
and textScaler.scale(16) <=24, inside a 1280px maximum; short layouts scroll.
Structure 4, seed 8cc36f0b and the five-part source contract remain recorded.

## Routing and account protection
Configured startup always starts at /welcome. Welcome and /sign-up are public
and never bind or expose financial data. Entrar pushes /sign-in with no session,
or requests /overview with one. Protected routing requires recent email proof,
MFA, device unlock and identity binding, including post-await identity checks.
Unconfigured local mode retains overview startup.

Cadastrar opens /sign-up with registration copy and blank email, sharing
existing passwordless OTP/MFA. Opening it, requesting a code or pressing Voltar
preserves the saved session. Only accepted email confirmation may replace
identity; session-change handling clears local unlock and the authenticator
follows. Existing-account email still uses its MFA. Financial data is never
cleared or merged. Native Back and visible Voltar return from pushed forms;
successful authentication retains normal route completion.

## Quality bar and verification boundary
Preserve the asymmetric ledger/P and both actions on phone/desktop, including
320px/200% text and short windows. Saved AAL1/AAL2 sessions start at welcome;
Entrar never skips email renewal or unlock. Registration cancellation preserves
a session; another verified identity resets unlock before data access.

Original B received ship, clean analysis, 600 general tests, three native
updater tests and Windows build 1.0.0+1015. The current behavior amendment is
verified separately: its independent finish review returned **SHIP**, with no
material findings and all five contract sections passing; static analysis is
clean and all **605 general Flutter tests passed**. Windows release `1.0.0+1016`
compiled successfully with remote configuration. The unchanged native updater
tests remain mandatory in publishing CI. Neither result implies physical-device
acceptance or publication of the pending revision.

