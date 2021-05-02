`include "opcodes.v"

module hazard_detect(inst_IFID, rs1, rs2, inst_IDEX,inst_EXMEM, inst_MEMWB,reg_write_IDEX, reg_write_EXMEM, reg_write_MEMWB, rd_IDEX, rd_EXMEM, rd_MEMWB, is_stall);

	input [`WORD_SIZE-1:0] inst_IFID;
	input [1:0] rs1;
	input [1:0] rs2;
	input [`WORD_SIZE-1:0] inst_IDEX;
	input [`WORD_SIZE-1:0] inst_EXMEM;
	input [`WORD_SIZE-1:0] inst_MEMWB;

	input reg_write_IDEX;
	input reg_write_EXMEM;
	input reg_write_MEMWB;

	input [1:0] rd_IDEX;
	input [1:0] rd_EXMEM;
	input [1:0] rd_MEMWB;

	output is_stall;



	//TODO: implement hazard detection unit
	reg [1:0] use_rs1;
	reg [1:0] use_rs2;

	wire [3:0] opcode;
	wire [5:0] funcode;

	assign opcode = inst_IFID[15:12];
	assign funcode = inst_IFID[5:0];


	
	
endmodule