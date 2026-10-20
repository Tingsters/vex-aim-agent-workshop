# VEX AIM agent workshop

Build robot ideas through ordinary prompts with Goose, Codex or Claude Code.
Ask it to move, react, play sounds, change lights, or take a photograph.

This repository contains the **workshop teaching skill and activities**. The
standalone [vexaim CLI](https://github.com/Tingsters/vexaim-cli) provides robot
communication, prebuilt binaries and a general-purpose robot skill.

## Start here

You need an agent installed and signed in, a VEX AIM, and a Windows x86_64,
Linux x86_64, Apple Silicon Mac or Intel Mac. USB and Bluetooth are supported.
No Rust, Python packages, VEXcode, saved robot project or special Wi-Fi is needed.
Your agent's model needs internet access; the robot does not need venue Wi-Fi.

Paste into your agent:

> Clone https://github.com/Tingsters/vex-aim-agent-workshop and follow AGENTS.md
> to install the workshop and the released vexaim CLI. Ask which connection I
> want if I haven't specified USB or Bluetooth. Check the robot without moving
> it and report its battery. Tell me before anything needs administrator access.

The installer installs the latest stable CLI release with its matching basic
skill, then adds this workshop's teaching skill. Start a **new agent session**
after installation so both skills can be discovered. Then try:

> Use the vex-aim-workshop skill. Make the robot's lights blue for two seconds.
> Do not move it.

For Bluetooth, tell the agent the exact robot name and keep VEXcode closed.
Pairing codes go into a masked local terminal, never into chat. The agent reuses
the connection across requests. If the robot sleeps, it needs switching on again.

## Explore

Try "spin in a circle", "make up a short dance", or an idea of your own.
Students do not need to learn CLI commands, identify their floor, arrange
calibration targets, or install developer tools. Before motion, clear the floor
and have someone near the power switch. Keep camera photographs local unless
you explicitly choose to share them.

The current turn default is conservative. Physical accuracy varies by surface;
automatic camera-based movement correction is not enabled. Software CI does not
prove hardware accuracy. [Current movement evidence](docs/workshop-motion.md).

## Manual installation

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
while the robot is off. Rerun to adopt the latest stable release; nothing updates
itself during a workshop. Close robot sessions before updating.

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
