`timescale 1ns/1ps

module tb_imem;

    reg [31:0] addr;
    wire [31:0] instruction;

    imem dut (
        .addr(addr),
        .instruction(instruction)
    );

    initial begin
        dut.memory[0] = 8'h78;
dut.memory[1] = 8'h56;
dut.memory[2] = 8'h34;
dut.memory[3] = 8'h12;

dut.memory[4] = 8'hDD;
dut.memory[5] = 8'hCC;
dut.memory[6] = 8'hBB;
dut.memory[7] = 8'hAA;

dut.memory[8]  = 8'hEF;
dut.memory[9]  = 8'hBE;
dut.memory[10] = 8'hAD;
dut.memory[11] = 8'hDE;

dut.memory[12] = 8'hBE;
dut.memory[13] = 8'hBA;
dut.memory[14] = 8'hFE;
dut.memory[15] = 8'hCA;
        addr = 32'h00000000;
        #1;
        $display("ADDR = %h, INSTRUCTION = %h", addr, instruction);

        addr = 32'h00000004;
        #1;
        $display("ADDR = %h, INSTRUCTION = %h", addr, instruction);

        addr = 32'h00000008;
        #1;
        $display("ADDR = %h, INSTRUCTION = %h", addr, instruction);

        addr = 32'h0000000C;
        #1;
        $display("ADDR = %h, INSTRUCTION = %h", addr, instruction);

        $finish;
    end

endmodule