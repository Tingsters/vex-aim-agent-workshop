# Hardware notes: what has actually been tested

Linux tests: one robot (VEX AIM, firmware reported as 1.0.0-beta.2), one Linux x86_64 computer, USB only,
October 2026. Windows diagnostics were added on October 19, 2026, on one Windows 11 x86_64 computer.
Anything not listed here is **untested**.

## Verified on Linux

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
- The whole CLI builds natively for `x86_64-pc-windows-msvc` with Rust 1.99.1, Visual Studio 2022
  C++ Build Tools (MSVC 14.44), and Windows SDK 10.0.26100.0.
- That adapter was forced on with `--features blocking-io` and tested against the real robot **on Linux**: doctor, exec,
  error and timeout/interrupt paths, 100/100 consecutive calls. A first version of it failed on hardware (a read timeout was
  reported as the next write's error), which is why reads and writes use separate handles.
- Windows 11 build 26200, built-in Microsoft `usbser` driver 10.0.26100.9278: USB discovery identified
  system COM4 (`MI_00`) and user COM3 (`MI_04`). The installed 0.1.0 executable opened both but raw REPL
  initialization returned no bytes, including after power-cycling in an earlier agent session.
- Direct PowerShell/.NET serial probes held baud rate (115200), 8N1, no flow control, and RTS low constant.
  DTR low returned no bytes. Setting DTR high on the same connection immediately returned the raw REPL
  prompt and executed `print`. Fresh-open true/false/true comparisons repeated the result: both DTR-high
  connections read battery 100%, stopped true, MicroPython core 1.22.0, Python compatibility 3.4.0.
  The unmodified Rust executable still failed afterward: DTR is required on every open.
- The rebuilt **vexaim 0.1.1** executable and the executable extracted through the checksum-verified ZIP
  installer both reported `verdict: ready`, battery 100%, MicroPython core 1.22.0, Python compatibility
  3.4.0, and stopped true. No actuators or camera were used.
- The packaged executable passed **100/100 consecutive round trips** in PowerShell 7.6.7 (mean 1062.8 ms
  per process invocation). One-line execution, multiline stdin, a file path containing spaces, Python
  errors, timeout/interrupt and recovery all passed. An out-of-range device index reported not ready.
- All 10 CLI and 6 vendored serial unit tests passed locally. Installer regression tests passed all
  18 assertions in both Windows PowerShell 5.1.26100.9711 and PowerShell 7.6.7: dry run, both agent
  destinations, upgrade, single-agent selection, checksum/missing-checksum rejection, old/malformed/
  failed-version rejection, foreign-skill protection, and uninstall isolation.
- Reproduce stationary validation with `dev/test-hardware.ps1` and installer checks with
  `dev/test-install.ps1`. Local reports are generated in the ignored `dist/` folder; these results do not
  establish Windows camera or actuator support.
- Two automated USB reconnect cycles and one manually verified reconnection returned to ready. An initial
  third automated attempt did not include a completed reconnection and is excluded; this is not an
  uninterrupted automated 3/3 run. The manual reconnection check read battery 98% and stopped true;
  the subsequent PowerShell 5.1 run read 100% while connected over USB.
- The reconnect harness now waits for all AIM serial endpoints to disappear and for both endpoints to
  remain present for at least one second using `Get-PnpDevice -PresentOnly`, rather than advancing on a
  transient CIM serial-port snapshot. Every reconnect attempt saves its diagnostic output beside the
  requested report, including failures. The stable-presence check was exercised with the connected robot;
  simulated transient and partially enumerated states were rejected in both PowerShell 5.1 and 7.

## Known limits

- Output bursts over about 2 KB are lost (robot firmware).
- No software safety limits on motion. Physical supervision is required.
- Uploading and running a stored program through the library was tried and **not** made to work; it is not needed.

## Not tested

- Windows camera/actuators and macOS hardware, including camera permissions and signing/SmartScreen/Gatekeeper behaviour.
- Turns, `kicker.place/push`, harder kicks, longer or faster moves, `Ctrl-C` during a move.
- AI Vision on real objects (tags, balls, barrels).
- Bluetooth (the host used had none); several robots at once; many robots in one room.
- Goose desktop end to end with a real robot.
- Firmware versions other than 1.0.0-beta.2.
