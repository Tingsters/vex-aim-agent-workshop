# Hardware notes: what has actually been tested

One robot (VEX AIM, firmware reported as 1.0.0-beta.2), one Linux x86_64 computer, USB only, October 2026.
Anything not listed here is **untested**.

## Verified

| Area | Result |
|---|---|
| USB discovery | Robot enumerates as `2888:0700` with serial interfaces 0 (system) and 4 (user) plus a UVC camera. Upstream `vex-v5-serial` returned no user port; fixed by the vendored patch. |
| System port | Read-only `SystemVersion` query answers in about 1.3 ms (product `Aim`). |
| REPL over the library | `write_user`/`read_user` round trips: 10/10 in four separate runs, about 40 ms each. Raw-REPL framing (`OK`, stdout, `\x04`, stderr, `\x04`) parsed correctly, including tracebacks. |
| Steady state | 100/100 consecutive `vexaim exec` calls succeeded (mean about 0.7 s per CLI invocation including process start, REPL sync and cleanup). |
| Unplug/replug | 20/20 recoveries over four runs (15/15 with the udev rule installed): working again within about 2 s after a stable replug. Cutting the cable mid-command gives a clear "robot disconnected" error. |
| Actuators | LED on/off, emoji, sounds (play, note), a 50 mm forward move, and `kicker.kick(SOFT)` executed without error. A human confirmed the kicker moved. LED/emoji/sound effects were not visually confirmed in the test log. |
| Sensors | Battery, IMU (heading, rotation, pitch, roll), position, AI Vision queries (empty scene). |
| Camera | `vexaim snap` returns clean 640x480 JPEGs; the V4L2 buffer is zero-padded and is trimmed. |
| Language | f-strings, comprehensions, try/except, `asyncio`, `Thread`, `json`, `math`, `random` work. |
| Agent use | A fresh agent given only the skill completed a student-style task (diagnostic, battery, LEDs, camera, version) with no failures. Goose lists the skill from a project `.agents/skills` folder. |
| ModemManager (Linux) | Without the udev rule ModemManager probes both ports for 6-9 s after every enumeration (journal-confirmed), causing busy ports and recoveries up to 14 s. With the rule: no probes, recoveries about 0.7-1.7 s. |

## Windows: what is and is not verified

- Upstream's serial layer (`async-serial` 0.2.0) does not compile on Windows. Vendored patch 0002 replaces it on Windows with
  a thread-based adapter (`blocking::Unblock`, separate read and write handles).
- The whole CLI **compiles** for `x86_64-pc-windows-msvc` (`cargo check --target`, from Linux).
- That adapter was forced on with `--features blocking-io` and tested against the real robot **on Linux**: doctor, exec,
  error and timeout/interrupt paths, 100/100 consecutive calls. A first version of it failed on hardware (a read timeout was
  reported as the next write's error), which is why reads and writes use separate handles.
- Not tested: running on real Windows (COM port naming, driver behaviour, SmartScreen, camera access through Media Foundation,
  `install.ps1`).

## Known limits

- Output bursts over about 2 KB are lost (robot firmware).
- No software safety limits on motion. Physical supervision is required.
- Uploading and running a stored program through the library was tried and **not** made to work; it is not needed.

## Not tested

- Windows and macOS (CI builds only), including camera permissions and signing/SmartScreen/Gatekeeper behaviour.
- Turns, `kicker.place/push`, harder kicks, longer or faster moves, `Ctrl-C` during a move.
- AI Vision on real objects (tags, balls, barrels).
- Bluetooth (the host used had none); several robots at once; many robots in one room.
- Goose desktop end to end with a real robot.
- Firmware versions other than 1.0.0-beta.2.
