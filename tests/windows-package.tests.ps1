# Standalone checks; no Pester, Flutter or Visual Studio required.
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../tools/windows-package.psm1') -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Assert-Pollar {
  param([bool]$Condition, [string]$Message)
  if (-not $Condition) { throw $Message }
}
function Assert-PollarFailure {
  param([scriptblock]$Action, [string]$Expected)
  $pollarFailure = $null
  try { & $Action | Out-Null } catch { $pollarFailure = $_.Exception.Message }
  Assert-Pollar ($null -ne $pollarFailure -and $pollarFailure -like "*$Expected*") "Expected failure: $Expected; got: $pollarFailure"
}

$pollarTempParent = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\', '/')
$pollarTemp = Join-Path $pollarTempParent ('pollar-packaging-test-' + [Guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $pollarTemp
try {
  foreach ($pollarScript in @('../build-windows.ps1', '../tools/windows-package.psm1', 'windows-package.tests.ps1')) {
    $pollarTokens = $null
    $pollarParseErrors = $null
    $null = [Management.Automation.Language.Parser]::ParseFile(
      (Join-Path $PSScriptRoot $pollarScript), [ref]$pollarTokens, [ref]$pollarParseErrors
    )
    Assert-Pollar (@($pollarParseErrors).Count -eq 0) "PowerShell parse failure: $pollarScript"
  }
  $pollarRelease = Join-Path $pollarTemp 'release'
  $null = New-Item -ItemType Directory -Path (Join-Path $pollarRelease 'data/flutter_assets/fonts') -Force
  foreach ($pollarFile in @('pollar_app.exe', 'flutter_windows.dll', 'plugin.dll', 'data/icudtl.dat', 'data/app.so', 'data/flutter_assets/fonts/test.ttf')) {
    [IO.File]::WriteAllText((Join-Path $pollarRelease $pollarFile), "fixture:$pollarFile")
  }
  $pollarOriginalHash = (Get-FileHash -LiteralPath (Join-Path $pollarRelease 'pollar_app.exe')).Hash
  $pollarParameters = @{
    ReleaseDirectory = $pollarRelease
    OutputDirectory = (Join-Path $pollarTemp 'output')
    Version = '1.0.0+3'
    BackendMode = 'remote'
    ChecksPassed = $true
    NoticesPath = (Join-Path $PSScriptRoot '../THIRD_PARTY_NOTICES.md')
    ReadmePath = (Join-Path $PSScriptRoot '../packaging/windows/LEIA-ME.txt')
  }
  $pollarPackage = New-PollarWindowsPackage @pollarParameters
  $pollarManifest = Get-Content -LiteralPath $pollarPackage.ManifestPath -Raw | ConvertFrom-Json
  Assert-Pollar ($pollarManifest.backendMode -eq 'remote' -and $pollarManifest.checksPassed) 'Backend/check status missing.'
  Assert-Pollar ($pollarManifest.version -eq '1.0.0+3' -and $pollarManifest.internalOnly) 'Version/internal label missing.'
  Assert-Pollar ($pollarManifest.files.Count -eq 8) 'Package must include runtime, plugins, assets and documentation.'
  foreach ($pollarEntry in $pollarManifest.files) {
    $pollarActual = Get-Item -LiteralPath (Join-Path $pollarPackage.PackageDirectory $pollarEntry.path)
    Assert-Pollar ($pollarActual.Length -eq $pollarEntry.bytes) 'Incorrect manifest size.'
    Assert-Pollar ((Get-FileHash -LiteralPath $pollarActual.FullName).Hash -eq $pollarEntry.sha256) 'Incorrect manifest checksum.'
  }
  $pollarZip = [IO.Compression.ZipFile]::OpenRead($pollarPackage.ArchivePath)
  try {
    $pollarArchivedFiles = @($pollarZip.Entries | Where-Object { $_.Name })
    Assert-Pollar ($pollarArchivedFiles.Count -eq 9) 'ZIP must include every manifest file and the manifest itself.'
    # PowerShell 5.1 ZIP entries may use Windows separators; the manifest uses '/'.
    $pollarPrefix = [IO.Path]::GetFileName($pollarPackage.PackageDirectory) + '/'
    foreach ($pollarEntry in $pollarManifest.files) {
      $pollarMatches = @($pollarZip.Entries | Where-Object {
        $_.FullName.Replace('\', '/') -eq ($pollarPrefix + $pollarEntry.path)
      })
      Assert-Pollar ($pollarMatches.Count -eq 1) 'ZIP entry missing or ambiguous.'
      $pollarStream = $pollarMatches[0].Open()
      $pollarDigest = [Security.Cryptography.SHA256]::Create()
      try {
        $pollarArchivedHash = [BitConverter]::ToString($pollarDigest.ComputeHash($pollarStream)).Replace('-', '')
      } finally { $pollarStream.Dispose(); $pollarDigest.Dispose() }
      Assert-Pollar ($pollarArchivedHash -eq $pollarEntry.sha256) 'ZIP content differs from manifest.'
    }
  } finally { $pollarZip.Dispose() }
  Assert-Pollar ((Get-FileHash -LiteralPath $pollarPackage.ArchivePath).Hash -eq $pollarPackage.Sha256) 'Incorrect archive checksum.'
  Assert-Pollar ((Get-Content -LiteralPath "$($pollarPackage.ArchivePath).sha256") -like "$($pollarPackage.Sha256)*") 'Checksum sidecar missing.'
  Assert-Pollar ((Get-FileHash -LiteralPath (Join-Path $pollarRelease 'pollar_app.exe')).Hash -eq $pollarOriginalHash) 'Packaging modified the original release.'
  Write-Host 'PASS: complete ZIP, per-file and archive checksums, source preserved'

  $pollarParameters.BackendMode = 'local'
  $pollarParameters.ChecksPassed = $false
  $pollarSecond = New-PollarWindowsPackage @pollarParameters
  $pollarSecondManifest = Get-Content -LiteralPath $pollarSecond.ManifestPath -Raw | ConvertFrom-Json
  Assert-Pollar ($pollarSecond.ArchivePath -ne $pollarPackage.ArchivePath) 'A new package overwrote an older one.'
  Assert-Pollar ($pollarSecondManifest.backendMode -eq 'local' -and -not $pollarSecondManifest.checksPassed) 'Skipped checks/local mode misreported.'
  Write-Host 'PASS: distinct outputs, local mode and skipped checks explicitly recorded'

  $pollarInvalid = $pollarParameters.Clone()
  $pollarInvalid.Version = '../../bad'
  Assert-PollarFailure { New-PollarWindowsPackage @pollarInvalid } 'Invalid package version'
  $pollarInvalid = $pollarParameters.Clone()
  $pollarInvalid.OutputDirectory = Join-Path $pollarRelease 'nested'
  Assert-PollarFailure { New-PollarWindowsPackage @pollarInvalid } 'outside the release directory'
  Write-Host 'PASS: unsafe version and nested output rejected'

  $pollarPartial = Join-Path $pollarTemp 'partial'
  $null = New-Item -ItemType Directory -Path $pollarPartial
  [IO.File]::WriteAllText((Join-Path $pollarPartial 'pollar_app.exe'), 'incomplete')
  $pollarInvalid = $pollarParameters.Clone()
  $pollarInvalid.ReleaseDirectory = $pollarPartial
  Assert-PollarFailure { New-PollarWindowsPackage @pollarInvalid } 'missing flutter_windows.dll'
  [IO.File]::WriteAllText((Join-Path $pollarRelease 'pollar.sqlite'), 'must-not-ship')
  Assert-PollarFailure { New-PollarWindowsPackage @pollarParameters } 'local data or configuration'
  Write-Host 'PASS: incomplete runtime and local database rejected'
} finally {
  # Only delete this test's GUID-named directory directly under the temp root.
  $pollarResolved = [IO.Path]::GetFullPath($pollarTemp)
  if ([IO.Path]::GetDirectoryName($pollarResolved) -ne $pollarTempParent -or
      [IO.Path]::GetFileName($pollarResolved) -notmatch '^pollar-packaging-test-[a-f0-9]{32}$') {
    throw 'Unsafe test cleanup target.'
  }
  Remove-Item -LiteralPath $pollarResolved -Recurse -Force
}
