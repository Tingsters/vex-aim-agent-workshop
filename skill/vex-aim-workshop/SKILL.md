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

## Keep the interaction responsive

For wireless work, reuse one named connection as described in vex-aim. Startup
already verifies live state; avoid repeated scanning and diagnostics before each
healthy action. Translate requests such as "spin in a circle" into one requested
action, announce it, then acknowledge completion promptly. Honor readiness
already established in this interaction; ask again when circumstances change.

If the user requests unattended stationary work, gather setup and pairing up
front and rehearse an audible cue from the computer. Confirm they heard it and
explain that it means return for one specific action. Pause and checkpoint before
later intervention; do not assume the user watches chat. Follow vex-aim's
unattended-work reference when available. Movement still requires someone nearby.

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
