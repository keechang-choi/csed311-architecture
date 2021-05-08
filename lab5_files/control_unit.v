`include "opcodes.v" 

module control_unit_EX(inst,is_stall,is_flush, alu_src_B, alu_op);
	input [`WORD_SIZE-1:0] inst;
	input is_stall;
	input is_flush;
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
 			 opcode==`BGZ_OP || opcode==`BLZ_OP ) begin
			//opcode==`BNE_OP || opcode==`BEQ_OP is not the case for imm
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

module control_unit_M(inst, is_stall, is_flush, mem_read, mem_write, pc_br, pc_j, pc_jr, pc_jrl);
	input [`WORD_SIZE-1:0] inst;
	input is_stall;
	input is_flush;
	output reg mem_read;
	output reg mem_write;
	// for Branch inst
	output reg pc_br;
	//output reg pc_src;
	// for jump branch
	output reg pc_j;
	output reg pc_jr;
	output reg pc_jrl;

	wire [3:0] opcode;
	wire [5:0] func_code;
	assign opcode = inst[15:12];
	assign func_code = inst[5:0];
	always @(*) begin
		if(is_flush || is_stall) begin
			mem_read = 0;
			mem_write = 0;
			pc_br = 0;
			pc_j = 0;
			pc_jr = 0;
			pc_jrl = 0;
		end
		else begin
			if(opcode==`LWD_OP) begin
				mem_read = 1;
			end
			else begin
				mem_read = 0;
			end

			if(!is_stall && opcode==`SWD_OP ) begin
				mem_write = 1;
			end
			else begin
				mem_write = 0;
			end
			if((opcode==`JRL_OP&& func_code == `INST_FUNC_JRL)
			|| (opcode==`JPR_OP && func_code == `INST_FUNC_JPR)) begin
				pc_j = 1;
				pc_jr = 1;
			end
			else if(opcode==`JAL_OP || opcode==`JMP_OP) begin
				pc_j = 1;
				pc_jr = 0;
			end
			else begin
				pc_j = 0;
				pc_jr = 0;
			end
			if(opcode==`BNE_OP || opcode==`BEQ_OP ||
				opcode==`BGZ_OP ||opcode==`BLZ_OP) begin
				pc_br = 1;
			end
			else begin
				pc_br = 0;
			end
		end
	end
endmodule

module control_unit_WB(inst,is_stall, is_flush, mem_to_reg, reg_write, pc_to_reg, is_lhi);
	input [`WORD_SIZE-1:0] inst;
	input is_stall;
	input is_flush;
	output reg mem_to_reg;
	output reg reg_write;
	output reg pc_to_reg;
	//for write data LHI
	output reg is_lhi;

	wire [3:0] opcode;
	wire [5:0] func_code;
	assign opcode = inst[15:12];
	assign func_code = inst[5:0];

	always @(*) begin
		if(is_flush) begin
			mem_to_reg = 0;
			reg_write = 0;
			pc_to_reg = 0;
			is_lhi = 0;
		end
		else begin
			if(opcode==`LWD_OP ) begin
				mem_to_reg = 1;
			end
			else begin
				mem_to_reg = 0;
			end
		
			if((opcode==`ALU_OP&&func_code==`INST_FUNC_ADD) ||
			(opcode==`ALU_OP&&func_code==`INST_FUNC_SUB) ||
			(opcode==`ALU_OP&&func_code==`INST_FUNC_AND) ||
			(opcode==`ALU_OP&&func_code==`INST_FUNC_ORR) ||
			(opcode==`ALU_OP&&func_code==`INST_FUNC_NOT) ||
			(opcode==`ALU_OP&&func_code==`INST_FUNC_TCP) ||
			(opcode==`ALU_OP&&func_code==`INST_FUNC_SHL) ||
			(opcode==`ALU_OP&&func_code==`INST_FUNC_SHR) ||
			opcode==`ADI_OP ||opcode==`ORI_OP || opcode==`LHI_OP ||
 			opcode==`LWD_OP || opcode==`JAL_OP ||
			(opcode==`JRL_OP&& func_code == `INST_FUNC_JRL)) begin
				if(!is_stall) begin
					reg_write = 1;
				end
				else begin
					reg_write = 0;
				end
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
			end begin
				is_lhi = (opcode == `LHI_OP);
			end
		end
	end
endmodule



module control_unit (reset_n, inst, is_stall, is_flush, halt, wwd, new_inst);

	//input [3:0] opcode;
	//input [5:0] func_code;
	input reset_n;
	input [`WORD_SIZE-1:0] inst;
	input is_stall;
	input is_flush;
	

  	//additional control signals. pc_to_reg: to support JAL, JRL. halt: to support HLT. wwd: to support WWD. new_inst: new instruction start
  	output reg halt;
	output reg wwd;
	output reg new_inst;

	wire [3:0] opcode;
	wire [5:0] func_code;
	assign opcode = inst[15:12];
	assign func_code = inst[5:0];
	
	initial begin
		halt = 0;
		wwd = 0;
		new_inst = 0;
	end
	/*
	always @(*) begin
		if(new_inst)begin
			new_inst = 0;
		end
	end*/
	always @(posedge reset_n) begin
		halt <= 0;
		wwd <= 0;
		new_inst <= 0;
	end
	always @(*) begin
		if(opcode == `NOP_OP) begin
			halt = 0;
			wwd = 0;
			new_inst = 0;
		end
		else begin
			if(!is_stall && !is_flush) begin
				new_inst = 1;
				if(opcode==`HLT_OP && func_code == `INST_FUNC_HLT) begin
					halt = 1;
				end
				else begin
					halt = 0;
				end
				if(opcode==`WWD_OP && func_code == `INST_FUNC_WWD) begin
					wwd = 1;
				end 
				else begin
					wwd = 0;
				end
			end
			else begin
				halt = 0;
				wwd = 0;
				new_inst = 0;
			end
		end
	end
endmodule
