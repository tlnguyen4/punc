//==============================================================================
// Global Defines for PUnC LC3 Computer
//==============================================================================

// Add defines here that you'll use in both the datapath and the controller

//------------------------------------------------------------------------------
// Opcodes
//------------------------------------------------------------------------------
`define OC 15:12       // Used to select opcode bits from the IR

`define OC_ADD 4'b0001 // Instruction-specific opcodes
`define OC_AND 4'b0101
`define OC_BR  4'b0000
`define OC_JMP 4'b1100
`define OC_JSR 4'b0100
`define OC_LD  4'b0010
`define OC_LDI 4'b1010
`define OC_LDR 4'b0110
`define OC_LEA 4'b1110
`define OC_NOT 4'b1001
`define OC_ST  4'b0011
`define OC_STI 4'b1011
`define OC_STR 4'b0111
`define OC_HLT 4'b1111

`define IMM_BIT_NUM 5  // Bit for distinguishing ADDR/ADDI and ANDR/ANDI
`define IS_IMM 1'b1
`define JSR_BIT_NUM 11 // Bit for distinguishing JSR/JSRR
`define IS_JSR 1'b1

`define BR_N 11        // Location of special bits in BR instruction
`define BR_Z 10
`define BR_P 9

`define MEM_R_ADDR_FETCH 3'b001
`define MEM_R_ADDR_SEL_PC 3'b010
`define MEM_R_ADDR_SEL_MEM 3'b011
`define MEM_R_ADDR_SEL_RF 3'b100

`define MEM_W_ADDR_SEL_PC 2'b01
`define MEM_W_ADDR_SEL_MEM 2'b10
`define MEM_W_ADDR_SEL_RF 2'b11

`define RF_R_ADDR0_SEL_86 2'b01 
`define RF_R_ADDR0_SEL_119 2'b10 
`define RF_R_ADDR0_SEL_7 2'b11 

`define RF_R_ADDR1_SEL_20 2'b01 
`define RF_R_ADDR1_SEL_86 2'b10

`define RF_W_ADDR_SEL_119 2'b01 
`define RF_W_ADDR_SEL_7 2'b10

`define RF_W_DATA_SEL_ALU 2'b01
`define RF_W_DATA_SEL_PC 2'b10
`define RF_W_DATA_SEL_MEM 2'b11

`define ALU_ADD1 3'd1
`define ALU_ADD2 3'd2
`define ALU_AND1 3'd3 
`define ALU_AND2 3'd4
`define ALU_NOT 3'd5 
`define ALU_PC 3'd6

`define PC_INCREMENT 3'd1
`define PC_OFFSET9 3'd2
`define PC_RF_R_DATA 3'd3
`define PC_OFFSET11 3'd4

`define COND_NEG 3'b100
`define COND_ZERO 3'b010
`define COND_POS 3'b001
`define COND_RESET 3'b000