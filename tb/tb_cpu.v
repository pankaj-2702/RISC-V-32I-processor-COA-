`timescale 1ns/1ps

module tb_cpu;

    reg clk;
    reg reset;

    cpu dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock
    always #5 clk = ~clk;

    
initial begin

    clk = 1'b0;
    reset = 1'b1;

    // ADD x3, x1, x2
    dut.imem_unit.memory[0] = 8'hB3;
    dut.imem_unit.memory[1] = 8'h81;
    dut.imem_unit.memory[2] = 8'h20;
    dut.imem_unit.memory[3] = 8'h00;

    // Keep reset active
    #12;

    reset = 1'b0;

    // Put known values into registers
    dut.regfile_unit.regs[1] = 32'd10;
    dut.regfile_unit.regs[2] = 32'd20;

    // Wait for the instruction to execute
    #3;

    $display("=================================");
    $display("ADD TEST");
    $display("=================================");

    $display("x1          = %d", dut.regfile_unit.regs[1]);
    $display("x2          = %d", dut.regfile_unit.regs[2]);

    $display("ALU A       = %d", dut.alu_a);
    $display("ALU B       = %d", dut.alu_b);
    $display("ALU Result  = %d", dut.alu_result);

    $display("Writeback   = %d", dut.writeback_data);

    // Wait for rising edge so register write occurs
    #2;

    $display("x3          = %d", dut.regfile_unit.regs[3]);

    $finish;

end

        
endmodule