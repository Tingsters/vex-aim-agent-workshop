# Hardware evidence

The executable and its hardware evidence now live in the standalone CLI project.
See [hardware notes](https://github.com/Tingsters/vexaim-cli/blob/main/docs/hardware-notes.md),
[Bluetooth investigation](https://github.com/Tingsters/vexaim-cli/blob/main/docs/bluetooth.md)
and [movement acceptance](https://github.com/Tingsters/vexaim-cli/blob/main/docs/motion.md).

CI build/install checks cover Windows x86_64, Linux x86_64, macOS Apple Silicon
and macOS Intel. They do not exercise physical robots. Original Windows USB/BLE
and Linux USB tests remain evidence for their tested configurations; macOS
hardware and the newest session/helper behavior require separate verification.

Do not claim all permitted speeds/surfaces have passed or that the robot's own
IMU proves physical accuracy. The workshop does not require calibration.
