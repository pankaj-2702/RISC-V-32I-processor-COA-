module imem (
    input [31:0] addr,
    output [31:0] instruction
);

    reg [7:0] memory [0:4095];

    assign instruction = {
        memory[addr + 32'd3],
        memory[addr + 32'd2],
        memory[addr + 32'd1],
        memory[addr]
    };

endmodule