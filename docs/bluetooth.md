# Bluetooth in the workshop

The released standalone vexaim CLI provides Bluetooth. Run this workshop's
installer to install its latest stable executable and matching basic skill,
then start a new agent session to discover both skills.

Switch the AIM on, close VEXcode, and tell the agent the exact robot name. Pairing
uses a masked local terminal prompt and the OS vault. Students do not type
commands or disclose codes in chat. For wireless-only testing, unplug USB first.

The agent reuses one connection across prompts. Native camera snapshots do not
require an AI Vision LCD mode, reset or preview. If the robot sleeps, switch it
on again when the agent gives a readiness cue. A connection cannot guarantee it
will stay awake.

With a matching 0.3.0-rc.5 or newer CLI/basic skill, students can also ask for a
happy face, message or drawing over Bluetooth. The tool activates and maintains
the program display automatically; no saved project, menu sequence or USB cable
is required. Reuse the connection. Stop/close or one minute without activity
returns the LCD to its menu. Camera photographs remain independent of LCD mode.

For the prerelease, install this workshop first, then select the matching CLI
and basic skill explicitly. Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Tingsters/vexaim-cli/main/install.ps1))) -Version 0.3.0-rc.5
```

macOS (Apple Silicon or Intel) and Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/Tingsters/vexaim-cli/main/install.sh | sh -s -- --version 0.3.0-rc.5
```

Start a new agent session after installing. Rerunning the unversioned workshop
installer selects the latest stable CLI again. These prerelease instructions
do not establish macOS/Linux robot compatibility; see the CLI hardware notes.

Commands, recovery and original investigation evidence now live in the
[CLI Bluetooth guide](https://github.com/Tingsters/vexaim-cli/blob/main/docs/bluetooth.md)
and [generic skill reference](https://github.com/Tingsters/vexaim-cli/blob/main/skill/vex-aim/references/bluetooth.md).
