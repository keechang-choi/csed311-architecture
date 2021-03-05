`include "alu_func.v"
module ALU_addsub #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);

initial begin
	C = 0;
	OverflowFlag = 0;
end   	

always @(*) begin
	case (FuncCode)
	`FUNC_ADD : begin
		C = A + B;
		OverflowFlag = (~A[data_width-1] & ~B[data_width-1] & C[data_width-1]) | (A[data_width-1] & B[data_width-1] & ~C[data_width-1]) ;
	end
	`FUNC_SUB : begin 
		C = A - B;
		OverflowFlag = (~A[data_width-1] & B[data_width-1] & C[data_width-1]) | (A[data_width-1] & ~B[data_width-1] & ~C[data_width-1]) ;
	end
	default : begin
		C = A;
		OverflowFlag = 1;
	end
	endcase
end

endmodule

