# Automatic Washing Machine Control System — Project Summary

## 1. Project overview

This project implements a digital automatic washing-machine sequence controller in Verilog HDL for the Digilent Basys 3 FPGA development board. It demonstrates a finite-state machine (FSM), timer/countdown logic, debounced push-button inputs, seven-segment display multiplexing, and status/output control.

**Target FPGA:** Xilinx Artix-7 XC7A35T-1CPG236C (Basys 3)  
**System clock:** 100 MHz  
**Toolchain used for local verification:** Xilinx Vivado 2018.2 / XSim  
**Top-level RTL module:** `basys3_washing_machine`

The design is a logic-level FPGA demonstrator. It does not directly drive appliance motors, pumps, or valves.

## 2. Operating modes

### Automatic mode

With `SW15=0`, pressing the center button starts the complete sequence:

`IDLE → FILL → WASH → DRAIN → RINSE → SPIN → COMPLETE`

The controller advances automatically when each stage countdown expires.

### Manual stage-test mode

With `SW15=1`, select exactly one of `SW0` through `SW4`, then press the center button to start that stage directly. This allows each stage output and timer to be tested independently without running the full cycle.

| Switch | Selected stage |
|---|---|
| SW0 | Fill |
| SW1 | Wash |
| SW2 | Drain |
| SW3 | Rinse |
| SW4 | Spin |

A single stage selection is required; zero or multiple selected stage switches are not accepted as a valid manual selection.

## 3. Washing stages and default durations

All stage durations are parameterized in seconds and are below two minutes.

| FSM state | Default duration | Logic-level output command |
|---|---:|---|
| Fill | 20 s | Inlet valve |
| Wash | 90 s | Wash motor |
| Drain | 15 s | Drain pump |
| Rinse | 30 s | Inlet valve + rinse motor |
| Spin | 60 s | Spin motor |
| Complete | Latched | Done indicator |

The output names represent logical control commands only. They are not power outputs.

## 4. Basys 3 user interface

### Push buttons

| Basys 3 button | Function |
|---|---|
| Center (BTNC) | Start / resume |
| Up (BTNU) | Pause / resume toggle |
| Down (BTND) | Reset to Idle |
| Left (BTNL) | Return to Idle |

The start, pause, and idle button inputs pass through the debounce module before reaching the controller. The down button is used as the reset input.

### Seven-segment display

The four-digit, active-low Basys 3 seven-segment display shows the remaining time in `MM:SS` format. The display module multiplexes the four digits. The decimal point is held inactive.

### LEDs

- LED0–LED4: Fill, Wash, Drain, Rinse, and Spin state indicators.
- LED8: Cycle complete.
- LED9: Paused status.
- LED10: Inlet-valve command.
- LED11: Wash-motor command.
- LED12: Drain-pump command.
- LED13: Rinse-motor command.
- LED14: Spin-motor command.
- Other LEDs are not assigned a functional status by the current RTL.

## 5. RTL source organization

| File | Responsibility |
|---|---|
| `rtl/basys3_washing_machine.v` | Basys 3 top-level module; connects switches, buttons, FSM, timer conversion, display and LEDs |
| `rtl/washing_machine_ctrl.v` | Washing-cycle FSM, automatic/manual control, stage timer, pause/resume and logical actuator commands |
| `rtl/debounce.v` | Synchronizes and debounces push-button inputs and generates rising-edge pulses |
| `rtl/seg7_mux.v` | Converts packed BCD digits into active-low seven-segment patterns and multiplexes the four display digits |
| `tb/tb_washing_machine.v` | Accelerated testbench for manual operation, pause/resume, automatic progression and completion |
| `vivado/constraints/basys3_washing_machine.xdc` | Basys 3 package-pin assignments, LVCMOS33 I/O standards and 100 MHz clock constraint |
| `vivado/create_project.tcl` | Creates the Vivado project, adds RTL, constraints and simulation sources, and sets the top modules |
| `vivado/run_simulation.tcl` | Launches simulation, runs all testbench stimulus, and closes simulation |

## 6. Timing and parameterization

The hardware design uses a 100 MHz input clock and a 10.000 ns clock period constraint. The FSM generates one-second timing intervals from the clock count. Stage durations are configurable through the top-level parameters:

- `FILL_SEC` (default 20)
- `WASH_SEC` (default 90)
- `DRAIN_SEC` (default 15)
- `RINSE_SEC` (default 30)
- `SPIN_SEC` (default 60)

The testbench overrides the clock and stage-duration parameters to accelerate simulation. The default hardware values are retained for the Basys 3 design.

## 7. Basys 3 constraints

The XDC file targets the Basys 3 XC7A35T package and specifies:

- 100 MHz clock on the board clock input, with a 10 ns period.
- Pin locations and LVCMOS33 I/O standards for all 16 switch bits, including SW5–SW14 which are currently unused by the RTL.
- Push-button, LED, seven-segment segment, decimal-point and digit-enable pins.
- Configuration voltage of 3.3 V and CFGBVS set to VCCO.

Constraining every bit of the 16-bit switch port avoids a partially locked I/O bus warning caused by assigning only the switches currently used by the RTL. The unused switch inputs are constrained but do not acquire new RTL functions.

## 8. Verification performed

The following results were reported from the user's local Vivado 2018.2 session:

### Behavioral simulation

The testbench completed and printed:

`PASS: manual stage, pause/resume, automatic sequence and safe completion`

The testbench checks direct manual Wash selection, the Wash motor command, pause disabling the motor command, resume restoring it, automatic progression to completion, and inactive actuator commands at completion.

### Synthesis utilization

| Resource | Used | Available | Utilization |
|---|---:|---:|---:|
| Slice LUTs | 115 | 20,800 | 0.55% |
| Slice registers | 138 | 41,600 | 0.33% |
| Block RAM tiles | 0 | 50 | 0% |
| DSPs | 0 | 90 | 0% |
| Bonded IOBs | 39 | 106 | 36.79% |
| BUFG | 1 | 32 | 3.13% |

### Implementation timing report

The user reported these timing results:

| Metric | Reported value |
|---|---:|
| Worst Negative Slack (WNS) | +4.221 ns |
| Total Negative Slack (TNS) | 0.000 ns |
| Worst Hold Slack (WHS) | +0.213 ns |
| Total Hold Slack (THS) | 0.000 ns |
| Failing setup endpoints | 0 |
| Failing hold endpoints | 0 |
| Pulse-width slack | +4.500 ns |

### Design Rule Check and bitstream

- The generated DRC report for the routed design reported **0 violations**.
- The user confirmed that Vivado successfully generated the bitstream.
- Physical programming and functional testing on the Basys 3 board are not yet confirmed.

**Verification note:** The reported simulation, synthesis, timing, DRC and bitstream results are from the user's local Vivado run. Updating the XDC requires rerunning implementation/DRC and regenerating the bitstream to validate the updated constraints.

## 9. Build and simulation

1. Open Vivado 2018.2.
2. In the Tcl Console, run `source vivado/create_project.tcl` from the repository root.
3. Set `tb_washing_machine` as the simulation top if it is not already selected.
4. Run behavioral simulation using `vivado/run_simulation.tcl` or the Vivado Simulation flow.
5. For hardware implementation, set `basys3_washing_machine` as the synthesis top, run synthesis and implementation, review timing and DRC reports, and generate the bitstream.
6. Program the Basys 3 using Hardware Manager and test the switches, buttons, LEDs and countdown display.

## 10. Safety and limitations

This project is intended for FPGA learning, demonstration and simulation. Basys 3 FPGA pins provide low-voltage logic signals only. **Never connect FPGA pins directly to mains voltage, washing-machine motors, pumps, solenoid valves or other high-power loads.**

A real appliance requires properly rated and isolated driver stages, suitable power electronics, feedback sensors (such as water-level and speed sensing), door/lid interlocks, fault handling, overcurrent and thermal protection, and a qualified electrical/mechanical safety design. Those circuits and protections are outside the scope of this RTL project.

## 11. Current project status

- RTL behavioral simulation: passed in the user's local Vivado run.
- Synthesis: completed successfully in the user's local Vivado run.
- Implementation timing checks: reported positive setup and hold slack.
- DRC: routed-design report showed zero violations.
- Bitstream: generated successfully.
- Basys 3 physical programming and end-to-end board test: pending confirmation.
- Updated full-switch XDC constraints: committed in this revision; rerun implementation, DRC and bitstream generation to validate this revision.
