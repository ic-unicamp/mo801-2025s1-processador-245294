`include "constants.v"

module alu_decoder (
    input wire [1:0] alu_op,
    input wire [2:0] funct3,
    input wire funct7,
    output reg [3:0] alu_ctrl
);

    // FIXME: implement alu_ctrl decoding for the B-type ops
    always @(*) begin
        case (alu_op)
            `ALU_OP_ADD: alu_ctrl = `ALU_CMD_ADD;
            `ALU_OP_EVAL: begin
                case (funct3)
                    // add or sub (funct3 == 0x0)
                    3'b000: alu_ctrl = (funct7 == 0) ? `ALU_CMD_ADD : `ALU_CMD_SUB;
                    // xor (funct3 == 0x4)
                    3'b100: alu_ctrl = `ALU_CMD_XOR;
                    // or (funct3 == 0x6)
                    3'b110: alu_ctrl = `ALU_CMD_OR;
                    // and (funct3 == 0x7)
                    3'b111: alu_ctrl = `ALU_CMD_AND;
                    // sll (funct3 == 0x1)
                    3'b001: alu_ctrl = `ALU_CMD_SLL;
                    // srl or sra (funct3 == 0x5)
                    3'b101: alu_ctrl = (funct7 == 0) ? `ALU_CMD_SRL : `ALU_CMD_SRA;
                    // slt (funct3 == 0x2)
                    3'b010: alu_ctrl = `ALU_CMD_SLT;
                    // sltu (funct3 == 0x3)
                    3'b011: alu_ctrl = `ALU_CMD_SLTU;
                endcase
            end
        endcase
    end

endmodule

module control (
    input wire clk,
    input wire reset,
    input wire [31:0] instr,
    output reg pc_write,
    output reg addr_src,
    output reg mem_write,
    output reg instr_write,
    output reg reg_write,
    output reg [1:0] imm_src,
    output reg [1:0] result_src,
    output wire [3:0] alu_ctrl,
    output reg [1:0] alu_src_a,
    output reg [1:0] alu_src_b
);

    reg [3:0] state;
    reg [3:0] next_state;

    wire [6:0] op;
    wire [2:0] funct3;
    wire funct7;

    reg [1:0] alu_op;

    assign op = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[30]; // RV32I only uses bit 5 from func7

    // define the imm_src derived from the instruction type (combinational)
    always @(*) begin
        case (op)
            `OPCODE_LOAD, `OPCODE_I_TYPE: imm_src = `IMM_TYPE_I;
            `OPCODE_STORE: imm_src = `IMM_TYPE_S;
        endcase
    end

    alu_decoder alu_decoder (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .alu_ctrl(alu_ctrl)
    );

    // update state on rising edge
    always @(posedge clk) begin
        if (reset == 1'b0) begin
            state <= `CTRL_FSM_RESET;
        end
        else state <= next_state;
    end

    // FSM state transitions (combinational)
    always @(*) begin
        next_state = `CTRL_FSM_FETCH;
        case (state)
            `CTRL_FSM_RESET: next_state = `CTRL_FSM_FETCH;
            `CTRL_FSM_FETCH: next_state = `CTRL_FSM_DECODE;
            `CTRL_FSM_DECODE: begin
                case (op)
                    `OPCODE_LOAD, `OPCODE_STORE: next_state = `CTRL_FSM_MEMADR;
                    `OPCODE_R_TYPE: next_state = `CTRL_FSM_EXEC_R;
                    `OPCODE_I_TYPE: next_state = `CTRL_FSM_EXEC_I;
                    `OPCODE_JAL: next_state = `CTRL_FSM_JAL;
                    `OPCODE_BEQ: next_state = `CTRL_FSM_BEQ;
                endcase
            end
            `CTRL_FSM_MEMADR: begin
                case (op)
                    `OPCODE_LOAD: next_state = `CTRL_FSM_MEMREAD;
                    `OPCODE_STORE: next_state = `CTRL_FSM_MEMWRITE;
                    // should never happen:
                    default: next_state = `CTRL_FSM_FETCH;
                endcase
            end
            `CTRL_FSM_EXEC_R, `CTRL_FSM_EXEC_I, `CTRL_FSM_JAL: next_state = `CTRL_FSM_ALUWB;
            `CTRL_FSM_MEMREAD: next_state = `CTRL_FSM_MEMWB;
            `CTRL_FSM_MEMWB, `CTRL_FSM_MEMWRITE, `CTRL_FSM_ALUWB, `CTRL_FSM_BEQ: next_state = `CTRL_FSM_FETCH;
            // should never happen
            default: next_state = `CTRL_FSM_FETCH;
        endcase
    end

    // output control signals for each FSM state (combinational)
    always @(*) begin
        // control signals for each state
        // FIXME: ensure that each state explicitly zeroes the control
        // signals that shouldn't be set
        case (state)
            `CTRL_FSM_FETCH: begin
                instr_write = 1;
                reg_write = 0;
                mem_write = 0;
                pc_write = 1;

                addr_src = `ADDR_SRC_PC;

                // increment pc += 4 during the fetch stage
                // alu_ctrl = `ALU_CMD_ADD;
                alu_src_a = `ALU_SRC_A_PC;
                alu_src_b = `ALU_SRC_B_4;
                result_src = `RES_SRC_ALU_RESULT;
            end

            `CTRL_FSM_DECODE: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 0;
                pc_write = 0;
            end

            `CTRL_FSM_MEMADR: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 0;
                pc_write = 0;

                // alu_ctrl = `ALU_CMD_ADD;
                alu_src_a = `ALU_SRC_A_RS1;
                alu_src_b = `ALU_SRC_B_IMM;
            end

            `CTRL_FSM_MEMREAD: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 0;
                pc_write = 0;

                addr_src = `ADDR_SRC_RESULT;
                result_src = `RES_SRC_ALU_OUT;
            end

            `CTRL_FSM_MEMWB: begin
                instr_write = 0;
                reg_write = 1;
                mem_write = 0;
                pc_write = 0;

                result_src = `RES_SRC_MEM_DATA;
            end

            `CTRL_FSM_MEMWRITE: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 1;
                pc_write = 0;

                addr_src = `ADDR_SRC_RESULT;
                result_src = `RES_SRC_ALU_OUT;
            end

            `CTRL_FSM_EXEC_I: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 0;
                pc_write = 0;


                alu_src_a = `ALU_SRC_A_RS1;
                alu_src_b = `ALU_SRC_B_IMM;
            end

            `CTRL_FSM_EXEC_R: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 0;
                pc_write = 0;

                alu_src_a = `ALU_SRC_A_RS1;
                alu_src_b = `ALU_SRC_B_RS2;
            end

            `CTRL_FSM_ALUWB: begin
                instr_write = 0;
                reg_write = 1;
                mem_write = 0;
                pc_write = 0;

                result_src = `RES_SRC_ALU_OUT;
            end
        endcase
    end
endmodule
