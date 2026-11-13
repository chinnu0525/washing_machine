# Project status

- Target: Digilent Basys 3, XC7A35T-1CPG236C, 100 MHz.
- RTL: modular debounce, washing-cycle FSM, countdown display multiplexer, Basys 3 top.
- Modes: automatic Fill → Wash → Drain → Rinse → Spin → Complete; manual direct-stage selection using SW0–SW4.
- Controls: SW15 mode, center Start/Resume, up Pause/Resume, down Reset, left Idle.
- Display: remaining time in MM:SS; stage and actuator command indicators on LEDs.
- Default stage times: 20 s / 90 s / 15 s / 30 s / 60 s.
- Verification: simulation testbench supplied; Vivado/XSim execution and board validation remain to be run locally.

This is a logic-level FPGA demonstrator, not a mains appliance controller. External actuators require isolated, rated driver hardware and safety interlocks.
