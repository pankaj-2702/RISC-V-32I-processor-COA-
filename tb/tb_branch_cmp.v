`timescale 1ns/1ps

module tb_branch_cmp;

    reg [31:0] a;
    reg [31:0] b;
    reg [2:0] branch_type;

    wire taken;

    branch_cmp dut (
        .a(a),
        .b(b),
        .branch_type(branch_type),
        .taken(taken)
    );

    initial begin

        // BEQ: 10 == 10 → true
        a = 10;
        b = 10;
        branch_type = 3'b000;
        #10;
        $display("BEQ  = %b", taken);


        // BNE: 10 != 5 → true
        a = 10;
        b = 5;
        branch_type = 3'b001;
        #10;
        $display("BNE  = %b", taken);


        // BLT signed: -5 < 3 → true
        a = -5;
        b = 3;
        branch_type = 3'b100;
        #10;
        $display("BLT  = %b", taken);


        // BGE signed: 5 >= -3 → true
        a = 5;
        b = -3;
        branch_type = 3'b101;
        #10;
        $display("BGE  = %b", taken);


        // BLTU unsigned: 1 < 5 → true
        a = 1;
        b = 5;
        branch_type = 3'b110;
        #10;
        $display("BLTU = %b", taken);


        // BGEU unsigned: FFFFFFFF >= 1 → true
        a = 32'hFFFFFFFF;
        b = 1;
        branch_type = 3'b111;
        #10;
        $display("BGEU = %b", taken);


        $finish;

    end

endmodule