`define WORD_SIZE 16
`include "opcodes.v"

module IFID(inst_in, inst_out, pc_in, stall_on,flush_on,is_flush_in, is_flush_out,  pc_out, isStall_out,  reset_n, clk);
    // TODO: IFID latch를 컨트롤 할 control unit input을 받아야함
	// inst_in이 IR_in 임
	input clk;
	input reset_n;
    	input [`WORD_SIZE-1:0] inst_in;
	input [`WORD_SIZE-1:0] pc_in;
	input stall_on;
	input is_flush_in;
	input flush_on;
	output reg [`WORD_SIZE-1:0] pc_out;
    	output reg [`WORD_SIZE-1:0] inst_out;
	output reg isStall_out;
	output reg is_flush_out;

	initial begin

        	inst_out = 0;
		pc_out = 0;
		isStall_out = 0;
		is_flush_out = 0;
	end
	
	always @(posedge reset_n)
	begin
		inst_out <= {`NOP_OP,12'b0};
		pc_out <= 0 ;
		isStall_out <= 0;
		is_flush_out <= 0;
	end
	
	always @(posedge clk) 
	begin
        	//if(!is_flush_out) begin
			if(!isStall_out) begin
				inst_out <= inst_in;
				pc_out <= pc_in;
			end
		//end
		/*else begin
			inst_out <= inst_in;
			pc_out <= pc_in;
		end*/
		is_flush_out <= is_flush_in;
		//isStall_out <= isStall_in;    
		
	end
	always @(*) begin
		if(flush_on) begin
			is_flush_out = flush_on;
		end
		/*else begin
			is_flush_out = 0;
		end*/
		if(stall_on) begin
			isStall_out = stall_on;
		end
		else begin
			isStall_out = 0;
			//inst_out = inst_in;
			//pc_out = pc_in; // #281 inst??
		end
	end
endmodule


module IDEX(A_in, B_in, pc_in, imm_in, inst_in, isStall_in, is_flush_in, flush_on,
 A_out, B_out, pc_out, imm_out, inst_out, isStall_out, is_flush_out, reset_n, clk);
    // TODO: IDEX latch를 컨트롤 할 control unit input을 받아야함
	input clk;
	input reset_n;
    	input [`WORD_SIZE-1:0] A_in;
	input [`WORD_SIZE-1:0] B_in;
	input [`WORD_SIZE-1:0] pc_in;
	input [`WORD_SIZE-1:0] inst_in;
	input [`WORD_SIZE-1:0] imm_in;
	input isStall_in;
	input is_flush_in;
	input flush_on;
	output reg [`WORD_SIZE-1:0] A_out;
    output reg [`WORD_SIZE-1:0] B_out;
	output reg [`WORD_SIZE-1:0] pc_out;
    output reg [`WORD_SIZE-1:0] inst_out;
	output reg [`WORD_SIZE-1:0] imm_out;
	output reg isStall_out;
	output reg is_flush_out;
	initial begin
		A_out = 0;
		B_out = 0;
		imm_out = 0;
        	inst_out = 0;
		pc_out = 0;
		isStall_out = 0;
		is_flush_out = 0;
	end
	
	always @(posedge reset_n)
	begin
		A_out <= 0;
		B_out <= 0;
		imm_out <=0;
		inst_out <= {`NOP_OP,12'b0};
		pc_out <= 0 ;
		isStall_out <= 0;
		is_flush_out <= 0;
	end
	
	always @(posedge clk) 
	begin
		A_out <= A_in;
		B_out <= B_in;
		imm_out <= imm_in;
        	pc_out <= pc_in;
		inst_out <= inst_in;
		isStall_out <= isStall_in;
		is_flush_out <= is_flush_in;
  
	end
	always @(*) begin
		if(flush_on) begin
			is_flush_out = flush_on;  
		end
	end
endmodule

				
module EXMEM(pc_next_in, pc_in, aluout_in, bcond_in,A_in, B_in, inst_in, dest_in, isStall_in, is_flush_in,
pc_next_out, pc_out, aluout_out, bcond_out,A_out, B_out, inst_out, dest_out, isStall_out, is_flush_out, reset_n, clk);
    // TODO: IDEX latch를 컨트롤 할 control unit input을 받아야함
	input clk;
	input reset_n;
    	input [`WORD_SIZE-1:0] pc_in;
	input [`WORD_SIZE-1:0] pc_next_in;
	input [`WORD_SIZE-1:0] aluout_in;
	input [`WORD_SIZE-1:0] A_in;
	input [`WORD_SIZE-1:0] B_in;
	input [`WORD_SIZE-1:0] inst_in;
	input bcond_in;
	input [1:0] dest_in;
	input isStall_in;
	input is_flush_in;
	output reg [`WORD_SIZE-1:0] pc_out;
	output reg [`WORD_SIZE-1:0] pc_next_out;
    	output reg [`WORD_SIZE-1:0] aluout_out;
	output reg [`WORD_SIZE-1:0] A_out;
	output reg [`WORD_SIZE-1:0] B_out;
    	output reg [`WORD_SIZE-1:0] inst_out;
	output reg bcond_out;
	output reg [1:0] dest_out;
	output reg isStall_out;
	output reg is_flush_out;
	initial begin
		pc_next_out = 0;
		pc_out = 0;
		aluout_out = 0;
		A_out = 0;
		B_out = 0;
        	inst_out = 0;
		bcond_out = 0;
		dest_out = 0;
		isStall_out = 0;
		is_flush_out = 0;
	end
	
	always @(posedge reset_n)
	begin
		pc_next_out <= 0;
		pc_out <= 0;
		aluout_out <= 0;
		A_out <= 0;
		B_out <= 0;
		inst_out <= {`NOP_OP,12'b0};
		bcond_out <= 0;
		dest_out <= 0;
		isStall_out <= 0;
		is_flush_out <= 0;
	end
	
	always @(posedge clk) 
	begin
		pc_next_out <= pc_next_in;
		pc_out <= pc_in;
		aluout_out <= aluout_in;
		A_out <= A_in;
		B_out <= B_in;
       		inst_out <= inst_in;    
		bcond_out <= bcond_in;
		dest_out <= dest_in;
		isStall_out <= isStall_in;
		is_flush_out <= is_flush_in;
	end

endmodule

				
module MEMWB(pc_in, mdr_in, aluout_in, inst_in, dest_in, isStall_in, is_flush_in,A_in,
A_out, pc_out, mdr_out, aluout_out, inst_out, dest_out, isStall_out, is_flush_out, reset_n, clk);
    // TODO: IDEX latch를 컨트롤 할 control unit input을 받아야함
	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] pc_in;
    	input [`WORD_SIZE-1:0] mdr_in;
	input [`WORD_SIZE-1:0] aluout_in;
	input [`WORD_SIZE-1:0] inst_in;
	input [1:0] dest_in;
	input isStall_in;
	input is_flush_in;
	input [`WORD_SIZE-1:0] A_in;
	output reg [`WORD_SIZE-1:0] A_out;
	output reg [`WORD_SIZE-1:0] pc_out;
	output reg [`WORD_SIZE-1:0] mdr_out;
    	output reg [`WORD_SIZE-1:0] aluout_out;
	output reg [`WORD_SIZE-1:0] inst_out;
	output reg [1:0] dest_out;
	output reg isStall_out;
	output reg is_flush_out;

	initial begin
		A_out = 0;
		pc_out = 0;
		mdr_out = 0;
		aluout_out = 0;
		inst_out = 0;
		dest_out = 0;
		isStall_out = 0;
		is_flush_out = 0;
	end
	
	always @(posedge reset_n)
	begin
		A_out <= 0;
		pc_out <= 0;
		mdr_out <= 0;
        	aluout_out <= 0;
		inst_out <= {`NOP_OP,12'b0};
		dest_out <= 0;
		isStall_out <= 0;
		is_flush_out <= 0;
	end
	
	always @(posedge clk) 
	begin
		A_out <= A_in;
		pc_out <= pc_in;
		mdr_out <= mdr_in;
        	aluout_out <= aluout_in;
		inst_out <= inst_in;
		dest_out <= dest_in;
		isStall_out <= isStall_in;
		is_flush_out <= is_flush_in;
	end
endmodule

				