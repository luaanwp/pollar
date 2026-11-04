---
version: 1
slug: "features-updates"
primary_target: "apps/pollar_app/lib/features/updates/presentation/app_update_widgets.dart"
related_targets:
  - "apps/pollar_app/lib/features/updates/presentation/app_update_controller.dart"
  - "apps/pollar_app/lib/app/routing/app_shell.dart"
  - "apps/pollar_app/lib/features/settings/presentation/settings_screen.dart"
---

## Scope and mode

Operate: let people discover, download and explicitly install a newer Pollar
version on Android or Windows, within the existing visual world. This surface
does not replace financial navigation, authentication or account data.

## Job and direction

The shell announces only an available release. Preferences also offers a manual
check and displays the installed version when there is no available release.
The user first selects Atualizar to download; a completed package changes the
action to Instalar atualização on Android or Atualizar e reiniciar on Windows.
An adaptive confirmation explains installation and retains Agora não. Download
completion alone never initiates installation or closes an editor.

## Implemented visual language

Reuse the existing outlined `PollarCard`, standard `PollarButton` with adaptive
height, Lucide download icon, `titleMedium`, `bodyMedium` and secondary text
token. No new brand color, financial surface, illustration or arrival animation
is introduced. The shell notice has 16px horizontal and 8px vertical outer
padding; the Preferences panel uses its page's existing spacing.

At widths below 680px, or text scale above 1.3×, title/description precede the
action in a column with 12px spacing. Wider normal-text panels place details
and action in a row with 16px spacing. Text wraps rather than truncating the
version or recovery instruction.

## Available space and editing

The shell notice uses at most 40% of its body's actual `LayoutBuilder` height,
not the whole window height, and scrolls internally when necessary. The current
route retains the remaining expanded space. With a nonzero keyboard view inset,
the notice is suppressed and the route receives the body; update state remains
available after editing. Without an available release, no notice wrapper is
inserted into the route's scrolling path.

## States and accessibility

Idle, checking, current, available, downloading, ready, installing, permission
required and error are explicit controller states. Download progress appears
as a percentage in the title. Busy states use the standard button's loading and
disabled behavior. Title and description share a live region; action labels
remain visible and use the existing native keyboard/touch semantics.

An Android permission request retains the downloaded package so the user can
return and explicitly retry installation. Cancellation likewise keeps the
package available. A failed installation offers a fresh download; query or
download errors leave financial screens usable. Error copy does not assert a
specific network cause when the failure could have another source.

The neighboring system-theme option uses Lucide smartphone on Android/iOS and
monitor on desktop. This is an icon adaptation only; theme selection behavior
and all other Preferences controls stay intact.

## Verification boundary

Widget and golden coverage includes the notice at 320px with 2× text and at
1200px, plus confirmation cancellation. Shell-specific cases cover simulated
keyboard insets and a short landscape body. Domain/controller/transport tests
cover version choice, invalid downloads and retry states. These sources do not
establish a physical Android installation, assistive-technology session, or a
completed GitHub publication; execution evidence belongs in
`docs/in-app-updates.md` and the release records.
