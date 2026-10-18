# Control a VEX AIM robot with an AI agent

Let an AI coding agent (**Goose**, **Claude Code**, or **Codex CLI**) drive your [VEX AIM](https://www.vexrobotics.com/aim)
robot: light it up, make it talk, read its sensors, look through its camera, and run your own ideas, just by
chatting. Everything runs on your laptop over the robot's USB cable. No VEXcode, no browser, no Wi-Fi setup, and
no programming tools to install by hand: your agent sets it all up.

## Quick start (about 5 minutes)

**You need:** a VEX AIM robot and its USB cable, a laptop, and one agent installed and signed in
([Goose](https://goose-docs.ai), [Claude Code](https://claude.com/claude-code), or
[Codex CLI](https://developers.openai.com/codex/cli)). The agent's AI model needs internet; the robot does not.

1. Plug the robot into your laptop with the USB cable and switch it on.
2. Open your agent and paste this prompt:

> Clone https://github.com/steveonjava/vex-aim-agent-workshop and follow its AGENTS.md to set up my VEX AIM robot (it is plugged in over USB). Install the skill and the vexaim tool for this agent. Tell me before you run anything that needs administrator/sudo access. When it's installed, run the diagnostic and tell me the robot's battery level, then tell me to start a new session so the skill is loaded.

3. Answer if it asks for permission (on Linux it asks once before using `sudo`).
4. When it says setup is done, **start a new session** of your agent (quit and reopen Goose, or start a new
   `claude` / `codex` session). Skills are loaded when a session starts.
5. Try it:

> Use the vex-aim skill. Run the diagnostic, set the robot's lights to blue for two seconds, then turn them off. Do not move it.

If the lights turn blue, you are done. Everything below is for the curious, for troubleshooting, and for
instructors.

## What can you ask it to do?

Once the skill is loaded the agent can run any Python on the robot. Ideas, easiest first:

- *"What is the robot's battery level and which way is it facing?"*
- *"Make the lights a rainbow that cycles through colours, then show a happy face and play a sound."*
- *"Take a photo with the robot's camera and tell me what you see."*
- *"Drive forward 5 cm slowly, then turn the lights green if it worked."* (clear the floor first)
- *"Look around with the camera and tell me if there is a ball in front of the robot."*
- *"Write me a little game or light show with the robot and run it."*

## Safety

The agent can make the robot move and there are no software speed or distance limits, so the safety is yours:

- Put the robot on a **clear, flat floor** (not a table edge) with room to move.
- Keep a hand near the **power switch**. If the robot misbehaves, switch it off.
- Start with **small, slow moves** and ask the agent to tell you before the robot moves.
- The camera sees your room. Don't send photos of people to an AI service without their permission.

## What the installer does (so nothing is a surprise)

`install.sh` (macOS/Linux) or `install.ps1` (Windows) does exactly this, and nothing else:

1. Downloads the prebuilt `vexaim` program for your computer from this repository's
   [Releases](https://github.com/steveonjava/vex-aim-agent-workshop/releases), and **checks its SHA-256 checksum**
   (it refuses to install if the check fails).
2. Copies the skill (`skill/vex-aim/`) and the program into `~/.agents/skills/vex-aim/` (Goose, Codex) and
   `~/.claude/skills/vex-aim/` (Claude Code). Those folders are the only places it writes.
3. Linux only, **with your permission**: installs a small udev rule (needs `sudo`) so the system's modem manager
   leaves the robot alone. See [docs/troubleshooting.md](docs/troubleshooting.md).
4. Runs `vexaim doctor` to check the robot connection.

Remove everything it installed with `sh install.sh --uninstall` (Windows: `install.ps1 -Uninstall`). It only removes
folders it created itself.

## Manual install (no agent needed)

```sh
git clone https://github.com/steveonjava/vex-aim-agent-workshop
cd vex-aim-agent-workshop
sh install.sh                       # macOS / Linux
# Windows PowerShell: powershell -ExecutionPolicy Bypass -File install.ps1
```

Useful options: `--agents goose|codex|claude|all`, `--dry-run`, `--uninstall`, `--udev` (Linux),
`--from-source` (build with Rust instead of downloading), `--help`.

## Does it work on my computer?

| Platform | Status |
|---|---|
| Linux x86_64 | **Tested with a real robot**: connection, commands, camera, unplug/replug recovery |
| macOS (Apple Silicon, Intel) | Built automatically by CI; **not yet tested with a real robot** |
| Windows x86_64 | Built automatically by CI; installer is experimental. The serial layer was fixed so it compiles on Windows and its I/O adapter is tested on Linux, but it is **not yet tested on real Windows** |
| Bluetooth | Not supported yet; USB only |

School-managed laptops may block downloaded programs. Ask your instructor about a loaner laptop. If you use
the Goose app from Flatpak on Linux, it cannot see USB devices without extra permissions; use the standard
Goose build or the CLI instead.

## Troubleshooting

Start with `vexaim doctor`; every failed check prints a `fix:` line. More help: [docs/troubleshooting.md](docs/troubleshooting.md).
Common ones: use the cable that came with the robot (some cables only charge), plug straight into the laptop,
close VEXcode or any serial monitor, and on Linux wait ~30 seconds after plugging in unless the udev rule is installed.

## How it works

The robot's USB port includes a MicroPython console and a camera. The `vexaim` tool sends your agent's Python code to
the console and returns what it prints; the camera shows up as an ordinary webcam. It is built on
[vexide/vex-v5-serial](https://github.com/vexide/vex-v5-serial) with two small patches. Details, evidence and known
limits: [docs/how-it-works.md](docs/how-it-works.md) and [docs/hardware-notes.md](docs/hardware-notes.md).
Instructors: [docs/instructors.md](docs/instructors.md).

## Repository map

| Path | What it is |
|---|---|
| `AGENTS.md` / `CLAUDE.md` | The step-by-step runbook your agent follows |
| `skill/vex-aim/` | The skill your agent loads: how to control the robot |
| `install.sh`, `install.ps1` | Installers (download + verify + copy) |
| `cli/` | Source of the `vexaim` tool (Rust) and the vendored, patched `vex-v5-serial` |
| `docs/` | Troubleshooting, how it works, hardware notes, instructor guide |
| `dev/` | Optional hardware and installer test scripts |

## License

Apache-2.0 (see [LICENSE](LICENSE)). Includes MIT-licensed code from vexide/vex-v5-serial; see [NOTICE.md](NOTICE.md).
VEX and AIM are trademarks of their owners; this is an independent project.
