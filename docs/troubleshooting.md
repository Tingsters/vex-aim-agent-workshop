# Workshop troubleshooting

- **Only one skill appears:** rerun the workshop installer, then start a new
  agent session. It installs vex-aim (robot control) and vex-aim-workshop (teaching).
- **Download or checksum failure:** retry on a working connection or download
  the complete CLI release assets and use --from-dir / -FromDir. No skills are
  installed from an unverified installer; there is no automatic source build.
- **Existing unrelated skill folder:** move it aside or explicitly choose force
  after checking it. The installer does not overwrite an unmarked folder silently.
- **Updating a running executable fails:** close its robot session and retry.
- **Robot unavailable:** check power and the intended connection. Use the generic
  vex-aim skill for transport diagnostics. USB reconnects do not repair Bluetooth.
- **Unexpected movement or uncertain result:** stop using the existing session,
  use the physical switch if necessary, then follow the generic skill's live
  status/recovery procedure. Never automatically replay movement.

Current USB, Windows DTR, Bluetooth pairing, native-camera and OS permission
guidance lives in the [CLI troubleshooting guide](https://github.com/Tingsters/vexaim-cli/blob/main/docs/troubleshooting.md)
and its [basic skill](https://github.com/Tingsters/vexaim-cli/blob/main/skill/vex-aim/SKILL.md).

When asking for help, retain the installed CLI version and relevant diagnostic
output locally. Do not attach credentials, photographs or work trails without
explicitly choosing to share them.
