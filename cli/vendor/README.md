# Vendored upstream: vexide/vex-v5-serial

`vex-v5-serial/` and `vex-cdc/` are copies of the crates in
[vexide/vex-v5-serial](https://github.com/vexide/vex-v5-serial) (MIT, see `LICENSE-vex-v5-serial-MIT`),
taken from upstream commit `b3a712a16c9c6819b69faacfee2284826a138070` (2026-09-22) with the patches
`0001-aim-user-port-and-write-all.patch`, `0002-serial-windows-capable-async-layer.patch`, and
`0003-windows-aim-dtr.patch` applied. They are
vendored so the repository builds with no network access to anything but crates.io, and so students never depend
on an unreleased upstream branch.

## Patch 0002: the serial layer did not compile on Windows

`vex-v5-serial`'s `serial` feature uses `async-serial` 0.2.0, which imports `std::os::fd` unconditionally, so it
does not build on Windows at all (and `async-io` cannot poll COM ports). On Windows, or with the `blocking-io`
cargo feature (so the same code can be exercised on any OS), the port is instead driven on a thread pool through
`blocking::Unblock`, using **separate cloned handles for reading and writing**. (A single `Unblock` reads ahead in
the background and reports that read's timeout as the error of the next *write*; this was found by testing the
adapter against a real robot on Linux with `--features blocking-io`.) Unix keeps `async-serial` unchanged.
The adapter was hardware-tested on Linux via `blocking-io`. Windows diagnosis exposed a further DTR
requirement covered by patch 0003; see `docs/hardware-notes.md` for the platform-specific evidence.

## Patch 0003: Windows opened the ports but the AIM REPL stayed silent

On Windows 11, the 0.1.0 executable correctly found system COM4 (`MI_00`) and user COM3 (`MI_04`) and opened
both, but received zero bytes during REPL initialization. Power-cycling did not help. A direct serial
comparison with the same 115200/8N1 settings and RTS disabled produced no bytes with DTR low, then a raw
REPL prompt and successful execution as soon as DTR was asserted. Fresh-open comparisons reproduced it.

`serialport` 4.10.1 preserves OS DTR defaults: Linux asserts DTR on open, Windows does not. Its builder's
`dtr_on_open` is best-effort and ignores errors. The blocking adapter now makes a checked
`write_data_terminal_ready(true)` call on every Windows AIM user-port open, **before** cloning read/write
handles. Other ports and Unix behavior are unchanged. Configuration errors retain the port name and source
error; normal ownership cleanup closes a handle when setup fails. Tests cover the DTR requirement, failure
propagation, other-port behavior, and Windows interface metadata independent of COM numbering.

## What patch 0001 changes (all in `vex-v5-serial/src/serial.rs`)

1. **AIM user port.** `types_by_location()` only knew the V5 Brain layout (interface 0 = system, 2 = user). The
   AIM exposes a UVC camera on USB interfaces 2-3, so its serial ports are interfaces **0 and 4**. Interface 4
   used to be dropped as "Unknown location", leaving `SerialDevice::user_port()` empty. It is now recognised as
   the user port for USB PID `0x0700`.
2. **Fallbacks can run.** `types_by_location()` returned `Some(...)` even when it recognised nothing, so the
   name-based fallbacks were never tried. It now returns `None` when nothing was recognised.
3. **No partial writes.** `write_user()` on the user-port path used a single `write()`, which may accept only
   part of the buffer. It now uses `write_all()` + `flush()`.

Discovery and configuration tests: `cargo test -p vex-v5-serial --no-default-features --features serial`.

## Provenance and upstreaming

Reproduce the vendored tree: clone upstream, check out the commit above, `git am 0001-*.patch 0002-*.patch`,
then `git apply 0003-windows-aim-dtr.patch`,
and compare `packages/vex-v5-serial` and `packages/vex-cdc` with these directories. These changes are small and
self-contained and are intended to be proposed upstream; when upstream releases an equivalent fix, replace this
directory with the released crates.

Hardware evidence for the AIM findings (Linux and Windows x86_64): `docs/hardware-notes.md`.
