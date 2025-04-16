// combinationally convert a word to half-word/byte, with
// optional sign-extension
// TODO: if we had a separate load/store unit this logic
//       should live there instead, but alas
module bitfield (
    input wire [31:0] in,
    input wire [1:0] size,
    input wire is_unsigned,
    output reg [31:0] out
);
    always @(*) begin
        case (size)
            `SIZE_WORD: out = in;
            `SIZE_HALF: out = (is_unsigned) ? { {16{1'b0}}, in[15:0] } : { {16{in[15]}}, in[15:0]};
            `SIZE_BYTE: out = (is_unsigned) ? { {24{1'b0}}, in[7:0] } : { {24{in[7]}}, in[7:0] };
            default: out = in;
        endcase
    end
endmodule

module regfile (
    input wire clk,
    input wire write_enable,
    input wire [4:0] addr_1,
    input wire [4:0] addr_2,
    input wire [4:0] addr_3,
    input wire [31:0] write_data,
    input wire [1:0] data_size,
    input wire data_unsigned,
    output reg [31:0] read_data_1,
    output reg [31:0] read_data_2
);
    reg [31:0] registers [0:31];

    reg [31:0] rs1;
    reg [31:0] rs2;
    always @(*) begin
        // reads from x0 return 0
        rs1 = (addr_1 == 0) ? 32'b0 : registers[addr_1];
        rs2 = (addr_2 == 0) ? 32'b0 : registers[addr_2];
    end

    // adjust word/half/byte size for load/store instructions
    wire [31:0] data_in;
    bitfield bitfield_in (
        .in(write_data),
        .size(data_size),
        .is_unsigned(data_unsigned),
        .out(data_in)
    );

    wire [31:0] rs2_out;
    bitfield bitfield_2 (
        .in(rs2),
        .size(data_size),
        .is_unsigned(data_unsigned),
        .out(rs2_out)
    );

    always @(posedge clk) begin
        if (write_enable) begin
            // writes to x0 have no effect
            if (addr_3 != 0)
                registers[addr_3] <= data_in;
        end

        read_data_1 <= rs1;
        read_data_2 <= rs2_out;
    end
endmodule
