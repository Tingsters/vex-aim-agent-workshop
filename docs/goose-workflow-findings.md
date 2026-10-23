# Findings from the workshop experiment

The experiment exposed several independent issues. This summary contains no
pairing codes, photographs or raw conversation export.

| Observation | Evidence and correction |
|---|---|
| Multiple shell attempts to pair | The agent mixed PowerShell and CMD syntax, then tried stdin redirection from a code file that did not yet exist. Start one pairing process, wait until its LCD request is ready, and feed that original process. The CLI now ships a Windows pipe bridge. |
| Barrel not collected | The first routine stopped at a wide bounding box and used a short slow nudge. AIM's magnet is behind the kicker; kit cargo has a metal core. Align first, advance deliberately into contact, and require the requested possession predicate. Width alone never means collected. |
| Excessive searching | The robot reported many turns during an unsuccessful routine. Add accumulated absolute search-angle limits, target-loss handling and one whole-routine deadline, rather than separate long searches alone. |
| Revised routine could report success after a stall | Two motion-wait Boolean failures were ignored. Every finite move must finish or raise; placement and celebration require confirmed possession, approach and release. |
| Host timeout lost the final result | The generated routine used a 55-second CLI budget inside a 65-second shell call, with roughly 10.8 seconds of preparation observed on another call. Use 30 seconds on the robot, 60 for CLI execution and 120 outside it. The CLI separates preparation/upload/execution and retains final outcomes when callers disappear. |
| Old program blocked a retry | The old connector deliberately preserved another program, and the agent asked for extra permission. A new workshop activity or explicit retry authorizes native program takeover on the selected robot. Use that command instead of calling `robot.stop_program()` inside the REPL and losing its reply. |
| Robot awake with face visible, Bluetooth timed out | The old owner still reported cached ready after a closed Windows Bluetooth object and failed maintenance. A face proves neither liveness nor running motion. The CLI now marks reconnecting, rebuilds the selected robot's connection and checks fresh stopped state. |
| Activity finish disconnected future students | Bonded credentials, live connection, program, display and power lease need separate lifetimes. Persistent workshop ownership spans prompts, chats and breaks; explicit handoff closes without forgetting pairing. Actual two-computer AIM handoff remains unverified. |
| Goose picture geometry | The generated rectangles treated the last two arguments as opposite corners. VEX takes width and height on a 240 by 240 screen. The drawing guide now states those dimensions and bounds. |

The first collection script returned a normal unsuccessful result; that is not
proof that it remained running later. The later host timeout also does not prove
Bluetooth failed at that moment. The subsequent immediate closed-object camera
failure does establish a separate stale-session/recovery defect.

[Cargo script and hardware references](../skill/vex-aim-workshop/references/cargo-and-tags.md),
[connection and retry policy](../skill/vex-aim-workshop/references/connection-and-retries.md),
[CLI implementation and stationary evidence](https://github.com/Tingsters/vexaim-cli/blob/main/docs/persistent-workshops.md).

Offline checks require forward contact before cargo can attach and exercise
wrong cargo, wide off-axis targets, failed/stalled contact, missing tags and
success ordering. Independent agents generated whole activities without
additional readiness gates, waited for automatic recovery before image capture,
and preserved the connection after an activity. These checks do not establish
real magnetic pickup geometry, surface accuracy or two-computer radio behavior.
