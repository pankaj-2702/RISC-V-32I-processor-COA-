module alu_control (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg [3:0] alu_control
);

    always @(*) begin

        // Default: ADD
        alu_control = 4'b0000;

        case (opcode)

            // -------------------------
            // R-type
            // -------------------------
            7'b0110011: begin

                case (funct3)

                    3'b000: begin
                        if (funct7[5])
                            alu_control = 4'b0001; // SUB
                        else
                            alu_control = 4'b0000; // ADD
                    end

                    3'b001:
                        alu_control = 4'b0010; // SLL

                    3'b010:
                        alu_control = 4'b0011; // SLT

                    3'b011:
                        alu_control = 4'b0100; // SLTU

                    3'b100:
                        alu_control = 4'b0101; // XOR

                    3'b101: begin
                        if (funct7[5])
                            alu_control = 4'b0111; // SRA
                        else
                            alu_control = 4'b0110; // SRL
                    end

                    3'b110:
                        alu_control = 4'b1000; // OR

                    3'b111:
                        alu_control = 4'b1001; // AND

                    default:
                        alu_control = 4'b0000;

                endcase
            end


            // -------------------------
            // I-type ALU
            // -------------------------
            7'b0010011: begin

                case (funct3)

                    3'b000:
                        alu_control = 4'b0000; // ADDI

                    3'b010:
                        alu_control = 4'b0011; // SLTI

                    3'b011:
                        alu_control = 4'b0100; // SLTIU

                    3'b100:
                        alu_control = 4'b0101; // XORI

                    3'b110:
                        alu_control = 4'b1000; // ORI

                    3'b111:
                        alu_control = 4'b1001; // ANDI

                    3'b001:
                        alu_control = 4'b0010; // SLLI

                    3'b101: begin
                        if (funct7[5])
                            alu_control = 4'b0111; // SRAI
                        else
                            alu_control = 4'b0110; // SRLI
                    end

                    default:
                        alu_control = 4'b0000;

                endcase
            end


            // -------------------------
            // LOAD
            // -------------------------
            7'b0000011:
                alu_control = 4'b0000; // address = rs1 + imm


            // -------------------------
            // STORE
            // -------------------------
            7'b0100011:
                alu_control = 4'b0000; // address = rs1 + imm


            // -------------------------
            // JALR
            // -------------------------
            7'b1100111:
                alu_control = 4'b0000; // rs1 + imm


            // -------------------------
            // AUIPC
            // -------------------------
            7'b0010111:
                alu_control = 4'b0000; // PC + imm


            default:
                alu_control = 4'b0000;

        endcase
    end

endmodule