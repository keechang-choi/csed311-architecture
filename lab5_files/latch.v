module IFID(inst_in, inst_out pc_in, pc_out, reset_n, clk);
    // TODO: IFID latch를 컨트롤 할 control unit input을 받아야함
	// inst_in이 IR_in 임
	input clk;
	input reset_n;
    input [`WORD_SIZE-1:0] inst;
	input [`WORD_SIZE-1:0] pc_in;
	output reg [`WORD_SIZE-1:0] pc_out;
    output reg [`WORD_SIZE-1:0] inst_out;

	initial begin
        inst_out = 0;
		pc_out = 0;
	end
	
	always @(posedge reset_n)
	begin
        inst_out <= 0;
		pc_out <= 0 ;
	end
	
	always @(posedge clk) 
	begin
        pc_out <= pc_in;
		inst_out <= inst_in;    
	end
endmodule


module IDEX(A_in, B_in, pc_in, imm_in, inst_in, A_out, B_out, pc_out, imm_out, inst_out, reset_n, clk);
    // TODO: IDEX latch를 컨트롤 할 control unit input을 받아야함
	input clk;
	input reset_n;
    input [`WORD_SIZE-1:0] A_in;
	input [`WORD_SIZE-1:0] B_in;
	input [`WORD_SIZE-1:0] pc_in;
	input [`WORD_SIZE-1:0] inst_in;
	input [`WORD_SIZE-1:0] imm_in;
	output reg [`WORD_SIZE-1:0] A_out;
    output reg [`WORD_SIZE-1:0] B_out;
	output reg [`WORD_SIZE-1:0] pc_out;
    output reg [`WORD_SIZE-1:0] inst_out;
	output reg [`WORD_SIZE-1:0] imm_out;

	initial begin
		A_out = 0;
		B_out = 0;
		imm_out = 0;
        inst_out = 0;
		pc_out = 0;
	end
	
	always @(posedge reset_n)
	begin
		A_out <= 0;
		B_out <= 0;
		imm_out <=0;
        inst_out <= 0;
		pc_out <= 0 ;
	end
	
	always @(posedge clk) 
	begin
		A_out <= A_in;
		B_out <= B_in;
		imm_out <= imm_in;
        pc_out <= pc_in;
		inst_out <= inst_in;    
	end
endmodule

				
module EXMEM(pc_in, aluout_in, B_in, inst_in, pc_out, aluout_out, B_out, inst_out, reset_n, clk);
    // TODO: IDEX latch를 컨트롤 할 control unit input을 받아야함
	input clk;
	input reset_n;
    input [`WORD_SIZE-1:0] pc_in;
	input [`WORD_SIZE-1:0] aluout_in;
	input [`WORD_SIZE-1:0] B_in;
	input [`WORD_SIZE-1:0] inst_in;
	output reg [`WORD_SIZE-1:0] pc_out;
    output reg [`WORD_SIZE-1:0] aluout_out;
	output reg [`WORD_SIZE-1:0] B_out;
    output reg [`WORD_SIZE-1:0] inst_out;

	initial begin
		pc_out = 0;
		aluout_out = 0;
		B_out = 0;
        inst_out = 0;
	end
	
	always @(posedge reset_n)
	begin
		pc_out <= 0;
		aluout_out <= 0;
		B_out <= 0;
        inst_out <= 0;
	end
	
	always @(posedge clk) 
	begin
		pc_out <= pc_in;
		aluout_out <= aluout_in;
		B_out <= B_in;
        inst_out <= inst_in;    
	end
endmodule

				
module MEMWB(mdr_in, aluout_in, inst_in, mdr_out, aluout_out, reset_n, clk);
    // TODO: IDEX latch를 컨트롤 할 control unit input을 받아야함
	input clk;
	input reset_n;
    input [`WORD_SIZE-1:0] mdr_in;
	input [`WORD_SIZE-1:0] aluout_in;
	input [`WORD_SIZE-1:0] inst_in;
	output reg [`WORD_SIZE-1:0] mdr_out;
    output reg [`WORD_SIZE-1:0] aluout_out;


	initial begin
		mdr_out = 0;
		aluout_out = 0;
	end
	
	always @(posedge reset_n)
	begin
		mdr_out <= 0;
        aluout_out <= 0;
	end
	
	always @(posedge clk) 
	begin
		mdr_out <= mdr_in;
        aluout_out <= aluout_in;
	end
endmodule

				