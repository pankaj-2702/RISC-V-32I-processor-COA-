`timescale 1ns/1ps

module tb_pc;

    reg clk;
    reg reset;
    reg [31:0] next_pc;
    wire [31:0] pc;

    integer tests = 0;
    integer fails = 0;

    pc dut (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    always #5 clk = ~clk;

    task check_step(
        input [31:0] in_next_pc,
        input in_reset,
        input [31:0] expected_pc
    );
        begin
            tests = tests + 1;
            @(negedge clk);
            next_pc = in_next_pc;
            reset = in_reset;
            @(posedge clk);
            #1;

            if (pc !== expected_pc) begin
                $display(
                    "FAIL: next_pc=%h reset=%b got=%h expected=%h",
                    in_next_pc, in_reset, pc, expected_pc
                );
                fails = fails + 1;
            end
            else begin
                $display(
                    "PASS: next_pc=%h reset=%b got=%h expected=%h",
                    in_next_pc, in_reset, pc, expected_pc
                );
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_pc.vcd");
        $dumpvars(0, tb_pc);

        clk = 0;
        reset = 1;
        next_pc = 32'h00000000;

        // Reset verification
        check_step(32'h00000000, 1'b1, 32'h00000000);
        check_step(32'h12345678, 1'b1, 32'h00000000); // Reset overrides non-zero next_pc

        // Sequential advancement
        check_step(32'h00000004, 1'b0, 32'h00000004);
        check_step(32'h00000008, 1'b0, 32'h00000008);
        check_step(32'h0000000C, 1'b0, 32'h0000000C);
        check_step(32'h00000010, 1'b0, 32'h00000010);

        // Branch and jump targets
        check_step(32'h00001000, 1'b0, 32'h00001000); // Forward branch/jump
        check_step(32'h00001004, 1'b0, 32'h00001004); // Sequential after jump
        check_step(32'h00000040, 1'b0, 32'h00000040); // Backward branch/jump
        check_step(32'hFFFFFFFC, 1'b0, 32'hFFFFFFFC); // Upper memory range

        // Reset asserted again while in upper range
        check_step(32'h00000004, 1'b1, 32'h00000000); // Reset to 0
        check_step(32'h00000004, 1'b0, 32'h00000004); // Normal operation resumes

       
        $display("Total tests: %0d", tests);
        $display("Total failures: %0d", fails);
       

        if (fails == 0)
            $display("ALL TESTS PASSED");
        else begin
            $display("TESTS FAILED");
            $fatal(1, "PC testbench encountered failures.");
        end

        $finish;
    end

endmodule