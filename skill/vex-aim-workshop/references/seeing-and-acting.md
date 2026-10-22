# Choose where the seeing happens

Students ask ordinary questions. The agent handles images and scripts; they
don't need an image API account, a live stream or an extra Python package.

## Native robot vision for fast feedback

Prefer native AI Vision for sports balls, blue/orange barrels, AIM robots,
AprilTags and configured color/code signatures. Search, align, approach, react
and finish in one finite robot script. Feedback stays on AIM, typically with
50 ms waits, rather than crossing Bluetooth to the language model each time.
See `references/fast-behaviors.md` for a complete search/collect/celebrate example.

Native detections are 320x240 pixels. Filter empty results and the requested
class/ID; use bearing for direction and the appropriate cargo predicate for
collection. Pixel width is a proximity cue, not a millimetre range measurement.
The native model cannot recognize an arbitrary controller, person or drawing.
Configured colors/codes must actually exist; don't invent a trained signature.

## Agent image understanding for meaning

Use the companion skill's camera transport instructions to capture a native
photograph, normally `--json --session ID camera observe`. Open the returned
absolute image path with Codex `view_image` or Claude Code `Read` in that same
turn. A filename, JSON detections or a desktop preview is not seeing the image.
If the installed CLI lacks this command, use its documented native snapshot
workflow when supported, or explain the version limitation.

The agent can recognize a VEX controller, read a clue, compare objects, interpret
gestures or design a response to a scene. Empty native detections do not mean
that the photograph failed. Do not claim the robot learned a new native class.

After one useful observation, plan and execute the whole requested sequence.
For "go to my controller and wave", use an approximate approach, the kicker
wave and an expressive ending in one finite script. Ordinary contact is fine.
Do not default to repeated 5 cm movements, camera transfers and student checks.
Geometry can be approximate; describe it as an estimate. When the image doesn't
support a route, get the missing information rather than inventing distance.

Another image is useful when a target moved, the first image is ambiguous,
a search needs a new view, or a later story/game checkpoint needs interpretation.
It is not mandatory after each motion or to verify every effect. Laptop snapshots
are observations for planning, not a real-time camera servo.

## Combine semantic choices with native tracking

The agent can choose "the orange barrel beside the controller" from a scene,
then use native barrel feedback for execution. If several orange barrels are
visible, retain the spatial selection instead of silently switching to whichever
is largest. Use a supported tag or configured color as a tracking proxy only
when it actually identifies the target. If no reliable native proxy exists,
execute the agent-planned sequence and inspect again at a useful checkpoint.

For people games, use introduced participants and agreed visible cues such as
name badges or clothing. Let the agent choose greetings, gestures or story
roles. Don't describe this as AIM's native face recognition or autonomous model
training. Use the session's stated photo consent; ordinary agent image analysis
needs no separate upload service. Keep reference photos local and temporary.

## Create and show original artwork

A student can ask for an invented character, a camera-inspired portrait or
illustrations for a story. Generate compact VEX screen drawing code using lines,
circles, rectangles, text and colors, then show it in one execution. Hide the
AI Vision/emoji overlays before drawing. The LCD is 240x240; it is independent
of the 640x480 camera photograph and the 320x240 detector coordinates.
See `references/fast-behaviors.md` for an original space-cat example.
This is agent-created artwork, not merely selecting a built-in emoji.

Use named emoji constants and contrasting text/background colors. The companion
skill's matching display-capable CLI handles program ownership over Bluetooth;
no saved project, reset or menu navigation is needed. Create custom variables
inside each script because a display/system-REPL transition can replace them.
Keep the session open after a routine and stop wheels through the robot API so
the final drawing can remain. The CLI's display lifetime still applies.

New PNG asset uploads remain gated until their firmware encoding is verified.
Don't make a student use VEXcode, bypass the gate or report an unsupported upload
as successful. Prefer generated drawing primitives; existing supported image
slots can also be used when they already contain the required artwork.

## Recover without derailing play

Keep transport/firmware troubleshooting and sustained-power evidence in the
basic skill. A healthy session is reused across prompts; don't start private
SDK experiments or promise that traffic prevents sleep. After a link failure,
recover live state without replaying the old movement. Ask for power-on only
if required. Unattended maintenance uses the basic skill's up-front setup and
rehearsed computer cue; it is separate from these ordinary play activities.

Keep photographs, scripts and the student's Showtail trail local unless sharing
is explicitly requested. Don't add photos to Git or duplicate automatic capture.
