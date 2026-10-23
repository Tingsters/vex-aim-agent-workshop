# Magnetic pickup and marker delivery

The magnet behind AIM's kicker attracts the metal-core kit barrels and ball.
Collection requires deliberate physical contact. A large camera bounding box
means close, not collected. Use the requested `has_blue_barrel`,
`has_orange_barrel` or `has_sports_ball` predicate. Do not substitute
`has_any_barrel` for a particular color. These APIs report possession; report
their evidence without claiming measured grip force or exact final placement.

Official collection macros keep driving until possession, while AprilTag
approach uses a visual stand-off (the official example starts with width 60).
References: [VEX macros](https://api.vex.com/aim/home/python/Macro.html) and
[robot features](https://kb.vex.com/hc/en-us/articles/35994363720340-Features-of-VEX-AIM).
The student's observed need for a brisk contact stroke informs this example;
it is not a claim that every surface requires maximum-speed impact.

## Find the blue barrel, place it near Tag 0, then celebrate

One execution contains search, alignment, contact, one automatic retry,
delivery and effects. Adapt target, destination and effects to the child's idea.
For fetch without delivery, omit the Tag 0 and placement section. For orange
cargo or the ball, change both the model target and its possession predicate.
Use 60 seconds for CLI execution and 120 for the outer tool call.

```python
import json
clock = Timer()
phase = "starting"
reason = "not_found"
search_degrees = {}

def progress(value):
    global phase
    phase = value
    print('__VEXAIM_EVENT__' + json.dumps({"event": "progress", "phase": value}))

def check_deadline():
    if clock.time(MSEC) >= 30000:
        raise RuntimeError("Routine deadline reached during " + phase)

def finish_motion(limit_ms=3000, collected=None):
    began = clock.time(MSEC)
    while not robot.is_stopped():
        check_deadline()
        if collected is not None and collected():
            robot.stop_all_movement()
            return
        if clock.time(MSEC) - began >= limit_ms:
            raise RuntimeError("Movement deadline reached during " + phase)
        wait(25, MSEC)

def approach(target, width, collected=None):
    global reason
    began = clock.time(MSEC)
    last_seen = None
    previous = robot.inertial.get_rotation()
    key = str(target)
    search_degrees.setdefault(key, 0)
    while clock.time(MSEC) - began < 10000:
        check_deadline()
        rotation = robot.inertial.get_rotation()
        search_degrees[key] += abs(rotation - previous)
        previous = rotation
        if search_degrees[key] >= 360:
            robot.stop_all_movement()
            reason = "not_found"
            return False
        if collected is not None and collected():
            robot.stop_all_movement()
            return True
        objects = [o for o in robot.vision.get_data(target, 4) if o.exists]
        if objects:
            last_seen = clock.time(MSEC)
            obj = max(objects, key=lambda o: o.width)
            if abs(obj.bearing) > 10:
                robot.turn(LEFT if obj.bearing < 0 else RIGHT, 60, DPS)
            elif obj.width >= width:
                robot.stop_all_movement()
                return True
            else:
                robot.move_at(obj.bearing, 150, MMPS)
        elif last_seen is None and search_degrees[key] < 360:
            robot.turn(RIGHT, 60, DPS)
        else:
            robot.stop_all_movement()
            if last_seen is None:
                reason = "not_found"
                return False
            if clock.time(MSEC) - last_seen >= 600:
                reason = "target_lost"
                return False
        wait(50, MSEC)
    robot.stop_all_movement()
    reason = "timed_out"
    return False

try:
    robot.vision.model_detection(True)
    robot.vision.tag_detection(True)
    progress("collecting_blue")
    for attempt in range(2):
        if robot.has_blue_barrel():
            break
        if not approach(BLUE_BARREL, 90, robot.has_blue_barrel):
            raise RuntimeError(reason)
        if not robot.has_blue_barrel():
            progress("contact")
            robot.move_for(200, 0, 200, MMPS, False)
            finish_motion(2000, robot.has_blue_barrel)
            wait(100, MSEC)
        if robot.has_blue_barrel():
            break
        if attempt == 0:
            progress("realigning")
            robot.move_for(50, 180, 150, MMPS, False)
            finish_motion()
    if not robot.has_blue_barrel():
        raise RuntimeError("not_collected")
    progress("finding_tag_0")
    if not approach(TAG0, 60):
        raise RuntimeError("tag_0_" + reason)
    if not robot.has_blue_barrel():
        raise RuntimeError("cargo_lost_before_placement")
    progress("placing")
    robot.kicker.place()
    wait(300, MSEC)
    robot.move_for(100, 180, 150, MMPS, False)
    finish_motion()
    if robot.has_blue_barrel():
        raise RuntimeError("cargo_not_released")
    progress("complete")
    robot.led.on(ALL_LEDS, GREEN)
    robot.screen.show_emoji(Emoji.HAPPY, EmojiLook.LOOK_FORWARD)
    print(json.dumps({"ok": True, "phase": phase, "collected_blue": True,
                      "released_near_tag": 0, "elapsed_ms": clock.time(MSEC)}))
finally:
    robot.stop_all_movement()
```

Every timed movement either completes or raises; an unsuccessful wait cannot
fall through to success. Width is pixels, not metric range. The 200 mm contact
advance is a maximum, with early stop on possession. It is not a mandatory
open-loop charge. An unseen target ends a bounded search rather than many laps.
Adjust geometry for the requested game while retaining a whole-routine deadline.
