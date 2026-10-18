# Troubleshooting

First run the robot check. Every failed step prints a `fix:` line.

```
~/.agents/skills/vex-aim/bin/vexaim doctor           # Windows: %USERPROFILE%\.agents\skills\vex-aim\bin\vexaim.exe doctor
```

## Installing

| Symptom | Cause | Fix |
|---|---|---|
| `download failed (offline, or no release published yet?)` | No internet, a proxy, or the repository has no release yet | Check the connection and retry. Instructors: publish the release (see `docs/instructors.md`). Or build locally: install Rust from https://rustup.rs, then `sh install.sh --from-source`. |
| `checksum mismatch ... refusing to install` | Corrupted or tampered download | Retry. If it repeats, do not install; tell the instructor. |
| `no prebuilt binary for <os/arch>` | A platform we do not build (for example Linux ARM) | `sh install.sh --from-source` (needs Rust). |
| `<dir> already exists and was not installed by this script` | You already have a skill folder with that name | Move it away, or re-run with `--force`. |
| `the vexaim binary does not run on this machine` | Blocked by the OS or antivirus, or wrong architecture | macOS: `xattr -d com.apple.quarantine ~/.agents/skills/vex-aim/bin/vexaim`, or right-click > Open once. Windows: SmartScreen "More info > Run anyway"; school laptops may forbid unsigned programs: use the instructor's loaner laptop. |
| Build from source fails on Linux (`libudev`) | Missing development headers | `sudo apt install libudev-dev pkg-config` (Fedora: `sudo dnf install systemd-devel`). |
| The agent does not know the `vex-aim` skill | It was started before the install | Start a **new** session (quit and reopen Goose; new `claude` / `codex` session). Goose/Codex read `~/.agents/skills`, Claude Code reads `~/.claude/skills`. |

## Talking to the robot

| Symptom | Likely cause | Fix |
|---|---|---|
| `robot-detected: 0 device(s)` / "no VEX device found" | Charge-only cable, robot off, or not plugged in | Use the cable that came with the robot, plug directly into the laptop (not a hub or dock), switch the robot on. Linux: `lsusb \| grep 2888:0700`. |
| `open-ports` fails, "Device or resource busy" | Another program has the port (VEXcode, a serial monitor, a second agent). **Linux:** ModemManager probes new serial ports for ~25 s | Close the other program. Linux: install the udev rule (below) or wait 30 s. |
| `open-ports` fails, "Permission denied" (Linux) | Not allowed to open `/dev/ttyACM*` | Install the udev rule (below) and re-plug. Or `sudo usermod -aG dialout $USER` and log out and in. |
| `repl` fails or times out | Robot busy running something, or just powered on | `vexaim stop`, wait 5 s, retry. If stuck, power-cycle the robot. |
| A command hangs and then "timed out" after printing about 2 KB | The robot's USB output buffer overflows on large bursts | Print less per burst, or chunk with `wait(60, MSEC)` between pieces. |
| "the robot disconnected during the command" | Cable pulled or robot lost power mid-command | Check the robot (a move may or may not have run) before re-running. Re-plug and run `doctor`. |
| `snap`: "no camera with 'AIM' in its name" | Robot not plugged in, or the OS blocked camera access | macOS: System Settings > Privacy & Security > Camera, allow your terminal / Goose. Windows: Settings > Privacy > Camera. |
| Photo is upside down | The robot is sitting or mounted upside down | `snap` never rotates the image; rotate 180 degrees before analysing. |
| Goose (Flatpak) cannot see the robot | The Flatpak sandbox has no access to `/dev/ttyACM*` or `/dev/video*` | Use the standard Goose build or the Goose CLI. (Advanced: `flatpak override --user --device=all io.github.block.Goose`.) |
| Unexpected `SyntaxError` on the first command (Linux) | ModemManager wrote an `AT` command to the robot's console | Install the udev rule; re-run. |

## Linux: stop ModemManager and fix permissions (once per computer, needs sudo)

ModemManager sends `AT` commands to every new USB serial port. It holds the robot's ports busy for about 25 seconds
after each plug-in and can inject junk into the robot's console. The rule makes ModemManager ignore the AIM
(USB `2888:0700`, nothing else) and gives the logged-in user access without the `dialout` group:

```
sh ~/.agents/skills/vex-aim/linux/install-udev.sh        # or: sh install.sh --udev   (asks for sudo)
```

Then unplug and replug the robot. Check it took effect: `udevadm info -q property -n /dev/ttyACM1 | grep MM_DEVICE_IGNORE`
should print `ID_MM_DEVICE_IGNORE=1`. Remove it with `sudo rm /etc/udev/rules.d/99-vex-aim.rules`.
Immutable distros (Bazzite, Silverblue) keep `/etc/udev/rules.d` writable, so the same command works.
