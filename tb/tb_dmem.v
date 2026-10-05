`timescale 1ns/1ps

module tb_dmem;

    reg clk;
    reg [31:0] addr;
    reg [31:0] write_data;

    reg mem_read;
    reg mem_write;

    reg [1:0] mem_size;
    reg mem_unsigned;

    wire [31:0] read_data;

    dmem dut (
        .clk(clk),
        .addr(addr),
        .write_data(write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_size(mem_size),
        .mem_unsigned(mem_unsigned),
        .read_data(read_data)
    );


    // Clock
    always #5 clk = ~clk;


    initial begin

        clk = 0;

        addr = 0;
        write_data = 0;

        mem_read = 0;
        mem_write = 0;

        mem_size = 0;
        mem_unsigned = 0;


        // ==========================================
        // SW
        // Store 0x12345678 at address 0
        // ==========================================

        addr = 32'd0;
        write_data = 32'h12345678;

        mem_size = 2'b10;       // WORD
        mem_write = 1;
        mem_read = 0;

        #10;

        mem_write = 0;


        // ==========================================
        // LW
        // Load word from address 0
        // ==========================================

        addr = 32'd0;

        mem_size = 2'b10;       // WORD
        mem_read = 1;
        mem_unsigned = 0;

        #1;

        $display("LW  = %h", read_data);

        mem_read = 0;


        // ==========================================
        // LB
        // Memory[0] = 0x78
        // ==========================================

        addr = 32'd0;

        mem_size = 2'b00;       // BYTE
        mem_read = 1;
        mem_unsigned = 0;

        #1;

        $display("LB  = %h", read_data);

        mem_read = 0;


        // ==========================================
        // LBU
        // ==========================================

        addr = 32'd0;

        mem_size = 2'b00;       // BYTE
        mem_read = 1;
        mem_unsigned = 1;

        #1;

        $display("LBU = %h", read_data);

        mem_read = 0;


        // ==========================================
        // LH
        // Memory[0] + Memory[1] = 0x5678
        // ==========================================

        addr = 32'd0;

        mem_size = 2'b01;       // HALFWORD
        mem_read = 1;
        mem_unsigned = 0;

        #1;

        $display("LH  = %h", read_data);

        mem_read = 0;


        // ==========================================
        // LHU
        // ==========================================

        addr = 32'd0;

        mem_size = 2'b01;       // HALFWORD
        mem_read = 1;
        mem_unsigned = 1;

        #1;

        $display("LHU = %h", read_data);

        mem_read = 0;


        // ==========================================
        // SB
        // Store AA at address 10
        // ==========================================

        addr = 32'd10;
        write_data = 32'h000000AA;

        mem_size = 2'b00;       // BYTE
        mem_write = 1;

        #10;

        mem_write = 0;


        // Read it back using LBU

        addr = 32'd10;
        mem_size = 2'b00;
        mem_unsigned = 1;
        mem_read = 1;

        #1;

        $display("SB/LBU = %h", read_data);

        mem_read = 0;


        // ==========================================
        // SH
        // Store 0xBEEF at address 12
        // ==========================================

        addr = 32'd12;
        write_data = 32'h0000BEEF;

        mem_size = 2'b01;       // HALFWORD
        mem_write = 1;

        #10;

        mem_write = 0;


        // Read it back using LHU

        addr = 32'd12;
        mem_size = 2'b01;
        mem_unsigned = 1;
        mem_read = 1;

        #1;

        $display("SH/LHU = %h", read_data);

        mem_read = 0;


        $finish;

    end

endmodule