module regfile (
    input wire clk,
    input wire write_enable,
    input wire [4:0] addr_1,
    input wire [4:0] addr_2,
    input wire [4:0] addr_3,
    input wire [31:0] write_data,
    output reg [31:0] read_data_1,
    output reg [31:0] read_data_2
);
    reg [31:0] registers [0:31];

    always @(posedge clk) begin
        if (write_enable) begin
            // writes to x0 have no effect
            if (addr_3 != 0)
                registers[addr_3] = write_data;
        end

        // reading from x0 should always return 0
        read_data_1 = (addr_1 == 0) ? 32'b0 : registers[addr_1];
        read_data_2 = (addr_2 == 0) ? 32'b0 : registers[addr_2];
    end
endmodule
