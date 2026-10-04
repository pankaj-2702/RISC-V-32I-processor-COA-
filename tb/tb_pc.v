`timescale 1ns/1ps

module tb_pc;

    reg clk;
    reg reset;
    reg [31:0] next_pc;

    wire [31:0] pc;

    pc dut (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_pc.vcd");
        $dumpvars(0, tb_pc);

        clk = 0;
        reset = 1;
        next_pc = 32'h00000000;

        #12;

        reset = 0;
        next_pc = 32'h00000004;

        #10;
        $display("PC = %h", pc);

        next_pc = 32'h00000008;

        #10;
        $display("PC = %h", pc);

        next_pc = 32'h0000000C;

        #10;
        $display("PC = %h", pc);

        $finish;
    end

endmodule