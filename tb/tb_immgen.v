`timescale 1ns/1ps

module tb_immgen;

    reg [31:0] instruction;
    reg [2:0] imm_type;
    wire [31:0] immediate;

    integer tests = 0;
    integer fails = 0;

    immgen dut (
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );

    task check(
        input [31:0] inst,
        input [2:0] itype,
        input [31:0] expected,
        input [127:0] desc
    );
        begin
            tests = tests + 1;
            instruction = inst;
            imm_type = itype;
            #1;

            if (immediate !== expected) begin
                $display(
                    "FAIL [%0s]: inst=%h itype=%b got=%h expected=%h",
                    desc, inst, itype, immediate, expected
                );
                fails = fails + 1;
            end
            else begin
                $display(
                    "PASS [%0s]: inst=%h itype=%b got=%h expected=%h",
                    desc, inst, itype, immediate, expected
                );
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_immgen.vcd");
        $dumpvars(0, tb_immgen);

        // I-type (imm_type = 3'b000)
        check(32'h00500093, 3'b000, 32'h00000005, "I-type positive");
        check(32'hFFF00093, 3'b000, 32'hFFFFFFFF, "I-type negative -1");
        check(32'h7FF00093, 3'b000, 32'h000007FF, "I-type max positive");
        check(32'h80000093, 3'b000, 32'hFFFFF800, "I-type min negative");

        // S-type (imm_type = 3'b001)
        check(32'h00502223, 3'b001, 32'h00000004, "S-type positive");
        check(32'hFE502FA3, 3'b001, 32'hFFFFFFFF, "S-type negative -1");
        check(32'h5A000323, 3'b001, 32'h000005A6, "S-type split fields");

        // B-type (imm_type = 3'b010)
        check(32'h00208863, 3'b010, 32'h00000010, "B-type positive +16");
        check(32'hFE000EE3, 3'b010, 32'hFFFFFFFC, "B-type negative -4");

        // U-type (imm_type = 3'b011)
        check(32'h12345037, 3'b011, 32'h12345000, "U-type positive upper");
        check(32'h80000037, 3'b011, 32'h80000000, "U-type negative sign");
        check(32'hFFFFFFFF, 3'b011, 32'hFFFFF000, "U-type clear lower 12");

        // J-type (imm_type = 3'b100)
        check(32'h0080006F, 3'b100, 32'h00000008, "J-type positive +8");
        check(32'hFFDFF06F, 3'b100, 32'hFFFFFFFC, "J-type negative -4");

        // Default / unsupported type
        check(32'hFFFFFFFF, 3'b101, 32'h00000000, "Unsupported 3'b101");
        check(32'hFFFFFFFF, 3'b111, 32'h00000000, "Unsupported 3'b111");

       
        $display("Total tests: %0d", tests);
        $display("Total failures: %0d", fails);
       

        if (fails == 0)
            $display("ALL TESTS PASSED");
        else begin
            $display("TESTS FAILED");
            $fatal(1, "Immgen testbench encountered failures.");
        end

        $finish;
    end

endmodule