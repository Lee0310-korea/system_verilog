`timescale 1ns / 1ps


module tb ();
    logic clk = 0, reset = 1;

    RV32I_TOP UUT (.*);

    always #5 clk = ~clk;

    initial begin
        #30;
        reset = 0;
        #150;
        $stop;
    end
endmodule
