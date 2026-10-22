# Ideas to borrow, combine and reinvent

Follow the student's own idea first. Offer a couple of these when they want
inspiration, not a compulsory sequence. Use one complete behavior per request;
the perception column tells the agent which feedback belongs on the robot.

The [official kit inventory](https://kb.vex.com/hc/en-us/articles/40585968773524-Overview-of-the-VEX-AIM-Classroom-Bundle)
lists two sports balls, three blue and three orange barrels, AprilTag signs 0–4,
and a One Stick controller per AIM kit. Fields and walls depend on the bundle.
Do not assume extra robots, custom printed props or markers are available.

## Kit games

| Student prompt | Materials and perception | Whole behavior |
| --- | --- | --- |
| "Find a ball and knock over the barrels." | Ball and stacked barrels; native ball vision. | Search, collect, aim from the arranged scene, kick, celebrate. Inspired by Barrel Knockdown. |
| "Sort the cargo by color." | Blue/orange barrels and tag-marked stations; native classes/tags. | Find the requested color, collect it, travel to its station and place it. Inspired by Arranging Barrels. |
| "Deliver this barrel and celebrate." | Barrel and destination sign; native cargo/tag feedback. | Collect, find the station, deliver, then combine a wiggle, face and sound. Inspired by Cargo Quest. |
| "Be a goalie." | Sports ball; native ball tracking. | React to bearing with sideways travel, then kick when the ball is collected. Run for a finite requested interval. |
| "Take me on an aquarium adventure." | Signs 0–4; native tag feedback plus agent-authored content. | Generate a story and simple sea-creature drawings, visit the chosen stations and reveal each panel. Inspired by Aquarium Adventure. |
| "Make a ridiculous robot dance." | Robot only; no camera. | Compose side steps, diagonal movement, turns, lights, sounds and expressive kicks in one script. |
| "Play a touch-and-shake pet." | Robot only; native touch/inertial readings. | React to touch or a gentle stationary shake with faces and sounds; no photo loop. |
| "Follow the other robot." | Optional second AIM; native AIM_ROBOT detections. | Follow for a finite interval with on-robot feedback. Use only when a second robot is available. |

The inspirations above come from [VEX AIM Activities](https://education.vex.com/stemlabs/aim/activities).
The agent adapts the ideas to prompts and available equipment; students don't
need to reproduce the official button-coding or controller instructions.

## Things an agent adds

These use open-ended image interpretation or generation beyond AIM's native
object classes. The agent chooses content; AIM performs the resulting program.

| Student prompt | Agent contribution | Robot payoff |
| --- | --- | --- |
| "Find my controller and wave hello." | Recognize the kit's controller from one opened photo and plan an approximate route. | Approach, wave the kicker and show a face in one script. |
| "Give each visitor a different greeting." | Interpret introduced participants using agreed visible cues, such as clothing or a name badge. | Choose a personalized face, sound, drawing and greeting dance. |
| "Draw me as a space monster." | Inspect a consenting participant's photo and invent a compact cartoon using LCD primitives. | Show original art, rather than a stock emoji. |
| "Turn these objects into a robot story." | Recognize ordinary props and invent characters, plot and illustrations. | Perform a short illustrated scene with movement, sound and expressions. |
| "Read this clue and visit the answer." | Read a supplied card and reason about the destination. | Use native tags to navigate once the agent has chosen the answer. |
| "Which pile has more? Celebrate the winner." | Compare a visible arrangement of ordinary objects, including ones outside the native model. | Choose the corresponding station, color and celebration. |

Ask for physical setup only when an activity actually needs a new prop or
participant. Do not turn the table into a preparation checklist for every child.
Use existing consent for camera activities; keep photographs local. Generate
art with supported drawing primitives instead of depending on a gated PNG upload.

For a 90-minute workshop, offer an immediate expressive success, leave most time
for the children's ideas, and finish with their own demonstration. Predictions,
"what changed?" and "what next?" can enrich play after action; they are never
required before the robot executes a healthy request.
