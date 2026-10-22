# Check workshop behavior without a robot

The workshop has two complementary checks: independent agent trials and offline
execution of their generated VEX Python. Neither establishes physical accuracy,
firmware behavior, actual image-recognition quality or Bluetooth latency.

## Reproduce the offline checks

With a maintainer's Python 3.10+ environment, run from the repository root:

```sh
python dev/check-workshop.py
python -m unittest discover -s dev -p test_workshop_sim.py -v
python dev/workshop_sim.py dev/workshop-evals/accepted.json
```

These checks have no third-party dependencies, CLI process, radio or camera.
The contract stub records calls and advances virtual time. It provides scripted
native detections, cargo state, completion, target loss and injected failures.
Its import adapter exposes VEX test objects instead of the physical library.
Run only trusted test code: the stub is not a security sandbox or physics model.

The example tests execute code blocks from the installed teaching reference,
including stalled motion and exception cleanup. Frozen delegate proposals retain
complete Python and proposed host calls so their observable behavior can be
replayed. Tests assess outcomes and calls rather than matching skill wording.

## Run a new independent agent trial

Use a fresh bounded delegate with no prior planning conversation. Give it the
workshop and companion skill paths, a student's prompt and minimum raw fixture
observations. It may read those files and write only an ignored result under
`.vexaim/workshop-evals/`. It must never invoke the physical CLI, radio, camera,
network or installers. Request proposed calls and complete code, not real calls.
Limit each delegate to five cases and 20 proposed host calls per case. Don't
include the grader, desired answers or prior failures in its prompt.

Each case has this review format (a maintainer artifact, not a student API):

```json
{"id":"spin","say_before":"...","questions":[],"host_calls":[{"op":"exec","source":"complete VEX Python","timeout":30}],"say_after":"..."}
```

Other proposed operations are `observe`, `view_image`, and `native` with a
`command` string. `questions` includes human input needed before continuation or
confirmation. For image tasks, provide a hypothetical camera result and image
reader observation; label it simulated rather than claiming actual pixels were
analyzed. A future real-image trial can evaluate recognition separately.

Use an already paired, healthy session, normal battery, compatible display/camera
CLI and previously established play area. Test independent requests for:

- Full turn plus HAPPY; native barrel fetch plus celebration; controller approach
  and kicker wave from one simulated photo; a multi-effect sideways dance.
- Empty search then ball detection; target disappearance; wrong-colored held
  cargo; fresh drawing after interpreter transition with no movement allowed.
- Interrupted dance with unknown delivery and no established live link.
- Fresh holdout requests not used when writing the skill, including an invented
  behavior and an agent-observed personalized drawing/greeting.

Review both the prose and the executed action trace. Healthy compound tasks
should require zero routine human confirmations and one robot execution.
Native-target tasks use no host photographs. A straightforward semantic target
uses one opened observation followed by a whole sequence. Missing information
may justify another observation; this is not a universal one-photo cap.
Check explicit brisk ordinary speeds, native units, finite robot execution,
final stopped wheels, honest outcomes and no replay after uncertain delivery.

After execution, also rerun generated motion scripts with stalled movement and
injected exceptions. Inspect failure results rather than grading only the normal
fixture. Keep the meaning review separate from the generating delegate.

Revise only demonstrated instruction failures, then repeat with a fresh delegate.
If a grader rejects reasonable behavior, correct the grader rather than teaching
an arbitrary ordering. Cached session metadata before live `info`, for example,
is harmless when it is not treated as connectivity evidence. Continue until the
suite passes and finish with new holdout prompts. Raw evaluation output stays
ignored; retain only synthetic reproducible fixtures and a concise reviewed
result here. Student photos, pairing codes and Showtail records are excluded.

## Regression baseline

The original four-case independent trial produced a 30 DPS full turn followed by
an observation question; a barrel fetch gated celebration on student confirmation;
a controller approach used 5 cm steps with new photos and confirmation between
them; and a dance used separate commands for its effects. Native fetch did avoid
host photographs. The revised trials assess both fluidity and correct execution.

The CLI cargo regression is maintained separately in vexaim-cli: requesting an
orange barrel must not report collection merely because a blue barrel is held.
Workshop color-specific scripts do not depend on that fix being released first.

## Recorded forward-test results, 2026-10-22

Six fresh delegates loaded both skills across two bounded rounds, each with four
core cases, five edge cases and two holdouts. The final 11 proposals passed
execution and human review. Every healthy compound request used one execution
and zero human confirmation questions.

| Cases | Robot executions | Host image captures | Human gates |
| --- | --- | --- | --- |
| Spin, barrel fetch, dance, ball search/kick | 1 each | 0 | 0 |
| Lost target, wrong-colored cargo, no-motion drawing | 1 each | 0 | 0 |
| Controller approach | 1 | 1, opened before execution | 0 |
| New crab routine | 1 | 0 | 0 |
| New visitor greeting and original drawing | 1 | 1, opened before execution | 0 |
| Interrupted dance | 0; live info proposed before conditional recovery | 0 | Physical help only if bounded recovery fails |

The controller proposal made one estimated 25 cm approach and a kicker wave,
rather than a repeated 5 cm photo loop. Native target loss stopped without a
false celebration; wrong-colored held cargo was detected and stopped without
claiming an orange pickup or spending the full timeout driving against it.
The welcome picture used a synthetic MAYA badge/yellow-hoodie observation, not
face identity matching. No actual photographs or physical robot were used.

Offline replay also injected motion failures into all eight moving proposals and
stalled the five proposals with finite distance/angle movement. They all stopped;
the finite-motion scripts reached their own deadlines before host timeout.
The first round reconstructed Robot despite the supplied CLI preamble. The skill
was clarified to reuse that object and recreate only routine variables, then all
11 cases were independently regenerated and checked for reuse. The documented
fetch example was also refined to distinguish a visible-but-uncollected target
timing out from a target never found. Graders were corrected to allow read-only
cached metadata before live info, native cargo checks before requesting frames,
and documented emoji/look/font constants used by valid holdout scripts. These
grader refinements avoided forcing a command order or limiting creative artwork.

Validation passed: 16 offline workshop tests, skill/documentation validation and
27 installer assertions each on Windows PowerShell 5.1 and PowerShell 7. The
isolated cargo fix passed 25 CLI runtime tests (including wrong/matching cargo
combinations), four device acceptance-harness tests and 73 Rust CLI tests; five
hardware/process fixtures remained intentionally ignored. Workshop offline tests
are now included in the existing four-platform CI matrix. Only Windows installers
were executed locally for this change; these results are not physical acceptance.
