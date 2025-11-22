`timescale 1ns / 1ps

`include "define.sv"

module datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_code,
    input  logic [ 3:0] alu_controls,
    input  logic        reg_wr_en,
    input  logic        aluSrcMux,
    input  logic [ 2:0] regwdataSel,
    input  logic        branch,
    input  logic        JAL,
    input  logic        JARL,
    input  logic [31:0] dRdata,
    output logic [31:0] instr_rAddr,
    output logic [31:0] dAddr,
    output logic [31:0] dWdata

);

    logic [31:0] w_regfile_rd1, w_regfile_rd2, w_alu_result;
    logic [31:0] w_imm_ext, w_alusrcmuxsel_out, w_pc_Out;
    logic [31:0] regwdataout, w_pc_next, w_pc;
    logic pc_MuxSel, btaken;
    logic [31:0] w_utype_add, w_j_u_sel;

    assign dAddr = w_alu_result;
    assign dWdata = w_regfile_rd2;
    assign pc_MuxSel = JAL |  {branch & btaken};

    mux_5x1 U_51MUX (
        .sel(regwdataSel),
        .x0 (w_alu_result),
        .x1 (dRdata),
        .x2 (w_imm_ext),
        .x3 (w_utype_add),
        .x4 (w_pc_next),
        .y  (regwdataout)
    );

    pc_adder U_Utype_adder (
        .a  (w_imm_ext),
        .b  (w_j_u_sel),
        .sum(w_utype_add)
    );

    mux_2x1 U_PC_MUX_JARL (
        .sel(JARL),
        .x0 (w_regfile_rd1),
        .x1 (instr_rAddr),
        .y  (w_j_u_sel)
    );

    mux_2x1 U_PC_MUX_SEL (
        .sel(pc_MuxSel),
        .x0 (w_utype_add),
        .x1 (w_pc_next),
        .y  (w_pc)
    );

    pc_adder U_pc_adder (
        .a  (32'd4),
        .b  (instr_rAddr),
        .sum(w_pc_next)
    );

    program_counter U_PC (
        .clk    (clk),
        .reset  (reset),
        .pc_next(w_pc),
        .pc     (instr_rAddr)
    );

    register_file U_REG_FILE (
        .clk      (clk),
        .RA1      (instr_code[19:15]),  // read address 1
        .RA2      (instr_code[24:20]),  // read address 2
        .WA       (instr_code[11:7]),   // write address
        .reg_wr_en(reg_wr_en),          // write enable
        .funct3   (instr_code[14:12]),
        .opcode   (instr_code[6:0]),
        .WData    (regwdataout),        // write data
        .RD1      (w_regfile_rd1),      // read data 1
        .RD2      (w_regfile_rd2)       // read data 2
    );


    ALU U_ALU (
        .a           (w_regfile_rd1),
        .b           (w_alusrcmuxsel_out),
        .alu_controls(alu_controls),
        .alu_result  (w_alu_result),
        .btaken      (btaken)
    );

    extend U_extend (
        .instr_code(instr_code),
        .imm_ext(w_imm_ext)
    );

    mux_2x1 U_mux_sel (
        .sel(aluSrcMux),
        .x0 (w_regfile_rd2),
        .x1 (w_imm_ext),
        .y  (w_alusrcmuxsel_out)
    );

endmodule

module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] pc_next,
    output logic [31:0] pc
);

    register U_PC_REG (
        .clk  (clk),
        .reset(reset),
        .d    (pc_next),
        .q    (pc)
    );
endmodule

module register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    output logic [31:0] q
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end

endmodule

module register_file (
    input  logic        clk,
    input  logic [ 4:0] RA1,        // read address 1
    input  logic [ 4:0] RA2,        // read address 2
    input  logic [ 4:0] WA,         // write address
    input  logic        reg_wr_en,  // write enable
    input  logic [ 2:0] funct3,
    input  logic [ 6:0] opcode,
    input  logic [31:0] WData,      // write data
    output logic [31:0] RD1,        // read data 1
    output logic [31:0] RD2         // read data 2
);

    logic [31:0] reg_file[0:31];  // 32bit 32개.

    initial begin
        reg_file[0]  = 32'd0;
        reg_file[1]  = 32'd1;
        reg_file[2]  = 32'd2;
        reg_file[3]  = 32'd3;
        reg_file[4]  = 32'd4;
        reg_file[5]  = 32'd5;
        reg_file[6]  = 32'd6;
        reg_file[7]  = 32'd7;
        reg_file[8]  = 32'd8;
        reg_file[9]  = 32'd9;
        reg_file[10] = 32'd10;
        reg_file[11] = 32'd11;
        reg_file[12] = 32'd12;
        reg_file[13] = 32'd13;
        reg_file[14] = 32'd14;
        reg_file[15] = 32'd15;
        reg_file[16] = 32'd16;
        reg_file[17] = 32'd17;
        reg_file[18] = 32'd18;
        reg_file[19] = 32'd19;
        reg_file[20] = 32'd20;
        reg_file[21] = 32'd21;
        reg_file[22] = 32'd22;
        reg_file[23] = 32'd23;
        reg_file[24] = 32'd24;
        reg_file[25] = 32'd25;
        reg_file[26] = 32'd26;
        reg_file[27] = 32'd27;
        reg_file[28] = 32'd28;
        reg_file[29] = 32'd29;
    end

    always_ff @(posedge clk) begin
        if (reg_wr_en) begin
            if (opcode == `OP_R_TYPE||opcode == `OP_I_TYPE||opcode == `OP_U_TYPE||opcode == `OP_UL_TYPE||opcode == `OP_J_TYPE||opcode == `OP_JL_TYPE) begin
                reg_file[WA] <= WData;
            end
            if (opcode == `OP_IL_TYPE) begin
                case (funct3)
                    3'b000: begin
                        reg_file[WA][7:0]  <= WData[7:0];
                        reg_file[WA][31:8] <= {24{WData[7]}};
                    end
                    3'b001: begin
                        reg_file[WA][15:0]  <= WData[15:0];
                        reg_file[WA][31:16] <= {16{WData[15]}};
                    end
                    3'b010: begin
                        reg_file[WA] <= WData;
                    end
                    3'b100: begin
                        reg_file[WA][7:0]  <= WData[7:0];
                        reg_file[WA][31:8] <= 16'b0;
                    end
                    3'b101: begin
                        reg_file[WA][15:0]  <= WData[15:0];
                        reg_file[WA][31:16] <= 16'b0;
                    end
                endcase
            end

        end
    end

    assign RD1 = (RA1 != 0) ? reg_file[RA1] : 0;
    assign RD2 = (RA2 != 0) ? reg_file[RA2] : 0;

endmodule

module ALU (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [ 3:0] alu_controls,
    output logic [31:0] alu_result,
    output logic        btaken
);

    always_comb begin
        case (alu_controls)
            `ADD: alu_result = a + b;
            `SUB: alu_result = a - b;
            `SLL: alu_result = a << b[4:0];
            `SRL: alu_result = a >> b[4:0];  // 0으로 extend
            `SRA: alu_result = $signed(a) >>> b[4:0];  //[31] extend by signed
            `SLT: alu_result = $signed(a) < $signed(b) ? 1 : 0;
            `SLTU: alu_result = a < b ? 1 : 0;
            `XOR: alu_result = a ^ b;
            `AND: alu_result = a & b;
            `OR: alu_result = a | b;
            default: alu_result = 32'bx;
        endcase
    end

    always_comb begin
        case (alu_controls[2:0])
            `BEQ: begin
                btaken = ($signed(a) == $signed(b));
            end
            `BNE: begin
                btaken = ($signed(a) != $signed(b));
            end
            `BLT: begin
                btaken = ($signed(a) < $signed(b));
            end
            `BGE: begin
                btaken = ($signed(a) >= $signed(b));
            end
            `BLTU: begin
                btaken = ($unsigned(a) < $unsigned(b));
            end
            `BGEU: begin
                btaken = ($unsigned(a) >= $unsigned(b));
            end
            default: btaken = 1'b0;
        endcase
    end

endmodule

module extend (
    input  logic [31:0] instr_code,
    output logic [31:0] imm_ext
);

    wire [6:0] opcode = instr_code[6:0];
    wire [2:0] funct3 = instr_code[14:12];
    wire       funct7 = instr_code[30];

    always_comb begin
        case (opcode)
            `OP_R_TYPE: imm_ext = 32'bx;
            `OP_S_TYPE:
            imm_ext = {
                {20{instr_code[31]}}, instr_code[31:25], instr_code[11:7]
            };
            `OP_IL_TYPE: imm_ext = {{20{instr_code[31]}}, instr_code[31:20]};
            `OP_I_TYPE: imm_ext = {{20{instr_code[31]}}, instr_code[31:20]};
            `OP_B_TYPE:
            imm_ext = {
                {20{instr_code[31]}},
                instr_code[7],
                instr_code[30:25],
                instr_code[11:8],
                1'b0
            };
            `OP_U_TYPE: imm_ext = {instr_code[31:12], 12'b0};
            `OP_UL_TYPE: imm_ext = {instr_code[31:12], 12'b0};
            `OP_J_TYPE:
            imm_ext = {
                {11{instr_code[31]}},
                instr_code[21:12],
                instr_code[22],
                instr_code[31:23],
                1'b0
            };
            `OP_JL_TYPE: imm_ext = {{20{instr_code[31]}}, instr_code[31:20]};
            default: imm_ext = 32'bx;
        endcase
    end
endmodule

module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] x0,
    input  logic [31:0] x1,
    output logic [31:0] y
);

    assign y = (sel) ? x1 : x0;

endmodule


module mux_5x1 (
    input  logic [ 2:0] sel,
    input  logic [31:0] x0,
    input  logic [31:0] x1,
    input  logic [31:0] x2,
    input  logic [31:0] x3,
    input  logic [31:0] x4,
    output logic [31:0] y
);

    assign y = (sel == 3'b000) ? x0 :
                (sel == 3'b001) ? x1 :
                (sel == 3'b010) ? x2 :
                (sel == 3'b011) ? x3 : x4;
endmodule


module pc_adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] sum
);
    assign sum = a + b;
endmodule
