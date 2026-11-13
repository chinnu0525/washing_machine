`timescale 1ns/1ps
module seg7_mux #(
    parameter integer CLK_HZ=100_000_000,
    parameter integer REFRESH_HZ=1000
)(
    input wire clk, input wire rst,
    input wire [15:0] value, // packed BCD: MMSS
    output reg [6:0] seg, output reg [3:0] an, output wire dp
);
    localparam integer DIV = CLK_HZ/(REFRESH_HZ*4);
    localparam integer CW = (DIV<2)?1:$clog2(DIV);
    reg [CW-1:0] div_count;
    reg [1:0] digit;
    reg [3:0] nibble;
    assign dp=1'b1;
    always @(posedge clk) begin
        if(rst) begin div_count<=0; digit<=0; end
        else if(div_count>=DIV-1) begin div_count<=0; digit<=digit+1'b1; end
        else div_count<=div_count+1'b1;
    end
    always @* begin
        case(digit)
            2'd0: begin nibble=value[3:0]; an=4'b1110; end
            2'd1: begin nibble=value[7:4]; an=4'b1101; end
            2'd2: begin nibble=value[11:8]; an=4'b1011; end
            default: begin nibble=value[15:12]; an=4'b0111; end
        endcase
        case(nibble)
            4'd0:seg=7'b1000000; 4'd1:seg=7'b1111001;
            4'd2:seg=7'b0100100; 4'd3:seg=7'b0110000;
            4'd4:seg=7'b0011001; 4'd5:seg=7'b0010010;
            4'd6:seg=7'b0000010; 4'd7:seg=7'b1111000;
            4'd8:seg=7'b0000000; 4'd9:seg=7'b0010000;
            default:seg=7'b1111111;
        endcase
    end
endmodule
