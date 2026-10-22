# Responsive movement through prompts

Students describe ideas such as "spin in a circle" or "fetch a ball and celebrate".
The workshop skill composes complete routines using the standalone CLI's reusable
Bluetooth session and ordinary VEX Python APIs. Students don't learn commands.

Establish the floor/play area once. A student's request authorizes the movement,
kicker and effects reasonably needed to carry it out. Announce briefly and act;
don't repeat readiness checks or ask for confirmation after every effect.
Ordinary contact with kit objects or sneakers is part of play. Setup remains
stationary, and explicit constraints such as "don't move" still apply.

The workshop supplies explicit speeds of 150 mm/s and 90 degrees/s for ordinary
motion, slowing for tracking/precision or increasing when requested within AIM's
native 200 mm/s and 150 degrees/s limits. The CLI's general defaults remain
80 mm/s and 30 degrees/s. These choices aren't hardware accuracy guarantees.

For compound behavior, send one transient script. Use native forward/backward,
diagonal, strafe and vector operations; avoid a custom individual-wheel mixer.
Use nonblocking motion, a private robot Timer and a final wheel stop so execution
is finite even without more host traffic. Keep the owned session and final face
or drawing; CLI stop/close is not routine cleanup after every prompt.

Prefer on-robot AI Vision feedback for kit cargo, AIM robots, tags and configured
colors/codes. For a controller or unfamiliar scene, the agent opens a fresh
photograph, plans an approximate useful sequence and executes it together.
Take additional images for missing information or meaningful checkpoints, rather
than after every small move. This isn't a real-time laptop camera servo.

No floor labels, calibration station or extra student Python dependency is
required. Surface slip still affects movement, and image geometry is approximate.
Never replay uncertain movement after a connection failure. Report what executed
and what the sensors reported without requiring a student observation gate.

See the skill's [finite composition examples](../skill/vex-aim-workshop/references/fast-behaviors.md)
and [perception guidance](../skill/vex-aim-workshop/references/seeing-and-acting.md).
CLI implementation, timing benchmarks and hardware acceptance remain in the
[CLI movement notes](https://github.com/Tingsters/vexaim-cli/blob/main/docs/motion.md).
Offline workshop evaluations establish script/agent behavior, not physical
accuracy or measured Bluetooth latency.
