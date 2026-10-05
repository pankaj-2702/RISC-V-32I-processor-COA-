module dmem (
    input clk,
    input [31:0] addr,
    input [31:0] write_data,

    input mem_read,
    input mem_write,

    input [1:0] mem_size,
    input mem_unsigned,

    output reg [31:0] read_data
);

    // Byte-addressable memory
    reg [7:0] memory [0:4095];

    // Memory size encoding
    // 00 = BYTE
    // 01 = HALFWORD
    // 10 = WORD


    // =========================
    // STORE
    // =========================

    always @(posedge clk) begin

        if (mem_write) begin

            case (mem_size)

                // SB
                2'b00: begin
                    memory[addr] = write_data[7:0];
                end

                // SH
                2'b01: begin
                    memory[addr]     = write_data[7:0];
                    memory[addr + 1] = write_data[15:8];
                end

                // SW
                2'b10: begin
                    memory[addr]     = write_data[7:0];
                    memory[addr + 1] = write_data[15:8];
                    memory[addr + 2] = write_data[23:16];
                    memory[addr + 3] = write_data[31:24];
                end

                default: begin
                end

            endcase

        end

    end


    // =========================
    // LOAD
    // =========================

    always @(*) begin

        read_data = 32'b0;

        if (mem_read) begin

            case (mem_size)

                // BYTE
                2'b00: begin

                    if (mem_unsigned)
                        read_data = {24'b0, memory[addr]};
                    else
                        read_data = {{24{memory[addr][7]}},
                                     memory[addr]};

                end


                // HALFWORD
                2'b01: begin

                    if (mem_unsigned)
                        read_data = {
                            16'b0,
                            memory[addr + 1],
                            memory[addr]
                        };
                    else
                        read_data = {
                            {16{memory[addr + 1][7]}},
                            memory[addr + 1],
                            memory[addr]
                        };

                end


                // WORD
                2'b10: begin

                    read_data = {
                        memory[addr + 3],
                        memory[addr + 2],
                        memory[addr + 1],
                        memory[addr]
                    };

                end


                default: begin
                    read_data = 32'b0;
                end

            endcase

        end

    end

endmodule