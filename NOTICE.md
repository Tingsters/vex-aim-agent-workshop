# Notices

This project's own code and documentation are licensed under the Apache License 2.0 (see `LICENSE`).

## Third-party code included in this repository

- **vex-v5-serial** and **vex-cdc** (vexide and contributors), MIT License. Vendored under `cli/vendor/` with
  two small patches (see `cli/vendor/README.md`). License text: `cli/vendor/LICENSE-vex-v5-serial-MIT`.
  Source: https://github.com/vexide/vex-v5-serial

## Third-party code compiled into the `vexaim` binary (from crates.io, not vendored here)

Pulled in by `cli/Cargo.lock`, each under its own permissive license (MIT/Apache-2.0 and similar), including
`clap`, `serde_json`, `smol`, `serialport`, `async-serial`, and `nokhwa` (camera access). Run `cargo tree` in `cli/`
for the full list.

## Trademarks

VEX, VEX Robotics and VEX AIM are trademarks of their respective owners. This project is independent and is not
affiliated with or endorsed by VEX Robotics.
