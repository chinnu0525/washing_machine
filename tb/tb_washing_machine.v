`timescale 1ns/1ps
module tb_washing_machine;
 reg clk=0; always #5 clk=~clk;
 reg [15:0] sw=0; reg btnC=0,btnU=0,btnD=0,btnL=0;
 wire [15:0] led; wire [6:0] seg; wire dp; wire [3:0] an;
 basys3_washing_machine #(.CLK_HZ(4000),.DEBOUNCE_MS(1),
   .FILL_SEC(2),.WASH_SEC(3),.DRAIN_SEC(1),.RINSE_SEC(2),.SPIN_SEC(2)) dut
   (.clk(clk),.sw(sw),.btnC(btnC),.btnU(btnU),.btnD(btnD),.btnL(btnL),
    .led(led),.seg(seg),.dp(dp),.an(an));
 task press_start; begin btnC=1; repeat(8) @(posedge clk); btnC=0; repeat(8) @(posedge clk); end endtask
 task press_pause; begin btnU=1; repeat(8) @(posedge clk); btnU=0; repeat(8) @(posedge clk); end endtask
 initial begin
   btnD=1; repeat(8) @(posedge clk); btnD=0; repeat(8) @(posedge clk);
   // Manual mode: select Wash directly, verify motor command and pause/resume.
   sw[15]=1; sw[1]=1; press_start();
   if(dut.ctrl.state!==3'd2 || !led[1] || !led[11]) $fatal(1,"Manual Wash start failed");
   press_pause(); if(!led[9] || led[11]) $fatal(1,"Pause did not disable motor");
   press_pause(); if(led[9] || !led[11]) $fatal(1,"Resume failed");
   // Reset, then automatic sequence must reach completion.
   btnD=1; repeat(8) @(posedge clk); btnD=0; repeat(8) @(posedge clk);
   sw=0; press_start();
   wait(led[8]===1'b1);
   if(led[10] || led[12] || led[14]) $fatal(1,"Actuator remained active at completion");
   $display("PASS: manual stage, pause/resume, automatic sequence and safe completion");
   $finish;
 end
 initial begin #2_000_000; $fatal(1,"Simulation timeout"); end
endmodule
