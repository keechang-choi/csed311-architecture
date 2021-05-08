`timescale 1ns/1ns
`include "opcodes.v"
`include "register_file.v" 
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


	// stall
	wire isStall;
	// IFID input output
	wire [`WORD_SIZE-1:0] inst_out_IFID;
	wire [`WORD_SIZE-1:0] pc_out_IFID;
	wire isStall_out_IFID;
	wire flush_out_IFID;


	// control unit input output
	wire i_or_d;
	wire mem_read;
	wire ir_write; 
	wire halt; 
	wire wwd; 
	wire new_inst;

	// IDEX input output
	wire [1:0] write_reg;
	wire [`WORD_SIZE-1:0] inst_out_IDEX;
	wire [`WORD_SIZE-1:0] pc_out_IDEX;
	wire [`WORD_SIZE-1:0] A_out_IDEX;
	wire [`WORD_SIZE-1:0] B_out_IDEX;
	wire [`WORD_SIZE-1:0] extended_immediate_value_out;
	wire [1:0] dest_out_IDEX;
	wire isStall_out_IDEX;
	
	wire mem_to_reg_IDEX; 
	wire reg_write_IDEX;
	wire pc_to_reg_IDEX;
	wire is_lhi_IDEX;	

	// control unit EX input output
	wire alu_src_B; 
	wire alu_op;

	// next_pc
	wire [`WORD_SIZE-1:0] pc_next_in_EXMEM;
	wire [`WORD_SIZE-1:0] pc_in;
	wire [`WORD_SIZE-1:0] pc_out;
	wire [`WORD_SIZE-1:0] pc_pred;

	// EXMEM input output
	wire [`WORD_SIZE-1:0] inst_out_EXMEM;
	wire [`WORD_SIZE-1:0] pc_out_EXMEM;
	wire [`WORD_SIZE-1:0] pc_next_out_EXMEM;
	wire [`WORD_SIZE-1:0] A_out_EXMEM;
	wire [`WORD_SIZE-1:0] B_out_EXMEM;
	wire [`WORD_SIZE-1:0] aluout_out_EXMEM;
	wire bcond_out_EXMEM;
	wire [1:0] dest_out_EXMEM;
	wire isStall_out_EXMEM;
	wire reg_write_EXMEM;
	// control unit MEM input output
	wire i_or_d_IDEX;	
	wire mem_read_IDEX;
	wire mem_write_IDEX;
	//wire pc_write_cond_IDEX; 
	//wire pc_write_IDEX;
	wire pc_br_IDEX;
	wire pc_j_IDEX;
	wire pc_jr_IDEX;
	wire pc_jrl_IDEX;


	wire mem_write;
	//wire pc_write_cond; 
	//wire pc_write;
	wire pc_br_EXMEM;
	wire pc_j_EXMEM;
	wire pc_jr_EXMEM;
	wire pc_jrl_EXMEM;

	// computed by bcond, pc_write_cond, pc_write
	// for pc update
	wire pc_src; 

	// MEMWB input output
	wire [`WORD_SIZE-1:0] aluout_out_MEMWB;
	wire [`WORD_SIZE-1:0] pc_out_MEMWB;
	wire [`WORD_SIZE-1:0] mdr_out_MEMWB;
	wire [`WORD_SIZE-1:0] inst_out_MEMWB;
	wire [`WORD_SIZE-1:0] A_out_MEMWB;
	wire [1:0] dest_out_MEMWB;
	wire isStall_out_MEMWB;

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

	wire [`WORD_SIZE-1:0] jmp_address;

	wire dummyControlUnit;
	
	//flush
	reg flush_in;
	wire flush_out_IDEX, flush_out_EXMEM, flush_out_MEMWB;

	//mem read data
	reg [`WORD_SIZE-1:0] mem_read_data;

	assign immediate_value = inst_out_IFID[7:0];
	assign read1 = inst_out_IFID[11:10];
	assign read2 = inst_out_IFID[9:8];

	assign data2 = write_m2 ? B_out_EXMEM : 16'bz;

	// TODO: register file dest(write_reg) mux
	// TODO: register file wirte_data mux
	// TODO: alu, alu control unit
	initial begin
		num_inst = 0;
		output_port = 0;
		flush_in = 0;
	end

	always @(posedge reset_n)
	begin
		num_inst <= 0;
		output_port <= 0;
		flush_in <= 0;
		
	end

	IFID IFID_module(
		.inst_in(data1),  // 확인 필요
		.inst_out(inst_out_IFID), 
		.pc_in(pc_out), // 확인 필요
		.stall_on(isStall),
		.flush_on(flush_in),
		.is_flush_in(flush_in),
		.pc_out(pc_out_IFID),
		.isStall_out(isStall_out_IFID), 
		.is_flush_out(flush_out_IFID),
		.reset_n(reset_n), 
		.clk(clk));


	IDEX IDEX_module(
		.A_in(read_out1), 
		.B_in(read_out2), 
		.pc_in(pc_out_IFID), 
		.imm_in(extended_immediate_value), 
		.inst_in(inst_out_IFID),
		//.dest_in(write_reg), // write reg mux로 구해야함
		.A_out(A_out_IDEX), 
		.B_out(B_out_IDEX), 
		.pc_out(pc_out_IDEX), 
		.imm_out(extended_immediate_value_out), 
		.inst_out(inst_out_IDEX),
		.isStall_in(isStall_out_IFID), 
		.isStall_out(isStall_out_IDEX),
		.flush_on(flush_in),
		.is_flush_in(flush_out_IFID),
		.is_flush_out(flush_out_IDEX),
		//.dest_out(dest_out_IDEX), 
		.reset_n(reset_n), 
		.clk(clk));

	control_unit_EX control_unit_EX_module(
		.inst(inst_out_IDEX), 
		.is_flush(flush_out_IDEX),
		.alu_src_B(alu_src_B), 
		.alu_op(alu_op),
		.is_stall(isStall_out_IDEX));

	control_unit_M control_unit_M_IDEX_module(
		.inst(inst_out_IDEX), 
		.mem_read(mem_read_IDEX), 
		.mem_write(mem_write_IDEX),
		.is_stall(isStall_out_IDEX), 
		.is_flush(flush_out_IDEX),
		.pc_br(pc_br_IDEX), 
		.pc_j(pc_j_IDEX),
		.pc_jr(pc_jr_IDEX),
		.pc_jrl(pc_jrl_IDEX)
		);

	//kc add
	control_unit_WB control_unit_WB_IDEX_module(
		.inst(inst_out_IDEX), 
		.mem_to_reg(mem_to_reg_IDEX),
		.reg_write(reg_write_IDEX), 
		.pc_to_reg(pc_to_reg_IDEX),
		.is_stall(isStall_out_IDEX),
		.is_flush(flush_out_IDEX),
		.is_lhi(is_lhi_IDEX));
	// for loading, mem_to_reg
	// srcB 1: using imm
 	// pc_to_reg : jal jrl -> write_reg=2
	mux4_1 mux_write_reg(.sel( {(alu_src_B  || mem_to_reg_IDEX),(pc_to_reg_IDEX)} ),
					.i1(inst_out_IDEX[7:6]), 
					.i2(2'b10), 
					.i3(inst_out_IDEX[9:8]), 
					.i4(2'b10), 
					.o(dest_out_IDEX));

	EXMEM EXMEM_module(
		//.pc_in(pc_next_in_EXMEM), 
		.pc_in(pc_out_IDEX),
		.aluout_in(alu_output), // alu result, bcond
		.bcond_in(bcond), // bcond
		.A_in(A_out_IDEX),
		.B_in(B_out_IDEX), 
		.inst_in(inst_out_IDEX),
		.dest_in(dest_out_IDEX), 
		.pc_next_in(pc_jrl_IDEX? A_out_IDEX :pc_next_in_EXMEM),
		.pc_out(pc_out_EXMEM),
		//.pc_out(pc_next_out_EXMEM),
		.pc_next_out(pc_next_out_EXMEM),
		.bcond_out(bcond_out_EXMEM), 
		.aluout_out(aluout_out_EXMEM), 
		.A_out(A_out_EXMEM),
		.B_out(B_out_EXMEM), 
		.inst_out(inst_out_EXMEM),
		.dest_out(dest_out_EXMEM), 
		.isStall_in(isStall_out_IDEX),
		.isStall_out(isStall_out_EXMEM),
		.is_flush_in(flush_out_IDEX ),
		.is_flush_out(flush_out_EXMEM),
		.reset_n(reset_n), 
		.clk(clk));
	
	control_unit_M control_unit_M_module(
		.inst(inst_out_EXMEM), 
		.mem_read(mem_read), 
		.mem_write(mem_write),
		.is_stall(isStall_out_EXMEM),
		.is_flush(flush_out_EXMEM), 
		.pc_br(pc_br_EXMEM), 
		.pc_j(pc_j_EXMEM),
		.pc_jr(pc_jr_EXMEM),
		.pc_jrl(pc_jrl_EXMEM));
	
	control_unit_WB control_unit_WB_M_module(
		.inst(inst_out_EXMEM), 
		.mem_to_reg(dummyControlUnit),
		.reg_write(reg_write_EXMEM), 
		.is_flush(flush_out_EXMEM), 
		.pc_to_reg(dummyControlUnit),
		.is_stall(isStall_out_EXMEM),
		.is_lhi(dummyControlUnit));

	MEMWB MEMWB_module(
		.pc_in(pc_out_EXMEM),
		.mdr_in(data2), // 확인 필요 
		.aluout_in(aluout_out_EXMEM), 
		.inst_in(inst_out_EXMEM),
		.dest_in(dest_out_EXMEM), 
		.A_in(A_out_EXMEM),
		.A_out(A_out_MEMWB),
		.pc_out(pc_out_MEMWB),
		.mdr_out(mdr_out_MEMWB), 
		.aluout_out(aluout_out_MEMWB),
		.inst_out(inst_out_MEMWB),
		.dest_out(dest_out_MEMWB), 
		.isStall_in(isStall_out_EXMEM),
		.isStall_out(isStall_out_MEMWB),
		.is_flush_in(flush_out_EXMEM),
		.is_flush_out(flush_out_MEMWB),
		.reset_n(reset_n), 
		.clk(clk));

	control_unit_WB control_unit_WB_module(
		.inst(inst_out_MEMWB), 
		.mem_to_reg(mem_to_reg),
		.reg_write(reg_write), 
		.pc_to_reg(pc_to_reg),
		.is_stall(isStall_out_MEMWB),
		.is_flush(flush_out_MEMWB), 
		.is_lhi(is_lhi));

	control_unit control_unit_module(
		.inst(inst_out_MEMWB), 
		.is_stall(isStall_out_MEMWB),
		.is_flush(flush_out_MEMWB),
		.halt(halt), 
		.wwd(wwd), 
		.new_inst(new_inst));

	// to define dest, we need pc_to_reg from control unit.
	// which is not yet defined IDEX 
	register_file register_file_module(
		.read_out1(read_out1),
		.read_out2(read_out2),
		.read1(read1),
		.read2(read2),
		.dest(dest_out_MEMWB),
		//.dest(write_reg),
		.write_data(write_data),
		.reg_write(reg_write),
		.reset_n(reset_n),
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

		
	mux2_1 mux_alu_input_2(
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



	// 0 : R type alu 
	// 01 : memory load
	// 10 : pc 
	// 11 : is_lhi
	mux4_1 mux_write_data(.sel({pc_to_reg || is_lhi ,mem_to_reg || is_lhi}),
					.i1(aluout_out_MEMWB),
					.i2(mdr_out_MEMWB),
					.i3(pc_out_MEMWB + 1), // pc+1?
					.i4({inst_out_MEMWB[7:0],8'b0}),
					.o(write_data));

	// pc src -> mux : pc in 
	// 0 : pc+1
	// 1 : pc_next_out_EXMEM
	assign pc_src = ((bcond_out_EXMEM && pc_br_EXMEM) || pc_j_EXMEM || pc_jrl_EXMEM) ;
	
	mux2_1 mux_pc_src(.sel(pc_src),
			.i1(pc_out+1),
			.i2(pc_next_out_EXMEM),
			.o(pc_in)
			);
	// pc module
	PC pc_module(
		.pc_in(pc_in),
		.reset_n(reset_n),
		.pc_update(!isStall),
		.clk(clk),
		.pc_out(pc_out)
	);


	// pc_next_in_EXMEM
	assign jmp_address = {pc_out_IDEX[15:12], inst_out_IDEX[11:0]};
	// pc_br -> not j& not jr -> 01
	// pc_j & not pc_jr -> not pc_br -> 10
	// pc_j & pc_jr -> not pc_br -> 11
	// not pc_j  & not br & not j -> 0 : then we do not use pc_next. ok
	mux4_1 mux_pc_next(.sel({pc_j_IDEX, pc_jr_IDEX||pc_br_IDEX}),
			.i1(0),
			.i2(pc_out_IDEX+1 + {8'b0,extended_immediate_value_out[7:0]}),//for branch
			.i3(jmp_address),
			.i4(A_out_IDEX),
			.o(pc_next_in_EXMEM));
	
	// mux2_1 mux_pc_jrl(.sel(pc_jrl_IDEX),
	// .i1(pc_next_in_EXMEM),
	// .i2(A_out_IDEX),
	// .o(pc_next_in_EXMEM));
	
	 hazard_detect hazard_detect_module(
		 .inst_IFID(inst_out_IFID), 
		 .rs1(read1), 
		 .rs2(read2), 
		 .reg_write_IDEX(reg_write_IDEX), 
		 .reg_write_EXMEM(reg_write_EXMEM), 
		 .reg_write_MEMWB(reg_write), 
		 .rd_IDEX(dest_out_IDEX), 
		 .rd_EXMEM(dest_out_EXMEM), 
		 .rd_MEMWB(dest_out_MEMWB), 
		 .is_stall(isStall));
	branch_predictor branch_predictor_module(
		.clk(clk), 
		.reset_n(reset_n), 
		.PC(pc_out), 
		.next_PC(pc_pred)
		);

	
	always @(*) begin
		if(pc_pred != pc_in) begin
			//IFID
			//IDEX 
			//control value -> 0
			flush_in = 1;
		end
		else begin
			flush_in = 0;
		end
		if(mem_read) begin
			mem_read_data = data2;
		end
	end

	always @(posedge clk) begin
		
		if(new_inst)begin
			num_inst <= num_inst+1;
		end
		if(wwd) begin
			output_port <= A_out_MEMWB;
		end
	end

	assign is_halted = halt;

	assign read_m1 = 1;
	assign address1 = pc_out;

	assign read_m2  = mem_read; 
	assign write_m2 = mem_write;
	assign address2 = aluout_out_EXMEM;

	
	always @(posedge clk) begin
		#(3*100/4);
		$display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
		$display("@@@@ data1 : %b", data1);
		$display("@@@@    inst_out_IFID : %b", inst_out_IFID);
		$display("@@@@ isStall_out_IFID : %d", isStall_out_IFID);		
		$display("@@@@   flush_out_IFID : %d", flush_out_IFID);	
		$display("@@@@        read_out1 : %d", read_out1);
		$display("@@@@        read_out2 : %d", read_out2);
		$display("========================================================");
		$display("@@@@    inst_out_IDEX : %b", inst_out_IDEX);
		$display("@@@@ isStall_out_IDEX : %d", isStall_out_IDEX);	
		$display("@@@@   flush_out_IDEX : %d", flush_out_IDEX);		
		$display("@@@@   reg_write_IDEX : %d", reg_write_IDEX);
		$display("@@@@       A_out_IDEX : %d", A_out_IDEX);
		$display("@@@@       B_out_IDEX : %d", B_out_IDEX);
		$display("@@@@      alu_input_2 : %d", alu_input_2);
		$display("@@@@    dest_out_IDEX : %d", dest_out_IDEX);
		$display("@@@         pc_j_IDEX : %b", pc_j_IDEX);
		$display("@@@        pc_jr_IDEX : %b", pc_jr_IDEX);
		$display("@@@        pc_br_IDEX : %b", pc_br_IDEX);

		$display("========================================================");

		$display("@@@@    inst_out_EXMEM : %b", inst_out_EXMEM);
		$display("@@@@ isStall_out_EXMEM : %d", isStall_out_EXMEM);	
		$display("@@@@   flush_out_EXMEM : %d", flush_out_EXMEM);	
		$display("@@@@   reg_write_EXMEM : %d", reg_write_EXMEM);
		$display("@@@   pc_next_in_EXMEM : %b", pc_next_in_EXMEM);
		$display("@@@  pc_next_out_EXMEM : %b", pc_next_out_EXMEM);
		$display("@@@   aluout_out_EXMEM : %b", aluout_out_EXMEM);
		$display("@@@           mem_read : %d", mem_read);
		$display("@@@          mem_write : %d", mem_write);
		$display("@@@    bcond_out_EXMEM : %b", bcond_out_EXMEM);

		$display("========================================================");
		$display("@@@@    inst_out_MEMWB : %b", inst_out_MEMWB);
		$display("@@@@ isStall_out_MEMWB : %d", isStall_out_MEMWB);	
		$display("@@@@   flush_out_MEMWB : %d", flush_out_MEMWB);	
		$display("@@@@   reg_write_MEMWB : %d", reg_write);

		$display("@@@   alu_output_MEMWB : %d", aluout_out_MEMWB);
		$display("@@@      mdr_out_MEMWB : %d", mdr_out_MEMWB);
		$display("@@@       pc_out_MEMWB : %d", pc_out_MEMWB);
		$display("@@@     dest_out_MEMWB : %d", dest_out_MEMWB);


		$display("========================================================");
		$display("@@@    pc_in : %b", pc_in);
		$display("@@@ pc_out b : %b", pc_out);
		$display("@@@ pc_out h : %h", pc_out);
		$display("@@@ pc_out d : %d", pc_out);

		$display("@@@  pc_pred : %b", pc_pred);
		$display("@@@  isStall : %b", isStall);
		$display("@@@        branch_type : %d", branchType);
		$display("@@@   pc_src : %b", pc_src);


		
		$display("@@@       address2 : %d", address2);
		$display("@@@        read_m2 : %d", read_m2);
		$display("@@@          data2 : %d", data2);
		$display("@@@  mem_read_data : %d", mem_read_data);	
	
		
		
		$display("@@@ mem_to_reg : %d", mem_to_reg);
		$display("@@@  pc_to_reg : %d", pc_to_reg);
		$display("@@@       cond : %b", {pc_to_reg || is_lhi ,mem_to_reg || is_lhi});
		$display("@@@ write_data : %d", write_data);
		//$display("@@@ is_lhi: %d", is_lhi);

		$display("@@@        flush_in : %b", flush_in);
		$display("@@@        num_inst : %d", num_inst);
		$display("@@@@       new_inst : %d", new_inst);	
		$display("@@@@            wwd : %d", wwd);	
		$display("@@@@    output_port : %d", output_port);	
		
	end

endmodule

