`timescale 1ns/1ps
module washing_machine_ctrl #(
    parameter integer CLK_HZ=100_000_000,
    parameter integer FILL_SEC=20, WASH_SEC=90, DRAIN_SEC=15,
    parameter integer RINSE_SEC=30, SPIN_SEC=60
)(
    input wire clk, input wire rst,
    input wire auto_mode, input wire start_pulse, input wire pause_pulse,
    input wire idle_pulse, input wire [4:0] stage_sw,
    output reg [2:0] state, output reg paused,
    output reg inlet_valve, output reg wash_motor,
    output reg drain_pump, output reg rinse_motor, output reg spin_motor,
    output reg done,
    output reg [6:0] seconds_left
);
    localparam IDLE=3'd0, FILL=3'd1, WASH=3'd2, DRAIN=3'd3,
               RINSE=3'd4, SPIN=3'd5, COMPLETE=3'd6;
    reg [31:0] tick_count;
    reg [31:0] duration;
    reg [2:0] next_state;
    wire sec_tick = (tick_count >= CLK_HZ-1);
    wire [5:0] selected_count = stage_sw[0]+stage_sw[1]+stage_sw[2]+stage_sw[3]+stage_sw[4];

    always @* begin
        case(state)
            FILL:duration=FILL_SEC; WASH:duration=WASH_SEC;
            DRAIN:duration=DRAIN_SEC; RINSE:duration=RINSE_SEC;
            SPIN:duration=SPIN_SEC; default:duration=0;
        endcase
    end
    always @* begin
        inlet_valve=0; wash_motor=0; drain_pump=0; rinse_motor=0; spin_motor=0; done=0;
        if (!paused) begin
            case(state)
                FILL:inlet_valve=1;
                WASH:wash_motor=1;
                DRAIN:drain_pump=1;
                RINSE:begin inlet_valve=1; rinse_motor=1; end
                SPIN:spin_motor=1;
                default:;
            endcase
        end
        if (state==COMPLETE) done=1;
    end
    always @(posedge clk) begin
        if(rst) begin state<=IDLE; paused<=0; tick_count<=0; seconds_left<=0; end
        else begin
            if(idle_pulse) begin state<=IDLE; paused<=0; tick_count<=0; seconds_left<=0; end
            else if(pause_pulse && state!=IDLE && state!=COMPLETE) paused<=~paused;
            if(state==IDLE) begin
                tick_count<=0; seconds_left<=0;
                if(start_pulse) begin
                    if(auto_mode) begin state<=FILL; seconds_left<=FILL_SEC; end
                    else if(selected_count==1) begin
                        case(stage_sw)
                            5'b00001:begin state<=FILL;seconds_left<=FILL_SEC;end
                            5'b00010:begin state<=WASH;seconds_left<=WASH_SEC;end
                            5'b00100:begin state<=DRAIN;seconds_left<=DRAIN_SEC;end
                            5'b01000:begin state<=RINSE;seconds_left<=RINSE_SEC;end
                            5'b10000:begin state<=SPIN;seconds_left<=SPIN_SEC;end
                            default:;
                        endcase
                    end
                end
            end else if(state==COMPLETE) begin paused<=0; tick_count<=0; seconds_left<=0; end
            else if(!paused) begin
                if(sec_tick) begin
                    tick_count<=0;
                    if(seconds_left>1) seconds_left<=seconds_left-1'b1;
                    else begin
                        seconds_left<=0;
                        if(auto_mode) begin
                            case(state)
                                FILL:begin state<=WASH;seconds_left<=WASH_SEC;end
                                WASH:begin state<=DRAIN;seconds_left<=DRAIN_SEC;end
                                DRAIN:begin state<=RINSE;seconds_left<=RINSE_SEC;end
                                RINSE:begin state<=SPIN;seconds_left<=SPIN_SEC;end
                                default:state<=COMPLETE;
                            endcase
                        end else state<=COMPLETE;
                    end
                end else tick_count<=tick_count+1'b1;
            end
            if(start_pulse && paused) paused<=0;
        end
    end
endmodule
