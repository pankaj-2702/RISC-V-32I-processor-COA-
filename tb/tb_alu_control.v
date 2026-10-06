`timescale 1ns/1ps

module tb_alu_control;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire [3:0] alu_control;

    alu_control dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );

    initial begin

        // R-type ADD
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;
        $display("ADD  = %b", alu_control);

        // R-type SUB
        funct7 = 7'b0100000;
        #10;
        $display("SUB  = %b", alu_control);

        // SLL
        funct3 = 3'b001;
        funct7 = 7'b0000000;
        #10;
        $display("SLL  = %b", alu_control);

        // SLT
        funct3 = 3'b010;
        #10;
        $display("SLT  = %b", alu_control);

        // SLTU
        funct3 = 3'b011;
        #10;
        $display("SLTU = %b", alu_control);

        // XOR
        funct3 = 3'b100;
        #10;
        $display("XOR  = %b", alu_control);

        // SRL
        funct3 = 3'b101;
        funct7 = 7'b0000000;
        #10;
        $display("SRL  = %b", alu_control);

        // SRA
        funct7 = 7'b0100000;
        #10;
        $display("SRA  = %b", alu_control);

        // OR
        funct3 = 3'b110;
        #10;
        $display("OR   = %b", alu_control);

        // AND
        funct3 = 3'b111;
        #10;
        $display("AND  = %b", alu_control);


        // I-type ADDI
        opcode = 7'b0010011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;
        $display("ADDI = %b", alu_control);

        // I-type SLTI
        funct3 = 3'b010;
        #10;
        $display("SLTI = %b", alu_control);

        // I-type XORI
        funct3 = 3'b100;
        #10;
        $display("XORI = %b", alu_control);

        // I-type SRAI
        funct3 = 3'b101;
        funct7 = 7'b0100000;
        #10;
        $display("SRAI = %b", alu_control);


        // LOAD
        opcode = 7'b0000011;
        funct3 = 3'b010;
        #10;
        $display("LOAD = %b", alu_control);

        // STORE
        opcode = 7'b0100011;
        funct3 = 3'b010;
        #10;
        $display("STORE = %b", alu_control);

        // JALR
        opcode = 7'b1100111;
        #10;
        $display("JALR = %b", alu_control);

        // AUIPC
        opcode = 7'b0010111;
        #10;
        $display("AUIPC = %b", alu_control);

        $finish;
    end

endmodule