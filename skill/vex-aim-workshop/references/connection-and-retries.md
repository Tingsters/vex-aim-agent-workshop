# One connection across workshop activities

Use the matching released CLI/basic skill. Inspect help before assuming new
flags exist; a source checkout does not update an installed executable.

```sh
"<Tool path>" --json --name NAME session start --persistent --takeover
```

Keep the returned session ID. Persistent mode belongs to the CLI's detached
background owner; no Goose settings or hooks are needed. It keeps reconnecting
to the same selected robot across chats and idle breaks. Credentials stay in
the OS vault; a power cycle does not mean "forget and pair again".

Read cached `session status` after a link failure. `reconnecting` means wait for
automatic repair, then read live `info`. Do not declare sleep from a link error
or a stale battery reading. `auth_required` means background authentication
stopped to allow changed pairing/ownership; do not repeatedly pair or reclaim
the robot. Explain the evidence and follow the student's next connection request.

For a new request or explicit retry, cancel the old action with `stop`, read live
`info`, then run the revised script once. If the native program still blocks
startup, use `session start --persistent --takeover`; this is already authorized
by starting the workshop. Do not ask the child to approve stopping it. Takeover
of a student program is separate from handing Bluetooth to a different computer.

Only retry automatically when `delivery:not_sent` proves the script never
started. An uncertain action remains uncertain; inspect `last_result` and
`last_progress` rather than resending it. Read-only observations can be requested
again after readiness returns. Tell the student what the result establishes.

Explicit "disconnect" / "hand over this robot" means `session close`. This stops
this computer's reconnection attempts and retains credentials. Ordinary activity
completion or closing the chat does not close a persistent session. Native
second-computer pairing/handoff still needs hardware verification: if firmware
does not accept another connection, release from the old computer first. Never
promise all previously stored codes remain valid after another device pairs.

## Windows shells and pairing

Determine the tool's actual shell, not just its OS. PowerShell uses `&` before
a quoted executable path. A CMD tool needs an explicit PowerShell invocation:

```bat
powershell.exe -NoProfile -Command "& (Join-Path $env:USERPROFILE '.agents/skills/vex-aim/bin/vexaim.exe') --json --name AIM1234 session start --persistent --takeover"
```

Prefer an absolute path and argument array in a native process tool. Reuse a
working invocation; don't strip quotes from paths containing spaces.

For pairing, start `bluetooth pair --code-stdin` before asking for the displayed
code. Keep that same process's stdin open across turns and write one code line
to it. Never start a second pairing process to submit the code. If the agent's
tool cannot retain stdin, use the generic skill's packaged pairing bridge; it
uses a private local pipe, finite timeout and no PIN file. Do not improvise a
temporary file mailbox. On Windows any detached helper must be hidden and its
stdio handles must not keep a completed shell call waiting indefinitely.

## Time budgets and results

Use a private Timer and one overall robot-side budget. Default robot behavior
30 seconds, `exec --timeout 60`, outer tool timeout 120 seconds. For longer
activities, allow at least the CLI timeout plus 60 seconds at the outer layer.
The session execution limit is 120 seconds. Bound loops and nonblocking moves
on the robot even when the host has a generous timeout. Stop wheels in `finally`.

Emit concise phase summaries and a final JSON result. Check every timeout or
Boolean failure; do not continue to placement or a victory face after a stalled
move. A CLI `ok:true` only establishes successful Python execution; check the
activity's own result. Do not catch all RuntimeErrors and print a stale outcome.
