`timescale 1ns / 1ps


module tb_spi ();

    logic       clk;
    logic       rst;
    logic       sw;
    logic       leftbtn;
    logic       rightbtn;
    logic [7:0] rx_data;
    logic [3:0] fnd_com;
    logic [7:0] fnd_data;
    Spi_TOP UUT (.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        sw = 0;
        leftbtn = 0;
        rightbtn = 0;
        #10;
        rst = 0;
        #10;
        leftbtn = 1;
        #10000;
        leftbtn = 0;

        #100_000_000;
        sw = 1;
        #100_000_000;
        rightbtn = 1;
        #10000;
        rightbtn = 1;
        #1_000_000;
        $finish;


    end
endmodule
