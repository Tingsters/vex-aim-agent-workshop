# Compose cargo pickup and marker delivery

Use **vexaim 0.5.0+** and its matching generic skill. Read the generic skill's
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
behaviors.configure(move_mmps=150, turn_dps=45, contact_mmps=200,
                    timeout_ms=30000)
pickup = behaviors.collect(cargo)
delivery = behaviors.deliver(cargo, destination)
robot.led.on(ALL_LEDS, GREEN)
robot.sound.play_note("C6", 200, 50)
robot.screen.show_emoji(Emoji.HAPPY, EmojiLook.LOOK_FORWARD)
print(json.dumps({"pickup": pickup, "delivery": delivery}))
```

Change `cargo` to `ORANGE_BARREL` or `SPORTS_BALL`, and the destination to the
requested individual tag. For fetch alone, omit delivery. For "find it", use
`behaviors.find(cargo)`. For visiting a marker, use `behaviors.approach(TAG0)`.
Combine these with native strafing, turns, sound, lights and drawings as the
student imagines. Helpers raise on failure, so success effects belong after
the calls. No extra human confirmation is needed.

## How to interpret results

The front magnet behind the kicker needs physical contact with the metal-core
cargo. A large bounding box means near, not attached. The CLI deliberately
finishes bounded contact through expected near-field camera loss; distant loss
gets local reacquisition. Collection and marker stand-off are different tasks.

Possession is native vision evidence, not a magnetic-force sensor. Lighting may
make readings intermittent; the CLI filters brief misses and verifies retention.
Don't replace this with one width check, one `has_any_barrel()` call, a slow
series of laptop moves or a fresh photograph after every step. A picture does
not train the native detector to recognize an unfamiliar object.

A failed search, contact, marker approach or release is a useful result: say
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
