`timescale 1ns / 1ps

`include "define.sv"

module control_unit (
    input  logic [31:0] instr_code,
    output logic [ 3:0] alu_controls,
    output logic [ 2:0] extend_controls,
    output logic        aluSrcMux,
    output logic [2:0]  regwdataSel,
    output logic       JAL,
    output logic        JARL,
    output logic        reg_wr_en,
    output logic        d_wr_en,
    output logic        branch
);

    //    rom [0] = 32'h004182B3; //32'b0000_0000_0100_0001_1000_0010_1011_0011; // add x5, x3, x4
    wire  [6:0] funct7 = instr_code[31:25];
    wire  [2:0] funct3 = instr_code[14:12];
    wire  [6:0] opcode = instr_code[6:0];

    logic [7:0] controls;

    assign {regwdataSel[2:0],JAL,aluSrcMux, reg_wr_en, d_wr_en, branch} = controls;

    always_comb begin
        case (opcode)
            `OP_R_TYPE:  controls = 8'b00000100;  // R-type
            `OP_S_TYPE:  controls = 8'b00001010;
            `OP_IL_TYPE: controls = 8'b00101100;
            `OP_I_TYPE:  controls = 8'b00001100;
            `OP_B_TYPE:  controls = 8'b00000001;
            `OP_U_TYPE:  controls = 8'b01000100;
            `OP_UL_TYPE: controls = 8'b01100100;
            `OP_J_TYPE:  controls = 8'b10010100;
            `OP_JL_TYPE: controls = 8'b01100100;
            default:     controls = 8'b00000000;
        endcase
    end

    always_comb begin
        case (opcode)
            `OP_R_TYPE: begin
                alu_controls = {funct7[5], funct3};  // R-type
                extend_controls = 3'bxxx;
                JARL = 1'b0;
            end
            `OP_S_TYPE: begin
                alu_controls = `ADD;
                extend_controls = funct3;
                JARL = 1'b0;
            end
            `OP_IL_TYPE: begin
                alu_controls = `ADD;
                extend_controls = 3'bxxx;
                JARL = 1'b0;
            end
            `OP_I_TYPE: begin
                if ({funct7[5], funct3} == 4'b1101) begin
                    alu_controls = {1'b1, funct3};
                    extend_controls = 3'bxxx;
                    JARL = 1'b0;
                end else begin
                    alu_controls = {1'b0, funct3};
                    extend_controls = 3'bxxx;
                    JARL = 1'b0;
                end
            end
            `OP_B_TYPE: begin
                alu_controls = {1'b0, funct3};
                extend_controls = 3'bxxx;
                JARL = 1'b0;
            end
            `OP_I_TYPE:begin
                alu_controls = `ADD;
                extend_controls = 3'bxxx;
                JARL = 1'b0;
            end
            `OP_IL_TYPE : begin
                alu_controls = `ADD;
                extend_controls = 3'bxxx;
                JARL = 1'b0;
            end
             `OP_J_TYPE:begin
                alu_controls = `ADD;
                extend_controls = 3'bxxx;
                JARL = 1'b0;
             end
              `OP_JL_TYPE:begin
                alu_controls = `ADD;
                extend_controls = 3'bxxx;
                JARL = 1'b1;
              end
            default: begin
                alu_controls = 4'bxxxx;
                extend_controls = 3'bxxx;
                JARL = 1'bx;
            end
        endcase
    end


endmodule
