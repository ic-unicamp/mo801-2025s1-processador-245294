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
`define ALU_SRC_A_UNK           2'b01
`define ALU_SRC_A_RS1           2'b10

`define ALU_SRC_B_RS2           2'b00
`define ALU_SRC_B_IMM           2'b01
`define ALU_SRC_B_4             2'b10

`define ALU_OP_ADD              2'b00
`define ALU_OP_BRANCH           2'b01
`define ALU_OP_EVAL             2'b10

`define ADDR_SRC_PC             1'b0
`define ADDR_SRC_RESULT         1'b1

`define CTRL_FSM_FETCH          4'b0000
`define CTRL_FSM_DECODE         4'b0001
`define CTRL_FSM_MEMADR         4'b0010
`define CTRL_FSM_MEMREAD        4'b0011
`define CTRL_FSM_MEMWB          4'b0100
`define CTRL_FSM_MEMWRITE       4'b0101
`define CTRL_FSM_EXEC_R         4'b0110
`define CTRL_FSM_ALUWB          4'b0111
`define CTRL_FSM_EXEC_I         4'b1000
`define CTRL_FSM_JAL            4'b1001
`define CTRL_FSM_BEQ            4'b1010
`define CTRL_FSM_RESET          4'b1111

`define IMM_TYPE_I              2'b00
`define IMM_TYPE_S              2'b01
`define IMM_TYPE_B              2'b10
`define IMM_TYPE_J              2'b11

`define OPCODE_LOAD             7'b0000011
`define OPCODE_STORE            7'b0100011
`define OPCODE_I_TYPE           7'b0010011
`define OPCODE_R_TYPE           7'b0110011
`define OPCODE_JAL              7'b1101111
`define OPCODE_BEQ              7'b1100011

`define RES_SRC_ALU_OUT         2'b00
`define RES_SRC_MEM_DATA        2'b01
`define RES_SRC_ALU_RESULT      2'b10

`endif
