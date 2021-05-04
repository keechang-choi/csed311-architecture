`include "opcodes.v" 
`define NumBits 16

module alu (A, B, func_code, branch_type, alu_out, overflow_flag, bcond);

	input [`WORD_SIZE-1:0] A;
	input [`WORD_SIZE-1:0] B;
	input [2:0] func_code;
	input [1:0] branch_type; 

	output reg [`WORD_SIZE-1:0] alu_out;
	output reg overflow_flag; 
	output reg bcond;

	//TODO: implement alu 
	always @(*) begin
		case (func_code)
		`FUNC_ADD: begin
         alu_out = A + B;
         overflow_flag = (~A[`NumBits-1] & ~B[`NumBits-1] & alu_out[`NumBits-1]) | (A[`NumBits-1] & B[`NumBits-1] & ~alu_out[`NumBits-1]);
    end  
		`FUNC_SUB: begin
         alu_out = A - B;
         overflow_flag = (~A[`NumBits-1] & B[`NumBits-1] & alu_out[`NumBits-1]) | (A[`NumBits-1] & ~B[`NumBits-1] & ~alu_out[`NumBits-1]);	
    end
      	`FUNC_AND: alu_out = A & B;
		`FUNC_ORR: alu_out = A | B;
		`FUNC_NOT: alu_out = ~A;
		`FUNC_TCP: alu_out = ~A + 1;
		`FUNC_SHL: alu_out = A << 1;
		`FUNC_SHR: alu_out = A >> 1;
    default: begin
         overflow_flag = 0;
         alu_out = A;
    end 
		endcase
	end


    always @(*) begin
		case (branch_type)
		0: bcond = signed'(alu_out) == 0 ? 0 : 1; // BNE
		1: bcond = signed'(alu_out) == 0 ? 1 : 0; // BEQ
		2: bcond = signed'(A) > 0 ? 1 : 0; // BGZ
		3: bcond = signed'(A) < 0 ? 1 : 0; // BLZ
		default : bcond = 0;
		endcase
	end	

endmodule