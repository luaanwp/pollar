# Runs from the app cache, outside the files being replaced. Never touches AppData.
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$Archive,
  [Parameter(Mandatory)][ValidatePattern('^[a-fA-F0-9]{64}$')][string]$ExpectedHash,
  [Parameter(Mandatory)][ValidatePattern('^\d+\.\d+\.\d+\+\d+$')][string]$ExpectedVersion,
  [Parameter(Mandatory)][string]$InstallDirectory,
  [Parameter(Mandatory)][int]$ParentProcessId,
  [Parameter(Mandatory)][string]$StatusFile,
  [switch]$ValidateOnly
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Add-Type -AssemblyName System.IO.Compression.FileSystem
$pollarWork = [IO.Path]::GetFullPath((Split-Path -Parent $StatusFile))
$pollarStage = Join-Path $pollarWork 'stage'
$pollarBackup = Join-Path $pollarWork 'backup'
$pollarInstalled = [Collections.Generic.List[object]]::new()
$pollarApplying = $false

function Write-PollarStatus([string]$Phase) {
  $pollarStatusTemp = "$StatusFile.tmp"
  @{ phase = $Phase } | ConvertTo-Json -Compress | Set-Content -LiteralPath $pollarStatusTemp -Encoding UTF8
  Move-Item -LiteralPath $pollarStatusTemp -Destination $StatusFile -Force
}
function Resolve-PollarChild([string]$Root, [string]$Relative) {
  if ([IO.Path]::IsPathRooted($Relative) -or $Relative.Contains(':') -or $Relative -match '(^|[/\\])\.\.([/\\]|$)') {
    throw 'Unsafe package path'
  }
  $pollarResolved = [IO.Path]::GetFullPath((Join-Path $Root $Relative))
  if (-not $pollarResolved.StartsWith($Root.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Path escaped root' }
  return $pollarResolved
}
try {
  $pollarTarget = (Resolve-Path -LiteralPath $InstallDirectory).Path.TrimEnd('\')
  if ((Get-Item -LiteralPath $pollarTarget -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Installation root links are forbidden' }
  $pollarExe = Join-Path $pollarTarget 'pollar_app.exe'
  $pollarIdentity = (Get-Item -LiteralPath $pollarExe).VersionInfo
  if ($pollarIdentity.CompanyName -cne 'com.pollar' -or $pollarIdentity.ProductName -cne 'pollar_app') { throw 'Wrong installation identity' }
  if ((Get-FileHash -LiteralPath $Archive -Algorithm SHA256).Hash -cne $ExpectedHash.ToUpperInvariant()) { throw 'Archive integrity failure' }
  $null = New-Item -ItemType Directory -Path $pollarStage
  $pollarZip = [IO.Compression.ZipFile]::OpenRead($Archive)
  try {
    $pollarNames = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    [long]$pollarTotal = 0
    foreach ($pollarEntry in $pollarZip.Entries) {
      $pollarTotal += $pollarEntry.Length
      if ($pollarTotal -gt 1073741824) { throw 'Package too large' }
      $null = Resolve-PollarChild $pollarStage $pollarEntry.FullName
      if (-not $pollarNames.Add($pollarEntry.FullName.Replace('/', '\'))) { throw 'Duplicate package path' }
      if (($pollarEntry.ExternalAttributes -shr 16 -band 61440) -eq 40960) { throw 'Package links are forbidden' }
    }
  } finally { $pollarZip.Dispose() }
  [IO.Compression.ZipFile]::ExtractToDirectory($Archive, $pollarStage)
  $pollarManifests = @(Get-ChildItem -LiteralPath $pollarStage -Filter package-manifest.json -Recurse -File)
  if ($pollarManifests.Count -ne 1) { throw 'Missing package manifest' }
  $pollarManifest = Get-Content -LiteralPath $pollarManifests[0].FullName -Raw | ConvertFrom-Json
  if ($pollarManifest.version -cne $ExpectedVersion -or $pollarManifest.platform -cne 'windows-x64' -or
      $pollarManifest.backendMode -cne 'remote' -or -not $pollarManifest.checksPassed -or $pollarManifest.internalOnly) { throw 'Unexpected package metadata' }
  $pollarSource = $pollarManifests[0].Directory.FullName
  $pollarListed = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
  foreach ($pollarFile in $pollarManifest.files) {
    $pollarPath = [string]$pollarFile.path
    if (-not $pollarListed.Add($pollarPath.Replace('/', '\')) -or
        $pollarPath -match '(?i)(\.sqlite(?:-|$)|(^|/)\.env(?:\.|$)|(^|/)supabase\.remote\.json$)') { throw 'Invalid package contents' }
    $pollarInput = Resolve-PollarChild $pollarSource $pollarPath
    $pollarOutput = Resolve-PollarChild $pollarTarget $pollarPath
    # Existing links could redirect a valid package path outside the installation.
    $pollarAncestor = $pollarOutput
    while ($pollarAncestor -and $pollarAncestor -ne $pollarTarget) {
      if ((Test-Path -LiteralPath $pollarAncestor) -and
          ((Get-Item -LiteralPath $pollarAncestor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Installation links are forbidden' }
      $pollarAncestor = Split-Path -Parent $pollarAncestor
    }
    if ((Get-Item -LiteralPath $pollarInput).Length -ne $pollarFile.bytes -or
        (Get-FileHash -LiteralPath $pollarInput -Algorithm SHA256).Hash -ine $pollarFile.sha256) { throw 'File integrity failure' }
  }
  if (@(Get-ChildItem -LiteralPath $pollarSource -Recurse -File).Count -ne $pollarListed.Count + 1) { throw 'Unlisted package files' }
  foreach ($pollarRequired in @('pollar_app.exe', 'flutter_windows.dll', 'data/app.so', 'data/icudtl.dat')) {
    if (-not $pollarListed.Contains($pollarRequired.Replace('/', '\'))) { throw 'Incomplete runtime' }
  }
  $pollarNewIdentity = (Get-Item -LiteralPath (Join-Path $pollarSource 'pollar_app.exe')).VersionInfo
  if ($pollarNewIdentity.CompanyName -cne 'com.pollar' -or $pollarNewIdentity.ProductName -cne 'pollar_app' -or
      $pollarNewIdentity.FileVersion -cne $ExpectedVersion) { throw 'Unexpected executable identity or version' }
  if ($ValidateOnly) { Write-PollarStatus 'validated'; exit 0 }
  $pollarParent = Get-Process -Id $ParentProcessId
  if ($pollarParent.Path -ine $pollarExe) { throw 'Parent is not this Pollar installation' }
  # Probe write access before telling the running application to close.
  $pollarProbe = Join-Path $pollarTarget ('.pollar-write-' + [Guid]::NewGuid().ToString('N'))
  [IO.File]::WriteAllText($pollarProbe, 'probe')
  Remove-Item -LiteralPath $pollarProbe
  foreach ($pollarFile in $pollarManifest.files) {
    $pollarOutput = Resolve-PollarChild $pollarTarget $pollarFile.path
    $pollarSaved = Resolve-PollarChild $pollarBackup $pollarFile.path
    $pollarExisted = Test-Path -LiteralPath $pollarOutput -PathType Leaf
    if ($pollarExisted) {
      $null = New-Item -ItemType Directory -Path (Split-Path -Parent $pollarSaved) -Force
      Copy-Item -LiteralPath $pollarOutput -Destination $pollarSaved
    }
    $pollarInstalled.Add([pscustomobject]@{ Output = $pollarOutput; Backup = $pollarSaved; Existed = $pollarExisted })
  }
  Write-PollarStatus 'ready'
  $pollarParent | Wait-Process -Timeout 120
  $pollarApplying = $true
  foreach ($pollarFile in $pollarManifest.files) {
    $pollarOutput = Resolve-PollarChild $pollarTarget $pollarFile.path
    $null = New-Item -ItemType Directory -Path (Split-Path -Parent $pollarOutput) -Force
    Copy-Item -LiteralPath (Resolve-PollarChild $pollarSource $pollarFile.path) -Destination $pollarOutput -Force
  }
  $pollarLaunched = Start-Process -FilePath $pollarExe -WorkingDirectory $pollarTarget -WindowStyle Hidden -PassThru
  Start-Sleep -Seconds 2
  if ($pollarLaunched.HasExited -and $pollarLaunched.ExitCode -ne 0) { throw 'Updated application failed to start' }
  Write-PollarStatus 'installed'
} catch {
  if ($pollarApplying) {
    foreach ($pollarFile in $pollarInstalled) {
      try {
        if ($pollarFile.Existed) { Copy-Item -LiteralPath $pollarFile.Backup -Destination $pollarFile.Output -Force }
        elseif (Test-Path -LiteralPath $pollarFile.Output -PathType Leaf) { Remove-Item -LiteralPath $pollarFile.Output }
      } catch {
        $_ | Out-String | Add-Content -LiteralPath (Join-Path $pollarWork 'rollback-error.log') -Encoding UTF8
      }
    }
    Start-Process -FilePath $pollarExe -WorkingDirectory $pollarTarget -WindowStyle Hidden
  }
  Write-PollarStatus 'error'
  $_ | Out-String | Set-Content -LiteralPath (Join-Path $pollarWork 'update-error.log') -Encoding UTF8
  exit 1
}
