[CmdletBinding()]
param(
  [Parameter(Mandatory)][ValidatePattern('^\d+\.\d+\.\d+\+\d+$')][string]$Version,
  [Parameter(Mandatory)][ValidatePattern('^[0-9a-f]{40}$')][string]$Commit
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$pollarRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot 'windows-package.psm1') -Force
$pollarRelease = Join-Path $pollarRoot 'apps/pollar_app/build/windows/x64/runner/Release'
Assert-PollarWindowsStorageIdentity -VersionInfo (Get-Item -LiteralPath (Join-Path $pollarRelease 'pollar_app.exe')).VersionInfo
$pollarInfo = (Get-Item -LiteralPath (Join-Path $pollarRelease 'pollar_app.exe')).VersionInfo
if ($pollarInfo.FileVersion -cne $Version) { throw 'Built Windows version does not match release version.' }
$pollarDist = Join-Path $pollarRoot 'dist'
$pollarPackage = New-PollarWindowsPackage -ReleaseDirectory $pollarRelease -OutputDirectory $pollarDist -Version $Version -BackendMode remote -ChecksPassed $true -ForUpdates -NoticesPath (Join-Path $pollarRoot 'THIRD_PARTY_NOTICES.md') -ReadmePath (Join-Path $pollarRoot 'packaging/windows/LEIA-ME.txt')
$pollarZip = Join-Path $pollarDist 'pollar-windows.zip'
$pollarApk = Join-Path $pollarDist 'pollar-android.apk'
Copy-Item -LiteralPath $pollarPackage.ArchivePath -Destination $pollarZip
Copy-Item -LiteralPath (Join-Path $pollarRoot 'apps/pollar_app/build/app/outputs/flutter-apk/app-release.apk') -Destination $pollarApk
$pollarAndroidHome = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { $env:ANDROID_SDK_ROOT }
if (-not $pollarAndroidHome -or -not $env:POLLAR_ANDROID_CERT_SHA256) { throw 'Android verification configuration missing.' }
$pollarAapt = Get-ChildItem "$pollarAndroidHome/build-tools/*/aapt.exe" | Sort-Object FullName -Descending | Select-Object -First 1
$pollarSigner = Join-Path $pollarAapt.Directory.FullName 'apksigner.bat'
$pollarBadging = & $pollarAapt.FullName dump badging $pollarApk
$pollarBuild = $Version.Split('+')[1]
$pollarName = $Version.Split('+')[0]
if ($LASTEXITCODE -ne 0 -or -not ($pollarBadging -match "package: name='com.pollar.pollar_app' versionCode='$pollarBuild' versionName='$pollarName'")) { throw 'Android package/version mismatch.' }
$pollarCertificates = & $pollarSigner verify --print-certs $pollarApk
if ($LASTEXITCODE -ne 0 -or -not ($pollarCertificates -match ('certificate SHA-256 digest: ' + [regex]::Escape($env:POLLAR_ANDROID_CERT_SHA256)))) { throw 'Android signing identity mismatch.' }
$pollarHashes = Join-Path $pollarDist 'SHA256SUMS.txt'
@($pollarZip, $pollarApk) | ForEach-Object { '{0}  {1}' -f (Get-FileHash -LiteralPath $_ -Algorithm SHA256).Hash.ToLowerInvariant(), (Split-Path -Leaf $_) } | Set-Content -LiteralPath $pollarHashes -Encoding ascii
$pollarTag = "v$Version"
$pollarExisting = gh release view $pollarTag --repo luaanwp/pollar --json isDraft,targetCommitish 2>$null
if ($LASTEXITCODE -eq 0) {
  $pollarExisting = $pollarExisting | ConvertFrom-Json
  if (-not $pollarExisting.isDraft) { Write-Host 'Release already published; never replacing installed update artifacts.'; exit 0 }
  if ($pollarExisting.targetCommitish -cne $Commit) { throw 'Draft belongs to another commit.' }
} else {
  gh release create $pollarTag --repo luaanwp/pollar --target $Commit --title "Pollar $Version" --notes 'Atualização do Pollar para Windows e Android. Instale pelo botão de atualização no aplicativo; dados e identidade de acesso são preservados.' --draft
  if ($LASTEXITCODE -ne 0) { throw 'Could not create draft release.' }
}
gh release upload $pollarTag $pollarZip $pollarApk $pollarHashes --repo luaanwp/pollar --clobber
if ($LASTEXITCODE -ne 0) { throw 'Could not upload update packages; release remains draft.' }
$pollarReleaseApi = gh release view $pollarTag --repo luaanwp/pollar --json apiUrl --jq .apiUrl
if ($LASTEXITCODE -ne 0 -or $pollarReleaseApi -notmatch '^https://api\.github\.com/repos/luaanwp/pollar/releases/\d+$') { throw 'Could not locate the draft release ID.' }
# Drafts do not yet expose the final tag endpoint. Read by immutable release ID.
$pollarRemote = gh api $pollarReleaseApi | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'Could not verify uploaded packages.' }
if ($pollarRemote.tag_name -cne $pollarTag -or $pollarRemote.target_commitish -cne $Commit -or -not $pollarRemote.draft) { throw 'Unexpected draft release identity.' }
foreach ($pollarLocal in @($pollarZip, $pollarApk)) {
  $pollarAsset = @($pollarRemote.assets | Where-Object name -CEQ (Split-Path -Leaf $pollarLocal))
  $pollarDigest = 'sha256:' + (Get-FileHash -LiteralPath $pollarLocal -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($pollarAsset.Count -ne 1 -or $pollarAsset[0].state -cne 'uploaded' -or $pollarAsset[0].digest -cne $pollarDigest) { throw 'Uploaded integrity mismatch; release remains draft.' }
}
gh release edit $pollarTag --repo luaanwp/pollar --draft=false --latest
if ($LASTEXITCODE -ne 0) { throw 'Could not publish verified release.' }
