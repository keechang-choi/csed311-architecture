`include "opcodes.v"

`define	NumBits	16

module alu (alu_input_1, alu_input_2, func_code, alu_output);
	input [`NumBits-1:0] alu_input_1;
	input [`NumBits-1:0] alu_input_2;
	input [2:0] func_code;
	output reg [`NumBits-1:0] alu_output;

	always @(*)
	begin
		case (func_code)
		3'b000: alu_output = alu_input_1 + alu_input_2;
		3'b001: alu_output = alu_input_1 - alu_input_2;
		3'b010: alu_output = alu_input_1 & alu_input_2;
		3'b011: alu_output = alu_input_1 | alu_input_2;
		3'b100: alu_output = ~alu_input_1;
		3'b101: alu_output = ~alu_input_1 + 1;
		3'b110: alu_output = alu_input_1 << 1;
		3'b111: alu_output = alu_input_1 >> 1;
		endcase
	end

endmodule