`timescale 1ns/1ps

module tb_regfile;

    reg clk;
    reg reset;

    reg [4:0] rs1_addr;
    reg [4:0] rs2_addr;

    reg [4:0] rd_addr;
    reg [31:0] write_data;
    reg reg_write;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    regfile dut (
        .clk(clk),
        .reset(reset),

        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),

        .rd_addr(rd_addr),
        .write_data(write_data),
        .reg_write(reg_write),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/tb_regfile.vcd");
        $dumpvars(0, tb_regfile);

        clk = 0;
        reset = 1;

        rs1_addr = 5'd0;
        rs2_addr = 5'd0;

        rd_addr = 5'd0;
        write_data = 32'b0;
        reg_write = 0;

        // Reset registers
        #12;

        reset = 0;

        // Write 123 to x5
        rd_addr = 5'd5;
        write_data = 32'h0000007B;
        reg_write = 1;

        #10;

        reg_write = 0;

        // Read x5
        rs1_addr = 5'd5;

        #1;

        $display("x5 = %h", rs1_data);

        // Read x0
        rs1_addr = 5'd0;

        #1;

        $display("x0 = %h", rs1_data);

        // Try writing to x0
        rd_addr = 5'd0;
        write_data = 32'hDEADBEEF;
        reg_write = 1;

        #10;

        reg_write = 0;

        // Read x0 again
        rs1_addr = 5'd0;

        #1;

        $display("x0 after write attempt = %h", rs1_data);

        $finish;

    end

endmodule