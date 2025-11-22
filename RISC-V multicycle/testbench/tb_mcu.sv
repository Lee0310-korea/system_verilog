`timescale 1ns / 1ps

module uart_top_tb;

    logic       clk;
    logic       reset;
    logic [7:0] gpo;
    logic [7:0] gpi;
    wire  [7:0] gpio;
    logic       rx;
    logic       tx;

    MCU UUT (.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        #20;
        reset = 0;
        uart_send_char("A");
        
    end

    task uart_send_char(input [7:0] data);
        integer i;
        begin
            // Start bit
            rx = 0;
            #(104167); // assuming 9600 baud, 1 bit period = 1/9600 s = ~104.167 us

            // Data bits (LSB first)
            for(i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(104167);
            end

            // Stop bit
            rx = 1;
            #(104167);
        end
    endtask
endmodule
