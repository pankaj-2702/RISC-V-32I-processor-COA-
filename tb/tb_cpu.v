`timescale 1ns/1ps

module tb_cpu;

    reg clk;
    reg reset;

    integer tests = 0;
    integer fails = 0;

    cpu dut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    task check_reg(
        input [4:0] reg_num,
        input [31:0] expected_val
    );
        begin
            tests = tests + 1;
            if (dut.regfile_unit.regs[reg_num] !== expected_val) begin
                $display(
                    "FAIL: x%0d got=%0d (hex %h) expected=%0d (hex %h)",
                    reg_num, dut.regfile_unit.regs[reg_num], dut.regfile_unit.regs[reg_num],
                    expected_val, expected_val
                );
                fails = fails + 1;
            end
            else begin
                $display(
                    "PASS: x%0d = %0d (hex %h)",
                    reg_num, dut.regfile_unit.regs[reg_num], dut.regfile_unit.regs[reg_num]
                );
            end
        end
    endtask

    task check_pc(
        input [31:0] expected_pc
    );
        begin
            tests = tests + 1;
            if (dut.pc !== expected_pc) begin
                $display(
                    "FAIL: PC got=%h expected=%h",
                    dut.pc, expected_pc
                );
                fails = fails + 1;
            end
            else begin
                $display(
                    "PASS: PC = %h",
                    dut.pc
                );
            end
        end
    endtask

    task check_dmem(
        input [31:0] dmem_addr,
        input [31:0] expected_val
    );
        reg [31:0] actual_val;
        begin
            tests = tests + 1;
            actual_val = {
                dut.dmem_unit.memory[dmem_addr + 3],
                dut.dmem_unit.memory[dmem_addr + 2],
                dut.dmem_unit.memory[dmem_addr + 1],
                dut.dmem_unit.memory[dmem_addr]
            };

            if (actual_val !== expected_val) begin
                $display(
                    "FAIL: DMEM[%h] got=%0d (hex %h) expected=%0d (hex %h)",
                    dmem_addr, actual_val, actual_val, expected_val, expected_val
                );
                fails = fails + 1;
            end
            else begin
                $display(
                    "PASS: DMEM[%h] = %0d (hex %h)",
                    dmem_addr, actual_val, actual_val
                );
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_cpu.vcd");
        $dumpvars(0, tb_cpu);

        clk = 0;
        reset = 1;

        // Load complete RV32I program into instruction memory
        $readmemh("programs/hex/test_all.hex", dut.imem_unit.memory);

        // Hold reset for a little while
        #12;
        reset = 0;

        // Let the CPU execute the program
        #180;

        
        $display("VERIFYING REGISTER FILE STATE");
        

        check_reg(5'd1,  32'd10);
        check_reg(5'd2,  32'd20);
        check_reg(5'd3,  32'd30);
        check_reg(5'd4,  32'd10);
        check_reg(5'd5,  32'd0);
        check_reg(5'd6,  32'd30);
        check_reg(5'd7,  32'd30);
        check_reg(5'd8,  32'd40);
        check_reg(5'd9,  32'd1);
        check_reg(5'd10, 32'd30);
        check_reg(5'd11, 32'h12345000);
        check_reg(5'd12, 32'd50);

        
        $display("VERIFYING DATA MEMORY & PC");
        

        check_dmem(32'd0, 32'd30);
        check_pc(32'h0000003C);

       
        $display("Total tests: %0d", tests);
        $display("Total failures: %0d", fails);
       

        if (fails == 0)
            $display("ALL TESTS PASSED");
        else begin
            $display("TESTS FAILED");
            $fatal(1, "CPU integration testbench encountered failures.");
        end

        $finish;
    end

endmodule