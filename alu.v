`include "constants.v"

module alu (
    input wire [31:0] src_a,
    input wire [31:0] src_b,
    input wire [3:0] ctrl,
    output reg [31:0] out,
    output reg branch_flag
);
    wire signed [31:0] signed_src_a, signed_src_b;
    assign signed_src_a = src_a;
    assign signed_src_b = src_b;

    always @(*) begin
        case (ctrl)
            `ALU_CMD_ADD:   out = src_a + src_b;
            `ALU_CMD_SUB: begin
                out = src_a - src_b;
                branch_flag = (out == 0);
            end
            `ALU_CMD_XOR:   out = src_a ^ src_b;
            `ALU_CMD_OR:    out = src_a | src_b;
            `ALU_CMD_AND:   out = src_a & src_b;
            // note that this is because of the special encoding for shift
            // instructions (shamt has only 5 bits)
            `ALU_CMD_SLL:   out = src_a << src_b[4:0];
            `ALU_CMD_SRL:   out = src_a >> src_b[4:0];
            `ALU_CMD_SRA:   out = $signed(src_a) >>> $signed(src_b[4:0]);
            `ALU_CMD_SLT: begin
                out = ($signed(src_a) < $signed(src_b)) ? 32'b1 : 32'b0;
                branch_flag = out;
            end
            `ALU_CMD_SLTU: begin
                out = ($unsigned(src_a) < $unsigned(src_b)) ? 32'b1 : 32'b0;
                branch_flag = out;
            end
            default: out = src_a + src_b;
        endcase
    end
endmodule
