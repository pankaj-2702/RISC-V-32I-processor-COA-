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

    integer tests = 0;
    integer fails = 0;

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

    always #5 clk = ~clk;

    task write_mem(
        input [31:0] waddr,
        input [31:0] wdata,
        input [1:0] wsize
    );
        begin
            @(negedge clk);
            addr = waddr;
            write_data = wdata;
            mem_size = wsize;
            mem_write = 1'b1;
            mem_read = 1'b0;
            @(posedge clk);
            #1;
            mem_write = 1'b0;
        end
    endtask

    task check_read(
        input [31:0] raddr,
        input [1:0] rsize,
        input runsigned,
        input [31:0] expected,
        input [127:0] desc
    );
        begin
            tests = tests + 1;
            addr = raddr;
            mem_size = rsize;
            mem_unsigned = runsigned;
            mem_read = 1'b1;
            mem_write = 1'b0;
            #1;

            if (read_data !== expected) begin
                $display(
                    "FAIL [%0s]: addr=%h size=%b unsigned=%b got=%h expected=%h",
                    desc, raddr, rsize, runsigned, read_data, expected
                );
                fails = fails + 1;
            end
            else begin
                $display(
                    "PASS [%0s]: addr=%h size=%b unsigned=%b got=%h expected=%h",
                    desc, raddr, rsize, runsigned, read_data, expected
                );
            end
            mem_read = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("sim/tb_dmem.vcd");
        $dumpvars(0, tb_dmem);

        clk = 0;
        addr = 0;
        write_data = 0;
        mem_read = 0;
        mem_write = 0;
        mem_size = 0;
        mem_unsigned = 0;

        // SW and LW: Store 0x12345678 at address 0
        write_mem(32'd0, 32'h12345678, 2'b10); // SW
        check_read(32'd0, 2'b10, 1'b0, 32'h12345678, "SW -> LW");

        // Little-endian byte loads from address 0
        // Byte 0: 0x78 (positive)
        check_read(32'd0, 2'b00, 1'b0, 32'h00000078, "LB byte 0");
        check_read(32'd0, 2'b00, 1'b1, 32'h00000078, "LBU byte 0");

        // Byte 1: 0x56
        check_read(32'd1, 2'b00, 1'b0, 32'h00000056, "LB byte 1");

        // Halfword loads from address 0: 0x5678 (positive)
        check_read(32'd0, 2'b01, 1'b0, 32'h00005678, "LH halfword 0");
        check_read(32'd0, 2'b01, 1'b1, 32'h00005678, "LHU halfword 0");

        // Halfword load from address 2: 0x1234
        check_read(32'd2, 2'b01, 1'b0, 32'h00001234, "LH halfword 1");

        // Sign extension vs zero extension on byte: 0xAA (negative byte) at addr 4
        write_mem(32'd4, 32'h000000AA, 2'b00); // SB
        check_read(32'd4, 2'b00, 1'b0, 32'hFFFFFFAA, "LB sign extension");
        check_read(32'd4, 2'b00, 1'b1, 32'h000000AA, "LBU zero extension");

        // Sign extension vs zero extension on halfword: 0xBEEF (negative halfword) at addr 6
        write_mem(32'd6, 32'h0000BEEF, 2'b01); // SH
        check_read(32'd6, 2'b01, 1'b0, 32'hFFFFBEEF, "LH sign extension");
        check_read(32'd6, 2'b01, 1'b1, 32'h0000BEEF, "LHU zero extension");

        // Overwrite isolation: SB at byte 1 of a word must not corrupt other bytes
        write_mem(32'd16, 32'h11223344, 2'b10); // SW
        write_mem(32'd17, 32'h00000099, 2'b00); // SB at addr 17
        check_read(32'd16, 2'b10, 1'b0, 32'h11229944, "SB overwrite isolation");

        // Overwrite isolation: SH at bytes 2..3 must not corrupt bytes 0..1
        write_mem(32'd20, 32'hAABBCCDD, 2'b10); // SW
        write_mem(32'd22, 32'h00004321, 2'b01); // SH at addr 22
        check_read(32'd20, 2'b10, 1'b0, 32'h4321CCDD, "SH overwrite isolation");

        // Inactive mem_read returns 0
        tests = tests + 1;
        addr = 32'd0;
        mem_read = 1'b0;
        #1;
        if (read_data !== 32'b0) begin
            $display("FAIL [mem_read=0]: got=%h expected=00000000", read_data);
            fails = fails + 1;
        end
        else begin
            $display("PASS [mem_read=0]: got=%h expected=00000000", read_data);
        end

     
        $display("Total tests: %0d", tests);
        $display("Total failures: %0d", fails);
     

        if (fails == 0)
            $display("ALL TESTS PASSED");
        else begin
            $display("TESTS FAILED");
            $fatal(1, "DMEM testbench encountered failures.");
        end

        $finish;
    end

endmodule