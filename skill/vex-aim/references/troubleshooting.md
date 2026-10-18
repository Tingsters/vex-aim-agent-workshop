# Troubleshooting `vexaim`

Start with `vexaim doctor`. Its failures map to the rows below.

| Symptom | Likely cause | Fix |
|---|---|---|
| `robot-detected: 0 device(s)` | Charge-only cable, robot off, or not plugged in | Use the cable that came with the AIM, plug directly into the laptop (not a dock), turn the robot on. Linux: `lsusb | grep 2888:0700`. |
| `open-ports` fails, "Device or resource busy" | Another program has the port: VEXcode, a serial monitor, another `vexaim`. **Linux:** ModemManager probes new serial ports for ~25 s | Close the other program. Linux: install the udev rule (below) or wait 30 s. |
| `open-ports` fails, "Permission denied" (Linux) | User not allowed to open `/dev/ttyACM*` | Install the udev rule (below), then re-plug. Or `sudo usermod -aG dialout $USER` and log out/in. |
| `repl` fails or times out | Robot busy running a program, or just powered on | Run `vexaim stop`, wait 5 s, retry; if still stuck, power-cycle the robot. |
| A call hangs then "timed out" after printing ~2 KB | Robot USB output buffer overflowed | Print less per burst or chunk with `wait(60, MSEC)`. |
| `snap`: "no camera with 'AIM' in its name" | Robot not plugged in, or the OS blocked camera access | macOS: System Settings > Privacy > Camera, allow your terminal/Goose. Windows: Settings > Privacy > Camera. |
| `snap` image upside-down / odd | Robot pose, not a bug | Rotate the image when analysing. |
| Unexpected `SyntaxError` on your first command | Something else (ModemManager `AT` probe) wrote to the port | Install the udev rule; re-run. |

## Linux: stop ModemManager and fix permissions (once per computer, needs sudo)

ModemManager sends `AT` commands to every new serial port. It holds the AIM busy for ~25 s after each
plug-in and can inject junk into the robot's REPL. The rule below makes it ignore the AIM and gives the
logged-in user access without the `dialout` group:

```
sh ~/.agents/skills/vex-aim/linux/install-udev.sh     # asks for sudo; installs /etc/udev/rules.d/99-vex-aim.rules
```

Then unplug and replug the robot. The rule only matches USB `2888:0700` (the AIM), nothing else.
On immutable distros (Bazzite, Silverblue) `/etc/udev/rules.d` is writable, so the same command works.

## Windows / macOS

No ModemManager. Nothing to install for the serial part. Allow camera access when prompted for `vexaim snap`.
Windows SmartScreen or macOS Gatekeeper may warn about an unsigned binary: on macOS run
`xattr -d com.apple.quarantine vexaim` or right-click > Open once; on Windows choose "More info > Run anyway".
**These platforms have not been tested on real hardware yet.** Managed/school laptops may block unsigned
executables; ask the instructor for the loaner laptop.

## Linux binary requirements

Needs `libudev.so.1` (present on practically all systemd distributions). No other runtime dependencies.
