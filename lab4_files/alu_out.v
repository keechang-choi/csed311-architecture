`include "opcodes.v" 	   

module alu_out(alu_in, alu_out, reset_n, clk);
	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] alu_in;
	output reg [`WORD_SIZE-1:0] alu_out;

	initial begin
		alu_out = 0;
	end
	
	always @(posedge reset_n)
	begin
		alu_out <= 0 ;
	end
	
	always @(posedge clk) 
	begin
        alu_out <= alu_in;    
	end
endmodule

				