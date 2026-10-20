<#
.SYNOPSIS
  Installs the `vex-aim` agent skill and the `vexaim` robot tool (Windows).

.DESCRIPTION
  powershell -ExecutionPolicy Bypass -File install.ps1                 # Goose, Codex, Claude Code (user-level)
  powershell -ExecutionPolicy Bypass -File install.ps1 -Agents claude  # goose | codex | claude | all
  ... -DryRun            show what would happen, change nothing
  ... -Uninstall         remove what this script installed
  ... -FromSource        build with cargo instead of downloading
  ... -FromDir DIR       use vexaim-windows-x86_64.zip + SHA256SUMS from DIR
  ... -BaseUrl URL       download from URL instead of the GitHub release
  ... -TargetHome DIR    install under DIR instead of your profile (testing)

  Changes only: %USERPROFILE%\.agents\skills\vex-aim (Goose, Codex) and %USERPROFILE%\.claude\skills\vex-aim (Claude Code).
#>
[CmdletBinding()]
param(
  [string]$Agents = "all",
  [string]$FromDir = "",
  [string]$BaseUrl = "https://github.com/Tingsters/vex-aim-agent-workshop/releases/latest/download",
  [string]$TargetHome = $HOME,
  [switch]$FromSource,
  [switch]$DryRun,
  [switch]$Uninstall,
  [switch]$NoDoctor,
  [switch]$Force
)
$ErrorActionPreference = "Stop"
$Marker = ".vexaim-installed"
$MinimumVersion = [version]"0.1.1"  # 0.1.0 leaves DTR low: Windows opens the port but gets no REPL.
$SkillSrc = Join-Path $PSScriptRoot "skill\vex-aim"

function Say($m)  { Write-Host "==> $m" }
function Warn($m) { Write-Warning $m }
function Die($m)  { Write-Host "ERROR: $m" -ForegroundColor Red; exit 1 }

# --- which skill folders -----------------------------------------------------------------
$agentsDir  = Join-Path $TargetHome ".agents\skills\vex-aim"
$claudeDir  = Join-Path $TargetHome ".claude\skills\vex-aim"
$wantDirs = @()
foreach ($a in ($Agents -split ",")) {
  switch ($a.Trim().ToLower()) {
    "goose"  { $wantDirs += $agentsDir }
    "codex"  { $wantDirs += $agentsDir }
    "claude" { $wantDirs += $claudeDir }
    "all"    { $wantDirs += $agentsDir; $wantDirs += $claudeDir }
    default  { Die "unknown agent '$a' (use goose, codex, claude or all)" }
  }
}
$wantDirs = $wantDirs | Select-Object -Unique

function Remove-SkillFolder([string]$path) {
  # Only delete one of the two resolved skill destinations under the selected home.
  $absolute = [IO.Path]::GetFullPath($path)
  $allowed = @([IO.Path]::GetFullPath($agentsDir), [IO.Path]::GetFullPath($claudeDir))
  if ($absolute -notin $allowed) { Die "refusing to remove unexpected path: $absolute" }
  Remove-Item -LiteralPath $absolute -Recurse -Force
}

# --- uninstall ---------------------------------------------------------------------------
if ($Uninstall) {
  foreach ($d in @($agentsDir, $claudeDir)) {
    if (Test-Path (Join-Path $d $Marker)) {
      if ($DryRun) { Say "would remove $d" } else { Remove-SkillFolder $d; Say "removed $d" }
    } elseif (Test-Path $d) { Warn "$d exists but was not installed by this script: left alone" }
  }
  exit 0
}

# --- platform ----------------------------------------------------------------------------
$arch = $env:PROCESSOR_ARCHITECTURE
Say "platform: Windows $arch"
if (-not (Test-Path $SkillSrc)) { Die "run this script from a clone of the repository (missing $SkillSrc)" }
if ($arch -ne "AMD64" -and -not $FromSource) { Die "no prebuilt binary for Windows $arch. Re-run with -FromSource (needs Rust: https://rustup.rs)" }
$Archive = "vexaim-windows-x86_64.zip"

if ($DryRun) {
  if ($FromSource)    { Say "would build from source: cargo build --release --manifest-path cli\Cargo.toml" }
  elseif ($FromDir)   { Say "would use $FromDir\$Archive (verifying SHA256SUMS)" }
  else                { Say "would download $BaseUrl/$Archive and $BaseUrl/SHA256SUMS and verify the checksum" }
  foreach ($d in $wantDirs) { Say "would install skill + bin\vexaim.exe into $d" }
  Say "dry run: nothing changed"
  exit 0
}

$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("vexaim-install-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $Tmp | Out-Null
try {
  function Verify-And-Extract($dir) {
    $line = Get-Content (Join-Path $dir "SHA256SUMS") | Where-Object { $_ -match ([regex]::Escape($Archive) + '$') } | Select-Object -First 1
    if (-not $line) { Die "$Archive is not listed in SHA256SUMS: refusing to install" }
    $want = ($line -split '\s+')[0].ToLower()
    $got  = (Get-FileHash -Algorithm SHA256 (Join-Path $dir $Archive)).Hash.ToLower()
    if ($want -ne $got) { Die "checksum mismatch for $Archive (expected $want, got $got): refusing to install" }
    Say "checksum OK"
    Expand-Archive -Path (Join-Path $dir $Archive) -DestinationPath $Tmp -Force
  }

  function Build-FromSource {
    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) { Die "cargo not found. Install Rust from https://rustup.rs (ask the student first), then re-run with -FromSource" }
    Say "building from source (a few minutes the first time)"
    & cargo build --locked --release --manifest-path (Join-Path $PSScriptRoot "cli\Cargo.toml")
    if ($LASTEXITCODE -ne 0) { Die "build failed" }
    Copy-Item (Join-Path $PSScriptRoot "cli\target\release\vexaim.exe") (Join-Path $Tmp "vexaim.exe")
  }

  if ($FromSource) { Build-FromSource }
  elseif ($FromDir) { Say "using local files in $FromDir"; Verify-And-Extract $FromDir }
  else {
    Say "downloading $Archive"
    try {
      Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl/$Archive" -OutFile (Join-Path $Tmp $Archive)
      Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl/SHA256SUMS" -OutFile (Join-Path $Tmp "SHA256SUMS")
      $downloaded = $true
    } catch { $downloaded = $false }
    if ($downloaded) { Verify-And-Extract $Tmp }
    elseif (Get-Command cargo -ErrorAction SilentlyContinue) { Warn "download failed; falling back to building from source with your existing Rust toolchain"; Build-FromSource }
    else { Die "download failed (offline, or no release published yet?) and Rust is not installed. Options: check the internet connection and retry; or install Rust (https://rustup.rs) and re-run with -FromSource" }
  }

  $exe = Join-Path $Tmp "vexaim.exe"
  try { $ver = & $exe --version; $versionExit = $LASTEXITCODE } catch { Die "the vexaim binary does not run on this machine (blocked by SmartScreen/antivirus/policy? see docs/troubleshooting.md)" }
  if ($versionExit -ne 0 -or "$ver" -notmatch '^vexaim (\d+\.\d+\.\d+)(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$') { Die "the vexaim binary did not return a supported version: $ver" }
  if ([version]$Matches[1] -lt $MinimumVersion) {
    Die "vexaim $MinimumVersion or newer is required on Windows: 0.1.0 has a DTR bug that leaves the Python REPL silent. No skill folders changed. Use the corrected release, or -FromSource with an existing Rust/MSVC toolchain."
  }
  Say "$ver runs"

  # --- install ---------------------------------------------------------------------------
  $installed = @()
  foreach ($d in $wantDirs) {
    if ((Test-Path $d) -and -not (Test-Path (Join-Path $d $Marker)) -and -not $Force) {
      Die "$d already exists and was not installed by this script. Move it away or re-run with -Force"
    }
    if (Test-Path $d) { Remove-SkillFolder $d }
    New-Item -ItemType Directory -Path (Join-Path $d "bin") -Force | Out-Null
    Copy-Item -Recurse -Force (Join-Path $SkillSrc "*") $d
    Copy-Item $exe (Join-Path $d "bin\vexaim.exe")
    Set-Content -Path (Join-Path $d $Marker) -Value ("installed by vex-aim-agent-workshop install.ps1 on " + (Get-Date).ToUniversalTime().ToString("o"))
    Say "installed skill + tool: $d"
    $installed += $d
  }

  $first = $installed[0]
  if (-not $NoDoctor) {
    Say "robot check (plug the AIM in with its USB cable and turn it on)"
    & (Join-Path $first "bin\vexaim.exe") doctor
    if ($LASTEXITCODE -eq 0) { Say "robot ready" } else { Warn "robot not ready yet. The install itself is fine; see docs\troubleshooting.md for the 'fix:' lines above" }
  }
  Say "DONE. Tool: $(Join-Path $first 'bin\vexaim.exe')"
  Say "NEXT: start a NEW session of your agent (Goose / Codex / Claude Code) so it loads the vex-aim skill"
} finally {
  $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
  $tempPath = [IO.Path]::GetFullPath($Tmp)
  if ($tempPath.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -and
      [IO.Path]::GetFileName($tempPath) -match '^vexaim-install-[a-f0-9]{32}$') {
    Remove-Item -LiteralPath $tempPath -Recurse -Force -ErrorAction SilentlyContinue
  }
}
exit 0
