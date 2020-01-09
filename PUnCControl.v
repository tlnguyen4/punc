//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCControl(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Add more ports here
	input     [15:0] opcode,
	input     [2:0]  condCode,

	output reg       load_ir,
	output reg		 inc_pc,
	output reg [2:0] set_pc,
	output reg [2:0] alu_select,
	
	output reg       mem_w_en,
	output reg [2:0] set_mem_r_addr,
	output reg [1:0] set_mem_w_addr,
	output reg       set_mem_w_data,     

	output reg       rf_w_en,
	output reg [1:0] set_rf_r_addr0,
	output reg [1:0] set_rf_r_addr1,
	output reg [1:0] set_rf_w_addr,
	output reg [1:0] set_rf_w_data
);

	// FSM States
	// Add your FSM State values as localparams here
	localparam STATE_RESET = 3'd0;
	localparam STATE_FETCH = 3'd1;
	localparam STATE_DECODE = 3'd2;
	localparam STATE_EXECUTE1 = 3'd3;
	localparam STATE_EXECUTE2 = 3'd4;
	localparam STATE_HALT = 3'd5;

	// State, Next State
	reg [2:0] state;
	reg [2:0] next_state;

	// Next State Combinational Logic
	always @( * ) begin
		// Set default value for next state here
		next_state = state;

		// Add your next-state logic here
		case (state)
			STATE_FETCH: begin
				next_state = STATE_DECODE;
			end

			STATE_DECODE: begin
				next_state = STATE_EXECUTE1;
			end

			STATE_EXECUTE1: begin
				if (opcode[`OC] == `OC_HLT) begin
					next_state = STATE_HALT;
				end
				else if (opcode[`OC] == `OC_LDI) begin
					next_state = STATE_EXECUTE2;
				end
				else begin
					next_state = STATE_FETCH;
				end
			end

			STATE_EXECUTE2: begin
				next_state = STATE_FETCH;
			end

			STATE_HALT: begin
				// next_state = STATE_HALT;
			end
		endcase
	end

	// Output Combinational Logic
	always @( * ) begin
		// Set default values for outputs here (prevents implicit latching)
		load_ir = 1'd0;
		inc_pc = 1'd0;
		set_pc = 3'd0;
		alu_select = 3'd0;
		
		mem_w_en = 1'd0;
		set_mem_r_addr = 3'd0;
		set_mem_w_addr = 2'd0;
		set_mem_w_data = 1'd0;     

		rf_w_en = 1'd0;
		set_rf_r_addr0 = 2'd0;
		set_rf_r_addr1 = 2'd0;
		set_rf_w_addr = 2'd0;
		set_rf_w_data = 2'd0;

		// Add your output logic here
		case (state)
			STATE_FETCH: begin
				set_mem_r_addr = `MEM_R_ADDR_FETCH;
				load_ir = 1'd1;
			end

			STATE_DECODE: begin
				inc_pc = 1'd1;
			end

			STATE_EXECUTE1: begin
				if (opcode[`OC] == `OC_ADD) begin
					if (opcode[`IMM_BIT_NUM] == 1'd0) begin
						alu_select = `ALU_ADD1;
						rf_w_en = 1'd1;
						set_rf_r_addr0 = `RF_R_ADDR0_SEL_86;
						set_rf_r_addr1 = `RF_R_ADDR1_SEL_20;
						set_rf_w_addr = `RF_W_ADDR_SEL_119;
						set_rf_w_data = `RF_W_DATA_SEL_ALU;
					end
					else begin
						alu_select = `ALU_ADD2;
						rf_w_en = 1'd1;
						set_rf_r_addr0 = `RF_R_ADDR0_SEL_86;
						set_rf_w_addr = `RF_W_ADDR_SEL_119;
						set_rf_w_data = `RF_W_DATA_SEL_ALU;
					end
				end

				else if (opcode[`OC] == `OC_AND) begin
					if (opcode[`IMM_BIT_NUM] == 1'd0) begin
						alu_select = `ALU_AND1;
						rf_w_en = 1'd1;
						set_rf_r_addr0 = `RF_R_ADDR0_SEL_86;
						set_rf_r_addr1 = `RF_R_ADDR1_SEL_20;
						set_rf_w_addr = `RF_W_ADDR_SEL_119;
						set_rf_w_data = `RF_W_DATA_SEL_ALU;
					end
					else begin
						alu_select = `ALU_AND2;
						rf_w_en = 1'd1;
						set_rf_r_addr0 = `RF_R_ADDR0_SEL_86;
						set_rf_w_addr = `RF_W_ADDR_SEL_119;
						set_rf_w_data = `RF_W_DATA_SEL_ALU;
					end
				end

				else if (opcode[`OC] == `OC_BR) begin
					if ((opcode[`BR_N] == 1'd1 && condCode[2] == 1'd1) || 
						(opcode[`BR_Z] == 1'd1 && condCode[1] == 1'd1) ||
						(opcode[`BR_P] == 1'd1 && condCode[0] == 1'd1)) begin
							set_pc = `PC_OFFSET9;
					end
				end

				// TODO: Try without if else statement. The register address, regardless whether it's 7 or not, is stored in 8:6.
				else if (opcode[`OC] == `OC_JMP) begin
					if (opcode[8:6] != 3'd7) begin
						set_pc = `PC_RF_R_DATA;
						set_rf_r_addr0 = `RF_R_ADDR0_SEL_86;
					end
					else begin
						set_pc = `PC_RF_R_DATA;
						set_rf_r_addr0 = `RF_R_ADDR0_SEL_7;
					end
				end

				else if (opcode[`OC] == `OC_JSR) begin
					if (opcode[`JSR_BIT_NUM] == `IS_JSR) begin
						set_pc = `PC_OFFSET11;
						rf_w_en = 1'd1;
						set_rf_w_addr = `RF_W_ADDR_SEL_7;
						set_rf_w_data = `RF_W_DATA_SEL_PC;
					end
					else begin
						set_pc = `PC_RF_R_DATA;
						rf_w_en = 1'd1;
						set_rf_r_addr0 = `RF_R_ADDR0_SEL_86;
						set_rf_w_addr = `RF_W_ADDR_SEL_7;
						set_rf_w_data = `RF_W_DATA_SEL_PC;
					end
				end

				else if (opcode[`OC] == `OC_LD) begin
					set_mem_r_addr = `MEM_R_ADDR_SEL_PC;
					rf_w_en = 1'd1;
					set_rf_w_addr = `RF_W_ADDR_SEL_119;
					set_rf_w_data = `RF_W_DATA_SEL_MEM;
				end

				else if (opcode[`OC] == `OC_LDI) begin
					set_mem_r_addr = `MEM_R_ADDR_SEL_PC;
				end

				else if (opcode[`OC] == `OC_LDR) begin
					set_mem_r_addr = `MEM_R_ADDR_SEL_RF;
					rf_w_en = 1'd1;
					set_rf_r_addr0 = `RF_R_ADDR0_SEL_86;
					set_rf_w_addr = `RF_W_ADDR_SEL_119;
					set_rf_w_data = `RF_W_DATA_SEL_MEM;
				end

				else if (opcode[`OC] == `OC_LEA) begin
					alu_select = `ALU_PC;
					rf_w_en = 1'd1;
					set_rf_w_addr = `RF_W_ADDR_SEL_119;
					set_rf_w_data = `RF_W_DATA_SEL_ALU;
				end

				else if (opcode[`OC] == `OC_NOT) begin
					alu_select = `ALU_NOT;
					rf_w_en = 1'd1;
					set_rf_r_addr0 = `RF_R_ADDR0_SEL_86;
					set_rf_w_addr = `RF_W_ADDR_SEL_119;
					set_rf_w_data = `RF_W_DATA_SEL_ALU;
				end

				else if (opcode[`OC] == `OC_ST) begin
					mem_w_en = 1'd1;
					set_mem_w_addr = `MEM_W_ADDR_SEL_PC;
					set_mem_w_data = 1'd1;
					set_rf_r_addr0 = `RF_R_ADDR0_SEL_119;
				end

				else if (opcode[`OC] == `OC_STI) begin
					mem_w_en = 1'd1;
					set_mem_r_addr = `MEM_R_ADDR_SEL_PC;
					set_mem_w_addr = `MEM_W_ADDR_SEL_MEM;
					set_mem_w_data = 1'd1;
					set_rf_r_addr0 = `RF_R_ADDR0_SEL_119;
				end

				else if (opcode[`OC] == `OC_STR) begin
					mem_w_en = 1'd1;
					set_mem_w_addr = `MEM_W_ADDR_SEL_RF;
					set_mem_w_data = 1'd1;
					set_rf_r_addr0 = `RF_R_ADDR0_SEL_119;
					set_rf_r_addr1 = `RF_R_ADDR1_SEL_86;
				end

				else if (opcode[`OC] == `OC_HLT) begin
					
				end
			end

			STATE_EXECUTE2: begin
				set_mem_r_addr = `MEM_R_ADDR_SEL_MEM;
				rf_w_en = 1'd1;
				set_rf_w_addr = `RF_W_ADDR_SEL_119;
				set_rf_w_data = `RF_W_DATA_SEL_MEM;
			end
		endcase
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			// Add your initial state here
			state <= STATE_FETCH;
		end
		else begin
			// Add your next state here
			state <= next_state;
		end
	end

endmodule