# Instructor guide

The workshop owns teaching material; Tingsters/vexaim-cli owns the executable,
basic robot skill, USB/Bluetooth support and release builds. The workshop installer
installs both skills using the latest stable CLI release. Students do not compile.

## Before the event

Give students the command for their operating system. No clone is needed.

**Windows x86_64 (PowerShell 5.1+):**

```powershell
irm https://raw.githubusercontent.com/Tingsters/vex-aim-agent-workshop/main/install.ps1 | iex
```

**macOS (Apple Silicon or Intel), or Linux x86_64 (Terminal):**

```sh
curl -fsSL https://raw.githubusercontent.com/Tingsters/vex-aim-agent-workshop/main/install.sh | sh
```

Both install the prebuilt CLI and both skills. The robot can be off. Students
must start a new agent session afterward; the same command installs updates.

1. Try the installer on each expected laptop type, then start a new agent session.
   Verify both vex-aim and vex-aim-workshop are discovered. A checkout alone does
   not update an installed executable.
2. Charge robots and decide which student uses which robot. For Bluetooth, use
   exact names and masked local pairing input, keeping VEXcode closed.
3. Ask the agent for a stationary connection/battery check using the chosen
   transport. Installation itself does not need a connected robot.
4. Keep a prepared loaner laptop for managed devices that block executables.
5. Linux USB may require the basic skill's udev helper. Ask before sudo, and give
   an explicit unplug/replug cue afterward. Wireless use does not need that rule.

There is no instructor calibration task, floor classification or required target
arrangement. The optional developer surface benchmark belongs in the CLI project
and is not event preparation.

## During the session

Start with lights or sound, then invite students' own ideas. Use the workshop
skill's activities as inspiration rather than a fixed menu. Allow most of the
90 minutes for experiments and finish with student demonstrations/reflection.

For movement, provide a clear level floor and someone near the physical switch.
Keep Bluetooth sessions open across prompts; avoid repeated scans and diagnostics
while healthy. If the robot sleeps, give a clear power-on cue. Do not ask for a
USB reconnect to fix a wireless connection. Do not replay uncertain movements.

Agree before sharing photographs or other records. Showtail capture stays local;
follow the supplied project instructions for reporting at actual wrap-up.

## Maintenance

Rerun the workshop installer to install the latest stable CLI/basic skill and the
current workshop skill. Close active sessions first. The workshop does not build
or publish binaries. Releases, transport bugs and generic API documentation live
in https://github.com/Tingsters/vexaim-cli.

CI covers all four platform builds/installers. Hardware evidence and limitations
are maintained by the CLI project, including unverified macOS hardware and newest
movement-helper acceptance. Do not equate sensor agreement with a perfect turn.
