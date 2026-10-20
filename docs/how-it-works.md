# How the workshop fits together

The workshop installs two agent skills. vex-aim-workshop provides teaching
guidance, optional activities and an approach to creative prompts. The standalone
vex-aim skill provides robot commands and the vexaim executable.

The workshop installer resolves the latest stable CLI release once, verifies its
installer checksum, and delegates installation of that exact release's executable
and basic skill. It then installs the local teaching skill. The installed version
stays fixed until the installer is run again.

The CLI handles USB, Bluetooth pairing, persistent connections, transient Python,
movement helpers and camera frames. No project needs to be loaded on the robot.
For implementation details see the [CLI architecture](https://github.com/Tingsters/vexaim-cli/blob/main/docs/how-it-works.md).
