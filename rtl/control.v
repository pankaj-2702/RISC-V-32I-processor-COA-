module control (
    input [6:0] opcode,
    input [2:0] funct3,

    output reg reg_write,
    output reg alu_src,
    output reg alu_a_src,

    output reg mem_read,
    output reg mem_write,
    output reg [1:0] mem_size,
    output reg mem_unsigned,

    output reg branch,
    output reg [2:0] branch_type,

    output reg jump,
    output reg jump_register,

    output reg [2:0] imm_type,

    output reg [1:0] writeback_select
);

    // Writeback selection
    // 00 = ALU result
    // 01 = Memory data
    // 10 = PC + 4
    // 11 = Immediate

    // ALU A source
    // 0 = rs1_data
    // 1 = PC

    always @(*) begin

        // =====================================
        // DEFAULT VALUES
        // =====================================

        reg_write        = 1'b0;
        alu_src          = 1'b0;
        alu_a_src        = 1'b0;

        mem_read         = 1'b0;
        mem_write        = 1'b0;
        mem_size         = 2'b00;
        mem_unsigned     = 1'b0;

        branch           = 1'b0;
        branch_type      = 3'b000;

        jump             = 1'b0;
        jump_register    = 1'b0;

        imm_type         = 3'b000;

        writeback_select = 2'b00;


        // =====================================
        // OPCODE DECODING
        // =====================================

        case (opcode)

            // ---------------------------------
            // R-TYPE
            // ADD, SUB, SLL, SLT, SLTU,
            // XOR, SRL, SRA, OR, AND
            // ---------------------------------

            7'b0110011: begin

                reg_write = 1'b1;

                // ALU A = rs1_data
                alu_a_src = 1'b0;

                // ALU B = rs2_data
                alu_src = 1'b0;

                writeback_select = 2'b00;

            end


            // ---------------------------------
            // I-TYPE ALU
            // ADDI, SLTI, SLTIU,
            // XORI, ORI, ANDI,
            // SLLI, SRLI, SRAI
            // ---------------------------------

            7'b0010011: begin

                reg_write = 1'b1;

                // ALU A = rs1_data
                alu_a_src = 1'b0;

                // ALU B = immediate
                alu_src = 1'b1;

                imm_type = 3'b000;

                writeback_select = 2'b00;

            end


            // ---------------------------------
            // LOAD
            // LB, LH, LW, LBU, LHU
            // ---------------------------------

            7'b0000011: begin

                reg_write = 1'b1;

                // Address = rs1 + immediate
                alu_a_src = 1'b0;
                alu_src = 1'b1;

                mem_read = 1'b1;

                imm_type = 3'b000;

                writeback_select = 2'b01;


                case (funct3)

                    // LB
                    3'b000: begin
                        mem_size = 2'b00;
                        mem_unsigned = 1'b0;
                    end

                    // LH
                    3'b001: begin
                        mem_size = 2'b01;
                        mem_unsigned = 1'b0;
                    end

                    // LW
                    3'b010: begin
                        mem_size = 2'b10;
                        mem_unsigned = 1'b0;
                    end

                    // LBU
                    3'b100: begin
                        mem_size = 2'b00;
                        mem_unsigned = 1'b1;
                    end

                    // LHU
                    3'b101: begin
                        mem_size = 2'b01;
                        mem_unsigned = 1'b1;
                    end

                    default: begin
                        mem_size = 2'b00;
                        mem_unsigned = 1'b0;
                    end

                endcase

            end


            // ---------------------------------
            // STORE
            // SB, SH, SW
            // ---------------------------------

            7'b0100011: begin

                reg_write = 1'b0;

                // Address = rs1 + immediate
                alu_a_src = 1'b0;
                alu_src = 1'b1;

                mem_write = 1'b1;

                imm_type = 3'b001;


                case (funct3)

                    // SB
                    3'b000:
                        mem_size = 2'b00;

                    // SH
                    3'b001:
                        mem_size = 2'b01;

                    // SW
                    3'b010:
                        mem_size = 2'b10;

                    default:
                        mem_size = 2'b00;

                endcase

            end


            // ---------------------------------
            // BRANCH
            // BEQ, BNE, BLT, BGE,
            // BLTU, BGEU
            // ---------------------------------

            7'b1100011: begin

                branch = 1'b1;

                // Branch comparator uses rs1_data
                // and rs2_data directly.
                alu_a_src = 1'b0;
                alu_src = 1'b0;

                imm_type = 3'b010;


                case (funct3)

                    // BEQ
                    3'b000:
                        branch_type = 3'b000;

                    // BNE
                    3'b001:
                        branch_type = 3'b001;

                    // BLT
                    3'b100:
                        branch_type = 3'b100;

                    // BGE
                    3'b101:
                        branch_type = 3'b101;

                    // BLTU
                    3'b110:
                        branch_type = 3'b110;

                    // BGEU
                    3'b111:
                        branch_type = 3'b111;

                    default:
                        branch_type = 3'b000;

                endcase

            end


            // ---------------------------------
            // JAL
            // ---------------------------------

            7'b1101111: begin

                reg_write = 1'b1;

                jump = 1'b1;
                jump_register = 1'b0;

                imm_type = 3'b100;

                // rd = PC + 4
                writeback_select = 2'b10;

            end


            // ---------------------------------
            // JALR
            // ---------------------------------

            7'b1100111: begin

                reg_write = 1'b1;

                // Target = rs1 + immediate
                alu_a_src = 1'b0;
                alu_src = 1'b1;

                jump = 1'b1;
                jump_register = 1'b1;

                imm_type = 3'b000;

                // rd = PC + 4
                writeback_select = 2'b10;

            end


            // ---------------------------------
            // LUI
            // ---------------------------------

            7'b0110111: begin

                reg_write = 1'b1;

                imm_type = 3'b011;

                // rd = immediate
                writeback_select = 2'b11;

            end


            // ---------------------------------
            // AUIPC
            // ---------------------------------

            7'b0010111: begin

                reg_write = 1'b1;

                // ALU A = PC
                alu_a_src = 1'b1;

                // ALU B = immediate
                alu_src = 1'b1;

                imm_type = 3'b011;

                // rd = ALU result
                writeback_select = 2'b00;

            end


            // ---------------------------------
            // DEFAULT
            // ---------------------------------

            default: begin
                // Keep default control signals
            end

        endcase

    end

endmodule