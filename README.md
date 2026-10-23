# VEX AIM agent workshop

Build robot ideas through ordinary prompts with Goose, Codex or Claude Code.
Ask it to move, react, play sounds, change lights, or take a photograph.

CLI 0.5 adds shared, composable search, pickup and tag-delivery helpers through
`exec --behaviors`. The workshop selects targets and effects; the CLI owns
vision feedback, magnetic contact, deadlines and recovery. This workshop
requires 0.5.1+ and its matching basic skill. Workshop routines use brisk,
contact-based pickup and paused native tag acquisition in one execution, without
laptop camera checks between steps. The generic skill retains a vision-verified
diagnostic mode for testing.

CLI 0.4 added persistent Bluetooth sessions, automatic same-robot recovery and
quick program replacement. It includes pairing with `--code-stdin`, native
strafing, vector motion, device commands and camera observations. With its
matching skill, an agent can compose a whole behavior in one robot script. Native
AI Vision handles kit-target feedback on the robot; the agent opens a photograph
when a task needs scene understanding, then plans a complete useful sequence.
See the [visual activity guide](skill/vex-aim-workshop/references/seeing-and-acting.md).
Students continue using ordinary prompts; no additional vision API account is
needed. Rerun the installer below to update the CLI and both skills; older
versions before 0.4 do not provide the persistent workshop/retry policy.

This repository contains the **workshop teaching skill and activities**. The
standalone [vexaim CLI](https://github.com/Tingsters/vexaim-cli) provides robot
communication, prebuilt binaries and a general-purpose robot skill.

## Start here

You need an agent installed and signed in, a VEX AIM, and a Windows x86_64,
Linux x86_64, Apple Silicon Mac or Intel Mac. USB and Bluetooth are supported.
No Rust, Python packages, VEXcode, saved robot project or special Wi-Fi is needed.
Your agent's model needs internet access; the robot does not need venue Wi-Fi.

Paste the command for your computer into a terminal. No download, extraction
or Git clone is needed first. This installs the CLI and **both skills**.

**Windows x86_64 — PowerShell 5.1 or newer:**

```powershell
irm https://raw.githubusercontent.com/Tingsters/vex-aim-agent-workshop/main/install.ps1 | iex
```

**macOS — Apple Silicon or Intel (Terminal):**

```sh
curl -fsSL https://raw.githubusercontent.com/Tingsters/vex-aim-agent-workshop/main/install.sh | sh
```

**Linux x86_64 — terminal:**

```sh
curl -fsSL https://raw.githubusercontent.com/Tingsters/vex-aim-agent-workshop/main/install.sh | sh
```

The installer installs the latest stable CLI release with its matching basic
skill, then adds this workshop's teaching skill. It verifies the released CLI
installer and binary archive against SHA-256 checksums. Installation requires no
administrator access and can finish while the robot is off. Linux USB setup may
later need an approved udev rule. Start a **new agent session**
after installation so both skills can be discovered. Then try:

> Use the vex-aim-workshop skill. Make the robot's lights blue for two seconds.
> Do not move it.

For Bluetooth, tell the agent the exact robot name and keep VEXcode closed.
For pairing, the agent asks you for the four-digit code on the robot's screen
and pairs for you, so you do not open a terminal. The code is short-lived and
only works within Bluetooth range, but it will appear in the agent's transcript.
The agent keeps a background connection across requests, new chats and workshop
breaks, and automatically recovers ordinary link failures without replaying motion.
A student can say "try again" or request a new activity to replace the old program.
For another computer, ask the current agent to hand over the robot first; pairing
is remembered. A powered-off robot still needs its power switch.

See [connection and retry guidance](skill/vex-aim-workshop/references/connection-and-retries.md)
and [magnetic cargo delivery](skill/vex-aim-workshop/references/cargo-and-tags.md).
Two-computer Bluetooth handoff requires separate hardware verification.

## Explore

Try "spin in a circle", "make up a short dance", or an idea of your own.
Students do not need to learn CLI commands, identify their floor, arrange
calibration targets, or install developer tools. Set up a floor/play area once,
then ask for complete behaviors: "find a ball, kick it and celebrate" or
"make a dance with sideways moves and lights". The agent announces and acts
without repeated permission or observation checks. Ordinary bumps are part of
play. Keep camera photographs local unless you explicitly choose to share them.

The workshop explicitly chooses brisk speeds: 150 mm/s and 90 degrees/s, adjusting
for the task. The CLI's general defaults stay unchanged. Native vision can guide
movement inside a script; laptop photographs support agent planning rather than
live streaming. Physical accuracy varies by surface, and simulation does not
prove hardware accuracy. [Movement guidance](docs/workshop-motion.md).

## Installer options and offline installation

From a checkout, run:

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

```sh
sh install.sh
```

Both skills are installed under `~/.agents/skills/` for Goose/Codex and
`~/.claude/skills/` for Claude Code:

| Skill | Purpose |
|---|---|
| `vex-aim` | General robot control; contains `bin/vexaim` or `bin/vexaim.exe` |
| `vex-aim-workshop` | Workshop teaching; refers to the basic skill |

Use `--agents claude` / `-Agents claude` for one agent, or `--dry-run` /
`-DryRun` to preview. `--from-dir DIR` / `-FromDir DIR` accepts a downloaded CLI
release's archives, installers, VERSION and SHA256SUMS. Installation can finish
while the robot is off. Rerun your computer's one-line command to adopt the
latest stable release and current workshop skill; nothing updates
itself during a workshop. Close robot sessions before updating.

With the one-line installer, pass Unix options using `curl -fsSL
<installer-URL> | sh -s -- --agents claude`, or PowerShell options using
`& ([scriptblock]::Create((irm <installer-URL>))) -Agents claude`. Use the URL
for your platform above. You can open that URL or download the script first
to review it before running it. A downloaded workshop checkout plus the CLI
release assets supports installation without internet access.

`--uninstall` / `-Uninstall` removes the workshop skill only. The shared CLI and
basic skill remain available for other projects. Build-from-source instructions
live in the CLI repository rather than this workshop.

## Further reading

- [Instructor guide](docs/instructors.md)
- [Optional activity ideas](skill/vex-aim-workshop/references/activities.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Standalone CLI downloads](https://tingsters.github.io/vexaim-cli/)
- [CLI source and hardware evidence](https://github.com/Tingsters/vexaim-cli)

This project uses Showtail for a local record of the student's prompts and work.
Follow the project's capture instructions; keep the trail and photographs local.
