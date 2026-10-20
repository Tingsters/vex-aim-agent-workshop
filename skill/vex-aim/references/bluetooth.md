# Bluetooth status and instructor workflow

The published `vexaim 0.1.1` executable is still USB-only. The workshop's local
`0.2.0-dev` CLI implements Bluetooth; verify the executable version and help before
using its flags. For an explicitly wireless request with USB unplugged, use that
development CLI or the instructor probe below. A USB `doctor` failure does not
diagnose Bluetooth. Full sensor/actuator, reliability and release acceptance is pending.

## Development CLI

With the local development binary (Windows path shown), use the exact name:

```powershell
.\cli\target\debug\vexaim.exe bluetooth scan
.\cli\target\debug\vexaim.exe --name AIM6518 bluetooth pair
.\cli\target\debug\vexaim.exe --transport bluetooth --name AIM6518 doctor
.\cli\target\debug\vexaim.exe --transport bluetooth --name AIM6518 info
.\cli\target\debug\vexaim.exe --transport bluetooth --name AIM6518 snap -o dist/camera.jpg
```

Pair in an interactive local terminal using masked input; never ask for the code
in chat. Normal operations reuse the native OS vault. The Windows CLI can migrate
the instructor probe's matching credential after successful authentication. USB
remains the default, `--device` selects USB only, and commands never fall back to
another robot or transport. `exec` and `stop` also take the Bluetooth flags above.
The CLI's hardware verification status is recorded in `docs/bluetooth.md`.
On Windows the development CLI has passed doctor, info and native camera checks:
the latest 640x480 spinner image took 7.908 s, then a fresh Python state connection
passed at battery 33%, stopped true. This does not establish all sensors/motors.

## Native camera JPEG: demonstrated on Windows

The instructor probe retrieved a complete **640x480 native camera JPEG over BLE**
from AIM6518 / REV1 / BLE firmware `1.0.0.b0`. The first 13,641-byte frame took
3.453 seconds from capture request to completed file, with USB absent. The image
visibly showed the VEX controller with **no LCD border or back button**. This
supersedes the earlier LCD-only camera limitation. Three subsequent visibly
different frames took 2.594, 4.594 and 4.781 seconds, from home screen `0` with
no navigation. The last showed the student-confirmed pink spinner replacing the
controller. Same-session Python state reads passed before/after the last two
captures with both notification streams retained. Camera feasibility is passed
on this Windows/firmware combination.
The complete wireless release still requires the remaining hardware acceptance.

From the workshop root, with the existing accepted credential:

```powershell
uv run --no-project --with bleak==3.0.2 --with keyring==25.7.0 python dev/ble-feasibility.py --name AIM6518 --native-camera --jpeg-output dist/camera.jpg --report dist/camera.json
```

This is an **instructor development command**, not a student dependency or a flag
for the published `vexaim`. It requests CDC capture layer `8`, uses the established
read-only `screen` Cbuf protocol, and validates packet CRCs, addresses, length,
JPEG framing and frame dimensions before replacing the output atomically. It
saves the robot's JPEG unchanged: no resizing, cropping, transcoding or upload.
Check the **new report's** `ok`, `jpeg_dimensions` and `snapshot_seconds`, then
inspect the image. A failed run may leave a previous image at the same path.
The timing flag is separate from visual camera and overall release acceptance.

Regular `--native-camera` does not enter Python, request a preview or send menu
presses. Home-screen and AI Vision LCD modes both passed. Pair separately first if needed.
Native JPEG output does not require the Windows PowerShell bitmap decoder.
Other operating systems and firmware have not had hardware acceptance.

## Authentication and connection recovery

Keep the selected robot explicit; the probe verifies exactly one matching name
and its AIM model. Windows automatically checks that no AIM USB endpoint is
present. On other hosts, verify physical USB disconnection yourself.

The displayed four-digit VEX code belongs in a masked local terminal prompt and
the native OS credential store, never chat, arguments, logs or a plaintext file.
`dev/pair-bluetooth.ps1` opens the Windows pairing helper and waits for readiness.
Windows OS bonding being false does not mean VEX application authentication failed.
A separate process reused the stored credential successfully during earlier tests.
If a scan cannot find the robot, check power before blaming the radio or REPL;
the robot has powered off during past work. Give an explicit cue for every
required physical reconnect/power cycle; do not automate power cycles.

For stationary Python/camera recovery testing, add `--python-recovery-check` to
`--native-camera`. It reads battery/stopped state before and after capture, and
requires the robot to report stopped before continuing. It performs no motion,
kicker or Python preview commands. This control does touch the Python console;
normal native snapshots do not.

**Retain both system/TXData and user/TXUser notifications through all Python work.**
Use **notifications**, not indications: AIM advertised both, but indications
delivered zero REPL bytes in a controlled Windows test. The vendored Windows
`btleplug` fix prefers notifications; an unpatched crates.io build can authenticate
yet remain silent.
On Windows/Bleak 3.0.2/firmware `1.0.0.b0`, disabling system notifications mid-session
silenced Python responses; re-registering user notifications alone did not fix it.
Disable subscriptions only at connection teardown, after recovery reads. The
Rust backend already retains them. A missed response does not prove power-off.

## LCD navigation is a separate display feature

For requests to show AI Vision on the robot's actual LCD, the probe's
`--lcd-only --select-ai-vision --framebuffer-output PATH --report PATH` recognizes
Dashboard and AI Vision icons twice before selecting them. It returns home with
Back as needed and adapts to remembered carousel positions. Calibration is English
menus on REV1 / BLE firmware `1.0.0.b0`. Home is screen `0`, Dashboard carousel
`32`, and camera view `34`; **screen `32` never proves camera mode**. It sends no
navigation input if `34` is already active. Unknown icons cannot authorize Center;
uncertain commands stop without retrying presses. Leave the screen alone while
it runs. Do not replay the clean-boot press sequence from an unknown menu, since
Dashboard also contains drivetrain/kicker tests. `left` remains untested on hardware.

The LCD workflow takes about 45 seconds to navigate a remembered AI Vision tile
and about 75 seconds including its raw 240x240 capture. Its snapshots include UI;
use native JPEG for camera images. Default LCD capture plus `--jpeg-output PATH`
can invoke the local Windows RGB565 decoder, with distinct raw/JPEG/report paths.
A 45-second operational transfer deadline preserves slow complete frames while
the performance target stays 30 seconds. Keep sequential reads: a two-request
pipeline failed on hardware. Layer 1 was nonempty in camera mode but still showed
LCD UI. Do not sweep other undocumented selectors or infer AIM formats from a
different VEX product. Layer 8 was selected from an exact official host-tool JPEG
path and then verified empirically on this AIM, not inferred to work from its name.

No non-destructive Bluetooth reboot has been verified. The physical reset forces
shutdown and requires manual power-on; Factory Reset erases projects/settings.
Do not use reset as a menu shortcut or guess arguments for AIM screen command
`0x66`. Keep firmware and stored programs unchanged.

The workshop's [Bluetooth notes](https://github.com/Tingsters/vex-aim-agent-workshop/blob/main/docs/bluetooth.md)
maintain exact commands, source provenance, local evidence and remaining
acceptance. Keep photos and the local Showtail trail local. Movement tests require
separate physical readiness/supervision and a clear area; wireless stopping needs
a working connection.
