# Compose a whole behavior

Use these as starting points, adapting them to the student's idea. The ordinary
VEX API remains the programming interface; there is no workshop-specific SDK.
Read the basic skill for actual installed API availability and firmware recovery.

Run a complete block with the installed Tool path and retained session ID:

```sh
"<Tool path>" --json --session ID exec --timeout 60 -f behavior.py
```

PowerShell: `& "<Tool path>" --json --session ID exec --timeout 60 -f behavior.py`.
The agent writes the script; the student doesn't need to edit code or use a
terminal. Source stays local, transient on the robot, below the session's 48 KiB
source limit. The session accepts host timeouts of 1..120 seconds. Default to 30 seconds on AIM, 60 for CLI execution, and 120 seconds for the
outer tool call. Setup, upload and cleanup need their own margin. Extend these
budgets deliberately rather than splitting a routine into many host commands.

Every movement example uses nonblocking native calls and a private robot Timer.
Polling happens on AIM, not through the laptop. The deadline still works without
further host traffic. A `finally` stop only stops wheels; it leaves the final LCD
effect available to the owned display session. Do not append CLI `stop` or close
the session after every prompt. Display lifetime follows the installed CLI; do
not promise a drawing will remain indefinitely.

The examples use the observed `Emoji`/`EmojiLook` exports. If the installed SDK
uses different named exports, resolve them as described by the basic skill;
never guess numeric emoji IDs. A display transition may replace the interpreter,
so each script creates its own state and imports are supplied by CLI preamble.
The preamble also supplies the retained `robot` object. Do not add `robot =
Robot()` to these blocks; the CLI recreates its own object if a display transition
requires a new interpreter. Only the routine's custom variables need rebuilding.

## One full turn, then a face

For "spin in a circle and show a happy face", say "I'll spin left once, then
smile." Run the whole sequence. No camera or observation question is needed.

```python
clock = Timer()
def finish_motion():
    while not robot.is_stopped():
        if clock.time(MSEC) >= 20000:
            raise RuntimeError("Routine deadline reached")
        wait(20, MSEC)

try:
    robot.turn_for(LEFT, 360, 90, DPS, False)
    finish_motion()
    robot.screen.show_emoji(Emoji.HAPPY, EmojiLook.LOOK_FORWARD)
    print("Full left turn finished; HAPPY requested")
finally:
    robot.stop_all_movement()
```

## A dance, not a dozen laptop commands

This has sideways movement, a turn, changing lights, a chirp and an expressive
kick without cargo. Use SOFT, MEDIUM or HARD according to the requested game;
there is no mandatory soft-kick test first. Routine bumps are normal play.

```python
clock = Timer()
def finish_motion():
    while not robot.is_stopped():
        if clock.time(MSEC) >= 20000:
            raise RuntimeError("Dance deadline reached")
        wait(20, MSEC)

try:
    robot.led.on(ALL_LEDS, BLUE)
    robot.sound.play_note("C5", 200, 50)
    robot.move_for(150, 270, 150, MMPS, False)
    finish_motion()
    robot.led.on(ALL_LEDS, PURPLE)
    robot.move_for(150, 90, 150, MMPS, False)
    finish_motion()
    robot.turn_for(RIGHT, 90, 90, DPS, False)
    finish_motion()
    robot.kicker.kick(MEDIUM)
    robot.screen.show_emoji(Emoji.HAPPY, EmojiLook.LOOK_FORWARD)
    print("Dance finished")
finally:
    robot.stop_all_movement()
    robot.led.off(ALL_LEDS)
    robot.sound.stop()
```

For diagonal travel use `move_for(distance_mm, angle_deg, speed, MMPS, False)`;
0 is forward, 90 right, 180 back and 270 left. For moving and turning together,
use `move_with_vectors(forward_pct, right_pct, rotation_pct)`, with a finite
robot-side duration and final stop. Vector values are percentages, not MMPS/DPS.

## Find, collect and celebrate with native vision

Use `exec --behaviors` and the released CLI's shared controller for kit cargo.
Read `cargo-and-tags.md` for delivery. Change the native cargo constant to adapt
the activity; keep the control implementation in the CLI.

```python
import json
behaviors.configure(move_mmps=150, turn_dps=45, tag_turn_dps=90,
                    contact_mmps=200, verification="contact", timeout_ms=30000)
result = behaviors.collect(ORANGE_BARREL)
robot.led.on(ALL_LEDS, GREEN)
robot.screen.show_emoji(Emoji.HAPPY, EmojiLook.LOOK_FORWARD)
robot.sound.play_note("C6", 200, 50)
print(json.dumps(result))
```

For "find the ball and kick it", collect `SPORTS_BALL`, then call the native
kicker with the requested strength. For a marker visit, use
`behaviors.approach(TAG0)`. A failed helper raises, stops wheels and skips later
success effects. Search coverage, detection dropouts, magnetic contact, one
local recovery and the shared deadline are handled by the CLI.

Native coordinates are 320x240; bearings are degrees and image widths are pixels.
A photograph is not needed for these trained kit classes. Keep a custom routine
for unfamiliar objects in the agent image workflow instead of pretending the
native model recognizes them.

## An agent-observed controller approach

After opening one fresh photo, use its actual scene to choose a complete route.
For example, if the controller is roughly 40 cm ahead, an estimated 25 cm
approach plus a kicker wave and face can be one script using the dance's finite
motion pattern. Adapt direction and distance to the image. The estimate isn't a
measurement or a reason to demand repeated 5 cm steps. If the image does not
support a useful route, obtain the missing observation instead of inventing one.
The controller has no native AIM class; never put CONTROLLER in `get_data()`.

## Original LCD artwork

For "draw a space cat", generate a compact composition, not thousands of pixel
writes. Adapt shapes and colors to the student's request. For camera-inspired
art, let the agent inspect the image first, then generate the composition.

```python
robot.screen.hide_aivision()
robot.screen.hide_emoji()
robot.screen.clear_screen(BLUE)
robot.screen.set_pen_width(3)
robot.screen.set_pen_color(WHITE)
robot.screen.set_fill_color(PURPLE)
robot.screen.draw_circle(120, 125, 65)
robot.screen.draw_line(65, 90, 70, 35)
robot.screen.draw_line(70, 35, 105, 65)
robot.screen.draw_line(135, 65, 170, 35)
robot.screen.draw_line(170, 35, 175, 90)
robot.screen.set_fill_color(YELLOW)
robot.screen.draw_circle(95, 110, 10)
robot.screen.draw_circle(145, 110, 10)
robot.screen.draw_line(110, 145, 130, 145)
robot.screen.draw_line(65, 135, 25, 125)
robot.screen.draw_line(175, 135, 215, 125)
robot.screen.set_fill_color(BLUE)
robot.screen.print_at("SPACE CAT", x=40, y=220)
print("Original space-cat drawing requested")
```

Screen primitives work without new asset uploads. An actual PNG upload remains
firmware-gated in the CLI; do not bypass that gate, invoke an official uploader
as a student prerequisite, or claim a rejected upload worked. Existing verified
image slots are separate from freshly generated art.
