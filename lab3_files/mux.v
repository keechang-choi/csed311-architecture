`include "opcodes.v" 	   


module MUX2(in0, in1, ctrl, out);
	input [`WORD_SIZE-1:0] in0;
	input [`WORD_SIZE-1:0] in1;
	input ctrl;
	output [`WORD_SIZE-1:0] out;

	assign out = ctrl ? in1: in0;
endmodule

module MUX4(in0, in1,in2, in3, ctrl, out);
	input [`WORD_SIZE-1:0] in0;
	input [`WORD_SIZE-1:0] in1;
	input [`WORD_SIZE-1:0] in2;
	input [`WORD_SIZE-1:0] in3;
	
	input [1:0] ctrl;
	output [`WORD_SIZE-1:0] out;

	assign out = ctrl[1] ? (ctrl[0] ? in3 : in2) : (ctrl[0] ? in1 : in0);
endmodule