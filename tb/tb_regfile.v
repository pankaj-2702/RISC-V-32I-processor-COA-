`timescale 1ns/1ps

module tb_regfile;

    reg clk;
    reg reset;

    reg [4:0] rs1_addr;
    reg [4:0] rs2_addr;
    reg [4:0] rd_addr;
    reg [31:0] write_data;
    reg reg_write;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    integer tests = 0;
    integer fails = 0;

    regfile dut (
        .clk(clk),
        .reset(reset),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .write_data(write_data),
        .reg_write(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    always #5 clk = ~clk;

    task write_reg(
        input [4:0] addr,
        input [31:0] data
    );
        begin
            @(negedge clk);
            rd_addr = addr;
            write_data = data;
            reg_write = 1'b1;
            @(posedge clk);
            #1;
            reg_write = 1'b0;
        end
    endtask

    task check_read(
        input [4:0] r1_addr,
        input [4:0] r2_addr,
        input [31:0] exp1,
        input [31:0] exp2
    );
        begin
            tests = tests + 1;
            rs1_addr = r1_addr;
            rs2_addr = r2_addr;
            #1;

            if (rs1_data !== exp1 || rs2_data !== exp2) begin
                $display(
                    "FAIL: rs1[%0d]=%h (exp %h) rs2[%0d]=%h (exp %h)",
                    r1_addr, rs1_data, exp1, r2_addr, rs2_data, exp2
                );
                fails = fails + 1;
            end
            else begin
                $display(
                    "PASS: rs1[%0d]=%h (exp %h) rs2[%0d]=%h (exp %h)",
                    r1_addr, rs1_data, exp1, r2_addr, rs2_data, exp2
                );
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_regfile.vcd");
        $dumpvars(0, tb_regfile);

        clk = 0;
        reset = 1;
        rs1_addr = 5'd0;
        rs2_addr = 5'd0;
        rd_addr = 5'd0;
        write_data = 32'b0;
        reg_write = 1'b0;

        // Synchronous reset cycle
        @(negedge clk);
        reset = 1;
        @(posedge clk);
        #1;
        reset = 0;

        // Verify initial state: x0, x1, x5 are 0
        check_read(5'd0, 5'd1, 32'h00000000, 32'h00000000);

        // Write to x5 and read back
        write_reg(5'd5, 32'h0000007B);
        check_read(5'd5, 5'd0, 32'h0000007B, 32'h00000000);

        // Verify write attempt to x0 is ignored
        write_reg(5'd0, 32'hDEADBEEF);
        check_read(5'd0, 5'd5, 32'h00000000, 32'h0000007B);

        // Simultaneous read of distinct registers
        write_reg(5'd1, 32'h11111111);
        write_reg(5'd2, 32'h22222222);
        check_read(5'd1, 5'd2, 32'h11111111, 32'h22222222);

        // Swap read ports
        check_read(5'd2, 5'd1, 32'h22222222, 32'h11111111);

        // Read same register simultaneously on both ports
        check_read(5'd5, 5'd5, 32'h0000007B, 32'h0000007B);

        // Write without reg_write asserted (data should not be written)
        @(negedge clk);
        rd_addr = 5'd3;
        write_data = 32'h33333333;
        reg_write = 1'b0;
        @(posedge clk);
        #1;
        check_read(5'd3, 5'd0, 32'h00000000, 32'h00000000);

        // Upper register address test (x31)
        write_reg(5'd31, 32'hCAFE1234);
        check_read(5'd31, 5'd1, 32'hCAFE1234, 32'h11111111);

        // Overwrite existing register value
        write_reg(5'd5, 32'hA5A5A5A5);
        check_read(5'd5, 5'd31, 32'hA5A5A5A5, 32'hCAFE1234);

        // Synchronous reset clears all registers
        @(negedge clk);
        reset = 1;
        @(posedge clk);
        #1;
        reset = 0;
        check_read(5'd1, 5'd2, 32'h00000000, 32'h00000000);
        check_read(5'd5, 5'd31, 32'h00000000, 32'h00000000);

       
        $display("Total tests: %0d", tests);
        $display("Total failures: %0d", fails);
       

        if (fails == 0)
            $display("ALL TESTS PASSED");
        else begin
            $display("TESTS FAILED");
            $fatal(1, "Register file testbench encountered failures.");
        end

        $finish;
    end

endmodule