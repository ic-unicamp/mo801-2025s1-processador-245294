`include "constants.v"

module alu_decoder (
    input wire [1:0] alu_op,
    input wire op_5,
    input wire [2:0] funct3,
    input wire funct7_5,
    output reg [3:0] alu_ctrl
);

    always @(*) begin
        case (alu_op)
            `ALU_OP_ADD: alu_ctrl = `ALU_CMD_ADD;
            `ALU_OP_BRANCH: begin
                case(funct3)
                    // beq (funct3 == 0x0), bne (funct3 == 0x1)
                    3'b000, 3'b001: alu_ctrl = `ALU_CMD_SUB;
                    // blt (funct3 == 0x4), bge (funct3 == 0x5)
                    3'b100, 3'b101: alu_ctrl = `ALU_CMD_SLT;
                    // bltu (funct3 == 0x6), bgeu (funct3 == 0x7)
                    3'b110, 3'b111: alu_ctrl = `ALU_CMD_SLTU;
                endcase
            end
            `ALU_OP_EVAL: begin
                case (funct3)
                    // add (funct3 == 0x0) or sub (funct3 == 0x0 and funct7_5 == 1
                    // but only when op == 0x33 -> op[5] == 1 in R-type)
                    3'b000: alu_ctrl = (funct7_5 & op_5) ? `ALU_CMD_SUB : `ALU_CMD_ADD;
                    // xor (funct3 == 0x4)
                    3'b100: alu_ctrl = `ALU_CMD_XOR;
                    // or (funct3 == 0x6)
                    3'b110: alu_ctrl = `ALU_CMD_OR;
                    // and (funct3 == 0x7)
                    3'b111: alu_ctrl = `ALU_CMD_AND;
                    // sll (funct3 == 0x1)
                    3'b001: alu_ctrl = `ALU_CMD_SLL;
                    // srl or sra (funct3 == 0x5)
                    // note that we take advantage here of the special
                    // encoding for shifts (that have bit 30 set, where
                    // funct7_5 would normally be, even in I-type)
                    3'b101: alu_ctrl = (funct7_5 == 0) ? `ALU_CMD_SRL : `ALU_CMD_SRA;
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
    input wire alu_branch_flag,
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
    wire funct7_5;
    wire op_5;

    reg [1:0] alu_op;
    reg pc_update;      // should update pc = pc + 4
    reg branch;         // is a branch instr
    reg jump;           // is a jump instr
    reg take_branch;    // whether to take the branch (based on ALU output)

    // funct3[0] tells us whether take_branch = alu_zero or !alu_zero
    // beq (0x0), blt (0x4), bltu (0x6):
    //     funct3[0] == 0 -> take_branch = alu_zero
    // bne (0x1), bge (0x5), bgeu (0x7):
    //     funct3[0] == 1 -> take_branch = !alu_zero
    always @(*) begin
        take_branch = funct3[0] ^ alu_branch_flag;
    end

    // update pc on three occasions:
    // - updating pc <= pc + 4 during the fetch stage
    // - jump during a jump stage
    // - jump if alu result is zero during a branch stage
    always @(*) begin
        pc_write = pc_update | jump | (branch & take_branch);
    end

    assign op = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7_5 = instr[30]; // RV32I only uses bit 5 from func7
    assign op_5 = op[5];         // we use this to differentiate between R/I type arithm. instrs

    // define the imm_src derived from the instruction type (combinational)
    always @(*) begin
        case (op)
            `OPCODE_LOAD, `OPCODE_I_TYPE: imm_src = `IMM_TYPE_I;
            `OPCODE_STORE: imm_src = `IMM_TYPE_S;
            `OPCODE_BRANCH: imm_src = `IMM_TYPE_B;
            `OPCODE_JAL: imm_src = `IMM_TYPE_J;
        endcase
    end

    alu_decoder alu_decoder (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .op_5(op_5),
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
                    `OPCODE_BRANCH: next_state = `CTRL_FSM_BEQ;
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
                pc_update = 1;
                jump = 0;
                branch = 0;

                addr_src = `ADDR_SRC_PC;

                // increment pc += 4 during the fetch stage
                alu_op = `ALU_OP_ADD;
                alu_src_a = `ALU_SRC_A_PC;
                alu_src_b = `ALU_SRC_B_4;
                result_src = `RES_SRC_ALU_RESULT;
            end

            `CTRL_FSM_DECODE: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 0;
                pc_update = 0;
                jump = 0;
                branch = 0;

                // calculate old_pc += imm since the ALU is idle during decode
                alu_op = `ALU_OP_ADD;
                alu_src_a = `ALU_SRC_A_OLD_PC;
                alu_src_b = `ALU_SRC_B_IMM;
            end

            `CTRL_FSM_MEMADR: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 0;
                pc_update = 0;
                jump = 0;
                branch = 0;

                // alu_ctrl = `ALU_CMD_ADD;
                alu_op = `ALU_OP_ADD;
                alu_src_a = `ALU_SRC_A_RS1;
                alu_src_b = `ALU_SRC_B_IMM;
            end

            `CTRL_FSM_MEMREAD: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 0;
                pc_update = 0;
                jump = 0;
                branch = 0;

                addr_src = `ADDR_SRC_RESULT;
                result_src = `RES_SRC_ALU_OUT;
            end

            `CTRL_FSM_MEMWB: begin
                instr_write = 0;
                reg_write = 1;
                mem_write = 0;
                pc_update = 0;
                jump = 0;
                branch = 0;

                result_src = `RES_SRC_MEM_DATA;
            end

            `CTRL_FSM_MEMWRITE: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 1;
                pc_update = 0;
                jump = 0;
                branch = 0;

                addr_src = `ADDR_SRC_RESULT;
                result_src = `RES_SRC_ALU_OUT;
            end

            `CTRL_FSM_EXEC_I: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 0;
                pc_update = 0;
                jump = 0;
                branch = 0;

                alu_op = `ALU_OP_EVAL;
                alu_src_a = `ALU_SRC_A_RS1;
                alu_src_b = `ALU_SRC_B_IMM;
            end

            `CTRL_FSM_EXEC_R: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 0;
                pc_update = 0;
                jump = 0;
                branch = 0;

                alu_op = `ALU_OP_EVAL;
                alu_src_a = `ALU_SRC_A_RS1;
                alu_src_b = `ALU_SRC_B_RS2;
            end

            `CTRL_FSM_ALUWB: begin
                instr_write = 0;
                reg_write = 1;
                mem_write = 0;
                pc_update = 0;
                jump = 0;
                branch = 0;

                result_src = `RES_SRC_ALU_OUT;
            end

            `CTRL_FSM_BEQ: begin
                instr_write = 0;
                reg_write = 0;
                mem_write = 0;
                pc_update = 0;
                jump = 0;
                branch = 1;

                // compare the source registers
                alu_op = `ALU_OP_BRANCH;
                alu_src_a = `ALU_SRC_A_RS1;
                alu_src_b = `ALU_SRC_B_RS2;
                result_src = `RES_SRC_ALU_OUT;
            end

            `CTRL_FSM_JAL: begin
                instr_write = 0;
                reg_write = 1;
                mem_write = 0;
                pc_update = 1;
                jump = 1;
                branch = 0;

                alu_op = `ALU_OP_ADD;
                alu_src_a = `ALU_SRC_A_OLD_PC;
                alu_src_b = `ALU_SRC_B_4;
                result_src = `RES_SRC_ALU_OUT;
            end
        endcase
    end
endmodule
