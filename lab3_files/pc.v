`include "opcodes.v" 	   

module PC(pc_in, pc_out, reset_n, clk);
	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] pc_in;
	output reg [`WORD_SIZE-1:0] pc_out;

	initial begin
		pc_out = -1;
	end
	
	always @(posedge reset_n)
	begin
		pc_out <= -1 ;
	end
	
	always @(posedge clk) 
	begin
		pc_out <= pc_in;
	end
endmodule

					  			