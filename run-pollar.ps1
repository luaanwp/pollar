# Convenience launcher for the isolated Flutter toolchain on this machine.
# Usage:
#   .\run-pollar.ps1              # runs on Windows desktop
#   .\run-pollar.ps1 chrome       # runs in Chrome (web)
#   .\run-pollar.ps1 -List        # lists connected devices
param(
  [string]$Device = "windows",
  [switch]$List
)

$env:Path = "C:\Users\luanl\orca\tools\pollar\flutter\bin;$env:Path"
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-21.0.5.11-hotspot"
$env:ANDROID_HOME = "C:\Users\luanl\orca\tools\pollar\android-sdk"

Set-Location "$PSScriptRoot\apps\pollar_app"

if ($List) { flutter devices; return }

flutter run -d $Device
