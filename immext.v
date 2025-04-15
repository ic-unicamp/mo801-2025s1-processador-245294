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
            `IMM_TYPE_B: out = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 };
            `IMM_TYPE_J: out = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
            default: out = 'b0;
        endcase
    end

endmodule
