# Bluetooth in the workshop

Run the workshop's one-line installer to get vexaim 0.4 or newer and its matching
basic skill, then start a new agent chat. Power on AIM, close VEXcode and give the
agent its exact name. USB is unnecessary. Pairing starts first; then the agent
asks for the four-digit code now on the robot's screen and feeds the original
process over stdin. The code appears in chat, but is never a command argument or
PIN file. Windows agents use the shipped pairing bridge when their shell cannot
keep stdin open across turns. Saved credentials live in the OS vault.

The agent starts one persistent background owner and reuses it across activities,
new chats, agent application closure and workshop breaks. No fixed workshop idle
cutoff applies. It renews a finite robot power lease while running. Camera images
do not need menu navigation, AI Vision LCD mode or reset. Screen effects have a
separate finite display lifetime; a face staying visible is not connection proof.

Ordinary Bluetooth failures trigger automatic reconnection to the same paired
robot. The agent waits for readiness and reads live state instead of immediately
asking for power cycling. Interrupted movement is never silently replayed. Say
"try again" or request a new activity to authorize replacing the previous student
program, checking stopped state and executing one fresh script.

To use another computer, say "hand over this robot" to the old agent. It closes
the session without forgetting pairing. Then connect/pair on the new computer.
Pairing changes stop old-owner reconnect attempts when detected. Automatic
two-computer AIM handoff has not been hardware verified; new pairing may not evict
an already connected client. A computer restart needs a new background session;
a powered-off robot needs its switch. Do not unpair for routine reconnects.

[Detailed connection and retry policy](../skill/vex-aim-workshop/references/connection-and-retries.md)
and [CLI implementation/evidence](https://github.com/Tingsters/vexaim-cli/blob/main/docs/persistent-workshops.md).

During a long instructor test, do physical setup at the beginning and rehearse
an audible computer cue for an unavoidable later action. Never assume the
operator is watching the console. Stationary tests run no wheels or kicker.
