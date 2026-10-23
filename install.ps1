<# Install the latest stable vexaim CLI/basic skill, then this workshop's skill.
   -FromDir RELEASE_ASSETS supports offline use; -BaseUrl URL supports fixtures.
   -Uninstall removes only the workshop skill, preserving the shared CLI. #>
[CmdletBinding()]
param([string]$Agents='all', [string]$FromDir='', [string]$BaseUrl='',
  [string]$TargetHome=$HOME, [switch]$DryRun, [switch]$Uninstall,
  [switch]$NoDoctor, [switch]$Force)
$ErrorActionPreference='Stop'
$Repo='https://github.com/Tingsters/vexaim-cli'
$Marker='.vexaim-workshop-installed'
$source=''
if ($PSScriptRoot) {
  $localSource=Join-Path $PSScriptRoot 'skill/vex-aim-workshop'
  if (Test-Path (Join-Path $localSource 'SKILL.md')) { $source=$localSource }
}
function Remove-Within([string]$path,[string]$root) {
  $absolute=[IO.Path]::GetFullPath($path)
  $prefix=[IO.Path]::GetFullPath($root).TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar
  if (-not $absolute.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw "unexpected removal: $absolute" }
  if (Test-Path -LiteralPath $absolute) { Remove-Item -LiteralPath $absolute -Recurse -Force }
}
$destinations=@()
foreach ($a in ($Agents -split ',')) {
  switch ($a.Trim().ToLower()) {
    { $_ -in 'goose','codex' } { $destinations+=Join-Path $TargetHome '.agents/skills/vex-aim-workshop' }
    'claude' { $destinations+=Join-Path $TargetHome '.claude/skills/vex-aim-workshop' }
    'all' { $destinations+=Join-Path $TargetHome '.agents/skills/vex-aim-workshop'; $destinations+=Join-Path $TargetHome '.claude/skills/vex-aim-workshop' }
    default { throw "unknown agent: $a" }
  }
}
$destinations=@($destinations | Select-Object -Unique)
foreach ($d in $destinations) {
  if ((Test-Path -LiteralPath $d) -and (Get-Item -LiteralPath $d -Force).Attributes.HasFlag([IO.FileAttributes]::ReparsePoint)) { throw "refusing linked skill folder: $d" }
  if ($Uninstall) {
    if (Test-Path (Join-Path $d $Marker)) {
      if ($DryRun) { Write-Host "would remove $d" } else { Remove-Within $d (Split-Path $d -Parent) }
    }
  } elseif ((Test-Path $d) -and -not (Test-Path (Join-Path $d $Marker)) -and -not $Force) { throw "$d was not installed by this script; move it away or use -Force" }
}
if ($Uninstall) { Write-Host 'Shared vexaim CLI/basic skill left installed.'; exit 0 }
if ($DryRun) { Write-Host "Would install latest stable CLI/basic skill and workshop skill for $Agents under $TargetHome. No changes."; exit 0 }
$temporary=Join-Path ([IO.Path]::GetTempPath()) ('vexaim-workshop-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temporary | Out-Null
try {
  if (-not $source) {
    $workshopArchive=Join-Path $temporary 'workshop.zip'
    Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/Tingsters/vex-aim-agent-workshop/archive/refs/heads/main.zip' -OutFile $workshopArchive
    Expand-Archive -LiteralPath $workshopArchive -DestinationPath (Join-Path $temporary 'workshop')
    $source=Join-Path $temporary 'workshop/vex-aim-agent-workshop-main/skill/vex-aim-workshop'
    if (-not (Test-Path (Join-Path $source 'SKILL.md'))) { throw 'downloaded workshop is missing its teaching skill' }
  }
  if ($FromDir) {
    Copy-Item (Join-Path $FromDir 'VERSION'),(Join-Path $FromDir 'SHA256SUMS'),(Join-Path $FromDir 'install.ps1') $temporary
  } else {
    $discovery=$BaseUrl
    if (-not $discovery) { $discovery="$Repo/releases/latest/download" }
    Invoke-WebRequest -UseBasicParsing -Uri "$discovery/VERSION" -OutFile (Join-Path $temporary 'VERSION')
  }
  $version=(Get-Content -Raw (Join-Path $temporary 'VERSION')).Trim()
  if ($version -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$') { throw 'invalid CLI release version' }
  if (-not $FromDir) {
    $release=$BaseUrl
    if (-not $release) { $release="$Repo/releases/download/v$version" }
    Invoke-WebRequest -UseBasicParsing -Uri "$release/install.ps1" -OutFile (Join-Path $temporary 'install.ps1')
    Invoke-WebRequest -UseBasicParsing -Uri "$release/SHA256SUMS" -OutFile (Join-Path $temporary 'SHA256SUMS')
  }
  $lines=@(Get-Content (Join-Path $temporary 'SHA256SUMS') | Where-Object { $_ -match '^[a-fA-F0-9]{64}\s+install\.ps1$' })
  if ($lines.Count -ne 1) { throw 'install.ps1 is not listed in SHA256SUMS exactly once' }
  if (($lines[0] -split '\s+')[0] -ne (Get-FileHash -Algorithm SHA256 (Join-Path $temporary 'install.ps1')).Hash) { throw 'CLI installer checksum mismatch; no skills changed' }
  $arguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $temporary 'install.ps1'),'-Agents',$Agents,'-TargetHome',$TargetHome,'-Version',$version)
  if ($FromDir) { $arguments+=@('-FromDir',(Resolve-Path -LiteralPath $FromDir).Path) }
  elseif ($BaseUrl) { $arguments+=@('-BaseUrl',$BaseUrl) }
  if ($Force) { $arguments+='-Force' }
  $shell=(Get-Process -Id $PID).Path
  & $shell @arguments
  if ($LASTEXITCODE -ne 0) { throw 'CLI installation failed; workshop skill was not installed' }
  $tool=Join-Path (Split-Path $destinations[0] -Parent) 'vex-aim/bin/vexaim.exe'
  $behaviorHelp=& $tool exec --help
  if ($LASTEXITCODE -ne 0 -or ($behaviorHelp -join "`n") -notmatch '--behaviors') {
    throw 'This workshop requires vexaim 0.5.0+ with exec --behaviors; update the CLI release assets. Teaching skill was not installed.'
  }
  foreach ($d in $destinations) {
    $parent=Split-Path $d -Parent
    $stage="$d.stage-$([guid]::NewGuid().ToString('N'))"
    $backup="$d.backup-$([guid]::NewGuid().ToString('N'))"
    foreach ($p in @($d,$stage,$backup)) {
      if (-not [IO.Path]::GetFullPath($p).StartsWith([IO.Path]::GetFullPath($parent).TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)) { throw 'unexpected skill move path' }
    }
    $committed=$false
    try {
      Copy-Item -LiteralPath $source -Destination $stage -Recurse
      Set-Content -LiteralPath (Join-Path $stage $Marker) -Value "workshop; vexaim $version" -Encoding ASCII
      if (Test-Path -LiteralPath $d) { Move-Item -LiteralPath $d -Destination $backup }
      try { Move-Item -LiteralPath $stage -Destination $d }
      catch { if (Test-Path -LiteralPath $backup) { Move-Item -LiteralPath $backup -Destination $d }; throw }
      $committed=$true
      Write-Host "Installed workshop skill: $d"
    } finally {
      Remove-Within $stage $parent
      if ($committed) { Remove-Within $backup $parent }
    }
  }
  Write-Host 'Start a NEW agent session to load vex-aim and vex-aim-workshop. Robot readiness is checked afterward using the selected transport.'
} finally { Remove-Within $temporary ([IO.Path]::GetTempPath()) }
