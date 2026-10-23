<# Workshop installation integration tests. Needs complete native CLI release assets.
   Run with both Windows PowerShell 5.1 and PowerShell 7. No Rust or robot. #>
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$AssetsDir)
$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot -Parent
$assets=(Resolve-Path -LiteralPath $AssetsDir).Path
$root=Join-Path $repo 'dist/workshop-tests'
$work=Join-Path $root ([guid]::NewGuid().ToString('N'))
$shell=(Get-Process -Id $PID).Path
$passed=0
New-Item -ItemType Directory -Path $work -Force | Out-Null
function Check([bool]$condition,[string]$message) {
  if (-not $condition) { throw "FAIL: $message" }
  $script:passed++; Write-Host "PASS: $message"
}
function Install([string]$target,[string[]]$options,[string]$failure='') {
  $previous=$ErrorActionPreference
  try {
    $ErrorActionPreference='Continue'
    $output=& $shell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repo 'install.ps1') -TargetHome $target @options 2>&1
    $code=$LASTEXITCODE
  } finally { $ErrorActionPreference=$previous }
  if ($failure) { Check ($code -ne 0 -and ($output -join "`n") -match $failure) "refused: $failure" }
  elseif ($code -ne 0) { throw "installation failed: $($output -join "`n")" }
}
try {
  $target=Join-Path $work 'home with spaces'
  Install $target @('-DryRun','-FromDir','not-a-real-directory')
  Check (-not (Test-Path $target)) 'dry run writes nothing and needs no download'
  $oldAssets=Join-Path $work 'old-assets'
  Copy-Item -LiteralPath $assets -Destination $oldAssets -Recurse
  '0.5.1' | Set-Content -LiteralPath (Join-Path $oldAssets 'VERSION')
  Install $target @('-FromDir',$oldAssets) 'requires vexaim 0.5.2'
  Check (-not (Test-Path $target)) 'old behavior release creates neither skill'
  Install $target @('-FromDir',$assets)
  foreach ($agent in @('.agents','.claude')) {
    $base=Join-Path $target "$agent/skills"
    Check ((Test-Path "$base/vex-aim/SKILL.md") -and (Test-Path "$base/vex-aim/bin/vexaim.exe")) "$agent has released CLI/basic skill"
    Check (Test-Path "$base/vex-aim/scripts/pair.ps1") "$agent has the matching Windows pairing bridge"
    $sessionHelp = & "$base/vex-aim/bin/vexaim.exe" session start --help
    Check (($sessionHelp -join "`n") -match '--persistent' -and ($sessionHelp -join "`n") -match '--takeover') "$agent CLI supports persistent sessions and program replacement"
    $behaviorHelp=& "$base/vex-aim/bin/vexaim.exe" exec --help
    Check (($behaviorHelp -join "`n") -match '--behaviors') "$agent CLI supplies the shared behavior controller"
    Check ((Test-Path "$base/vex-aim-workshop/SKILL.md") -and -not (Test-Path "$base/vex-aim-workshop/bin")) "$agent has a separate teaching skill"
    foreach ($reference in (Get-ChildItem -LiteralPath (Join-Path $repo 'skill/vex-aim-workshop/references') -File)) {
      $installedReference=Join-Path "$base/vex-aim-workshop/references" $reference.Name
      Check ((Test-Path $installedReference) -and ((Get-FileHash -Algorithm SHA256 $installedReference).Hash -eq (Get-FileHash -Algorithm SHA256 $reference.FullName).Hash)) "$agent installs matching $($reference.Name)"
    }
    $version=& "$base/vex-aim/bin/vexaim.exe" --version
    Check ("$version" -eq "vexaim $((Get-Content -Raw (Join-Path $assets 'VERSION')).Trim())") "$agent executable matches release"
  }
  Install $target @('-FromDir',$assets)
  Check (Test-Path "$target/.agents/skills/vex-aim-workshop/.vexaim-workshop-installed") 'repeat installation works'
  $single=Join-Path $work 'single'
  Install $single @('-FromDir',$assets,'-Agents','claude')
  Check ((Test-Path "$single/.claude/skills/vex-aim-workshop/SKILL.md") -and -not (Test-Path "$single/.agents")) 'single-agent choice applies to both skills'
  $streamed=Join-Path $work 'streamed home'
  # ScriptBlock.Create, like irm | iex, has no source-file directory. This
  # exercises downloading the complete teaching skill without a checkout.
  & ([scriptblock]::Create((Get-Content -Raw (Join-Path $repo 'install.ps1')))) -TargetHome $streamed -FromDir $assets
  Check ((Test-Path "$streamed/.agents/skills/vex-aim/bin/vexaim.exe") -and (Test-Path "$streamed/.claude/skills/vex-aim-workshop/references/activities.md")) 'streamed PowerShell installs binary and downloaded teaching references'
  $bad=Join-Path $work 'bad'
  Copy-Item -LiteralPath $assets -Destination $bad -Recurse
  Add-Content -LiteralPath (Join-Path $bad 'install.ps1') -Value '# tampered'
  $rejected=Join-Path $work 'rejected'
  Install $rejected @('-FromDir',$bad) 'installer checksum mismatch'
  Check (-not (Test-Path $rejected)) 'bad installer creates neither skill'
  Copy-Item -LiteralPath (Join-Path $assets 'install.ps1') -Destination $bad -Force
  $stream=[IO.File]::OpenWrite((Join-Path $bad 'vexaim-windows-x86_64.zip'))
  try { $null=$stream.Seek(0,[IO.SeekOrigin]::End); $stream.WriteByte(42) } finally { $stream.Dispose() }
  Install $rejected @('-FromDir',$bad) 'CLI installation failed|checksum mismatch'
  Check (-not (Test-Path "$rejected/.agents/skills/vex-aim-workshop")) 'failed CLI install never installs teaching skill'
  $foreign=Join-Path $work 'foreign'
  New-Item -ItemType Directory -Path "$foreign/.agents/skills/vex-aim-workshop" -Force | Out-Null
  'keep' | Set-Content "$foreign/.agents/skills/vex-aim-workshop/SKILL.md"
  Install $foreign @('-FromDir',$assets) 'not installed by this script'
  Install $foreign @('-Uninstall')
  Check ((Get-Content "$foreign/.agents/skills/vex-aim-workshop/SKILL.md") -eq 'keep') 'unmarked teaching skill survives install/uninstall'
  Install $target @('-Uninstall','-DryRun')
  Check (Test-Path "$target/.agents/skills/vex-aim-workshop/SKILL.md") 'uninstall dry run preserves teaching skill'
  Install $target @('-Uninstall')
  foreach ($agent in @('.agents','.claude')) {
    Check (-not (Test-Path "$target/$agent/skills/vex-aim-workshop")) "$agent teaching skill removed"
    Check (Test-Path "$target/$agent/skills/vex-aim/bin/vexaim.exe") "$agent shared CLI retained"
  }
  Write-Host "$passed workshop assertions passed ($($PSVersionTable.PSVersion))"
} finally {
  $absolute=[IO.Path]::GetFullPath($work)
  if (-not $absolute.StartsWith([IO.Path]::GetFullPath($root).TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)) { throw 'unexpected test cleanup path' }
  Remove-Item -LiteralPath $absolute -Recurse -Force
}
