`include "constants.v"

module core ( // modulo de um core
  input clk, // clock
  input resetn, // reset que ativa em zero
  output reg [31:0] address, // endereço de saída
  output reg [31:0] data_out, // dado de saída
  input [31:0] data_in, // dado de entrada
  output reg we // write enable
);

    wire addr_src; // control signal
    reg [31:0] pc;
    always @(posedge clk) begin
        if (pc_write == 1'b1) pc <= result;
    end


    always @(*) begin
        case (addr_src)
            `ADDR_SRC_PC: address = pc;
            `ADDR_SRC_RESULT: address = result;
        endcase
    end

    reg [31:0] instr;
    wire instr_write; // control signal
    always @(posedge clk) begin
        if (instr_write == 1'b1) instr <= data_in;
    end

    reg [31:0] mem_data;
    always @(posedge clk) begin
        mem_data <= data_in;
    end

    wire [31:0] imm_ext;
    wire [1:0] imm_src; // control signal
    immext immext (
        .instr(instr),
        .imm_src(imm_src),
        .out(imm_ext)
    );

    wire reg_write; // control signal
    wire [4:0] reg_addr_1 = instr[19:15]; // rs1
    wire [4:0] reg_addr_2 = instr[24:20]; // rs2
    wire [4:0] reg_addr_3 = instr[11:7];  // rd
    wire [31:0] reg_write_data = result;
    wire [31:0] reg_read_data_1;
    wire [31:0] reg_read_data_2;
    regfile regfile (
        .clk(clk),
        .write_enable(reg_write),
        .addr_1(reg_addr_1),
        .addr_2(reg_addr_2),
        .addr_3(reg_addr_3),
        .write_data(reg_write_data),
        .read_data_1(reg_read_data_1),
        .read_data_2(reg_read_data_2)
    );

    always @(*) data_out = reg_read_data_2;

    wire [3:0] alu_ctrl; // control signal
    wire [31:0] alu_result;
    reg [31:0] alu_out;
    reg [31:0] src_a, src_b;
    alu alu (
        .src_a(src_a),
        .src_b(src_b),
        .ctrl(alu_ctrl),
        .out(alu_result)
    );
    always @(posedge clk) alu_out <= alu_result;
    always @(*) begin
        case (alu_src_a)
            `ALU_SRC_A_PC: src_a = pc;
            `ALU_SRC_A_RS1: src_a = reg_read_data_1;
            // FIXME: fill the missing option
        endcase

        case (alu_src_b)
            `ALU_SRC_B_IMM: src_b = imm_ext;
            `ALU_SRC_B_4: src_b = 32'h4;
            `ALU_SRC_B_RS2: src_b = reg_read_data_2;
            // FIXME: fill the missing option
        endcase
    end

    reg [31:0] result;
    wire [1:0] result_src; // control signal
    always @(*) begin
        case (result_src)
            `RES_SRC_ALU_OUT: result = alu_out;
            `RES_SRC_MEM_DATA: result = mem_data;
            `RES_SRC_ALU_RESULT: result = alu_result;
        endcase
    end

    wire pc_write;
    wire mem_write;
    wire [1:0] alu_src_a;
    wire [1:0] alu_src_b;
    control control (
        .clk(clk),
        .reset(resetn),
        .instr(instr),
        .pc_write(pc_write),
        .addr_src(addr_src),
        .mem_write(mem_write),
        .instr_write(instr_write),
        .reg_write(reg_write),
        .imm_src(imm_src),
        .result_src(result_src),
        .alu_ctrl(alu_ctrl),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b)
    );

    always @(*) we = mem_write;

    always @(posedge clk) begin
        if (resetn == 1'b0) begin
            pc <= 32'h00000000;
        end
    end

endmodule
