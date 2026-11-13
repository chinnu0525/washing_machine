`timescale 1ns/1ps
module basys3_washing_machine #(
    parameter integer CLK_HZ=100_000_000,
    parameter integer DEBOUNCE_MS=20,
    parameter integer FILL_SEC=20, WASH_SEC=90, DRAIN_SEC=15,
    parameter integer RINSE_SEC=30, SPIN_SEC=60
)(
    input wire clk, input wire [15:0] sw,
    input wire btnC, input wire btnU, input wire btnD, input wire btnL,
    output wire [15:0] led,
    output wire [6:0] seg, output wire dp, output wire [3:0] an
);
    wire rst=btnD;
    wire start_level,start_rise,pause_level,pause_rise,idle_level,idle_rise;
    debounce #(.CLK_HZ(CLK_HZ),.DEBOUNCE_MS(DEBOUNCE_MS)) db_start(clk,rst,btnC,start_level,start_rise);
    debounce #(.CLK_HZ(CLK_HZ),.DEBOUNCE_MS(DEBOUNCE_MS)) db_pause(clk,rst,btnU,pause_level,pause_rise);
    debounce #(.CLK_HZ(CLK_HZ),.DEBOUNCE_MS(DEBOUNCE_MS)) db_idle(clk,rst,btnL,idle_level,idle_rise);

    wire [2:0] state; wire paused;
    wire inlet_valve,wash_motor,drain_pump,rinse_motor,spin_motor,done;
    wire [6:0] secs;
    washing_machine_ctrl #(.CLK_HZ(CLK_HZ),.FILL_SEC(FILL_SEC),.WASH_SEC(WASH_SEC),
      .DRAIN_SEC(DRAIN_SEC),.RINSE_SEC(RINSE_SEC),.SPIN_SEC(SPIN_SEC)) ctrl(
      .clk(clk),.rst(rst),.auto_mode(~sw[15]),.start_pulse(start_rise),
      .pause_pulse(pause_rise),.idle_pulse(idle_rise),.stage_sw(sw[4:0]),
      .state(state),.paused(paused),.inlet_valve(inlet_valve),.wash_motor(wash_motor),
      .drain_pump(drain_pump),.rinse_motor(rinse_motor),.spin_motor(spin_motor),
      .done(done),.seconds_left(secs));

    wire [6:0] mins=secs/60;
    wire [6:0] rems=secs%60;
    wire [3:0] m_tens=mins/10, m_ones=mins%10;
    wire [3:0] s_tens=rems/10, s_ones=rems%10;
    wire [15:0] bcd={m_tens,m_ones,s_tens,s_ones};
    seg7_mux #(.CLK_HZ(CLK_HZ)) display(clk,rst,bcd,seg,an,dp);

    assign led=16'b0 |
      (state==1 ? 16'h0001:0) | (state==2 ? 16'h0002:0) |
      (state==3 ? 16'h0004:0) | (state==4 ? 16'h0008:0) |
      (state==5 ? 16'h0010:0) | (done ? 16'h0100:0) |
      (paused ? 16'h0200:0) | (inlet_valve ? 16'h0400:0) |
      (wash_motor ? 16'h0800:0) | (drain_pump ? 16'h1000:0) |
      (rinse_motor ? 16'h2000:0) | (spin_motor ? 16'h4000:0);
endmodule
