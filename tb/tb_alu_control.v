`timescale 1ns/1ps

module tb_alu_control;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire [3:0] alu_control;

    integer tests = 0;
    integer fails = 0;

    alu_control dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );

    task check(
        input [6:0] op,
        input [2:0] f3,
        input [6:0] f7,
        input [3:0] expected,
        input [127:0] desc
    );
        begin
            tests = tests + 1;
            opcode = op;
            funct3 = f3;
            funct7 = f7;
            #1;

            if (alu_control !== expected) begin
                $display(
                    "FAIL [%0s]: op=%b f3=%b f7=%b got=%b expected=%b",
                    desc, op, f3, f7, alu_control, expected
                );
                fails = fails + 1;
            end
            else begin
                $display(
                    "PASS [%0s]: op=%b f3=%b f7=%b got=%b expected=%b",
                    desc, op, f3, f7, alu_control, expected
                );
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_alu_control.vcd");
        $dumpvars(0, tb_alu_control);

        // R-type operations (opcode 7'b0110011)
        check(7'b0110011, 3'b000, 7'b0000000, 4'b0000, "R-type ADD");
        check(7'b0110011, 3'b000, 7'b0100000, 4'b0001, "R-type SUB");
        check(7'b0110011, 3'b001, 7'b0000000, 4'b0010, "R-type SLL");
        check(7'b0110011, 3'b010, 7'b0000000, 4'b0011, "R-type SLT");
        check(7'b0110011, 3'b011, 7'b0000000, 4'b0100, "R-type SLTU");
        check(7'b0110011, 3'b100, 7'b0000000, 4'b0101, "R-type XOR");
        check(7'b0110011, 3'b101, 7'b0000000, 4'b0110, "R-type SRL");
        check(7'b0110011, 3'b101, 7'b0100000, 4'b0111, "R-type SRA");
        check(7'b0110011, 3'b110, 7'b0000000, 4'b1000, "R-type OR");
        check(7'b0110011, 3'b111, 7'b0000000, 4'b1001, "R-type AND");

        // I-type ALU operations (opcode 7'b0010011)
        check(7'b0010011, 3'b000, 7'b0000000, 4'b0000, "I-type ADDI");
        check(7'b0010011, 3'b010, 7'b0000000, 4'b0011, "I-type SLTI");
        check(7'b0010011, 3'b011, 7'b0000000, 4'b0100, "I-type SLTIU");
        check(7'b0010011, 3'b100, 7'b0000000, 4'b0101, "I-type XORI");
        check(7'b0010011, 3'b110, 7'b0000000, 4'b1000, "I-type ORI");
        check(7'b0010011, 3'b111, 7'b0000000, 4'b1001, "I-type ANDI");
        check(7'b0010011, 3'b001, 7'b0000000, 4'b0010, "I-type SLLI");
        check(7'b0010011, 3'b101, 7'b0000000, 4'b0110, "I-type SRLI");
        check(7'b0010011, 3'b101, 7'b0100000, 4'b0111, "I-type SRAI");

        // Address calculation operations
        check(7'b0000011, 3'b010, 7'b0000000, 4'b0000, "LOAD (ADD)");
        check(7'b0100011, 3'b010, 7'b0000000, 4'b0000, "STORE (ADD)");
        check(7'b1100111, 3'b000, 7'b0000000, 4'b0000, "JALR (ADD)");
        check(7'b0010111, 3'b000, 7'b0000000, 4'b0000, "AUIPC (ADD)");

        // Default / unsupported combinations
        check(7'b1111111, 3'b000, 7'b0000000, 4'b0000, "Unsupported opcode");

      
        $display("Total tests: %0d", tests);
        $display("Total failures: %0d", fails);
      

        if (fails == 0)
            $display("ALL TESTS PASSED");
        else begin
            $display("TESTS FAILED");
            $fatal(1, "ALU control testbench encountered failures.");
        end

        $finish;
    end

endmodule