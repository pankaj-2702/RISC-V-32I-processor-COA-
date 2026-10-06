module cpu (
    input clk,
    input reset
);

    // =========================================
    // PC AND INSTRUCTION MEMORY
    // =========================================

    wire [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] instruction;

    pc pc_unit (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    imem imem_unit (
        .addr(pc),
        .instruction(instruction)
    );


    // =========================================
    // INSTRUCTION FIELDS
    // =========================================

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] funct7;

    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];


    // =========================================
    // CONTROL SIGNALS
    // =========================================

    wire reg_write;
    wire alu_src;
    wire alu_a_src;

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


    // =========================================
    // CONTROL UNIT
    // =========================================

    control control_unit (
        .opcode(opcode),
        .funct3(funct3),

        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_a_src(alu_a_src),

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


    // =========================================
    // REGISTER FILE
    // =========================================

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    wire [31:0] writeback_data;

    regfile regfile_unit (
        .clk(clk),
        .reset(reset),

        .rs1_addr(rs1),
        .rs2_addr(rs2),

        .rd_addr(rd),
        .write_data(writeback_data),
        .reg_write(reg_write),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );


    // =========================================
    // IMMEDIATE GENERATOR
    // =========================================

    wire [31:0] immediate;

    immgen immgen_unit (
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );


    // =========================================
    // ALU CONTROL
    // =========================================

    wire [3:0] alu_control_signal;

    alu_control alu_control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control_signal)
    );


    // =========================================
    // ALU
    // =========================================

    wire [31:0] alu_a;
    wire [31:0] alu_b;
    wire [31:0] alu_result;

    // ALU A:
    // 0 = rs1_data
    // 1 = PC
    assign alu_a = alu_a_src ? pc : rs1_data;

    // ALU B:
    // 0 = rs2_data
    // 1 = immediate
    assign alu_b = alu_src ? immediate : rs2_data;

    alu alu_unit (
        .a(alu_a),
        .b(alu_b),
        .alu_control(alu_control_signal),
        .result(alu_result)
    );


    // =========================================
    // DATA MEMORY
    // =========================================

    wire [31:0] dmem_read_data;

    dmem dmem_unit (
        .clk(clk),

        .addr(alu_result),
        .write_data(rs2_data),

        .mem_read(mem_read),
        .mem_write(mem_write),

        .mem_size(mem_size),
        .mem_unsigned(mem_unsigned),

        .read_data(dmem_read_data)
    );


    // =========================================
    // WRITEBACK MUX
    // =========================================

    // 00 = ALU result
    // 01 = Memory data
    // 10 = PC + 4
    // 11 = Immediate

    assign writeback_data =
        (writeback_select == 2'b00) ? alu_result :
        (writeback_select == 2'b01) ? dmem_read_data :
        (writeback_select == 2'b10) ? (pc + 32'd4) :
                                       immediate;


    // =========================================
    // NEXT PC
    // =========================================

    // Temporary:
    // Always execute the next sequential instruction.
    //
    // Branch and jump logic will replace this later.

    assign next_pc = pc + 32'd4;

endmodule