Set-StrictMode -Version Latest

function New-PollarWindowsPackage {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$ReleaseDirectory,
    [Parameter(Mandatory)][string]$OutputDirectory,
    [Parameter(Mandatory)][string]$Version,
    [Parameter(Mandatory)][ValidateSet('local', 'remote')][string]$BackendMode,
    [Parameter(Mandatory)][bool]$ChecksPassed,
    [Parameter(Mandatory)][string]$NoticesPath,
    [Parameter(Mandatory)][string]$ReadmePath
  )
  $ErrorActionPreference = 'Stop'
  if ($Version -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?(?:\+[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$') {
    throw 'Invalid package version.'
  }
  $pollarSource = (Resolve-Path -LiteralPath $ReleaseDirectory).Path.TrimEnd('\', '/')
  $pollarOutput = [IO.Path]::GetFullPath($OutputDirectory).TrimEnd('\', '/')
  if ($pollarOutput -eq $pollarSource -or $pollarOutput.StartsWith(
    $pollarSource + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase
  )) { throw 'Package output must be outside the release directory.' }
  foreach ($pollarRequired in @('pollar_app.exe', 'flutter_windows.dll', 'data/icudtl.dat', 'data/app.so')) {
    if (-not (Test-Path -LiteralPath (Join-Path $pollarSource $pollarRequired) -PathType Leaf)) {
      throw "Incomplete Windows release: missing $pollarRequired"
    }
  }
  $pollarAssets = Join-Path $pollarSource 'data/flutter_assets'
  if (-not (Test-Path -LiteralPath $pollarAssets -PathType Container) -or
      @(Get-ChildItem -LiteralPath $pollarAssets -Recurse -File -Force).Count -eq 0) {
    throw 'Incomplete Windows release: missing Flutter assets.'
  }
  foreach ($pollarDocument in @($NoticesPath, $ReadmePath)) {
    if (-not (Test-Path -LiteralPath $pollarDocument -PathType Leaf)) {
      throw "Package document missing: $pollarDocument"
    }
  }
  $pollarEntries = @(Get-ChildItem -LiteralPath $pollarSource -Recurse -Force)
  if (@($pollarEntries | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }).Count) {
    throw 'Release contains links. Refusing to package files outside the release tree.'
  }
  if (@($pollarEntries | Where-Object {
    $_.Name -match '(?i)(\.sqlite(?:-|$)|^\.env(?:\.|$)|^supabase\.remote\.json$)'
  }).Count) { throw 'Release contains local data or configuration files. Packaging refused.' }

  $pollarName = 'pollar-windows-{0}-{1}-{2}-{3}' -f $Version, $BackendMode,
    [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss'), [Guid]::NewGuid().ToString('N').Substring(0, 8)
  $null = New-Item -ItemType Directory -Path $pollarOutput -Force
  $pollarBundle = Join-Path $pollarOutput $pollarName
  $null = New-Item -ItemType Directory -Path $pollarBundle
  Get-ChildItem -LiteralPath $pollarSource -Force | Copy-Item -Destination $pollarBundle -Recurse
  Copy-Item -LiteralPath $NoticesPath -Destination (Join-Path $pollarBundle 'THIRD_PARTY_NOTICES.md')
  Copy-Item -LiteralPath $ReadmePath -Destination (Join-Path $pollarBundle 'LEIA-ME.txt')

  $pollarFiles = @(Get-ChildItem -LiteralPath $pollarBundle -Recurse -File -Force | Sort-Object FullName | ForEach-Object {
    [ordered]@{
      path = $_.FullName.Substring($pollarBundle.Length + 1).Replace('\', '/')
      bytes = $_.Length
      sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
  })
  $pollarManifestPath = Join-Path $pollarBundle 'package-manifest.json'
  [ordered]@{
    format = 'pollar.windows.internal'
    formatVersion = 1
    version = $Version
    platform = 'windows-x64'
    backendMode = $BackendMode
    internalOnly = $true
    checksPassed = $ChecksPassed
    createdAtUtc = [DateTime]::UtcNow.ToString('o')
    files = $pollarFiles
  } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $pollarManifestPath -Encoding UTF8
  $pollarArchive = Join-Path $pollarOutput "$pollarName.zip"
  Compress-Archive -LiteralPath $pollarBundle -DestinationPath $pollarArchive
  $pollarHash = (Get-FileHash -LiteralPath $pollarArchive -Algorithm SHA256).Hash
  "$pollarHash  $pollarName.zip" | Set-Content -LiteralPath "$pollarArchive.sha256" -Encoding ASCII
  [pscustomobject]@{
    PackageDirectory = $pollarBundle
    ArchivePath = $pollarArchive
    ManifestPath = $pollarManifestPath
    Sha256 = $pollarHash
  }
}

Export-ModuleMember -Function New-PollarWindowsPackage
