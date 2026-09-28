# Convenience launcher for the isolated Flutter toolchain on this machine.
# Usage:
#   .\run-pollar.ps1              # runs on Windows desktop
#   .\run-pollar.ps1 -Remote      # runs with the hosted Supabase project
#   .\run-pollar.ps1 chrome       # runs in Chrome (web)
#   .\run-pollar.ps1 -List        # lists connected devices
param(
  [string]$Device = "windows",
  [switch]$List,
  [switch]$Remote
)

$env:Path = "C:\Users\luanl\orca\tools\pollar\flutter\bin;$env:Path"
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-21.0.5.11-hotspot"
$env:ANDROID_HOME = "C:\Users\luanl\orca\tools\pollar\android-sdk"

Set-Location "$PSScriptRoot\apps\pollar_app"

if ($List) { flutter devices; return }

$pollarFlutterArgs = @('run', '-d', $Device)
if ($Remote) {
  if (-not (Test-Path -LiteralPath 'config/supabase.remote.json')) {
    throw 'Remote Supabase config missing: apps/pollar_app/config/supabase.remote.json'
  }
  $pollarFlutterArgs += '--dart-define-from-file=config/supabase.remote.json'
}

flutter @pollarFlutterArgs
