# Builds an internal portable package; never installs or modifies local app data.
[CmdletBinding()]
param(
  [switch]$Remote,
  [switch]$SkipChecks,
  [string]$FlutterPath
)

$ErrorActionPreference = 'Stop'
$pollarAppDirectory = Join-Path $PSScriptRoot 'apps/pollar_app'
if (-not $FlutterPath) {
  $pollarFlutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
  if ($pollarFlutterCommand) {
    $FlutterPath = $pollarFlutterCommand.Source
  } else {
    $FlutterPath = 'C:\Users\luanl\orca\tools\pollar\flutter\bin\flutter.bat'
  }
}
if (-not (Test-Path -LiteralPath $FlutterPath -PathType Leaf)) {
  throw 'Flutter not found. Pass -FlutterPath with the path to flutter.bat.'
}
$FlutterPath = (Resolve-Path -LiteralPath $FlutterPath).Path
if ($Remote -and -not (Test-Path -LiteralPath (Join-Path $pollarAppDirectory 'config/supabase.remote.json') -PathType Leaf)) {
  throw 'Remote configuration missing: apps/pollar_app/config/supabase.remote.json'
}
if (-not $SkipChecks) {
  & (Join-Path $PSScriptRoot 'tests/windows-package.tests.ps1')
}

function Invoke-PollarFlutter {
  param([string[]]$FlutterArgs)
  & $FlutterPath @FlutterArgs
  if ($LASTEXITCODE -ne 0) {
    throw "Flutter failed ($LASTEXITCODE): $($FlutterArgs[0])"
  }
}

Push-Location -LiteralPath $pollarAppDirectory
try {
  Invoke-PollarFlutter -FlutterArgs @('pub', 'get')
  if (-not $SkipChecks) {
    Invoke-PollarFlutter -FlutterArgs @('analyze', '--no-pub')
    Invoke-PollarFlutter -FlutterArgs @('test', '--no-pub')
  }
  $pollarBuildArgs = @('build', 'windows', '--release', '--no-pub')
  if ($Remote) {
    $pollarBuildArgs += '--dart-define-from-file=config/supabase.remote.json'
  }
  Invoke-PollarFlutter -FlutterArgs $pollarBuildArgs
} finally {
  Pop-Location
}

$pollarVersionMatch = [regex]::Match(
  (Get-Content -LiteralPath (Join-Path $pollarAppDirectory 'pubspec.yaml') -Raw),
  '(?m)^version:\s*(\S+)\s*$'
)
if (-not $pollarVersionMatch.Success) { throw 'App version missing from pubspec.yaml.' }
Import-Module (Join-Path $PSScriptRoot 'tools/windows-package.psm1') -Force
$pollarMode = if ($Remote) { 'remote' } else { 'local' }
$pollarPackage = New-PollarWindowsPackage `
  -ReleaseDirectory (Join-Path $pollarAppDirectory 'build/windows/x64/runner/Release') `
  -OutputDirectory (Join-Path $PSScriptRoot 'dist') `
  -Version $pollarVersionMatch.Groups[1].Value `
  -BackendMode $pollarMode `
  -ChecksPassed (-not $SkipChecks) `
  -NoticesPath (Join-Path $PSScriptRoot 'THIRD_PARTY_NOTICES.md') `
  -ReadmePath (Join-Path $PSScriptRoot 'packaging/windows/LEIA-ME.txt')
Write-Host "Package: $($pollarPackage.ArchivePath)"
Write-Host "SHA-256: $($pollarPackage.Sha256)"
Write-Host "Open: $(Join-Path $pollarPackage.PackageDirectory 'pollar_app.exe')"
if ($SkipChecks) { Write-Warning 'Checks skipped. This is recorded in the package manifest.' }
