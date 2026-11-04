# Isolated native fixtures: never starts, closes, or updates the user's Pollar.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot '../tools/windows-package.psm1') -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
$pollarTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
$pollarTestRoot = Join-Path $pollarTempRoot ('pollar-update-test-' + [Guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $pollarTestRoot
$pollarHelper = (Resolve-Path (Join-Path $PSScriptRoot '../apps/pollar_app/assets/update/pollar-update.ps1')).Path
$pollarPowerShell = Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe'
function Assert-Update([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
function Invoke-UpdateValidation([string]$Zip, [string]$Hash, [string]$Case) {
  $pollarCaseRoot = Join-Path $pollarTestRoot $Case
  $null = New-Item -ItemType Directory -Path $pollarCaseRoot
  $pollarStatusPath = Join-Path $pollarCaseRoot 'status.json'
  & $pollarPowerShell -NoProfile -NonInteractive -File $pollarHelper -Archive $Zip -ExpectedHash $Hash -ExpectedVersion '1.0.0+10' -InstallDirectory $pollarInstall -ParentProcessId 0 -StatusFile $pollarStatusPath -ValidateOnly
  return (Get-Content -LiteralPath $pollarStatusPath -Raw | ConvertFrom-Json).phase
}
try {
  $pollarTokens = $null
  $pollarParseErrors = $null
  $null = [Management.Automation.Language.Parser]::ParseFile($pollarHelper, [ref]$pollarTokens, [ref]$pollarParseErrors)
  Assert-Update (@($pollarParseErrors).Count -eq 0) 'Updater PowerShell parse failure'
  $pollarInstall = Join-Path $pollarTestRoot 'installation'
  $pollarSource = Join-Path $pollarTestRoot 'release'
  foreach ($pollarDirectory in @($pollarInstall, (Join-Path $pollarSource 'data/flutter_assets'))) {
    $null = New-Item -ItemType Directory -Path $pollarDirectory -Force
  }
  foreach ($pollarBuild in @(9, 10)) {
    $pollarCode = @"
using System;
using System.IO;
using System.Reflection;
using System.Threading;
[assembly: AssemblyCompany("com.pollar")]
[assembly: AssemblyProduct("pollar_app")]
[assembly: AssemblyFileVersion("1.0.0+$pollarBuild")]
public class Fixture$pollarBuild {
  public static void Main(string[] args) {
    var directory = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
    if (args.Length > 0) {
      for (int i = 0; i < 3000 && !File.Exists(Path.Combine(directory, "exit.request")); i++) Thread.Sleep(20);
    } else File.WriteAllText(Path.Combine(directory, "started.txt"), "$pollarBuild");
  }
}
"@
    $pollarFixture = Join-Path $pollarTestRoot "fixture$pollarBuild.exe"
    Add-Type -TypeDefinition $pollarCode -OutputAssembly $pollarFixture -OutputType WindowsApplication -IgnoreWarnings -WarningAction SilentlyContinue
    $pollarDestination = if ($pollarBuild -eq 9) { $pollarInstall } else { $pollarSource }
    Copy-Item -LiteralPath $pollarFixture -Destination (Join-Path $pollarDestination 'pollar_app.exe')
  }
  foreach ($pollarRelative in @('flutter_windows.dll', 'data/app.so', 'data/icudtl.dat', 'data/flutter_assets/fixture.txt')) {
    [IO.File]::WriteAllText((Join-Path $pollarSource $pollarRelative), "new:$pollarRelative")
  }
  [IO.File]::WriteAllText((Join-Path $pollarInstall 'local.sqlite'), 'preserve-user-data')
  $pollarOriginalHash = (Get-FileHash -LiteralPath (Join-Path $pollarInstall 'pollar_app.exe')).Hash
  $pollarPackage = New-PollarWindowsPackage -ReleaseDirectory $pollarSource -OutputDirectory (Join-Path $pollarTestRoot 'packages') -Version '1.0.0+10' -BackendMode remote -ChecksPassed $true -ForUpdates -NoticesPath (Join-Path $PSScriptRoot '../THIRD_PARTY_NOTICES.md') -ReadmePath (Join-Path $PSScriptRoot '../packaging/windows/LEIA-ME.txt')
  Assert-Update ((Invoke-UpdateValidation $pollarPackage.ArchivePath $pollarPackage.Sha256 'valid') -eq 'validated') 'Valid package rejected'
  Assert-Update ((Invoke-UpdateValidation $pollarPackage.ArchivePath ('0' * 64) 'wrong-hash') -eq 'error') 'Invalid archive hash accepted'
  $pollarUnsafe = Join-Path $pollarTestRoot 'unsafe.zip'
  Copy-Item -LiteralPath $pollarPackage.ArchivePath -Destination $pollarUnsafe
  $pollarZip = [IO.Compression.ZipFile]::Open($pollarUnsafe, [IO.Compression.ZipArchiveMode]::Update)
  try {
    $pollarEntry = $pollarZip.CreateEntry('../escaped.txt')
    $pollarWriter = [IO.StreamWriter]::new($pollarEntry.Open())
    try { $pollarWriter.Write('unsafe') } finally { $pollarWriter.Dispose() }
  } finally { $pollarZip.Dispose() }
  Assert-Update ((Invoke-UpdateValidation $pollarUnsafe (Get-FileHash -LiteralPath $pollarUnsafe).Hash 'unsafe-path') -eq 'error') 'Archive traversal accepted'
  Assert-Update (-not (Test-Path -LiteralPath (Join-Path $pollarTestRoot 'unsafe-path/escaped.txt'))) 'Traversal wrote outside stage'
  Assert-Update ((Get-FileHash -LiteralPath (Join-Path $pollarInstall 'pollar_app.exe')).Hash -eq $pollarOriginalHash) 'Validation changed installed executable'
  Write-Host 'PASS: valid runtime, hash mismatch and archive traversal; validation never changes installation'

  $pollarParent = Start-Process -FilePath (Join-Path $pollarInstall 'pollar_app.exe') -ArgumentList '--hold' -WindowStyle Hidden -PassThru
  $pollarApplyRoot = Join-Path $pollarTestRoot 'apply'
  $null = New-Item -ItemType Directory -Path $pollarApplyRoot
  $pollarStatus = Join-Path $pollarApplyRoot 'status.json'
  $pollarArguments = @('-NoProfile', '-NonInteractive', '-File', ('"' + $pollarHelper + '"'), '-Archive', ('"' + $pollarPackage.ArchivePath + '"'), '-ExpectedHash', $pollarPackage.Sha256, '-ExpectedVersion', '1.0.0+10', '-InstallDirectory', ('"' + $pollarInstall + '"'), '-ParentProcessId', $pollarParent.Id, '-StatusFile', ('"' + $pollarStatus + '"'))
  $pollarUpdater = Start-Process -FilePath $pollarPowerShell -ArgumentList $pollarArguments -WindowStyle Hidden -PassThru
  for ($pollarWait = 0; $pollarWait -lt 100 -and -not (Test-Path -LiteralPath $pollarStatus); $pollarWait++) { Start-Sleep -Milliseconds 100 }
  Assert-Update ((Get-Content -LiteralPath $pollarStatus -Raw | ConvertFrom-Json).phase -eq 'ready') 'Preparation did not complete'
  Assert-Update ((Get-FileHash -LiteralPath (Join-Path $pollarInstall 'pollar_app.exe')).Hash -eq $pollarOriginalHash) 'Updater replaced running application before exit'
  [IO.File]::WriteAllText((Join-Path $pollarInstall 'exit.request'), 'exit')
  $pollarUpdater | Wait-Process -Timeout 30
  Assert-Update ((Get-Content -LiteralPath $pollarStatus -Raw | ConvertFrom-Json).phase -eq 'installed') 'Native update did not finish'
  Assert-Update ((Get-Item -LiteralPath (Join-Path $pollarInstall 'pollar_app.exe')).VersionInfo.FileVersion -eq '1.0.0+10') 'New executable missing'
  Assert-Update ((Get-Content -LiteralPath (Join-Path $pollarInstall 'started.txt') -Raw) -eq '10') 'Updated app did not relaunch'
  Assert-Update ((Get-Content -LiteralPath (Join-Path $pollarInstall 'local.sqlite') -Raw) -eq 'preserve-user-data') 'Unmanaged data changed'
  Write-Host 'PASS: native preflight, wait for app exit, replacement, relaunch and unmanaged data preservation'
} finally {
  if (Get-Variable pollarParent -ErrorAction SilentlyContinue) {
    if (-not $pollarParent.HasExited) { $pollarParent.Kill(); $pollarParent.WaitForExit() }
  }
  $pollarResolved = [IO.Path]::GetFullPath($pollarTestRoot)
  if ([IO.Path]::GetDirectoryName($pollarResolved) -ne $pollarTempRoot -or [IO.Path]::GetFileName($pollarResolved) -notmatch '^pollar-update-test-[a-f0-9]{32}$') { throw 'Unsafe test cleanup target' }
  Remove-Item -LiteralPath $pollarResolved -Recurse -Force
}
exit 0
