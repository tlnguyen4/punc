//==============================================================================
// Module for PUnC LC3 Processor
//==============================================================================

`include "PUnCDatapath.v"
`include "PUnCControl.v"

module PUnC(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Debug Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data
);

	//----------------------------------------------------------------------
	// Interconnect Wires
	//----------------------------------------------------------------------

	// Declare your wires for connecting the datapath to the controller here
	wire        load_ir;
	wire		inc_pc;
	wire [2:0]  set_pc;
	wire [2:0]  alu_select;

	wire        mem_w_en;
	wire [2:0]  set_mem_r_addr;
	wire [1:0]  set_mem_w_addr;
	wire        set_mem_w_data;

	wire        rf_w_en;
	wire [1:0]  set_rf_r_addr0;
	wire [1:0]  set_rf_r_addr1;
	wire [1:0]  set_rf_w_addr;
	wire [1:0]  set_rf_w_data;
	wire [15:0] opcode;
	wire [2:0]  condCode;

	//----------------------------------------------------------------------
	// Control Module
	//----------------------------------------------------------------------
	PUnCControl ctrl(
		.clk             (clk),
		.rst             (rst),

		// Input ports
		.opcode(opcode),
		.condCode(condCode),

		// Output ports
		.load_ir(load_ir),
		.inc_pc(inc_pc),
		.set_pc(set_pc),
		.alu_select(alu_select),
		.mem_w_en(mem_w_en),
		.set_mem_r_addr(set_mem_r_addr),
		.set_mem_w_addr(set_mem_w_addr),
		.set_mem_w_data(set_mem_w_data),
		.rf_w_en(rf_w_en),
		.set_rf_r_addr0(set_rf_r_addr0),
		.set_rf_r_addr1(set_rf_r_addr1),
		.set_rf_w_addr(set_rf_w_addr),
		.set_rf_w_data(set_rf_w_data)
	);

	//----------------------------------------------------------------------
	// Datapath Module
	//----------------------------------------------------------------------
	PUnCDatapath dpath(
		.clk             (clk),
		.rst             (rst),

		.mem_debug_addr   (mem_debug_addr),
		.rf_debug_addr    (rf_debug_addr),
		.mem_debug_data   (mem_debug_data),
		.rf_debug_data    (rf_debug_data),
		.pc_debug_data    (pc_debug_data),

		// Input ports
		.load_ir(load_ir),
		.inc_pc(inc_pc),
		.set_pc(set_pc),
		.alu_select(alu_select),
		.mem_w_en(mem_w_en),
		.set_mem_r_addr(set_mem_r_addr),
		.set_mem_w_addr(set_mem_w_addr),
		.set_mem_w_data(set_mem_w_data),
		.rf_w_en(rf_w_en),
		.set_rf_r_addr0(set_rf_r_addr0),
		.set_rf_r_addr1(set_rf_r_addr1),
		.set_rf_w_addr(set_rf_w_addr),
		.set_rf_w_data(set_rf_w_data),

		// Output ports
		.opcode(opcode),
		.condCode(condCode)
	);

endmodule
