`include "constants.v"

module immext (
    input wire [31:0] instr,
    input wire [1:0] imm_src,
    output reg [31:0] out
);

    always @(*) begin
        case (imm_src)
            `IMM_TYPE_I: out = { {20{instr[31]}}, instr[31:20] };
            `IMM_TYPE_S: out = { {20{instr[31]}}, instr[31:25], instr[11:7] };
            default: out = 'b0;
        endcase
    end

endmodule
