module regfile (
    input wire clk,
    input wire write_enable, /* write enable */
    input wire [4:0] addr_1,
    input wire [4:0] addr_2,
    input wire [4:0] addr_3,
    input wire [31:0] write_data,
    output wire [31:0] read_data_1,
    output wire [31:0] read_data_2
);
    reg [31:0] registers [31:0];

    always @(posedge clk) begin
        if (write_enable)
            registers[addr_3] = write_data;
    end

    assign read_data_1 = registers[addr_1];
    assign read_data_2 = registers[addr_2];
endmodule
