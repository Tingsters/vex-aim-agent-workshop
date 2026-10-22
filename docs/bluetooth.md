# Bluetooth in the workshop

The released standalone vexaim CLI provides Bluetooth. Run this workshop's
installer to install its latest stable executable and matching basic skill,
then start a new agent session to discover both skills.

Switch the AIM on, close VEXcode, and tell the agent the exact robot name. The agent
asks for the four-digit code on the robot's screen and pairs with
`bluetooth pair --code-stdin`; the credential is stored in the OS vault. This
trades a little security (the short-lived code appears in the agent transcript)
for not making students open a terminal. Older vexaim releases lack the flag and
need the masked terminal prompt instead. For wireless-only testing, unplug USB first.

The agent reuses one connection across prompts. Native camera snapshots do not
require an AI Vision LCD mode, reset or preview. If the robot sleeps, switch it
on again when the agent gives a readiness cue. Sensor/motor traffic and a visible
face have not reliably prevented sleep. The experimental rc.6 release's System
Alive probes also failed hardware endurance despite successful acknowledgments.
Do not recommend it as a sleep fix or infer sleep prevention from cached health.
Once powered off, the AIM needs a person to switch it back on. The CLI's 30-minute
client inactivity deadline closes its owner; it is separate from robot sleep.

The Windows firmware 1.0.4 follow-up compares the unchanged published CLI with
the official VEXcode application before adding maintenance traffic. It also
rehearses an audible computer cue while the operator is present, so later
physical intervention does not rely on watching the console. See the
[investigation and measured status](https://github.com/Tingsters/vexaim-cli/blob/main/docs/firmware-1.0.4-investigation.md).
Do not assume that an upgrade or installed VEX driver bundle proves a sleep fix.
On the tested 1.0.4 robot, a private SDK sleep-disable setter also read back
`True` without preventing the loss. It is a developer experiment, not an
additional student setup step or verified workaround.
One combined system-REPL/SDK mechanism subsequently passed 20 quiet minutes.
The matching CLI integration is being validated with a finite power lease;
that mechanism control alone does not certify the ordinary workshop workflow.

With a matching 0.3.0-rc.5 or newer CLI/basic skill, students can also ask for a
happy face, message or drawing over Bluetooth. The tool activates and maintains
the program display automatically; no saved project, menu sequence or USB cable
is required. Reuse the connection. Stop/close or one minute without activity
ends the drawing. The rc.7 power candidate may then show REPL Mode until the
session closes. Camera photographs remain independent of LCD mode.

For the prerelease, install this workshop first, then select the matching CLI
and basic skill explicitly. Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Tingsters/vexaim-cli/v0.3.0-rc.6/install.ps1))) -Version 0.3.0-rc.6
```

macOS (Apple Silicon or Intel) and Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/Tingsters/vexaim-cli/v0.3.0-rc.6/install.sh | sh -s -- --version 0.3.0-rc.6
```

Start a new agent session after installing. Rerunning the unversioned workshop
installer selects the latest stable CLI again. These prerelease instructions
do not establish macOS/Linux robot compatibility; follow the
[Mac verification checklist](https://github.com/Tingsters/vexaim-cli/blob/v0.3.0-rc.6/docs/macos-verification.md)
and see the CLI hardware notes. This is an investigation release, not a verified
sleep fix.

Commands, recovery and original investigation evidence now live in the
[CLI Bluetooth guide](https://github.com/Tingsters/vexaim-cli/blob/main/docs/bluetooth.md)
and [generic skill reference](https://github.com/Tingsters/vexaim-cli/blob/main/skill/vex-aim/references/bluetooth.md).
