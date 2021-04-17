`include "opcodes.v"

`define NumBits 16

module alu (A, B, func_code, branch_type, C, overflow_flag, bcond);
   input [`NumBits-1:0] A; //input data A
   input [`NumBits-1:0] B; //input data B
   input [3:0] func_code; //function code for the operation
   input [1:0] branch_type; //branch type for bne, beq, bgz, blz
   output reg [`NumBits-1:0] C; //output data C
   output reg overflow_flag; 
   output reg bcond; //1 if branch condition met, else 0

   //TODO: implement ALU
   always @(*) begin
		case (func_code)
		`FUNC_ADD: begin
         C = A + B;
         overflow_flag = (~A[`NumBits-1] & ~B[`NumBits-1] & C[`NumBits-1]) | (A[`NumBits-1] & B[`NumBits-1] & ~C[`NumBits-1]);
      end  
		`FUNC_SUB: begin
         C = A - B;
         overflow_flag = (~A[`NumBits-1] & B[`NumBits-1] & C[`NumBits-1]) | (A[`NumBits-1] & ~B[`NumBits-1] & ~C[`NumBits-1]);	
      end
      `FUNC_AND: C = A & B;
		`FUNC_ORR: C = A | B;
		`FUNC_NOT: C = ~A;
		`FUNC_TCP: C = ~A + 1;
		`FUNC_SHL: C = A << 1;
		`FUNC_SHR: C = A >> 1;
      default: begin
         overflow_flag = 0;
         C = A;
      end 
		endcase
	end


   always @(*) begin
		case (branch_type)
		0: bcond = C == 0 ? 0 : 1; // BNE
		1: bcond = C == 0 ? 1 : 0; // BEQ
		2: bcond = A > 0 ? 1 : 0; // BGZ
		3: bcond = A < 0 ? 1 : 0; // BLZ
		default : bcond = 0;
		endcase
	end
endmodule