`include "opcodes.v" 	   

module control_unit (instr, alu_src, reg_write, mem_read, mem_to_reg, mem_write, jp, branch);
input [`WORD_SIZE-1:0] instr;
output reg alu_src;
output reg reg_write;
output reg mem_read;
output reg mem_to_reg;
output reg mem_write;
output reg jp;
output reg branch;
	wire [3:0] opcode;
	wire [5:0] funcode;
	assign opcode = instr[15:12];
	assign funcode = instr[5:0];

	always @(*)
	begin
		if(opcode==`ADI_OP ||opcode==`ORI_OP || opcode==`LHI_OP ||
 		opcode==`LWD_OP || opcode==`SWD_OP ||
 		opcode==`BNE_OP || opcode==`BEQ_OP || opcode==`BGZ_OP || opcode==`BLZ_OP ) begin
			alu_src = 1;
		end
		else begin
			alu_src = 0;
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
		if(opcode==`LWD_OP) begin
			mem_read = 1;
		end
		else begin
			mem_read = 0;
		end	

		if(opcode==`LWD_OP ) begin
			mem_to_reg = 1;
		end
		else begin
			mem_to_reg = 0;
		end	

		if(opcode==`SWD_OP ) begin
			mem_write = 1;
		end
		else begin
			mem_write = 0;
		end	
		if(opcode==`JMP_OP || opcode==`JAL_OP ||
		(opcode==`JPR_OP && funcode == `INST_FUNC_JPR) ||
		(opcode==`JRL_OP && funcode == `INST_FUNC_JRL)) begin
			jp= 1;
		end
		else begin
			jp = 0;
		end	
		if(opcode==`BNE_OP || opcode==`BEQ_OP ||
		opcode==`BGZ_OP ||opcode==`BLZ_OP) begin
			branch= 1;
		end
		else begin
			branch = 0;
		end	
	end

endmodule