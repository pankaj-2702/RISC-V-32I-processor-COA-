`timescale 1ns/1ps

module tb_control;

    reg [6:0] opcode;
    reg [2:0] funct3;

    wire reg_write;
    wire alu_src;

    wire mem_read;
    wire mem_write;
    wire [1:0] mem_size;
    wire mem_unsigned;

    wire branch;
    wire [2:0] branch_type;

    wire jump;
    wire jump_register;

    wire [2:0] imm_type;
    wire [1:0] writeback_select;


    control dut (
        .opcode(opcode),
        .funct3(funct3),

        .reg_write(reg_write),
        .alu_src(alu_src),

        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_size(mem_size),
        .mem_unsigned(mem_unsigned),

        .branch(branch),
        .branch_type(branch_type),

        .jump(jump),
        .jump_register(jump_register),

        .imm_type(imm_type),

        .writeback_select(writeback_select)
    );


    initial begin

        // =========================================
        // R-TYPE
        // ADD, SUB, SLL, etc.
        // =========================================

        opcode = 7'b0110011;
        funct3 = 3'b000;

        #10;

        $display("R-TYPE:");
        $display("RegWrite=%b ALUSrc=%b MemRead=%b MemWrite=%b WB=%b",
                 reg_write, alu_src, mem_read, mem_write,
                 writeback_select);


        // =========================================
        // I-TYPE ALU
        // ADDI, SLTI, etc.
        // =========================================

        opcode = 7'b0010011;
        funct3 = 3'b000;

        #10;

        $display("I-TYPE ALU:");
        $display("RegWrite=%b ALUSrc=%b ImmType=%b WB=%b",
                 reg_write, alu_src, imm_type,
                 writeback_select);


        // =========================================
        // LB
        // =========================================

        opcode = 7'b0000011;
        funct3 = 3'b000;

        #10;

        $display("LB:");
        $display("RegWrite=%b MemRead=%b MemSize=%b Unsigned=%b WB=%b",
                 reg_write, mem_read, mem_size,
                 mem_unsigned, writeback_select);


        // =========================================
        // LH
        // =========================================

        opcode = 7'b0000011;
        funct3 = 3'b001;

        #10;

        $display("LH:");
        $display("MemSize=%b Unsigned=%b",
                 mem_size, mem_unsigned);


        // =========================================
        // LW
        // =========================================

        opcode = 7'b0000011;
        funct3 = 3'b010;

        #10;

        $display("LW:");
        $display("MemSize=%b Unsigned=%b",
                 mem_size, mem_unsigned);


        // =========================================
        // LBU
        // =========================================

        opcode = 7'b0000011;
        funct3 = 3'b100;

        #10;

        $display("LBU:");
        $display("MemSize=%b Unsigned=%b",
                 mem_size, mem_unsigned);


        // =========================================
        // LHU
        // =========================================

        opcode = 7'b0000011;
        funct3 = 3'b101;

        #10;

        $display("LHU:");
        $display("MemSize=%b Unsigned=%b",
                 mem_size, mem_unsigned);


        // =========================================
        // SB
        // =========================================

        opcode = 7'b0100011;
        funct3 = 3'b000;

        #10;

        $display("SB:");
        $display("MemWrite=%b MemSize=%b ImmType=%b",
                 mem_write, mem_size, imm_type);


        // =========================================
        // SH
        // =========================================

        opcode = 7'b0100011;
        funct3 = 3'b001;

        #10;

        $display("SH:");
        $display("MemWrite=%b MemSize=%b",
                 mem_write, mem_size);


        // =========================================
        // SW
        // =========================================

        opcode = 7'b0100011;
        funct3 = 3'b010;

        #10;

        $display("SW:");
        $display("MemWrite=%b MemSize=%b",
                 mem_write, mem_size);


        // =========================================
        // BEQ
        // =========================================

        opcode = 7'b1100011;
        funct3 = 3'b000;

        #10;

        $display("BEQ:");
        $display("Branch=%b BranchType=%b ImmType=%b",
                 branch, branch_type, imm_type);


        // =========================================
        // BNE
        // =========================================

        opcode = 7'b1100011;
        funct3 = 3'b001;

        #10;

        $display("BNE:");
        $display("Branch=%b BranchType=%b",
                 branch, branch_type);


        // =========================================
        // BLT
        // =========================================

        opcode = 7'b1100011;
        funct3 = 3'b100;

        #10;

        $display("BLT:");
        $display("Branch=%b BranchType=%b",
                 branch, branch_type);


        // =========================================
        // BGE
        // =========================================

        opcode = 7'b1100011;
        funct3 = 3'b101;

        #10;

        $display("BGE:");
        $display("Branch=%b BranchType=%b",
                 branch, branch_type);


        // =========================================
        // BLTU
        // =========================================

        opcode = 7'b1100011;
        funct3 = 3'b110;

        #10;

        $display("BLTU:");
        $display("Branch=%b BranchType=%b",
                 branch, branch_type);


        // =========================================
        // BGEU
        // =========================================

        opcode = 7'b1100011;
        funct3 = 3'b111;

        #10;

        $display("BGEU:");
        $display("Branch=%b BranchType=%b",
                 branch, branch_type);


        // =========================================
        // JAL
        // =========================================

        opcode = 7'b1101111;
        funct3 = 3'b000;

        #10;

        $display("JAL:");
        $display("RegWrite=%b Jump=%b JumpReg=%b ImmType=%b WB=%b",
                 reg_write, jump, jump_register,
                 imm_type, writeback_select);


        // =========================================
        // JALR
        // =========================================

        opcode = 7'b1100111;
        funct3 = 3'b000;

        #10;

        $display("JALR:");
        $display("RegWrite=%b Jump=%b JumpReg=%b ImmType=%b WB=%b",
                 reg_write, jump, jump_register,
                 imm_type, writeback_select);


        // =========================================
        // LUI
        // =========================================

        opcode = 7'b0110111;
        funct3 = 3'b000;

        #10;

        $display("LUI:");
        $display("RegWrite=%b ImmType=%b WB=%b",
                 reg_write, imm_type, writeback_select);


        // =========================================
        // AUIPC
        // =========================================

        opcode = 7'b0010111;
        funct3 = 3'b000;

        #10;

        $display("AUIPC:");
        $display("RegWrite=%b ImmType=%b WB=%b",
                 reg_write, imm_type, writeback_select);


        $finish;

    end

endmodule