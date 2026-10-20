# Agent runbook: set up the VEX AIM workshop

This repository provides the vex-aim-workshop teaching skill. The separately
maintained Tingsters/vexaim-cli project provides the executable and generic
vex-aim skill. Install both through this workshop's installer; students do not
need Rust, Python packages, VEXcode or a saved robot project.

## Install

1. Check the OS and architecture. Supported
   binaries are Windows x86_64, Linux x86_64, macOS Apple Silicon and macOS Intel.
2. No checkout is needed: on macOS/Linux run
   `curl -fsSL https://raw.githubusercontent.com/Tingsters/vex-aim-agent-workshop/main/install.sh | sh`.
   On Windows PowerShell 5.1 or newer run
   `irm https://raw.githubusercontent.com/Tingsters/vex-aim-agent-workshop/main/install.ps1 | iex`.
   From a checkout, `sh install.sh` or
   `powershell -ExecutionPolicy Bypass -File install.ps1` also works. Default
   agent selection is all (Goose/Codex and Claude). Select one only if requested.
3. The installer resolves the latest stable CLI release, verifies its installer,
   installs its matching executable/basic skill, then installs the teaching
   skill (downloaded with all its references when streamed). No robot is required during file installation. Never silently build
   from source when a download fails; see docs/troubleshooting.md.
4. Remember the exact `Tool:` path. The executable is inside vex-aim/bin, not
   vex-aim-workshop. Skills are under ~/.agents/skills and ~/.claude/skills.

## Verify without movement

Read the installed vex-aim SKILL.md before interacting with the robot. Use the
connection the student requested. Ask which transport they want only if unclear.
For Bluetooth, get the exact robot name, ask for power-on when needed, keep
VEXcode closed, and follow the basic skill's pairing/session workflow. Pairing
codes belong in masked local input, never chat or logs. Do not ask for a USB
reconnect when using Bluetooth.

For USB, make sure the AIM is switched on and connected with a data cable, then
run the installed executable's doctor. On Windows use `& "<Tool path>" doctor`.
Apply the reported fixes. On Linux only, ask before the installed basic skill's
udev helper uses sudo and explicitly tell the student to unplug/replug afterward.
Try at most three connection attempts, then explain what failed and what the
student should check. Do not invent a battery reading or claim unobserved success.

Report the actual battery/readiness result. Do not move motors or kicker during
setup. No firmware modifications or saved robot programs are needed.

## Finish

Explain that vex-aim provides robot control and vex-aim-workshop provides teaching.
Give the installed locations and executable path. Tell the student to start a
NEW agent session so both skills are discovered. Suggest:

> Use the vex-aim-workshop skill. Set the robot's lights blue for two seconds,
> then turn them off. Do not move it.

## Working on this project

Keep workshop activities and teaching guidance here. CLI implementation, command
syntax, transport troubleshooting, packaging and binary releases belong in
https://github.com/Tingsters/vexaim-cli. Workshop CI validates its wrappers and
skills against released binaries. Do not reintroduce a Rust workspace or a copied
generic skill. Follow skill-creator guidance when changing skills.

Movement requires a clear area, a person near the physical switch and an advance
announcement. Preserve readiness within an interaction; do not replay uncertain
movements. Keep photos, credentials and the student's Showtail trail local.
Never upload them without explicit consent. Do not change shell profiles or agent
settings. Ask before administrator actions or installing Rust.
