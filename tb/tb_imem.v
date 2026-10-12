`timescale 1ns/1ps

module tb_imem;

    reg [31:0] addr;
    wire [31:0] instruction;

    integer tests = 0;
    integer fails = 0;

    imem dut (
        .addr(addr),
        .instruction(instruction)
    );

    task check(
        input [31:0] test_addr,
        input [31:0] expected_inst
    );
        begin
            tests = tests + 1;
            addr = test_addr;
            #1;

            if (instruction !== expected_inst) begin
                $display(
                    "FAIL: addr=%h got=%h expected=%h",
                    test_addr, instruction, expected_inst
                );
                fails = fails + 1;
            end
            else begin
                $display(
                    "PASS: addr=%h got=%h expected=%h",
                    test_addr, instruction, expected_inst
                );
            end
        end
    endtask

    initial begin
        $dumpfile("sim/tb_imem.vcd");
        $dumpvars(0, tb_imem);

        // Word 0 (Address 0x0): Little-endian 0x12345678
        dut.memory[0] = 8'h78;
        dut.memory[1] = 8'h56;
        dut.memory[2] = 8'h34;
        dut.memory[3] = 8'h12;

        // Word 1 (Address 0x4): Little-endian 0xAABBCCDD
        dut.memory[4] = 8'hDD;
        dut.memory[5] = 8'hCC;
        dut.memory[6] = 8'hBB;
        dut.memory[7] = 8'hAA;

        // Word 2 (Address 0x8): Little-endian 0xDEADBEEF
        dut.memory[8]  = 8'hEF;
        dut.memory[9]  = 8'hBE;
        dut.memory[10] = 8'hAD;
        dut.memory[11] = 8'hDE;

        // Word 3 (Address 0xC): Little-endian 0xCAFEBABE
        dut.memory[12] = 8'hBE;
        dut.memory[13] = 8'hBA;
        dut.memory[14] = 8'hFE;
        dut.memory[15] = 8'hCA;

        // Word 4 (Address 0x10): Little-endian 0x04030201
        dut.memory[16] = 8'h01;
        dut.memory[17] = 8'h02;
        dut.memory[18] = 8'h03;
        dut.memory[19] = 8'h04;

        // Word 5 (Address 0x14): Little-endian 0xAA5500FF
        dut.memory[20] = 8'hFF;
        dut.memory[21] = 8'h00;
        dut.memory[22] = 8'h55;
        dut.memory[23] = 8'hAA;

        // Check word-aligned accesses
        check(32'h00000000, 32'h12345678);
        check(32'h00000004, 32'hAABBCCDD);
        check(32'h00000008, 32'hDEADBEEF);
        check(32'h0000000C, 32'hCAFEBABE);
        check(32'h00000010, 32'h04030201);
        check(32'h00000014, 32'hAA5500FF);

        // Check unaligned accesses to verify byte concatenation order
        // Addr 1: bytes {memory[4], memory[3], memory[2], memory[1]} = {DD, 12, 34, 56}
        check(32'h00000001, 32'hDD123456);
        // Addr 2: bytes {memory[5], memory[4], memory[3], memory[2]} = {CC, DD, 12, 34}
        check(32'h00000002, 32'hCCDD1234);

       
        $display("Total tests: %0d", tests);
        $display("Total failures: %0d", fails);
       

        if (fails == 0)
            $display("ALL TESTS PASSED");
        else begin
            $display("TESTS FAILED");
            $fatal(1, "IMEM testbench encountered failures.");
        end

        $finish;
    end

endmodule