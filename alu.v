`include "constants.v"

module alu (
    input wire [31:0] src_a,
    input wire [31:0] src_b,
    input wire [3:0] ctrl,
    output reg [31:0] out
);

always @(*) begin
    case (ctrl)
        `ALU_CMD_ADD:   out = src_a + src_b;
        default:        out = src_a + src_b;
    endcase
end

endmodule
