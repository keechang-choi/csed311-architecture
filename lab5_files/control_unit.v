`include "opcodes.v" 

module control_unit_EX(inst, alu_src_B, alu_op);
	input [`WORD_SIZE-1:0] inst;
	//output reg alu_src_A;
	output reg alu_src_B;
	output reg alu_op;

	wire [3:0] opcode;
	wire [5:0] funcode;
	assign opcode = inst[15:12];
	assign funcode = inst[5:0];

	always @(*) begin
		if(opcode==`ADI_OP ||opcode==`ORI_OP || opcode==`LHI_OP ||
 			opcode==`LWD_OP || opcode==`SWD_OP ||
 			opcode==`BNE_OP || opcode==`BEQ_OP || opcode==`BGZ_OP || opcode==`BLZ_OP ) begin
				alu_src_B = 1;
		end
		else begin
			alu_src_B = 0;
		end
		// jpr jrl hlt ??? dont need to care ? not using alu ouput
		if(opcode==`ALU_OP) begin
			alu_op = 1;
		end
		else begin
			alu_op = 0;
		end
	end
endmodule

module control_unit_M(inst,  i_or_d, mem_read, mem_write, pc_write_cond, pc_src, pc_write);
	input [`WORD_SIZE-1:0] inst;
	output reg i_or_d;
	output reg mem_read;
	output reg mem_write;
	//output reg pc_write_cond;
	//output reg pc_src;
	//output reg pc_write;

	wire [3:0] opcode;
	wire [5:0] funcode;
	assign opcode = inst[15:12];
	assign funcode = inst[5:0];
	always @(*) begin
		i_or_d = 0;
		if(opcode==`LWD_OP) begin
			mem_read = 1;
			i_or_d = 1;
		end
		else begin
			mem_read = 0;
		end

		if(opcode==`SWD_OP ) begin
			mem_write = 1;
			i_or_d = 1;
		end
		else begin
			mem_write = 0;
		end	
	end
endmodule

module control_unit_WB(inst, mem_to_reg, reg_write, pc_to_reg, is_lhi);
	input [`WORD_SIZE-1:0] inst;
	output reg mem_to_reg;
	output reg reg_write;
	output reg pc_to_reg;
	//for write data LHI
	output reg is_lhi;

	wire [3:0] opcode;
	wire [5:0] funcode;
	assign opcode = inst[15:12];
	assign funcode = inst[5:0];

	always @(*) begin
		if(opcode==`LWD_OP ) begin
			mem_to_reg = 1;
		end
		else begin
			mem_to_reg = 0;
		end
	
		if((opcode==`ALU_OP&&funcode==`INST_FUNC_ADD) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_SUB) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_AND) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_ORR) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_NOT) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_TCP) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_SHL) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_SHR) ||
		opcode==`ADI_OP ||opcode==`ORI_OP || opcode==`LHI_OP ||
 		opcode==`LWD_OP || opcode==`JAL_OP ||
		(opcode==`JRL_OP&& funcode == `INST_FUNC_JRL)) begin
			reg_write = 1;
		end
		else begin
			reg_write = 0;
		end	
		if(opcode==`JAL_OP ||
		(opcode==`JRL_OP&& func_code == `INST_FUNC_JRL)) begin
			pc_to_reg = 1;
		end
		else begin
			pc_to_reg = 0;
		end
		is_lhi = (opcode == `LHI_OP);
	end
endmodule



module control_unit (inst, clk, reset_n, mem_read, i_or_d, ir_write, halt, wwd, new_inst);

	//input [3:0] opcode;
	//input [5:0] func_code;
	input [`WORD_SIZE-1:0] inst;
	input clk;
	input reset_n;
	
	output reg mem_read;
	output reg  i_or_d, ir_write ;
  	//additional control signals. pc_to_reg: to support JAL, JRL. halt: to support HLT. wwd: to support WWD. new_inst: new instruction start
  	output reg halt, wwd, new_inst;

	wire [3:0] opcode;
	wire [5:0] funcode;
	assign opcode = inst[15:12];
	assign funcode = inst[5:0];
	
	initial begin
	end

	always @(posedge clk) begin
		// mem_read ? 
		//i_or_d ? 
		// ir_write ? 
		//new_inst <= 1;
		halt <= 0;
		wwd <= 0;
	end
	
	always @(*) begin
		if(opcode==`HLT_OP && func_code == `INST_FUNC_HLT) begin
			halt = 1;
		end
		if(opcode==`WWD_OP && func_code == `INST_FUNC_WWD) begin
			wwd = 1;
		end
	end
endmodule
