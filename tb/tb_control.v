`timescale 1ns/1ps

module tb_control;

    reg [6:0] opcode;
    reg [2:0] funct3;

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

    integer tests = 0;
    integer fails = 0;

    control dut (
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

    task check_ctrl(
        input [6:0] op,
        input [2:0] f3,
        input exp_rw,
        input exp_asrc,
        input exp_aasrc,
        input exp_mr,
        input exp_mw,
        input [1:0] exp_msize,
        input exp_mun,
        input exp_br,
        input [2:0] exp_brtype,
        input exp_jmp,
        input exp_jmpreg,
        input [2:0] exp_immtype,
        input [1:0] exp_wb,
        input [127:0] desc
    );
        begin
            tests = tests + 1;
            opcode = op;
            funct3 = f3;
            #1;

            if (reg_write !== exp_rw ||
                alu_src !== exp_asrc ||
                alu_a_src !== exp_aasrc ||
                mem_read !== exp_mr ||
                mem_write !== exp_mw ||
                mem_size !== exp_msize ||
                mem_unsigned !== exp_mun ||
                branch !== exp_br ||
                branch_type !== exp_brtype ||
                jump !== exp_jmp ||
                jump_register !== exp_jmpreg ||
                imm_type !== exp_immtype ||
                writeback_select !== exp_wb) begin
                $display("FAIL [%0s]: op=%b f3=%b", desc, op, f3);
                $display("  got: RW=%b ASrc=%b AASrc=%b MR=%b MW=%b MSize=%b MUn=%b Br=%b BrT=%b Jmp=%b JmpR=%b ImmT=%b WB=%b",
                         reg_write, alu_src, alu_a_src, mem_read, mem_write, mem_size, mem_unsigned, branch, branch_type, jump, jump_register, imm_type, writeback_select);
                $display("  exp: RW=%b ASrc=%b AASrc=%b MR=%b MW=%b MSize=%b MUn=%b Br=%b BrT=%b Jmp=%b JmpR=%b ImmT=%b WB=%b",
                         exp_rw, exp_asrc, exp_aasrc, exp_mr, exp_mw, exp_msize, exp_mun, exp_br, exp_brtype, exp_jmp, exp_jmpreg, exp_immtype, exp_wb);
                fails = fails + 1;
            end
            else begin
                $display("PASS [%0s]: op=%b f3=%b", desc, op, f3);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_control.vcd");
        $dumpvars(0, tb_control);

        // R-Type
        check_ctrl(7'b0110011, 3'b000, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 3'b000, 2'b00, "R-Type");

        // I-Type ALU
        check_ctrl(7'b0010011, 3'b000, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 3'b000, 2'b00, "I-Type ALU");

        // Loads
        check_ctrl(7'b0000011, 3'b000, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 3'b000, 2'b01, "LB");
        check_ctrl(7'b0000011, 3'b001, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 3'b000, 2'b01, "LH");
        check_ctrl(7'b0000011, 3'b010, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 2'b10, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 3'b000, 2'b01, "LW");
        check_ctrl(7'b0000011, 3'b100, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 2'b00, 1'b1, 1'b0, 3'b000, 1'b0, 1'b0, 3'b000, 2'b01, "LBU");
        check_ctrl(7'b0000011, 3'b101, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 2'b01, 1'b1, 1'b0, 3'b000, 1'b0, 1'b0, 3'b000, 2'b01, "LHU");

        // Stores
        check_ctrl(7'b0100011, 3'b000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 2'b00, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 3'b001, 2'b00, "SB");
        check_ctrl(7'b0100011, 3'b001, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 2'b01, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 3'b001, 2'b00, "SH");
        check_ctrl(7'b0100011, 3'b010, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 2'b10, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 3'b001, 2'b00, "SW");

        // Branches
        check_ctrl(7'b1100011, 3'b000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1, 3'b000, 1'b0, 1'b0, 3'b010, 2'b00, "BEQ");
        check_ctrl(7'b1100011, 3'b001, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1, 3'b001, 1'b0, 1'b0, 3'b010, 2'b00, "BNE");
        check_ctrl(7'b1100011, 3'b100, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1, 3'b100, 1'b0, 1'b0, 3'b010, 2'b00, "BLT");
        check_ctrl(7'b1100011, 3'b101, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1, 3'b101, 1'b0, 1'b0, 3'b010, 2'b00, "BGE");
        check_ctrl(7'b1100011, 3'b110, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1, 3'b110, 1'b0, 1'b0, 3'b010, 2'b00, "BLTU");
        check_ctrl(7'b1100011, 3'b111, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b1, 3'b111, 1'b0, 1'b0, 3'b010, 2'b00, "BGEU");

        // Jumps
        check_ctrl(7'b1101111, 3'b000, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 3'b000, 1'b1, 1'b0, 3'b100, 2'b10, "JAL");
        check_ctrl(7'b1100111, 3'b000, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 3'b000, 1'b1, 1'b1, 3'b000, 2'b10, "JALR");

        // Upper Immediates
        check_ctrl(7'b0110111, 3'b000, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 3'b011, 2'b11, "LUI");
        check_ctrl(7'b0010111, 3'b000, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 3'b011, 2'b00, "AUIPC");

        // Default / Unsupported opcodes
        check_ctrl(7'b0000000, 3'b000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 3'b000, 2'b00, "Unsupported 0");
        check_ctrl(7'b1111111, 3'b111, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 3'b000, 1'b0, 1'b0, 3'b000, 2'b00, "Unsupported 1");

        $display("Total tests: %0d", tests);
        $display("Total failures: %0d", fails);
       

        if (fails == 0)
            $display("ALL TESTS PASSED");
        else begin
            $display("TESTS FAILED");
            $fatal(1, "Control testbench encountered failures.");
        end

        $finish;
    end

endmodule