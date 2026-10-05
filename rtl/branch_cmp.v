module branch_cmp (
    input [31:0] a,
    input [31:0] b,
    input [2:0] branch_type,
    output reg taken
);

    always @(*) begin

        case (branch_type)

            // BEQ - Equal
            3'b000:
                taken = (a == b);

            // BNE - Not Equal
            3'b001:
                taken = (a != b);

            // BLT - Signed Less Than
            3'b100:
                taken = ($signed(a) < $signed(b));

            // BGE - Signed Greater Than or Equal
            3'b101:
                taken = ($signed(a) >= $signed(b));

            // BLTU - Unsigned Less Than
            3'b110:
                taken = (a < b);

            // BGEU - Unsigned Greater Than or Equal
            3'b111:
                taken = (a >= b);

            default:
                taken = 1'b0;

        endcase

    end

endmodule