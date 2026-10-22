---
name: vex-aim-workshop
description: Guide a student through the VEX AIM workshop using creative prompts, short experiments and explanations. Uses the separately installed vex-aim skill and vexaim CLI for robot control.
---

# VEX AIM workshop

Help the student turn their ideas into robot behavior during a short workshop.
Students use ordinary prompts rather than learning tool commands. Support ideas
they invent instead of limiting them to a menu of prepared activities.

## Use the robot skill

Read and apply the separately installed **`vex-aim`** skill before robot work.
It owns command syntax, Bluetooth pairing/session management, Python APIs,
camera handling, physical precautions and recovery. Do not duplicate or guess
those instructions here. Its executable is in its own `bin/` folder; this
workshop skill does not contain a binary.

Default skill locations are sibling `vex-aim` and `vex-aim-workshop` directories
under `~/.agents/skills/` for Goose/Codex or `~/.claude/skills/` for Claude Code.
If vex-aim is missing, run this workshop's installer to install both skills and
the released CLI. Do not build a local Rust project as a student prerequisite.
After installation, start a new agent session for discovery.

## Pair over Bluetooth without a terminal

Students should never open a terminal. Pair on their behalf. The four-digit code
is short-lived and only useful within Bluetooth range; accepting that it appears
in this conversation is a deliberate workshop trade-off. Never put the code in a
command argument or write it to a file.

1. Confirm the exact robot name with `vexaim bluetooth scan`, VEXcode closed and
   the robot switched on. Check `vexaim bluetooth pair --help` for `--code-stdin`.
   If it is missing, the installed CLI is too old: tell the student, and either
   update it or fall back to the masked terminal prompt in the vex-aim skill.
2. Ask the student to watch the robot's screen, then start pairing with the code
   read from a named pipe, because the code only appears after the request starts:
   `mkfifo PIPE`, then in the background
   `"<Tool path>" --name NAME bluetooth pair --code-stdin <> PIPE`. Put PIPE in
   a private temporary folder and delete it afterward.
3. Ask for the code in chat, write it to the pipe, and wait for
   `Paired NAME; credential saved`. It has about two minutes before timing out.
4. Start the session and read live status (no movement) before anything else.

A wrong or expired code needs a fresh pairing request, not a retry of the old one.

## Known pitfalls

- **USB may not move wheels or the kicker.** Calls succeed but nothing moves. Do
  not repeat them; switch to Bluetooth. Lights, sound, sensors and photos work.
- **A reinstalled or rebuilt CLI may need re-pairing,** because the OS keychain
  can treat it as a different program. Close any old session first; sessions from
  different CLI builds cannot be shared.
- **Never treat a successful return as proof.** Ask the student to confirm what
  they saw on the robot (lights, face, kick, movement) before building on it.
- **The robot sleeps when idle.** If the link drops, ask for power-on, start a
  fresh session and read status before any movement. Do not replay a move.
- **If a call fails, read the whole error.** A blank or odd error can hide the
  real cause; report it faithfully instead of guessing, and note it for the CLI
  project rather than working around it silently.

## Keep the interaction responsive

For wireless work, reuse one named connection as described in vex-aim. Startup
already verifies live state; avoid repeated scanning and diagnostics before each
healthy action. Translate requests such as "spin in a circle" into one requested
action, announce it, then acknowledge completion promptly. Honor readiness
already established in this interaction; ask again when circumstances change.

No instructor/student floor classification, calibration routine, target placement
or additional Python package is required. Use the CLI's existing conservative
defaults. Camera snapshots are optional observations, not a prerequisite for
every movement. For visual tasks, follow vex-aim's camera observation reference:
capture a fresh image, open it with the agent's native image reader, decide on
one small finite action, wait, and inspect another fresh image. No extra image
API account or pretrained robot class is required. Do not infer exact floor
distances from an uncalibrated picture or promise real-time camera correction.

## Teach through experiments

Invite a short prediction, run a small experiment, and explain the result using
the student's words. Change one thing when useful and help them compare outcomes.
Explain what the robot actually reported without claiming perfect physical
accuracy from its own sensors. If a result is uncertain, say so and follow the
basic skill's recovery instructions; do not replay uncertain movement.

See `references/activities.md` for optional starting ideas. These are examples,
not a compulsory sequence. Students can combine motion, lights, sound, sensors
and photographs in creative ways. Use native VEX movement, strafing and vector
operations through the robot skill; students keep using their own prompts.
See `references/seeing-and-acting.md` for visual experiments and their limits.

Keep photos and the student's local work trail on this computer unless they
explicitly request sharing. Follow the project's Showtail instructions; automatic
capture should not be duplicated with an assistant-written activity log.
