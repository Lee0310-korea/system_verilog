`timescale 1ns / 1ps

module data_ram (
    input  logic        clk,
    input  logic        d_wr_en,
    input  logic [31:0] dAddr,
    input  logic [ 2:0] extend_controls,
    input  logic [31:0] dWdata,
    output logic [31:0] dRdata
);

    logic [31:0] data_mem[0:63];

    initial begin
        for (int i = 0; i < 16; i++) begin
            data_mem[i] = i + 32'h87658381;
        end
    end
    always_ff @(posedge clk) begin
        if (d_wr_en) begin
            case (extend_controls)
                3'b010: begin  // SW
                    data_mem[dAddr] <= dWdata;
                end
                3'b001: begin
                    data_mem[dAddr][15:0] <= dWdata[15:0];
                end

                3'b000:begin
                    data_mem[dAddr][7:0] <= dWdata[7:0];
                end
            endcase
        end
    end

    assign dRdata = data_mem[dAddr];
endmodule
