`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size
`include "opcodes.v"


module cpu(clk, reset_n, read_m, write_m, address, data, num_inst, output_port, is_halted);
	input clk;
	input reset_n;
	
	output reg read_m;
	output reg write_m;
	output reg [`WORD_SIZE-1:0] address;

	inout [`WORD_SIZE-1:0] data;

	output reg [`WORD_SIZE-1:0] num_inst;		// number of instruction executed (for testing purpose)
	output [`WORD_SIZE-1:0] output_port;	// this will be used for a "WWD" instruction
	output is_halted;

	// TODO : implement multi-cycle CPU

	// pc
	wire [`WORD_SIZE-1:0] pc_in;
	wire [`WORD_SIZE-1:0] pc_out;
	wire update_pc;


	// register_file input
	wire [`WORD_SIZE-1:0] write_data;
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
	wire bcond;
	wire overflow_flag;
	wire [`WORD_SIZE-1:0] alu_output;

	// alu_out ouput
	wire [`WORD_SIZE-1:0] alu_out_output;

	// alu_control_unit input
	wire [5:0] funct;
	wire [3:0] opcode;

	// alu_control_unit output
	wire [3:0] funcCode;
	wire [1:0] branchType;

	// cpu
	reg [`WORD_SIZE-1:0] inst;
	reg [`WORD_SIZE-1:0] mem_data_reg;
	wire [7:0] immediate_value;
	wire [`WORD_SIZE-1:0] jmp_address;
	wire [`WORD_SIZE-1:0] address_wire;

	// control_unit output
	wire pc_write_cond;
	wire pc_write;
	wire i_or_d;
	wire mem_read;
	wire mem_to_reg;
	wire mem_write; 
	wire ir_write; 
	wire pc_to_reg; 
	wire [1:0] pc_src; 
	wire halt; 
	wire wwd; 
	wire new_inst; 
	wire reg_write; 
	wire alu_src_A; 
	wire[1:0] alu_src_B; 
	wire alu_op;

	// cpu
	assign immediate_value = inst[7:0];
	assign extended_imm_value = {{8{immediate_value[7]}}, immediate_value[7:0]};
	assign data = write_m ? read_out2 : 16'bz;
	assign jmp_address = {pc_out[15:12], inst[11:0]};


	
	// alu_control_unit
	assign funct = inst[5:0];
	assign opcode = inst[15:12];

	// pc
	assign update_pc = (bcond && pc_write_cond) || pc_write;

	initial begin
		inst = 0;
		mem_data_reg = 0;
		num_inst = 0;
	end


	// always @(*) begin
	// 	address = pc_out;
	// 	read_m = 1;
	// end

	/*always @(mem_read) begin
		read_m = mem_read;
	end
	always @(mem_write) begin
		write_m = mem_write;
	end*/

	always @(*) begin
		if(mem_read > 0) begin
			//$display("address wire %b", address_wire);
			read_m = 1;
			write_m = 0; // b/c memory
		end
	end

	always @(*) begin
		if(mem_read > 0) begin
			address = address_wire;	
		end
	end

	always @(posedge clk) begin
		if(read_m) begin
			read_m <= 0;
			if(ir_write)begin
				//$display("data %b", data);
				num_inst <= num_inst + 1;
			end
			
			// if(i_or_d) begin
			// 	inst <= data;
			// end
			// else begin
			// 	mem_data_reg <= data;
			// end
		end
	end
	always @(*) begin
		if(read_m) begin
			if(ir_write) begin
				inst = data;
			end
			else begin
				mem_data_reg = data;
			end
		end
	end

	always @(posedge clk) begin
		if(mem_write > 0) begin
			address <= alu_output;
			write_m <= 1;
		end
	end

	always @(posedge clk) begin
		if(write_m) begin
			write_m <= 0;
		end
	end

	mux2_1 mux_alu_input1(.sel(alu_src_A),
						.i1(pc_out),
						.i2(read_out1),
						.o(alu_input_1));

	mux4_1 mux_alu_input2(.sel(alu_src_B),
						.i1(read_out2),
						.i2(16'b1),
						.i3(extended_imm_value),
						.i4(16'b1),
						.o(alu_input_2));

	mux4_1 mux_pc_input(.sel(pc_src),
						.i1(alu_output),
						.i2(alu_out_output),
						.i3(jmp_address),
						.i4(read_out1),
						.o(pc_in));
	
	mux2_1 mux_address(.sel(i_or_d),
					.i1(pc_out),
					.i2(alu_out_output),
					.o(address_wire));

	mux4_1 mux_write_data(.sel({(pc_to_reg) || (opcode == `LHI_OP),(mem_to_reg) || (opcode == `LHI_OP)}),
					.i1(alu_out_output),
					.i2(mem_data_reg),
					.i3(pc_out),
					.i4(extended_imm_value<<8),
					.o(write_data));

	mux4_1 mux_write_reg(.sel( {(alu_src_B==2),(pc_to_reg)} ),
					.i1({(14'b0),(inst[7:6])}), 
					.i2(16'b10), 
					.i3({(14'b0),(inst[9:8])}), 
					.i4({(14'b0),(inst[9:8])}), 
					.o(write_reg));

	PC program_counter(.pc_in(pc_in), 
					.pc_out(pc_out), 
					.update_pc(update_pc), 
					.clk(clk), 
					.reset_n(reset_n));

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

	alu_out alu_out_module(.alu_in(alu_output),
						.alu_out(alu_out_output),
						.reset_n(reset_n), 
						.clk(clk));

	control_unit control_unit_module(.opcode(opcode),
									.func_code(funcCode),
									.clk(clk),
									.reset_n(reset_n),
									.pc_write_cond(pc_write_cond),
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
	always @(posedge clk) begin
		#(300/4);
		$display("@@@@ pc_out : %d", pc_out);
		$display("@@@@ pc_in : %d", pc_in);
		$display("@@@@ pc_update : %d", update_pc);
		$display("@@@@ mem_read : %d", mem_read);
		$display("@@@@ addr wire : %d", address_wire);
		$display("@@@@ addr  : %d", address);
		$display("@@@@ data : %b", data);
		$display("@@@@ i_or_d : %d",i_or_d);
		$display("@@@@ inst : %b", inst);
		$display("@@@ alu_input_1 : %d", alu_input_1);
		$display("@@@ alu_input_2 : %d", alu_input_2);
	end
endmodule
