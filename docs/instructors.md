# Instructor guide (short)

## Before the event (once)

1. **Publish the release** so the installer has something to download: tag and push `v0.1.0`
   (`git tag v0.1.0 && git push origin v0.1.0`). `release.yml` builds Linux, macOS (arm64, x86_64) and Windows
   binaries and attaches `vexaim-<target>.tar.gz|zip` plus `SHA256SUMS`. Check the Releases page has all of them.
2. **Test on every laptop type you expect**: macOS, Windows and Linux are CI-built but only Linux has been tested with
   a real robot. Plug in a robot and paste the student prompt from the README in a clean account.
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

See `docs/hardware-notes.md` ("Not tested"). In particular Windows/macOS and turns/vision-on-objects have not been verified
on hardware.
