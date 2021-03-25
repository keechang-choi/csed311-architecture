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

	always @(*)
	begin
		if(instr==`ADI_OP ||instr==`ORI_OP || instr==`LHI_OP ||
 		instr==`LWD_OP || instr==`SWD_OP ||
 		instr==`BNE_OP || instr==`BEQ_OP || instr==`BGZ_OP || instr==`BLZ_OP ) begin
			alu_src = 1;
		end
		else begin
			alu_src = 0;
		end
		if(instr==`ALU_OP ||instr==`ADI_OP ||instr==`ORI_OP || instr==`LHI_OP ||
 		instr==`LWD_OP || instr==`JAL_OP ||instr==`JRL_OP) begin
			reg_write = 1;
		end
		else begin
			reg_write = 0;
		end	
		if(instr==`LWD_OP) begin
			mem_read = 1;
		end
		else begin
			mem_read = 0;
		end	

		if(instr==`LWD_OP ) begin
			mem_to_reg = 1;
		end
		else begin
			mem_to_reg = 0;
		end	

		if(instr==`SWD_OP ) begin
			mem_write = 1;
		end
		else begin
			mem_write = 0;
		end	
		if(instr==`JMP_OP || instr==`JAL_OP ||
		instr==`JPR_OP ||instr==`JRL_OP) begin
			jp= 1;
		end
		else begin
			jp = 0;
		end	
		if(instr==`BNE_OP || instr==`BEQ_OP ||
		instr==`BGZ_OP ||instr==`BLZ_OP) begin
			branch= 1;
		end
		else begin
			branch = 0;
		end	
	end

endmodule