# Instructor guide (short)

For the developing Bluetooth workshop workflow, students use ordinary chat
prompts and the agent reuses a connection. No instructor/student surface setup or
calibration routine is required. See [motion status](workshop-motion.md) for
development acceptance and [agent instructions](../skill/vex-aim/references/workshop.md).
The developer surface benchmark is not an event preparation requirement.

## Before the event (once)

1. **Publish the corrected release** after validation: tag and push `v0.1.1`
   (`git tag v0.1.1 && git push origin v0.1.1`). `release.yml` builds Linux, macOS (arm64, x86_64) and Windows
   binaries and attaches `vexaim-<target>.tar.gz|zip` plus `SHA256SUMS`. Check the Releases page has all of them.
2. **Test on every laptop type you expect**: Windows serial verification is recorded separately from the Linux
   camera/actuator tests; macOS hardware remains untested. Plug in a robot and paste the student prompt from
   the README in a clean account. Verify the installed executable version, not just the repository checkout.
3. **Charge the robots** and check `vexaim doctor` shows `verdict: ready` for each. Name or label the robots.
4. **Loaner laptop**: keep one laptop with everything preinstalled for students whose managed device blocks
   downloaded programs.
5. **Linux laptops** need the udev rule once (`sh install.sh --udev`, asks for sudo).

## Room setup and safety

- Flat, clear floor area per team, nothing at the edges; robots never on tables unattended.
- A person with a hand near the power switch whenever a robot moves; first moves small and slow.
- Use the robot's own cable, plugged straight into the laptop. One laptop per robot at a time (only one program may use
  the robot's ports).
- The camera sees the room: agree a policy before students send photos to a cloud AI service.
- The AI model needs the venue's internet; the robot does not. If the internet is unreliable, the robot still works from
  the command line (`vexaim exec`), but the agent will not.

## Reset between groups

Switch the robot off and on, then `vexaim stop` and `vexaim doctor`. Clear variables left in the robot's console by
power-cycling it.

## When something goes wrong

Follow `docs/troubleshooting.md`; it is organised by symptom. Most failures are a charge-only cable, a robot that is
off, another program holding the port, or (Linux) ModemManager before the udev rule is installed.

## Known gaps before you teach

See `docs/hardware-notes.md` ("Not tested"). Windows camera/actuators, macOS hardware, and
turns/vision-on-objects have not been verified on those platforms.

## Validate and distribute the Windows correction

0.1.0 detects and opens the AIM's COM ports but leaves DTR low, so the REPL never responds. The Windows
installer now refuses that version before changing skill folders. Until 0.1.1 is published, the default
download can therefore report an obsolete-release error; do not send students through repeated reinstalls.

Maintainers can build with Rust stable's MSVC toolchain, Visual Studio C++ Build Tools, and a Windows SDK.
Ask before installing administrator-level prerequisites. Students continue using prebuilt binaries.
If Rust was installed without modifying PATH, prepend its bin folder to the current PowerShell process
with `$env:PATH = (Join-Path $env:USERPROFILE '.cargo\bin') + ';' + $env:PATH`.

```powershell
cargo build --locked --release --manifest-path cli/Cargo.toml
New-Item -ItemType Directory -Path dist -Force | Out-Null
Compress-Archive -Path cli/target/release/vexaim.exe -DestinationPath dist/vexaim-windows-x86_64.zip -Force
$hash = (Get-FileHash dist/vexaim-windows-x86_64.zip -Algorithm SHA256).Hash.ToLower()
"$hash  vexaim-windows-x86_64.zip" | Set-Content dist/SHA256SUMS -Encoding ASCII
./dev/test-install.ps1 -AssetsDir dist
powershell -NoProfile -ExecutionPolicy Bypass -File dev/test-install.ps1 -AssetsDir dist
./dev/test-hardware.ps1 -Tool ./cli/target/release/vexaim.exe -ReplugCycles 3
```

The hardware harness uses no actuators or camera. Follow its unplug/reconnect cues with the robot stationary.
To validate a packaged installation, use `install.ps1 -FromDir dist -TargetHome <test-folder> -NoDoctor`,
then run the harness against that installed executable. Supply both ZIP and SHA256SUMS for offline installs.
Before the workshop, verify the published release has all four platform archives and matching checksums,
then test the normal download install on a clean Windows account. Source changes alone do not distribute
the fix. Restart the agent after updating its installed skill.
