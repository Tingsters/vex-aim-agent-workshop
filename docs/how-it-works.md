# How it works

## The robot's USB port

A VEX AIM plugged in over USB (vendor `2888`, product `0700`) presents a composite device:

| USB interface | What it is |
|---|---|
| 0 | CDC-ACM serial: the **system** port (VEX protocol: version query, file listing, program control) |
| 2-3 | UVC **camera** (640x480, 30 fps, MJPG and H.264) |
| 4 | CDC-ACM serial: the **user** port, a **MicroPython REPL** (MicroPython 1.22 on an ESP32) |

The robot runs MicroPython with the `vex` and `aim` modules. Typing Python into the user port runs it on the robot.

## What `vexaim` does

- **Discovery and I/O** use `vex-v5-serial` (`serial::find_devices()`, `Connection::read_user/write_user`).
  Upstream did not recognise the AIM's user port (it assumed the V5 Brain layout, interface 2); the vendored patch
  fixes that. See `cli/vendor/README.md`.
- **`exec`** switches the REPL to *raw mode* (Ctrl-A), sends the code followed by Ctrl-D, and parses the reply
  `OK <stdout> \x04 <stderr> \x04 >`. Variables persist between calls, and `robot = Robot()` plus the VEX imports are
  created automatically (`from vex import *`, `from vex_globals import *`). On timeout the program is interrupted
  (Ctrl-C).
- **`stop`** interrupts the running program and stops the wheels and sound.
- **`snap`** reads one frame from the robot's UVC camera through the operating system's camera API (Video4Linux,
  Media Foundation, AVFoundation) and saves the JPEG. The camera needs no robot-side code.
- **`doctor`** checks: robot detected, both ports found, ports openable, REPL answers.

- **Windows** uses a different I/O adapter than macOS/Linux (the upstream one does not compile there); see
  `cli/vendor/README.md` and `docs/hardware-notes.md`.

## Things worth knowing (verified on real hardware, Linux)

- **Large output is lost.** More than about 2 KB printed in one burst overflows the robot's USB output buffer; the
  rest of the output and the end-of-message marker never arrive. Paced writes (about 250 bytes with a 50 ms gap) delivered
  5 KB intact. `vexaim` prints a hint when a call times out with large partial output.
- **Position frame.** `robot.get_x_position()/get_y_position()` use a frame fixed to heading 0 degrees, not the robot's
  current facing.
- **`robot.get_name()` does not exist** on the tested firmware (1.0.0-beta.2) even though the public docs list it.
- **Constants** like `ALL_LEDS` or `RED` only exist after `from vex_globals import *` (done automatically).
- **Camera orientation** is whatever the sensor sees; an upside-down robot gives rotated frames.

## Why not VEXcode, Wi-Fi or Bluetooth?

USB needs no network setup on a venue's Wi-Fi and no VEX software on the student's laptop, which is the point of the
workshop. VEX also offers a Wi-Fi WebSocket API; it needs the laptop and robot on a shared network, which venues often
block. Bluetooth is not implemented yet.
