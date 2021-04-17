`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

module cpu(clk, reset_n, read_m, write_m, address, data, num_inst, output_port, is_halted);
	input clk;
	input reset_n;
	
	output read_m;
	output write_m;
	output [`WORD_SIZE-1:0] address;

	inout [`WORD_SIZE-1:0] data;

	output [`WORD_SIZE-1:0] num_inst;		// number of instruction executed (for testing purpose)
	output [`WORD_SIZE-1:0] output_port;	// this will be used for a "WWD" instruction
	output is_halted;

	// TODO : implement multi-cycle CPU

	// register_file input
	reg [`WORD_SIZE-1:0] write_data;
	wire [1:0] write_reg;
	wire [1:0] read1;
	wire [1:0] read2;
	wire [`WORD_SIZE-1:0] read_out1;
	wire [`WORD_SIZE-1:0] read_out2;
	wire [15:0] extended_imm_value;

	// alu input
	wire [`WORD_SIZE-1:0] alu_input_1;
	wire [`WORD_SIZE-1:0] alu_input_2;

	// alu output
	reg bcond;
	wire overflow_flag;
	wire [`WORD_SIZE-1:0] alu_output;

	// alu_control_unit input
	wire [5:0] funct;
	wire [4:0] opcode;

	// alu_control_unit output
	wire [3:0] funcCode;
	wire [1:0] branchType;

	reg [`WORD_SIZE-1:0] inst;
	
	// alu_control_unit
	assign funct = inst[5:0];
	assign opcode = inst[15:12];

	// control_unit output
	wire pc_write_cond;
	wire pc_write;
	wire i_or_d;
	wire mem_read;
	wire mem_to_reg;
	wire mem_write; 
	wire ir_write; 
	wire pc_to_reg; 
	wire pc_src; 
	wire halt; 
	wire wwd; 
	wire new_inst; 
	wire reg_write; 
	wire alu_src_A; 
	wire alu_src_B; 
	wire alu_op;


	
	register_file register_file_module(
		.read_out1(read_out1),
		.read_out2(read_out2),
		.read1(read1),
		.read2(read2),
		.write_reg(write_reg),
		.write_data(write_data),
		.reg_write(reg_write),
		.clk(clk));

	alu_control_unit alu_control_unit_module(.funct(funct),
	 										.opcode(opcode),
											.ALUOp(alu_op),
											.clk(clk),
											.funcCode(funcCode),
											.branchType(branchType));

	alu alu_module(.A(alu_input_1),
					.B(alu_input_2),
					.func_code(funcCode),
					.branch_type(branchType),
					.C(alu_output),
					.overflow_flag(overflow_flag),
					.bcond(bcond));

	control_unit control_unit_module(.pc_write_cond(pc_write_cond),
									.pc_write(pc_write),
									.i_or_d(i_or_d),
									.mem_read(mem_read),
									.mem_to_reg(mem_to_reg),
									.mem_write(mem_write), 
									.ir_write(ir_write), 
									.pc_to_reg(pc_to_reg), 
									.pc_src(pc_src), 
									.halt(halt), 
									.wwd(wwd), 
									.new_inst(new_inst), 
									.reg_write(reg_write), 
									.alu_src_A(alu_src_A), 
									.alu_src_B(alu_src_B), 
									.alu_op(alu_op));

endmodule
