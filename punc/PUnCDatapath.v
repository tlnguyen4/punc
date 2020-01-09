//==============================================================================
// Datapath for PUnC LC3 Processor
//==============================================================================

`include "Memory.v"
`include "RegisterFile.v"
`include "Defines.v"

module PUnCDatapath(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// DEBUG Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data,

	// Add more ports here
	input   		   load_ir,
	input			   inc_pc,
	input       [2:0]  set_pc,
	input       [2:0]  alu_select,
	
	input  		       mem_w_en,
	input       [2:0]  set_mem_r_addr,
	input       [1:0]  set_mem_w_addr,
	input              set_mem_w_data,     

	input   	       rf_w_en,
	input       [1:0]  set_rf_r_addr0,
	input       [1:0]  set_rf_r_addr1,
	input       [1:0]  set_rf_w_addr,
	input       [1:0]  set_rf_w_data,

	output reg  [15:0] opcode,
	output reg  [2:0]  condCode
);

	// Local Registers
	reg  [15:0] pc = 16'd0;
	reg  [15:0] ir = 16'd0;

	reg  [15:0] debugger = 16'd0;
	reg  [15:0] debugger2 = 16'd0;

	// Declare other local wires and registers here
	wire [15:0] mem_r_data;
	reg  [15:0] mem_r_addr;
	reg  [15:0] mem_w_addr;
	reg  [15:0] mem_w_data;

	reg  [2:0] rf_r_addr0;
	reg  [2:0] rf_r_addr1;
	wire [15:0] rf_r_data0;
	wire [15:0] rf_r_data1;
	reg  [2:0] rf_w_addr;
	reg  [15:0] rf_w_data;

	reg  [15:0] ldi_temp;

	// Assign PC debug net
	assign pc_debug_data = pc;


	//----------------------------------------------------------------------
	// Add all other datapath logic here
	//----------------------------------------------------------------------

	always @( * ) begin
		// This handles the r_addr_0 port of RF.
		// Instructions: ADD, AND, JMP, JSRR, LDR, NOT (bits 8:6), RET (register 7), ST, STI, STR (bits 11:9)
		// TODO: Try this without the register 7 case. It's stored in 8:6 anyway.
		if (set_rf_r_addr0 == `RF_R_ADDR0_SEL_86) begin
			rf_r_addr0 = ir[8:6];
		end
		else if (set_rf_r_addr0 == `RF_R_ADDR0_SEL_119) begin
			rf_r_addr0 = ir[11:9];
		end
		else if (set_rf_r_addr0 == `RF_R_ADDR0_SEL_7) begin
			rf_r_addr0 = 3'b111;
		end

		// This handles the r_addr_1 port of RF.
		// Instructions: ADD, AND (bits 2:0), STR (bits 8:6)
		if (set_rf_r_addr1 == `RF_R_ADDR1_SEL_20) begin
			rf_r_addr1 = ir[2:0];
		end
		else if (set_rf_r_addr1 == `RF_R_ADDR1_SEL_86) begin
			rf_r_addr1 = ir[8:6];
		end

		// This handles the w_addr port of RF.
		// Instructions: ADD, AND, LD, LDI, LDR, LEA, NOT (bits 11:9), JSR, JSRR (register 7)
		if (set_rf_w_addr == `RF_W_ADDR_SEL_119) begin
			rf_w_addr = ir[11:9];
		end
		else if (set_rf_w_addr == `RF_W_ADDR_SEL_7) begin
			rf_w_addr = 3'b111;
		end
	end

	always @( * ) begin
		// This handles the r_addr_0 port of mem.
		// Instructions: LD, LDI (PCoffset9), STI (PCoffset9, mem data), LDR (offset6)
		// Sign extend offset before adding.
		if (set_mem_r_addr == `MEM_R_ADDR_SEL_PC) begin
			mem_r_addr = pc + {{7{ir[8]}}, ir[8:0]};
			ldi_temp = mem_r_data;
		end
		else if (set_mem_r_addr == `MEM_R_ADDR_SEL_MEM) begin
			mem_r_addr = ldi_temp;
		end
		else if (set_mem_r_addr == `MEM_R_ADDR_SEL_RF) begin
			mem_r_addr = rf_r_data0 + {{10{ir[5]}}, ir[5:0]};
		end
		else if (set_mem_r_addr == `MEM_R_ADDR_FETCH) begin
			mem_r_addr = pc;
		end

		// This handles the w_addr port of mem.
		// Instructions: ST (PCoffset 9), STI (mem result), STR (offset6)
		if (set_mem_w_addr == `MEM_W_ADDR_SEL_PC) begin
			mem_w_addr = pc + {{7{ir[8]}}, ir[8:0]};
		end
		else if (set_mem_w_addr == `MEM_W_ADDR_SEL_MEM) begin
			mem_w_addr = mem_r_data;
		end
		else if (set_mem_w_addr == `MEM_W_ADDR_SEL_RF) begin
			mem_w_addr = rf_r_data1 + {{10{ir[5]}}, ir[5:0]};
		end

		// This handles the w_data port of RF.
		// Instructions: ADD, AND, LEA, NOT (ALU computation), JSR, JSRR (PC), LD, LDI, LDR (mem output)
		if (set_rf_w_data == `RF_W_DATA_SEL_ALU) begin
			if (alu_select == `ALU_ADD1) begin
				rf_w_data = rf_r_data0 + rf_r_data1;
			end
			else if (alu_select == `ALU_ADD2) begin
				rf_w_data = rf_r_data0 + {{11{ir[4]}}, ir[4:0]};
			end
			else if (alu_select == `ALU_AND1) begin
				rf_w_data = rf_r_data0 & rf_r_data1;
			end
			else if (alu_select == `ALU_AND2) begin
				rf_w_data = rf_r_data0 & {{11{ir[4]}}, ir[4:0]};
			end
			else if (alu_select == `ALU_PC) begin 
				rf_w_data = pc + {{7{ir[8]}}, ir[8:0]};
			end
			else if (alu_select == `ALU_NOT) begin
				rf_w_data = ~(rf_r_data0);
			end
		end
		else if (set_rf_w_data == `RF_W_DATA_SEL_PC) begin
			rf_w_data = pc;
		end
		else if (set_rf_w_data == `RF_W_DATA_SEL_MEM) begin
			rf_w_data = mem_r_data;
		end

		// This handles the PC.
		// Instructions: BR (PCoffset11), JSR (PCoffset9), and JMP/RET (register output)
		if (set_pc == `PC_OFFSET9) begin 
			pc = pc + {{7{ir[8]}}, ir[8:0]};
		end
		else if (set_pc == `PC_OFFSET11) begin
			pc = pc + {{5{ir[10]}}, ir[10:0]};
		end
		else if (set_pc == `PC_RF_R_DATA) begin
			pc = rf_r_data0;
		end
	end
	
	always @(posedge clk) begin
		// Sequential Internal Logic Here

		// If resetting, reset PC, IR, condition codes
		if (rst) begin
			pc <= 16'd0;
			ir <= 16'd0;
			condCode <= `COND_RESET;
		end

		// Fetch stage
		if (load_ir) begin
			ir <= mem_r_data;
		end

		// Decode stage
		if (inc_pc) begin
			pc <= pc + 16'd1;
		end
	end


	//----------------------------------------------------------------------
	// Memory Module
	//----------------------------------------------------------------------

	// 1024-entry 16-bit memory (connect other ports)
	Memory mem(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (mem_r_addr),
		.r_addr_1 (mem_debug_addr),
		.w_addr   (mem_w_addr),
		.w_data   (rf_r_data0),
		.w_en     (mem_w_en),
		.r_data_0 (mem_r_data),
		.r_data_1 (mem_debug_data)
	);

	//----------------------------------------------------------------------
	// Register File Module
	//----------------------------------------------------------------------

	// 8-entry 16-bit register file (connect other ports)
	RegisterFile rfile(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (rf_r_addr0),
		.r_addr_1 (rf_r_addr1),
		.r_addr_2 (rf_debug_addr),
		.w_addr   (rf_w_addr),
		.w_data   (rf_w_data),
		.w_en     (rf_w_en),
		.r_data_0 (rf_r_data0),
		.r_data_1 (rf_r_data1),
		.r_data_2 (rf_debug_data)
	);

	always @( * ) begin
		// Output Logic Here
		opcode = ir;
		
		// Explanation: The rf_w_data port can be affected by JSR and JSRR, as well as
		// the instructions that we need for condition codes (ADD, AND, NOT, LD, etc.) If we had a scenario where
		// we loaded zero/negative number into RF, and then had a JSR/JSRR instruction, followed by the BR instruction,
		// we want the condition codes to reflect the loading of the zero/negative number, NOT the JSR/JSRR instruction,
		// which would have a positive number loaded into the RF. JSR/JSRR are not part of the condition code setting instruction set.
		if (ir[15:12] != 4'b0100) begin
			if (rf_w_data[15]) begin
				condCode = `COND_NEG;
			end
			else if (rf_w_data == 16'd0) begin
				condCode = `COND_ZERO;
			end
			else begin
				condCode = `COND_POS;
			end
		end
	end
	

endmodule