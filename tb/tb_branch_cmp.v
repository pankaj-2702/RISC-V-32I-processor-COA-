`timescale 1ns/1ps

module tb_branch_cmp;

    reg [31:0] a;
    reg [31:0] b;
    reg [2:0] branch_type;
    wire taken;

    integer tests = 0;
    integer fails = 0;

    branch_cmp dut (
        .a(a),
        .b(b),
        .branch_type(branch_type),
        .taken(taken)
    );

    task check(
        input [31:0] op1,
        input [31:0] op2,
        input [2:0] btype,
        input expected,
        input [127:0] desc
    );
        begin
            tests = tests + 1;
            a = op1;
            b = op2;
            branch_type = btype;
            #1;

            if (taken !== expected) begin
                $display(
                    "FAIL [%0s]: a=%h b=%h type=%b got=%b expected=%b",
                    desc, op1, op2, btype, taken, expected
                );
                fails = fails + 1;
            end
            else begin
                $display(
                    "PASS [%0s]: a=%h b=%h type=%b got=%b expected=%b",
                    desc, op1, op2, btype, taken, expected
                );
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_branch_cmp.vcd");
        $dumpvars(0, tb_branch_cmp);

        // BEQ tests (branch_type = 3'b000)
        check(32'd10, 32'd10, 3'b000, 1'b1, "BEQ equal true");
        check(32'd10, 32'd5, 3'b000, 1'b0, "BEQ unequal false");
        check(-32'd5, -32'd5, 3'b000, 1'b1, "BEQ equal negative true");

        // BNE tests (branch_type = 3'b001)
        check(32'd10, 32'd5, 3'b001, 1'b1, "BNE unequal true");
        check(32'd10, 32'd10, 3'b001, 1'b0, "BNE equal false");
        check(-32'd5, 32'd5, 3'b001, 1'b1, "BNE sign mismatch true");

        // BLT signed tests (branch_type = 3'b100)
        check(-32'd5, 32'd3, 3'b100, 1'b1, "BLT -5 < 3 true");
        check(32'd3, -32'd5, 3'b100, 1'b0, "BLT 3 < -5 false");
        check(32'd5, 32'd5, 3'b100, 1'b0, "BLT equal false");
        check(-32'd10, -32'd5, 3'b100, 1'b1, "BLT -10 < -5 true");
        check(32'h80000000, 32'h7FFFFFFF, 3'b100, 1'b1, "BLT min < max true");
        check(32'hFFFFFFFF, 32'd1, 3'b100, 1'b1, "BLT -1 < 1 true");

        // BGE signed tests (branch_type = 3'b101)
        check(32'd5, -32'd3, 3'b101, 1'b1, "BGE 5 >= -3 true");
        check(-32'd3, 32'd5, 3'b101, 1'b0, "BGE -3 >= 5 false");
        check(32'd5, 32'd5, 3'b101, 1'b1, "BGE equal true");
        check(-32'd5, -32'd5, 3'b101, 1'b1, "BGE equal negative true");
        check(32'h7FFFFFFF, 32'h80000000, 3'b101, 1'b1, "BGE max >= min true");
        check(32'hFFFFFFFF, 32'd1, 3'b101, 1'b0, "BGE -1 >= 1 false");

        // BLTU unsigned tests (branch_type = 3'b110)
        check(32'd1, 32'd5, 3'b110, 1'b1, "BLTU 1 < 5 true");
        check(32'd5, 32'd1, 3'b110, 1'b0, "BLTU 5 < 1 false");
        check(32'd5, 32'd5, 3'b110, 1'b0, "BLTU equal false");
        check(32'hFFFFFFFF, 32'd1, 3'b110, 1'b0, "BLTU 0xFFFFFFFF < 1 false (distinguishes signed)");
        check(32'd1, 32'hFFFFFFFF, 3'b110, 1'b1, "BLTU 1 < 0xFFFFFFFF true");

        // BGEU unsigned tests (branch_type = 3'b111)
        check(32'hFFFFFFFF, 32'd1, 3'b111, 1'b1, "BGEU 0xFFFFFFFF >= 1 true (distinguishes signed)");
        check(32'd1, 32'hFFFFFFFF, 3'b111, 1'b0, "BGEU 1 >= 0xFFFFFFFF false");
        check(32'd5, 32'd5, 3'b111, 1'b1, "BGEU equal true");
        check(32'd10, 32'd5, 3'b111, 1'b1, "BGEU 10 >= 5 true");

        // Default / invalid branch type
        check(32'd10, 32'd10, 3'b010, 1'b0, "Invalid branch_type 3'b010 false");

        $display("Total tests: %0d", tests);
        $display("Total failures: %0d", fails);
    

        if (fails == 0)
            $display("ALL TESTS PASSED");
        else begin
            $display("TESTS FAILED");
            $fatal(1, "Branch comparator testbench encountered failures.");
        end

        $finish;
    end

endmodule