`timescale 1ns/1ps

module tb_immgen;

    reg [31:0] instruction;
    reg [2:0] imm_type;

    wire [31:0] immediate;

    immgen dut (
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );

    initial begin

        // I-type
        instruction = 32'h00500093;
        imm_type = 3'b000;
        #10;

        $display("I-type immediate = %h", immediate);


        // S-type
        instruction = 32'h00502223;
        imm_type = 3'b001;
        #10;

        $display("S-type immediate = %h", immediate);


        // B-type
        instruction = 32'h00208863;
        imm_type = 3'b010;
        #10;

        $display("B-type immediate = %h", immediate);


        // U-type
        instruction = 32'h12345037;
        imm_type = 3'b011;
        #10;

        $display("U-type immediate = %h", immediate);


        // J-type
        instruction = 32'h0080006F;
        imm_type = 3'b100;
        #10;

        $display("J-type immediate = %h", immediate);


        $finish;

    end

endmodule