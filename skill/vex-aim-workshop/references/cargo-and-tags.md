# Compose cargo pickup and marker delivery

Use **vexaim 0.5.2+** and its matching generic skill. Read the generic skill's
`references/behaviors.md` for the exact API. The CLI owns search, alignment,
near-field contact, possession filtering, one recovery attempt, deadlines and
release checks. This workshop chooses the task, pace and effects.

## Collect the chosen cargo, deliver it, then celebrate

Submit this whole activity with:

```sh
"<Tool path>" --json --session ID exec --behaviors --timeout 60 -f activity.py
```

Use at least 120 seconds for the outer tool, preferably 150. Reuse the existing
persistent session. If `exec --help` lacks `--behaviors`, update the released
CLI/basic skill once before play; do not copy control loops into the activity.

```python
import json
cargo = BLUE_BARREL
destination = TAG0
behaviors.configure(move_mmps=150, turn_dps=45, tag_turn_dps=90,
                    contact_mmps=200, verification="contact", timeout_ms=30000)
pickup = behaviors.collect(cargo)
delivery = behaviors.deliver(cargo, destination)
robot.led.on(ALL_LEDS, GREEN)
robot.sound.play_note("C6", 200, 50)
print(json.dumps({"pickup": pickup, "delivery": delivery}))
```

Change `cargo` to `ORANGE_BARREL` or `SPORTS_BALL`, and the destination to the
requested individual tag. For fetch alone, omit delivery. For "find it", use
`behaviors.find(cargo)`. For visiting a marker, use `behaviors.approach(TAG0)`.
Combine these with native strafing, turns, sound, lights and drawings as the
student imagines. Helpers raise on failure, so success effects belong after
the calls. No extra human confirmation is needed. Include a smile or drawing
when requested; a short LED/chirp finish avoids unrequested LCD activation.

"The purple 0 tag" means `TAG0`, not a new purple object class. Brief stationary
tag views run inside the CLI; don't recreate a scan or add laptop camera calls.
The successful blue-to-purple-0 test used this acquisition pattern. Normal
play submits one activity and continues through pickup, tag approach and gentle
kicker placement. It does not pause for a second agent turn after pickup.

## How to interpret results

The front magnet behind the kicker needs physical contact with the metal-core
cargo. A large bounding box means near, not attached. The CLI deliberately
finishes bounded contact through expected near-field camera loss; distant loss
gets local reacquisition. Collection and marker stand-off are different tasks.

Possession is native vision evidence, not a magnetic-force sensor. A physically
attached barrel returned false repeatedly in testing. For workshop play,
`verification="contact"` accepts deliberate, bounded contact with the selected
nearby cargo and continues even when the detector cannot confirm attachment.
It omits the diagnostic retention reverse and later possession gates. A contact
that meets a pen wall can end at its local time limit and still count as an
attempt, once stopped; the whole-activity deadline remains enforced.

Read `completed` and `evidence`, without adding a new confirmation gate.
`contact_assumed`, `place_assumed` and `near_marker_assumed` are expected play results: `collected` or
`delivered` may be null while `completed` is true. Finish the requested effects
and say the routine ran. Don't turn these nulls into camera checks or ask the
child whether it worked. Use `verification="vision"` only for explicit
measurement/testing that needs retention and release confirmation.

At close-range arrival the carried barrel may hide the tag. The CLI first uses
the observation already obtained during acquisition; in contact mode it can
also accept a recent aligned near-tag sighting and finish gentle kicker
placement. It stops the approach before placing, with no extra forward charge
or turn away to reacquire. Missing or distant markers still fail. Keep this
decision on the robot rather than adding a new laptop image or child question.

Keep the child-facing response brief: "Done—the pickup-and-delivery routine
finished." Evidence fields belong in the result log. Don't narrate verification
modes or add an uncertainty caveat after every normally completed play routine;
explain the technical evidence when asked.

A failed search, marker approach or activity is a useful result: say
which phase failed. Do not call a timeout a Bluetooth failure without evidence.
When the original goal still needs a new strategy, a single agent camera image
can explain clutter, a tilted barrel or an obstructed approach. Recover live
stopped state first, then plan a fresh bounded approach from that observation.
Don't repeat the same failed line of contact or ask the child to reset objects
as the default recovery. Native kit detection cannot describe arbitrary clutter.
"Try again" authorizes stop/live-state recovery and one new activity, not
automatic replay of uncertain movement. Read `connection-and-retries.md`.

Sources: [official macros](https://api.vex.com/aim/home/python/Macro.html),
[physical features](https://kb.vex.com/hc/en-us/articles/35994363720340-Features-of-VEX-AIM),
[detection limitations](https://github.com/VEX-Robotics/AIM_Websocket_Library/issues/19).
Native acquisition needs time to see an object while turning; 45 DPS is the
workshop starting setting. This does not slow the 150 MMPS approach or bounded
200 MMPS contact. Hardware results and limitations belong in the CLI evidence.
