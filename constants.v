`ifndef _constants_h
`define _constants_h

`define ALU_CMD_ADD             4'b0000
`define ALU_CMD_SUB             4'b0001
`define ALU_CMD_XOR             4'b0011
`define ALU_CMD_OR              4'b0100
`define ALU_CMD_AND             4'b0101
`define ALU_CMD_SLL             4'b0110
`define ALU_CMD_SRL             4'b0111
`define ALU_CMD_SRA             4'b1000
`define ALU_CMD_SLT             4'b1001
`define ALU_CMD_SLTU            4'b1010

`define ALU_SRC_A_PC            2'b00
`define ALU_SRC_A_OLD_PC        2'b01
`define ALU_SRC_A_RS1           2'b10
`define ALU_SRC_A_ZERO          2'b11

`define ALU_SRC_B_RS2           2'b00
`define ALU_SRC_B_IMM           2'b01
`define ALU_SRC_B_4             2'b10

`define ALU_OP_ADD              2'b00
`define ALU_OP_BRANCH           2'b01
`define ALU_OP_EVAL             2'b10

`define ADDR_SRC_PC             1'b0
`define ADDR_SRC_RESULT         1'b1

`define SIZE_BYTE               2'b00
`define SIZE_HALF               2'b01
`define SIZE_WORD               2'b10

`define CTRL_FSM_FETCH          4'b0000
`define CTRL_FSM_DECODE         4'b0001
`define CTRL_FSM_MEMADR         4'b0010
`define CTRL_FSM_MEMREAD        4'b0011
`define CTRL_FSM_MEMWB          4'b0100
`define CTRL_FSM_MEMWRITE       4'b0101
`define CTRL_FSM_EXEC_R         4'b0110
`define CTRL_FSM_EXEC_I         4'b0111
`define CTRL_FSM_ALUWB          4'b1000
`define CTRL_FSM_JAL            4'b1001
`define CTRL_FSM_BEQ            4'b1010
`define CTRL_FSM_EXEC_JALR      4'b1011
`define CTRL_FSM_JALRWB         4'b1100
`define CTRL_FSM_LUIWB          4'b1101
`define CTRL_FSM_EXEC_AUIPC     4'b1110
`define CTRL_FSM_RESET          4'b1111

`define IMM_TYPE_I              3'b000
`define IMM_TYPE_S              3'b001
`define IMM_TYPE_B              3'b010
`define IMM_TYPE_J              3'b011
`define IMM_TYPE_U              3'b100

`define OPCODE_LOAD             7'b0000011
`define OPCODE_STORE            7'b0100011
`define OPCODE_I_TYPE           7'b0010011
`define OPCODE_R_TYPE           7'b0110011
`define OPCODE_JAL              7'b1101111
`define OPCODE_JALR             7'b1100111
`define OPCODE_BRANCH           7'b1100011
`define OPCODE_LUI              7'b0110111
`define OPCODE_AUIPC            7'b0010111

`define RES_SRC_ALU_OUT         2'b00
`define RES_SRC_MEM_DATA        2'b01
`define RES_SRC_ALU_RESULT      2'b10
`define RES_SRC_IMM             2'b11

`endif
