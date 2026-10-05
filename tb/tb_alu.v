`timescale 1ns/1ps

module tb_alu;

    reg [31:0] a;
    reg [31:0] b;
    reg [3:0] alu_control;

    wire [31:0] result;

    alu dut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result)
    );

    initial begin

        // ADD
        a = 10;
        b = 5;
        alu_control = 4'b0000;
        #10;
        $display("ADD  = %h", result);


        // SUB
        a = 10;
        b = 5;
        alu_control = 4'b0001;
        #10;
        $display("SUB  = %h", result);


        // SLL
        a = 32'h00000001;
        b = 2;
        alu_control = 4'b0010;
        #10;
        $display("SLL  = %h", result);


        // SLT signed: -5 < 3
        a = -5;
        b = 3;
        alu_control = 4'b0011;
        #10;
        $display("SLT  = %h", result);


        // SLTU unsigned: FFFFFFFF < 1 ?
        a = 32'hFFFFFFFF;
        b = 1;
        alu_control = 4'b0100;
        #10;
        $display("SLTU = %h", result);


        // XOR
        a = 32'hFF00FF00;
        b = 32'h0F0F0F0F;
        alu_control = 4'b0101;
        #10;
        $display("XOR  = %h", result);


        // SRL
        a = 32'h80000000;
        b = 2;
        alu_control = 4'b0110;
        #10;
        $display("SRL  = %h", result);


        // SRA
        a = 32'h80000000;
        b = 2;
        alu_control = 4'b0111;
        #10;
        $display("SRA  = %h", result);


        // OR
        a = 32'hF0F0F0F0;
        b = 32'h0F0F0F0F;
        alu_control = 4'b1000;
        #10;
        $display("OR   = %h", result);


        // AND
        a = 32'hF0F0F0F0;
        b = 32'h0F0F0F0F;
        alu_control = 4'b1001;
        #10;
        $display("AND  = %h", result);


        $finish;

    end

endmodule