# See, decide, try, compare

Use the separate vex-aim skill's device and agent-vision references. Students ask
ordinary questions; the agent handles commands, connections and opening images.
These experiments need the matching CLI command release with `camera observe`.

Invite the student to put an object in front of AIM and ask "What can you see?"
Capture and open the image within the same agent turn. The agent can recognize
ordinary objects, including things outside AIM's ball/barrel/robot model. Native
AI Vision detections are a separate optional observation, not a prerequisite.

A VEX controller is a useful example: the agent can recognize it from the photo
even when AIM's native detector returns no objects. Explain which recognition
path produced the answer. Do not treat an empty native result as a failed camera
capture or claim that the robot has learned a new object class.

For "turn until you're looking at my controller", inspect a fresh image, announce
one small bounded turn, wait for completion, then inspect a second image. Stop
when the request is satisfied or evidence is unclear. Preserve physical readiness
and never repeat movement whose delivery is uncertain. A slow Bluetooth snapshot
loop is an experiment in observation and decisions, not a real-time driving system.

For "slide sideways and keep facing me", use native strafing or vector motion.
Ask for a prediction and compare before/after images. Explain wheel slip and why
different floors change results. The built-in gyro and odometry report what the
robot estimates; an image alone does not establish a distance in millimetres.
No floor labels, calibration mat or separate student Python setup is required.

Other ideas: touch-controlled lights; compare acceleration when gently tilting a
stationary robot; recognize a color and choose an emoji; look for an AprilTag;
watch a button on an already connected One Stick; exchange messages between two
already linked AIMs. Missing firmware methods should produce a clear limitation,
not a fabricated reading. Kicker and motion tests require clearance and an
advance announcement, including expressive macros that move the robot.

Verify visible screen effects before building an activity around them. The
0.3.0-rc.5 CLI fixes hidden Bluetooth drawing on the tested early firmware by
activating and maintaining the program display. Use the matching CLI/basic skill
and a reusable session; students can ask for a face, message or drawing directly.
Use named emojis and contrasting text/background colors. Stop/close or one minute
without activity returns the display to its menu. Native camera photographs
remain independent. On older binaries or unsupported firmware, explain the
actual limitation and use lights/sounds as feedback instead.

Sustained Bluetooth power management is still under investigation. The unreleased
rc.6 candidate received successful System Alive replies but still lost the robot
around five minutes. Do not promise that it prevents sleep or ask students to
maintain an unverified keepalive workaround. Use a published matching CLI/skill.
Keep a healthy owned session across prompts and close at actual wrap-up. For an
unattended stationary check, collect charging/power-on/USB/VEXcode setup up front
and automate the remaining checks. Movement still requires a person nearby.

Maintainers can follow the CLI's
[display investigation](https://github.com/Tingsters/vexaim-cli/blob/main/docs/display-investigation.md)
for the protocol evidence and diagnostic matrix. Keep developer probes out of
student setup. The fix works over Bluetooth without a saved project; USB is a
diagnostic comparison only.

Keep photos local and ignored by Git. Explain a result promptly in the student's
words; do not append unrelated reporting work after every action. Showtail's
automatic trail records their prompts and code; don't add photos or duplicate logs.
