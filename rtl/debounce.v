`timescale 1ns/1ps
module debounce #(
    parameter integer CLK_HZ = 100_000_000,
    parameter integer DEBOUNCE_MS = 20,
    parameter integer COUNT_W = 21
)(
    input wire clk, input wire rst, input wire noisy,
    output reg clean, output reg rise
);
    localparam integer LIMIT = (CLK_HZ/1000)*DEBOUNCE_MS;
    reg sync1, sync2, prev;
    reg [COUNT_W-1:0] count;
    always @(posedge clk) begin
        if (rst) begin
            sync1<=0; sync2<=0; clean<=0; prev<=0; count<=0; rise<=0;
        end else begin
            sync1<=noisy; sync2<=sync1; prev<=clean; rise<=0;
            if (sync2==clean) count<=0;
            else if (count >= LIMIT-1) begin
                clean<=sync2; count<=0;
            end else count<=count+1'b1;
            if (clean && !prev) rise<=1'b1;
        end
    end
endmodule
