# Builds DLM for Windows x64: the app, the pinned dlm daemon inside it, a
# portable zip and an Inno Setup installer. Run from the repository root on
# Windows (PowerShell 7 or Windows PowerShell), with Flutter, Git Bash and
# Inno Setup (iscc) on the PATH.
#
#   tools/package_windows.ps1 -Version 1.0.0 [-OutDir dist]
#
# Signing is a separate step (signtool or Azure Trusted Signing) so that the
# same script makes unsigned test builds.
param(
  [Parameter(Mandatory = $true)][string]$Version,
  [string]$OutDir = 'dist',
  [string]$DaemonVersion = '',
  [string]$BuildNumber = '',
  [switch]$SkipBuild
)
$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
if (-not $DaemonVersion) { $DaemonVersion = (Get-Content packaging/daemon-version).Trim() }
$BuildName = ($Version -split '-')[0]
if (-not $BuildNumber) { $BuildNumber = (& git rev-list --count HEAD) }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$out = (Resolve-Path $OutDir).Path

if (-not $SkipBuild) {
  Push-Location apps/dlm_app
  flutter build windows --release --build-name $BuildName --build-number $BuildNumber
  if ($LASTEXITCODE -ne 0) { throw 'flutter build failed' }
  Pop-Location
}
$release = Join-Path $root 'apps/dlm_app/build/windows/x64/runner/Release'
if (-not (Test-Path (Join-Path $release 'dlm_app.exe'))) { throw "no build in $release" }

# The daemon goes where the app looks for it: bin\dlm.exe next to the app.
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("dlm-" + [guid]::NewGuid())
$env:DLM_OS = 'windows'; $env:DLM_ARCH = 'amd64'
$daemon = (& bash tools/fetch_daemon.sh $DaemonVersion ($tmp -replace '\\', '/')).Trim()
if ($LASTEXITCODE -ne 0) { throw 'could not fetch the daemon' }
New-Item -ItemType Directory -Force -Path (Join-Path $release 'bin') | Out-Null
Copy-Item $daemon (Join-Path $release 'bin/dlm.exe') -Force
Copy-Item LICENSE (Join-Path $release 'LICENSE.txt') -Force
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

# Portable zip.
$zip = Join-Path $out "DLM_${Version}_windows_x64.zip"
if (Test-Path $zip) { Remove-Item $zip }
Compress-Archive -Path (Join-Path $release '*') -DestinationPath $zip

# Installer.
iscc "/DAppVersion=$Version" "/DSourceDir=$release" "/DOutputDir=$out" "/DRootDir=$root" packaging/windows/dlm.iss
if ($LASTEXITCODE -ne 0) { throw 'iscc failed' }

foreach ($f in @($zip, (Join-Path $out "DLM_${Version}_windows_x64_setup.exe"))) {
  $hash = (Get-FileHash $f -Algorithm SHA256).Hash.ToLower()
  "$hash  $(Split-Path $f -Leaf)" | Set-Content -Encoding ascii "$f.sha256"
  Write-Output $f
}
