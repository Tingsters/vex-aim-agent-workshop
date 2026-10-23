---
name: vex-aim-workshop
description: Turn students' creative prompts into fast, playful VEX AIM behaviors. Compose movement, kicker, sensors and effects with the separately installed vex-aim skill; choose native robot vision or agent image understanding for the task.
---

# VEX AIM workshop

Help the student turn their ideas into robot behavior during a short workshop.
Students use ordinary prompts rather than learning tool commands. Support ideas
they invent instead of limiting them to a menu of prepared activities.

## Use the robot skill

Read and apply the separately installed **`vex-aim`** skill before robot work.
It owns command syntax, Bluetooth pairing/session management, Python APIs,
camera transport and recovery. **For this workshop, the interaction, motion pace
and perception choices below replace the basic skill's conservative defaults,
per-action observation checks and small-move/photo/repeat workflow.** Keep its
transport and firmware requirements. Its executable is in its own `bin/` folder;
this workshop skill does not contain a binary.

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
2. Ask the student to watch the robot's screen, then start pairing with stdin
   held open: the code appears only after the request starts. Use a persistent
   tool process with writable stdin when available. For Windows CMD/PowerShell
   and tools without process stdin, follow `references/connection-and-retries.md`.
3. Ask for the code in chat, write it to the pipe, and wait for
   `Paired NAME; credential saved`. It has about two minutes before timing out.
4. Start with `--name NAME session start --persistent --takeover`. Startup reads
   live state without movement. Check `session start --help` for these flags;
   update the released CLI/basic skill together if they are missing.

After stationary setup, warm the shared helpers once with
`--session ID exec --behaviors "pass"`. This loads them before the first play
request. Reuse the owner; don't repeat warmup or status checks before every
healthy activity.

A wrong or expired code needs a fresh pairing request, not a retry of the old one.

## Known pitfalls

- **USB may not move wheels or the kicker.** Calls succeed but nothing moves. Do
  not repeat them; switch to Bluetooth. Lights, sound, sensors and photos work.
- **A reinstalled or rebuilt CLI may need re-pairing,** because the OS keychain
  can treat it as a different program. Close any old session first; sessions from
  different CLI builds cannot be shared.
- **Report evidence accurately without an observation gate.** Continue a script
  using sensor results and command completion. Don't require the student to
  confirm every light, face, kick or movement. Say what ran or what the sensors
  reported; don't claim exact physical accuracy from an acknowledgment.
- **A dropped link is not proof of sleep.** Let persistent-session recovery run;
  inspect cached status before asking for a power cycle. Never replay uncertain movement. Use its
  published firmware compatibility evidence rather than private keepalive probes.
- **If a call fails, read the whole error.** A blank or odd error can hide the
  real cause; report it faithfully instead of guessing, and note it for the CLI
  project rather than working around it silently.

## Hear an idea, perform it, then explain

For wireless work, reuse one named connection as described in vex-aim. Startup
already verifies live state; avoid repeated scanning and diagnostics before each
healthy action. Establish a floor/play area once at the start. The student's
request authorizes the reasonable movement, kicker actions and effects needed
to carry out that idea. Give one short announcement and execute; do not ask
"ready?", "may I move/kick?" or "did that work?" before continuing a healthy task.
Ordinary bumps into kit objects or sneakers are normal play, not an automatic
failure. Expressive kicks can be part of a dance or greeting without cargo.

Keep the persistent owner across prompts, chats, student changes and workshop
breaks, including when the agent app closes. Pairing credentials remain local
across days. Do not close the connection at activity completion or ordinary
wrap-up. Explicit "disconnect" or "hand over this robot" releases it without
forgetting pairing. Another computer's pairing must not cause this computer to
fight for control. Automatic handoff depends on the tested firmware; if a second
computer cannot pair while connected, perform one explicit handoff. See
`references/connection-and-retries.md` for recovery and Windows invocation.

"Try again" or a new activity authorizes replacing the current student program
on this selected robot without another question. Cancel superseded work, check
live stopped state and execute the revised activity once. This differs from
automatically replaying a movement after uncertain delivery.

Compose a compound request into **one transient Python execution** with its
whole sequence and robot-side decisions. Use a single native command for a
simple action; don't add steps just to satisfy a batching rule. A dance can
strafe, turn, kick, blink and chirp in one script. Reuse the session afterward.
The CLI preamble already supplies VEX imports and `robot`: reuse that Robot
object. Recreate your routine's timers/variables inside each execution, not a
second Robot instance, including after a CLI-managed display transition.

Explicitly use **150 MMPS and 90 DPS** for ordinary workshop motion instead of
the CLI's unchanged 80 MMPS/30 DPS defaults. Honor faster requests within native
limits (200 MMPS/150 DPS); slow down when tracking or precision calls for it.
These are play defaults, not claims of measured accuracy on every surface.
Use native holonomic motion rather than mixing individual wheel speeds.

Make custom movement finite on the robot itself: use a private Timer, bounded
loops and nonblocking motion with deadline checks. Stop wheels in `finally`.
The host exec timeout alone is insufficient if the link disappears. Budget
up to 30 seconds for an ordinary routine, 60 seconds for CLI execution and 120
seconds for the outer shell/tool call. Extend deliberately for a longer game;
setup, source transfer and cleanup need time too. Keep source/timeout within
the basic skill's session limits, and check every movement-wait result. Use
`robot.stop_all_movement()` for routine cleanup so the final face/drawing stays
visible; reserve CLI `stop` for stopping/cancelling work. Never automatically
replay a sequence after uncertain delivery. Follow an explicit "don't move" or
other student constraint even when adding creative effects.

See `references/fast-behaviors.md` for adaptable, finite VEX Python examples.
Do not turn these examples into a fixed menu or require a new student SDK.
For pickup and delivery, read `references/cargo-and-tags.md`: collection needs
deliberate magnetic contact and the requested cargo predicate. Use vexaim
**0.5.1+** with `exec --behaviors` and its matching generic skill. Compose the
CLI's `behaviors.find`, `collect`, `approach` and `deliver` with native effects;
do not regenerate or copy vision-control loops into workshop scripts. Check
`exec --help` once before play and update the released tool/basic skill if the
flag is absent. Configure 150 MMPS approach, 45 DPS cargo acquisition, 90 DPS
between tag views, 200 MMPS contact, `verification="contact"` and a shared
30-second budget. The CLI handles brief stationary tag views internally.
Normal play assumes a bounded contact attempt worked and continues to the tag
without a retention reverse, repeated possession gates, laptop photographs or
agent analysis between steps. Treat `completed: true` with assumed evidence as
routine completion; a null confirmation field is not a new failure or a request
to photograph the robot. Diagnostic `verification="vision"` is for explicit
testing. A missing target, expired activity or transport error still stops work.
Report that the routine ran; don't claim independent physical verification when
its evidence is assumed. Save camera inspection for an explicit visual request,
an unfamiliar target or a failure that needs a different strategy.

If the user requests unattended stationary work, gather setup and pairing up
front and rehearse an audible cue from the computer. Confirm they heard it and
explain that it means return for one specific action. Pause and checkpoint before
later intervention; do not assume the user watches chat. Follow vex-aim's
unattended-work reference when available. This is a workflow for maintenance,
not a reason to interrupt ordinary workshop play with extra confirmations.

No instructor/student floor classification, calibration routine, target placement
or additional Python package is required. Choose perception by the task:

- **No visual decision:** execute directly, without a photograph.
- **Kit ball, blue/orange barrel, AIM robot, AprilTag, configured color/code:**
  prefer native AI Vision feedback within the script. Search, align, approach,
  collect/place/kick and celebrate without host photos or LLM round trips.
- **Controller, unfamiliar object, people, writing or scene meaning:** capture
  and open an image with the agent's native image reader in the same turn.
  Plan a complete useful sequence from that observation and run it together.
  Approximate geometry is fine; don't claim exact range from uncalibrated pixels.
- **Hybrid:** use agent understanding to select a supported target or strategy,
  then use native vision for movement feedback. A photo does not train a new
  native object class. Don't pretend native vision recognizes faces/controllers.

Take another host photo when new information or a meaningful checkpoint needs
it, not automatically after every short move. Missing targets may need a bounded
search; genuinely ambiguous goals may need a question. No extra image API account
or real-time Bluetooth camera streaming is required. Read
`references/seeing-and-acting.md` for image handling, people and LCD artwork.

## Teach through experiments

Act promptly, then explain briefly using the student's words. Offer predictions,
comparison and reflection when useful; they are not gates before execution.
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
