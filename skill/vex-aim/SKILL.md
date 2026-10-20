---
name: vex-aim
description: Control a VEX AIM robot from this computer over USB or the workshop's developing Bluetooth transport. Use when the user wants to drive, light up, make sounds with, read sensors from, or see through its camera. Uses the vexaim tool; read the Bluetooth reference for wireless requests and release limitations.
---

# Controlling a VEX AIM robot

The AIM's USB port is a **MicroPython REPL**. The bundled `vexaim` tool sends any Python you write to the
robot and returns what it prints. You may run arbitrary Python on the robot; be creative.
Camera frames come back to this computer as ordinary JPEG files.

For Bluetooth requests, first read `references/bluetooth.md`: published 0.1.1 is
USB-only; the local 0.2.0-dev CLI adds explicit Bluetooth commands. Native 640x480
JPEGs have been verified over BLE from the home screen with Python recovery.
Camera snapshots need no LCD navigation, preview or reset. The reference records
the development commands and remaining hardware/release checks.
For remembered LCD menu positions, that reference describes the instructor's
automatic AI Vision selector; do not replay a fixed press sequence or reset the robot.

`vexaim` is the program in this skill's own `bin/` folder, next to this SKILL.md (`bin/vexaim`, or
`bin\vexaim.exe` on Windows). Call it by its full path, e.g. `~/.agents/skills/vex-aim/bin/vexaim`; below it is
just written `vexaim`. If `bin/` is missing the skill was not installed with the repo's installer: see
https://github.com/Tingsters/vex-aim-agent-workshop (`install.sh` / `install.ps1`).

## First: always run the doctor

Use the selected transport. For wireless requests, follow the Bluetooth reference
and include `--transport bluetooth --name NAME`; do not diagnose Bluetooth with
the USB-only doctor or ask for a USB reconnect.

```
vexaim doctor
```

Fix whatever it reports before anything else (it prints a "fix:" for each failure). Success looks like
`verdict: ready` with the robot's battery percentage.

On Windows, use **vexaim 0.1.1 or newer**. Version 0.1.0 opens the COM ports but leaves DTR low, so the
Python console stays silent. Update the executable and skill together with `install.ps1`; read
`references/troubleshooting.md` if initialization fails. `vexaim stop` also requires a working REPL.

## Run Python on the robot

```sh
vexaim exec 'print(robot.get_battery_level())'          # one-liner
vexaim exec -f my_program.py                             # a file
vexaim exec - <<'PY'                                     # multi-line from stdin (preferred)
robot.led.on(ALL_LEDS, BLUE)
wait(1, SECONDS)
robot.led.off(ALL_LEDS)
PY
```

Windows PowerShell (5.1 or newer): use the executable in **this skill's** `bin` folder. For the default
Goose/Codex installation:

```powershell
$vexaim = Join-Path $env:USERPROFILE '.agents\skills\vex-aim\bin\vexaim.exe'
& $vexaim doctor
& $vexaim exec "print('battery:', robot.get_battery_level())"
& $vexaim exec -f 'my program.py'
@'
robot.led.on(ALL_LEDS, BLUE)
wait(1, SECONDS)
robot.led.off(ALL_LEDS)
'@ | & $vexaim exec -
```

For Claude's installation, use `.claude` instead of `.agents`. PowerShell needs `&` to invoke a quoted
executable path; Bash `<<'PY'` input and cmd.exe `%USERPROFILE%` syntax do not work there. Piped here-strings
avoid native argument quoting differences between PowerShell versions.

- `exec` automatically provides `robot = Robot()` plus `from vex import *` and `from vex_globals import *`
  (that second import is what defines names like `ALL_LEDS`, `RED`, `HAPPY`, `TADA`, `MMPS`).
- Variables persist between `exec` calls (the REPL stays alive), so you can build things up step by step.
- Output is stdout; a Python error prints the traceback and exits 1. Add `--json` for
  `{ok, stdout, stderr, timed_out}`. Default timeout 30 s (`--timeout N`); on timeout the program is
  interrupted with Ctrl-C.
- `vexaim stop` = emergency stop: interrupts the running program, stops wheels and sound.
- `vexaim info` = battery, heading, x/y position as JSON.
- `vexaim snap -o photo.jpg` = save one 640x480 camera frame. Open the JPEG yourself to look at it.

## Things that will bite you (all observed on a real robot)

1. **Keep printed output small.** If you print more than ~2 KB in one burst, the robot's USB output buffer
   overflows, the rest is lost and the call times out. Print summaries, or send long output in chunks:
   `sys.stdout.write(s[i:i+200]); wait(60, MSEC)`.
2. **Constants** such as `ALL_LEDS`, `RED`, `HAPPY` only exist after `from vex_globals import *`
   (already done by `exec`; use `--no-preamble` only if you know why).
3. **Position frame.** `robot.get_x_position()/get_y_position()` are in a fixed frame aligned to heading 0°
   (y along heading 0°, x to its right), not relative to where the robot currently faces. A 50 mm
   "forward" move while facing 25° reported (19, 45). Call `robot.set_xy_position(0, 0)` and
   `robot.inertial.reset_heading()` first if you want a clean frame.
4. **`robot.get_name()` does not exist** on this firmware (the public docs list it). Don't use it.
5. **Language/version:** the interpreter is MicroPython core 1.22.0. `sys.version` reports `3.4.0`, which is
   the Python language level it claims to be compatible with, not a CPython install (`vexaim doctor` shows
   both as `micropython_core` and `python_compat`). If asked "what Python version", say both. f-strings, list comprehensions, try/except,
   `asyncio`, `Thread(fn)`, `json`, `math`, `random` work. No pip, no numpy.
6. Moves like `move_for` **block** until finished. Prefer short distances/low speeds first. If something
   looks wrong run `vexaim stop` (or have the human press the robot's stop/power switch).
7. **Camera orientation = how the robot is physically sitting.** `vexaim snap` never rotates or flips the
   image; it is exactly what the sensor sees. The test robot was placed upside down, so its frames were
   rotated 180°. Look at the image first, and if the robot is mounted/placed inverted, rotate it 180° with any
   image tool before analysing (left/right and up/down swap). The camera is independent of the REPL: LEDs and
   running programs do not pause it.
8. Only one program should talk to the robot at a time (close VEXcode, serial monitors, other `vexaim` runs).

## Safety (physical, supervised use)

There are no software limits, so the human supplies them: a clear, level area; someone at the robot with
a hand on the power switch; keep early moves small and slow (e.g. `move_for(50, 0, 40, MMPS)`); tell the
human before the robot moves; never move toward the USB cable's end or off a table edge.
The camera sees the room: do not send images of people to cloud services without their consent.

## What has and hasn't been tested

Run on the Linux test robot without error: battery, IMU reads, position reads, LEDs, emoji, sounds, a 50 mm
forward move, `robot.kicker.kick(SOFT)` (a human confirmed the kicker moved), vision queries (empty scene),
threads, camera capture, error handling.
**Unplug/replug:** after a stable replug the robot works again within ~2 s (20/20 recoveries, Linux; with the
udev rule installed). If the cable is pulled mid-command, `vexaim` says the robot disconnected and that a move
may or may not have run: check the robot before re-running anything.
**Windows 11 (0.1.1):** doctor, info, Python execution, error/timeout recovery, and 100 consecutive calls
passed; packaged installation was checked in PowerShell 5.1 and 7.
**Not yet tested:** turns, `kicker.place/push`, harder kicks, longer/faster moves, AI Vision on real objects,
`Ctrl-C` interrupt during a move, Windows camera/actuators, and macOS hardware.
For LED/emoji/sound the call succeeded on Linux but the
human should confirm the effect. If the user asks for something untested, try it small first and report
what actually happened.

The `linux/` folder is only for Linux computers: `sh <this skill folder>/linux/install-udev.sh` once (needs sudo;
ask the human first) stops ModemManager from grabbing the robot's serial ports. Not needed on Windows/macOS,
or if `doctor` is ready.

Full API name list, constants and per-call status: `references/api.md`.
Troubleshooting and platform notes: `references/troubleshooting.md`.
Starter ideas: `references/examples.md`.
