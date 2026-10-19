# Agent runbook: set up a VEX AIM robot for this student

You are an AI coding agent (Goose, Claude Code, Codex, or similar). The student asked you to set up their
**VEX AIM robot** so you can control it. This file is your complete procedure. Follow it in order, run the
commands yourself, and report what actually happened. Do not skip verification.

What you are installing: a **skill** (`vex-aim`, instructions for you) and a small **tool** (`vexaim`, a
prebuilt program that sends MicroPython to the robot over USB and can take a camera photo). Students do **not**
need Rust, Python packages, VEXcode, a browser or special Wi-Fi.

## Ground rules

- Work from this repository's root (the folder containing this file). If you have not cloned it yet:
  `git clone https://github.com/Tingsters/vex-aim-agent-workshop` and `cd` into it.
- Change only what this runbook says: the skill folders listed below. Do not edit agent settings, shell profiles
  or other config.
- **Ask the student before anything that needs administrator rights (`sudo`)**, and before installing Rust.
  Say what it does in one sentence first.
- The robot may move when you later run programs on it. During setup, **do not move it**.
- If a step fails, read `docs/troubleshooting.md`, fix it if it is safe and in scope, otherwise tell the student
  exactly what failed and what they can do. Never claim success you did not observe.

## Step 1: find out the platform

Run `uname -sm` (macOS/Linux) or check `$env:OS` / `$PSVersionTable` (Windows). Supported:

| Platform | Installer | Status |
|---|---|---|
| Linux x86_64 | `sh install.sh` | tested with a real robot |
| macOS (Apple Silicon or Intel) | `sh install.sh` | built by CI, **not yet tested** with a robot (the serial layer needed a Windows fix, see `cli/vendor/README.md`) |
| Windows x86_64 | `powershell -ExecutionPolicy Bypass -File install.ps1` | built by CI, **not yet tested** with a robot (the serial layer needed a Windows fix, see `cli/vendor/README.md`) |

On other platforms use `--from-source` (macOS/Linux) / `-FromSource` (Windows); that needs Rust, so ask first.

## Step 2: run the installer

First make sure the robot is **plugged in over USB and switched on** (the installer finishes with a robot check;
if it is not ready yet that is only a warning, not a failed install).

The installer needs only tools every macOS/Linux install has: `sh`, `curl` or `wget`, `tar`, and `sha256sum` or
`shasum`. On Windows it needs PowerShell 5.1 or newer. If one is missing, tell the student which.

macOS / Linux:

```
sh install.sh
```

Windows (PowerShell):

```
powershell -ExecutionPolicy Bypass -File install.ps1
```

By default it installs for all three agents, which is the recommended choice (students often use more than one,
and it costs about 1 MB per agent). Install for just your own agent only if the student asks:
`--agents goose`, `--agents codex` or `--agents claude` (Windows: `-Agents claude`). You can preview with
`--dry-run` (`-DryRun`).

**Remember the path:** the installer ends with a line `Tool: <path>`. Use exactly that path for `vexaim` in the
steps below (it differs with `--agents`: `~/.claude/skills/vex-aim/bin/vexaim` for Claude Code,
`~/.agents/skills/vex-aim/bin/vexaim` for Goose/Codex/default).

It downloads the prebuilt `vexaim` for this platform from this repo's GitHub release, **verifies its SHA-256
checksum** (and refuses to install on a mismatch), then copies the skill and the tool into:

- `~/.agents/skills/vex-aim/`  (Goose and Codex)
- `~/.claude/skills/vex-aim/`  (Claude Code; Goose also reads this)

Each contains `SKILL.md`, `references/`, and `bin/vexaim` (`bin\vexaim.exe` on Windows).
If the download fails and a Rust toolchain is already installed, it builds from source instead. If there is no
Rust and no download, it stops with a message: tell the student, and offer to install Rust from
https://rustup.rs only if they agree, then re-run with `--from-source`.

## Step 3 (Linux only): the udev rule

**Skip this step if the installer printed `udev rule already installed`.** Otherwise: on Linux, ModemManager grabs new USB serial devices for ~25 seconds and can corrupt the robot's console, which
makes the robot flaky after every plug-in. A one-time udev rule fixes it (it only matches the AIM, USB
`2888:0700`). Ask the student before running it, for example:

> "On Linux the system's modem manager can disturb the robot's USB connection for about 25 seconds after every
> plug-in. I'd like to install a small udev rule that stops that; it only affects the VEX AIM (USB 2888:0700).
> It needs administrator access (sudo), so you may have to type your password. OK to go ahead?"

If they agree, from the repository root run (this works whichever agents you installed for):

```
sh install.sh --udev
```

It uses `sudo`; the student may need to type their password. Afterwards the robot must be **unplugged and plugged
back in**. macOS and Windows need nothing here.

## Step 4: verify with the real robot

The installer already ran the robot check at the end of step 2. If it printed `verdict: ready` you can skip the
re-check; otherwise make sure the robot is plugged in with its USB cable (a data cable, not charge-only) and
switched on, wait ~30 seconds, and run it again with the path from the installer's `Tool:` line:

```
<Tool path> doctor
```

(Windows: `& "<Tool path>" doctor`, where the path ends in `vexaim.exe`.) You want `verdict: ready` and a
battery percentage. Every failed check prints a `fix:` line; apply it or relay it.

Then read the battery and state with `<Tool path> info`, which prints one line of JSON such as
`{"battery_pct": 100, "heading": 125.4, "x_mm": 18, "y_mm": 45, "stopped": true}`, and report the battery to the
student. **Do not run robot commands that move it** at this stage.

### If the diagnostic does not say `ready`

1. On Linux run `lsusb | grep 2888:0700`. No output means the computer cannot see the robot at all: the cable,
   the power switch, or (in a virtual machine) USB passthrough. You cannot fix that yourself; ask the student to
   check: robot switched on, the USB **data** cable that came with it (some only charge), plugged straight into the
   computer (no hub or dock), unplug and re-plug.
2. Wait about 30 seconds (on Linux without the udev rule the first failure after plugging in is normal) and run
   `doctor` again. **Try at most 3 times**, then stop and hand back to the student.
3. If the robot is visible to the OS but `doctor` fails, read the `fix:` lines and `docs/troubleshooting.md`. A
   sandboxed agent (for example Goose installed as a Flatpak) cannot see USB devices at all; use a non-sandboxed
   install of the agent.
4. **Never invent a battery level.** If you could not read one, say so plainly, say what the diagnostic printed,
   and still do step 5 below: the install is complete and the new-session step does not depend on the robot.

## Step 5: finish

Tell the student, in plain language:

1. What was installed and where (the two skill folders and the `vexaim` path).
2. The robot's battery level and that `doctor` reported ready. If you could not reach the robot, say exactly what
   `doctor` printed and what the student should check, with **no battery number**.
3. **They must start a new session** of their agent (quit and reopen Goose, or start a new `claude` / `codex`
   session) so it loads the new `vex-aim` skill. Skills are discovered at session start.
4. A first prompt to try in the new session, for example:
   > Use the vex-aim skill. Run the diagnostic, set the robot's lights to blue for two seconds, then turn them
   > off. Do not move it.

## Using the robot afterwards

Everything about driving the robot lives in the skill: `skill/vex-aim/SKILL.md` (also installed to the
folders above). Read it before you run robot code. The essentials: `vexaim exec` runs any Python on the robot,
the camera is `vexaim snap`, printing more than ~2 KB at once loses output, and there are no software safety
limits, so be physically careful: clear space, a person at the robot, tell the student before it moves.

## Do not

- Do not run `sudo` or install Rust without asking.
- Do not modify the robot's firmware or upload programs to it (the tool needs neither).
- Do not push, publish, or send the student's photos/camera images anywhere without their consent.
