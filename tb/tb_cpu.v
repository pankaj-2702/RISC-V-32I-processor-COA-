`timescale 1ns/1ps

module tb_cpu;

    reg clk;
    reg reset;

    cpu dut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;

        // Load complete RV32I program into instruction memory
        $readmemh("programs/hex/test_all.hex",
                  dut.imem_unit.memory);

        // Hold reset for a little while
        #12;
        reset = 0;

        // Let the CPU execute the program
        #120;

        $display("=================================");
        $display("FINAL REGISTER STATE");
        $display("=================================");

        $display("x1  = %d", dut.regfile_unit.regs[1]);
        $display("x2  = %d", dut.regfile_unit.regs[2]);
        $display("x3  = %d", dut.regfile_unit.regs[3]);
        $display("x4  = %d", dut.regfile_unit.regs[4]);
        $display("x5  = %d", dut.regfile_unit.regs[5]);
        $display("x6  = %d", dut.regfile_unit.regs[6]);
        $display("x7  = %d", dut.regfile_unit.regs[7]);
        $display("x8  = %d", dut.regfile_unit.regs[8]);
        $display("x9  = %d", dut.regfile_unit.regs[9]);
        $display("x10 = %d", dut.regfile_unit.regs[10]);
        $display("x11 = %d", dut.regfile_unit.regs[11]);
        $display("x12 = %d", dut.regfile_unit.regs[12]);

        $display("=================================");
        $display("FINAL PC = %h", dut.pc);
        $display("=================================");

        $finish;
    end

endmodule