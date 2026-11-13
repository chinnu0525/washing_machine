# Automatic Washing Machine Controller — Basys 3

A Verilog RTL controller for a demonstrator washing-machine sequence on the Digilent Basys 3 (XC7A35T-1CPG236C). The design provides automatic and manual stage operation, a per-stage MM:SS countdown on the four-digit seven-segment display, debounced controls, and status LEDs.

## Stages

| Stage | Default duration | Output model |
|---|---:|---|
| Fill | 20 s | Inlet valve |
| Wash | 90 s | Wash motor |
| Drain | 15 s | Drain pump |
| Rinse | 30 s | Inlet valve + rinse motor |
| Spin | 60 s | Spin motor |
| Complete | Latched | Done LED |

All durations are parameters in seconds and are below two minutes. For simulation, override `CLK_HZ` and stage-duration parameters to shorten runs.

## Board controls

- `SW15=0`: automatic cycle; `SW15=1`: manual stage test.
- `SW0..SW4`: select Fill, Wash, Drain, Rinse, Spin respectively. Select exactly one switch in manual mode.
- Center button: Start / resume.
- Up button: Pause / resume.
- Down button: Reset to Idle.
- Left button: return to Idle.
- Seven-segment display: remaining `MM:SS` for the active stage.
- LEDs: stage/status and actuator-command indicators.

## Build and simulate

Open `vivado/create_project.tcl` in Vivado Tcl Console or run `vivado -mode batch -source vivado/create_project.tcl`. The project targets `xc7a35tcpg236-1`. Run the `tb_washing_machine` simulation from the Simulation Sources set. The testbench uses accelerated parameters and checks automatic progression, manual selection, pause, and completion.

## Safety boundary

This is an FPGA logic-level educational demonstrator. The outputs are low-voltage logic commands only; do not connect FPGA pins directly to mains, pumps, valves, or motors. Real appliance control requires appropriately rated isolated drivers, feedback sensors, door/lid interlocks, overcurrent/thermal protection, and qualified electrical design.
