`timescale 1ns / 1ps
module RV32I_TOP (
    input logic clk,
    input logic reset
);
    logic [31:0] instr_code, instr_rAddr;
    logic [31:0] dAddr, dWdata;
    logic d_wr_en;
    logic [2:0] extend_controls;
    logic [31:0] dRdata;

    instr_mem U_Instr_Mem (.*);
    RV32I_Core U_RV32I_CPU (.*);
    data_ram U_data_mem (
        .clk            (clk),
        .d_wr_en        (d_wr_en),
        .dAddr          (dAddr),
        .extend_controls(extend_controls),
        .dWdata         (dWdata),
        .dRdata         (dRdata)
    );

endmodule

module RV32I_Core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_code,
    input  logic [31:0] dRdata,
    output logic [31:0] instr_rAddr,
    output logic        d_wr_en,
    output logic [31:0] dAddr,
    output logic [31:0] dWdata,
    output logic [ 2:0] extend_controls
);

    logic [3:0] alu_controls;
    logic       reg_wr_en;
    logic       aluSrcMux;
    logic [2:0] regwdataSel;
    logic       branch;
    logic       JAL, JARL;

    control_unit U_Control_Unit (
        .instr_code     (instr_code),
        .alu_controls   (alu_controls),
        .aluSrcMux      (aluSrcMux),
        .extend_controls(extend_controls),
        .reg_wr_en      (reg_wr_en),
        .d_wr_en        (d_wr_en),
        .regwdataSel    (regwdataSel),
        .branch         (branch),
        .JAL            (JAL),
        .JARL           (JARL)
    );

    datapath U_data_path (
        .clk         (clk),
        .reset       (reset),
        .instr_code  (instr_code),
        .alu_controls(alu_controls),
        .reg_wr_en   (reg_wr_en),
        .aluSrcMux   (aluSrcMux),
        .regwdataSel (regwdataSel),
        .JAL         (JAL),
        .JARL        (JARL),
        .branch      (branch),
        .dRdata      (dRdata),
        .instr_rAddr (instr_rAddr),
        .dAddr       (dAddr),
        .dWdata      (dWdata)
    );
endmodule
