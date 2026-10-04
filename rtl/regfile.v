module regfile (
    input clk,
    input reset,

    input [4:0] rs1_addr,
    input [4:0] rs2_addr,

    input [4:0] rd_addr,
    input [31:0] write_data,
    input reg_write,

    output [31:0] rs1_data,
    output [31:0] rs2_data
);

    reg [31:0] regs [0:31];

    integer i;

    // Combinational reads
    assign rs1_data = (rs1_addr == 5'd0) ? 32'b0 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'b0 : regs[rs2_addr];

    // Synchronous write
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end
        else if (reg_write && rd_addr != 5'd0) begin
            regs[rd_addr] <= write_data;
        end
    end

endmodule