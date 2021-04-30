`include "opcodes.v"
`include "register.v" 
`include "alu.v"
`include "control_unit.v" 
`include "branch_predictor.v"
`include "hazard.v"
`include "latch.v"

module datapath(clk, reset_n, read_m1, address1, data1, read_m2, write_m2, address2, data2, num_inst, output_port, is_halted);

	input clk;
	input reset_n;

	output read_m1;
	output [`WORD_SIZE-1:0] address1;
	output read_m2;
	output write_m2;
	output [`WORD_SIZE-1:0] address2;

	input [`WORD_SIZE-1:0] data1;
	inout [`WORD_SIZE-1:0] data2;

	output reg [`WORD_SIZE-1:0] num_inst;
	output reg [`WORD_SIZE-1:0] output_port;
	output is_halted;

	// IFID input output
	wire inst_out_IFID;
	wire pc_out_IFID;

	// control unit input output
	wire i_or_d;
	wire mem_read;
	wire ir_write; 
	wire halt; 
	wire wwd; 
	wire new_inst;

	// IDEX input output
	wire [1:0] write_reg;
	wire inst_out_IDEX;
	wire pc_out_IDEX;
	wire A_out_IDEX;
	wire B_out_IDEX;
	wire extended_immediate_value_out;
	wire dest_out_IDEX:

	// control unit EX input output
	wire alu_src_B; 
	wire alu_op;

	// EXMEM input output
	wire inst_out_EXMEM;
	wire pc_out_EXMEM;
	wire B_out_EXMEM;
	wire aluout_out_EXMEM;
	wire bcond_out_EXMEM;
	wire dest_out_EXMEM:

	// control unit MEM input output
	wire mem_write;
	wire pc_write_cond; 
	wire pc_src; 
	wire pc_write;

	// MEMWB input output
	wire aluout_out_MEMWB;
	wire pc_out_MEMWB;
	wire mdr_out_MEMWB;
	wire inst_out_MEMWB;
	wire dest_out_MEMWB:

	// control unit WB input output
	wire mem_to_reg; 
	wire reg_write;
	wire pc_to_reg;
	wire is_lhi;

	// register_file input

	wire [`WORD_SIZE-1:0] write_data;
	wire [1:0] read1;
	wire [1:0] read2;
	wire [`WORD_SIZE-1:0] read_out1;
	wire [`WORD_SIZE-1:0] read_out2;
	
	wire [`WORD_SIZE-1:0] extended_immediate_value;
	wire [7:0] immediate_value;

	// alu input outpu
	wire [`WORD_SIZE-1:0] alu_output;
	wire bcond;
	wire overflow_flag;

	// alu_control_unit output
	wire [3:0] funcCode;
	wire [1:0] branchType;

	//alu input
	wire [`WORD_SIZE-1:0] alu_input_2;	

	wire 
	assign immediate_value = inst_out_IFID[7:0];
	assign read1 = inst_out_IFID[11:10];
	assign read2 = inst_out_IFID[9:8];

	assign data2 = write_m2 ? B_out_EXMEM : 16'bz;

	// TODO: register file dest(write_reg) mux
	// TODO: register file wirte_data mux
	// TODO: alu, alu control unit

	IFID IFID_module(
		.inst_in(data1),  // 확인 필요
		.inst_out(inst_out_IFID), 
		.pc_in(address1), // 확인 필요
		.pc_out(pc_out_IFID), 
		.reset_n(reset_n), 
		.clk(clk));

	control_unit control_unit_module(
		.inst(inst_out_IFID), 
		.clk(clk), 
		.reset_n(reset_n), 
		.mem_read(mem_read), // instruction memory는 항상 읽으니 여기서 mem_read필요 없을듯
		.i_or_d(i_or_d), // i_or_d 필요 없는듯?
		.ir_write(ir_write), // ir_write도 필요 없을듯. hazard에서 is_stall을 이용해서 IF/ID register에 쓸지 결정
		// ir_write를 쓰려면 control_unit이 IFID latch의 inst_out이 아니라 미리 inst를 입력 받아야함
		// ppt에는 control unit이 IF/ID latch의 output을 입력받는 걸로 되어있음
		.halt(halt), 
		.wwd(wwd), 
		.new_inst(new_inst));


	IDEX IDEX_module(
		.A_in(read_out1), 
		.B_in(read_out2), 
		.pc_in(pc_out_IFID), 
		.imm_in(extended_immediate_value), 
		.inst_in(inst_out_IFID), 
		.dest_in(write_reg), // write reg mux로 구해야함
		.A_out(A_out_IDEX), 
		.B_out(B_out_IDEX), 
		.pc_out(pc_out_IDEX), 
		.imm_out(extended_immediate_value_out), 
		.inst_out(inst_out_IDEX),
		.dest_out(dest_out_IDEX), 
		.reset_n(reset_n), 
		.clk(clk));

	control_unit_EX control_unit_EX_module(
		.inst(inst_out_IDEX), 
		.alu_src_B(alu_src_B), 
		.alu_op(alu_op));

	EXMEM EXMEM_module(
		.pc_in(pc_out_IDEX), 
		.aluout_in(alu_output), // alu result, bcond
		.bcond_in(bcond), // bcond
		.B_in(B_out_IDEX), 
		.inst_in(inst_out_IDEX),
		.dest_int(dest_out_IDEX), 
		.pc_out(pc_out_EXMEM),
		.bcond_out(bcond_out_EXMEM), 
		.aluout_out(aluout_out_EXMEM), 
		.B_out(B_out_EXMEM), 
		.inst_out(inst_out_EXMEM),
		.dest_out(dest_out_EXMEM), 
		.reset_n(reset_n), 
		.clk(clk));
	
	control_unit_M control_unit_M_module(
		.inst(inst_out_EXMEM), 
		.i_or_d(i_or_d), 
		.mem_read(mem_read), 
		.mem_write(mem_write), 
		.pc_write_cond(pc_write_cond), 
		.pc_src(pc_src), 
		.pc_write(pc_write));

	MEMWB MEMWB_module(
		.pc_in(pc_out_EXMEM),
		.mdr_in(data2), // 확인 필요 
		.aluout_in(aluout_out_EXMEM), 
		.inst_in(inst_out_EXMEM),
		.dest_in(dest_out_EXMEM), 
		.pc_out(pc_out_MEMWB)
		.mdr_out(mdr_out_MEMWB), 
		.aluout_out(aluout_out_MEMWB),
		.inst_out(inst_out_MEMWB),
		.dest_out(dest_out_MEMWB), 
		.reset_n(reset_n), 
		.clk(clk));

	control_unit_WB control_unit_WB_module(
		.inst(inst_out_MEMWB), 
		.mem_to_reg(mem_to_reg),
		.reg_write(reg_write), 
		.pc_to_reg(pc_to_reg),
		.is_lhi(is_lhi));


	// to define dest, we need pc_to_reg from control unit.
	// which is not yet defined IDEX 
	register_file register_file_module(
		.read_out1(read_out1),
		.read_out2(read_out2),
		.read1(read1),
		.read2(read2),
		//.dest(dest_out_MEMWB),
		.dest(write_reg),
		.write_data(write_data),
		.reg_write(reg_write),mdr_out_MEMWB
		.clk(clk));

	immediate_generator immediate_generator_module(
		.immediate_value(immediate_value),
		.extended_immediate_value(extended_immediate_value)
	);
	
	alu_control_unit alu_control_unit_module(
		.funct(inst_out_IDEX[5:0]), 
		.opcode(inst_out_IDEX[15:12]), 
		.ALUOp(alu_op), 
		.funcCode(funcCode), 
		.branchType(branchType));

		
	mux2_1 mux_alu_input1(
		.sel(alu_src_B),
		.i1(B_out_IDEX),
		.i2(extended_immediate_value_out),
		.o(alu_input_2));

	alu alu_module(
		.A(A_out_IDEX), 
		.B(alu_input_2), 
		.func_code(funcCode), 
		.branch_type(branchType), 
		.alu_out(alu_output), 
		.overflow_flag(overflow_flag), 
		.bcond(bcond));

	// for loading, mem_to_reg
	// srcB 1: using imm
 	// pc_to_reg : jal jrl -> write_reg=2
	mux4_1 mux_write_reg(.sel( {(alu_src_B  || mem_to_reg),(pc_to_reg)} ),
					.i1(inst_out_IFID[7:6]), 
					.i2(2'b10), 
					.i3(inst_out_IFID[9:8]), 
					.i4(2'b10), 
					.o(write_reg));

	// 0 : R type alu 
	// 01 : memory load
	// 10 : pc 
	// 11 : is_lhi
	mux4_1 mux_write_data(.sel({pc_to_reg || is_lhi ,mem_to_reg || is_lhi}),
					.i1(alu_output_MEMWB),
					.i2(mdr_out_MEMWB),
					.i3(pc_out_MEMWB),
					.i4(extended_imm_value<<8),
					.o(write_data));
endmodule

