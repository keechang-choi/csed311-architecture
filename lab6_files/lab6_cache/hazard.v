`include "opcodes.v"

module hazard_detect(inst_IFID,is_flush, rs1, rs2, reg_write_IDEX, reg_write_EXMEM, reg_write_MEMWB, rd_IDEX, rd_EXMEM, rd_MEMWB, is_stall);

	input [`WORD_SIZE-1:0] inst_IFID;
	input is_flush;
	input [1:0] rs1;
	input [1:0] rs2;
	

	input reg_write_IDEX;
	input reg_write_EXMEM;
	input reg_write_MEMWB;

	input [1:0] rd_IDEX;
	input [1:0] rd_EXMEM;
	input [1:0] rd_MEMWB;

	output reg is_stall;


	//TODO: implement hazard detection unit
	reg [1:0] use_rs1;
	reg [1:0] use_rs2;

	wire [3:0] opcode;
	wire [5:0] funcode;

	assign opcode = inst_IFID[15:12];
	assign funcode = inst_IFID[5:0];

	always @(*) begin
		use_rs1 = 0;
		use_rs2 = 0;
		
		if((opcode==`ALU_OP&&funcode==`INST_FUNC_ADD) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_SUB) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_AND) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_ORR) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_NOT) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_TCP) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_SHL) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_SHR) ||
		(opcode==`ADI_OP) || (opcode==`ORI_OP) || // no LHI
		(opcode==`WWD_OP && funcode == `INST_FUNC_WWD)||
		(opcode==`LWD_OP) || (opcode==`SWD_OP ) ||
		(opcode==`BNE_OP || opcode==`BEQ_OP || opcode==`BGZ_OP ||opcode==`BLZ_OP) ||
		(opcode==`JPR_OP && funcode == `INST_FUNC_JPR) ||
		(opcode==`JRL_OP&& funcode == `INST_FUNC_JRL)) begin
			use_rs1 = 1;
		end

		if ( (opcode==`ALU_OP&&funcode==`INST_FUNC_ADD) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_SUB) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_AND) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_ORR) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_NOT) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_TCP) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_SHL) ||
		(opcode==`ALU_OP&&funcode==`INST_FUNC_SHR) ||
		(opcode==`SWD_OP ) ||
		(opcode==`BNE_OP || opcode==`BEQ_OP )) begin
			use_rs2 = 1;
		end
		
		if(!is_flush&&
		(((rs1 == rd_IDEX) && use_rs1 && reg_write_IDEX) ||
		((rs1 == rd_EXMEM) && use_rs1 && reg_write_EXMEM) ||
		((rs1 == rd_MEMWB) && use_rs1 && reg_write_MEMWB) ||
		((rs2 == rd_IDEX) && use_rs2 && reg_write_IDEX) ||
		((rs2 == rd_EXMEM) && use_rs2 && reg_write_EXMEM) ||
		((rs2 == rd_MEMWB) && use_rs2 && reg_write_MEMWB))) begin
			is_stall = 1;
		end
		else begin
			is_stall = 0;
		end
	end
	
	
endmodule