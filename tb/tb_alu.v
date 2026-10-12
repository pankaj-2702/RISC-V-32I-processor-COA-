`timescale 1ns/1ps

module tb_alu;

    reg [31:0] a;
    reg [31:0] b;
    reg [3:0] alu_control;
    wire [31:0] result;

    integer tests = 0;
    integer fails = 0;

    alu dut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result)
    );

    task check(
        input [31:0] op1,
        input [31:0] op2,
        input [3:0] operation,
        input [31:0] expected
    );
        begin
            tests = tests + 1;
            a = op1;
            b = op2;
            alu_control = operation;
            #1;

            if (result !== expected) begin
                $display(
                    "FAIL: a=%h b=%h op=%h got=%h expected=%h",
                    op1, op2, operation, result, expected
                );
                fails = fails + 1;
            end
            else begin
                $display(
                    "PASS: a=%h b=%h op=%h got=%h expected=%h",
                    op1, op2, operation, result, expected
                );
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_alu.vcd");
        $dumpvars(0, tb_alu);

        // ADD tests
        check(32'd10, 32'd5, 4'b0000, 32'd15);
        check(32'h7FFFFFFF, 32'd1, 4'b0000, 32'h80000000);  // Signed overflow
        check(32'hFFFFFFFF, 32'd1, 4'b0000, 32'h00000000);  // Unsigned wraparound
        check(-32'd10, 32'd5, 4'b0000, -32'd5);

        // SUB tests
        check(32'd10, 32'd5, 4'b0001, 32'd5);
        check(32'd5, 32'd10, 4'b0001, 32'hFFFFFFFB); // -5
        check(32'h00000000, 32'd1, 4'b0001, 32'hFFFFFFFF); // Underflow wraparound
        check(32'h80000000, 32'd1, 4'b0001, 32'h7FFFFFFF); // Signed underflow
        check(32'd10, 32'd10, 4'b0001, 32'd0); // Equal operands

        // SLL tests
        check(32'h00000001, 32'd2, 4'b0010, 32'h00000004);
        check(32'h12345678, 32'd0, 4'b0010, 32'h12345678);  // Shift by 0
        check(32'h00000001, 32'd31, 4'b0010, 32'h80000000); // Shift by 31
        check(32'h00000001, 32'd32, 4'b0010, 32'h00000001); // Shift 32 -> lower 5 bits = 0
        check(32'h00000001, 32'd33, 4'b0010, 32'h00000002); // Shift 33 -> lower 5 bits = 1
        check(32'h00000001, 32'hFFFFFFE5, 4'b0010, 32'h00000020); // Lower 5 bits = 5

        // SLT (signed) tests
        check(-32'd5, 32'd3, 4'b0011, 32'd1);
        check(32'd3, -32'd5, 4'b0011, 32'd0);
        check(32'd10, 32'd10, 4'b0011, 32'd0); // Equal operands
        check(-32'd5, -32'd5, 4'b0011, 32'd0); // Equal negative operands
        check(32'h80000000, 32'h7FFFFFFF, 4'b0011, 32'd1); // Min signed < Max signed
        check(32'h7FFFFFFF, 32'h80000000, 4'b0011, 32'd0);
        check(32'hFFFFFFFF, 32'd1, 4'b0011, 32'd1); // -1 < 1

        // SLTU (unsigned) tests
        check(32'hFFFFFFFF, 32'd1, 4'b0100, 32'd0);
        check(32'd1, 32'hFFFFFFFF, 4'b0100, 32'd1);
        check(32'd10, 32'd10, 4'b0100, 32'd0); // Equal operands
        check(32'd0, 32'hFFFFFFFF, 4'b0100, 32'd1);
        check(32'd0, 32'd0, 4'b0100, 32'd0);

        // XOR tests
        check(32'hFF00FF00, 32'h0F0F0F0F, 4'b0101, 32'hF00FF00F);
        check(32'hAAAAAAAA, 32'hAAAAAAAA, 4'b0101, 32'h00000000);
        check(32'h12345678, 32'h00000000, 4'b0101, 32'h12345678);

        // SRL tests
        check(32'h80000000, 32'd2, 4'b0110, 32'h20000000);
        check(32'h80000000, 32'd0, 4'b0110, 32'h80000000); // Shift by 0
        check(32'h80000000, 32'd31, 4'b0110, 32'h00000001); // Shift by 31
        check(32'h80000000, 32'd32, 4'b0110, 32'h80000000); // Shift 32 -> lower 5 bits = 0
        check(32'h80000000, 32'd33, 4'b0110, 32'h40000000); // Shift 33 -> lower 5 bits = 1

        // SRA tests
        check(32'h80000000, 32'd2, 4'b0111, 32'hE0000000); // Sign extension
        check(32'h70000000, 32'd2, 4'b0111, 32'h1C000000); // Positive sign preserved
        check(32'h80000000, 32'd0, 4'b0111, 32'h80000000); // Shift by 0
        check(32'h80000000, 32'd31, 4'b0111, 32'hFFFFFFFF); // Shift by 31
        check(32'h80000000, 32'd32, 4'b0111, 32'h80000000); // Shift 32 -> lower 5 bits = 0
        check(32'h80000000, 32'd33, 4'b0111, 32'hC0000000); // Shift 33 -> lower 5 bits = 1

        // OR tests
        check(32'hF0F0F0F0, 32'h0F0F0F0F, 4'b1000, 32'hFFFFFFFF);
        check(32'h12345678, 32'h00000000, 4'b1000, 32'h12345678);

        // AND tests
        check(32'hF0F0F0F0, 32'h0F0F0F0F, 4'b1001, 32'h00000000);
        check(32'h12345678, 32'hFFFFFFFF, 4'b1001, 32'h12345678);

        // Default operation behavior
        check(32'h12345678, 32'h9ABCDEF0, 4'b1111, 32'h00000000);
        check(32'h12345678, 32'h9ABCDEF0, 4'b1010, 32'h00000000);

        $display("--------------------------------");
        $display("Total tests: %0d", tests);
        $display("Total failures: %0d", fails);
        $display("--------------------------------");

        if (fails == 0)
            $display("ALL TESTS PASSED");
        else begin
            $display("TESTS FAILED");
            $fatal(1, "ALU testbench encountered failures.");
        end

        $finish;
    end

endmodule