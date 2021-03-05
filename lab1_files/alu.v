`include "alu_func.v"
`include "alu_addsub.v"
module ALU #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);
// Do not use delay in your implementation.

// You can declare any variables as needed.
/*
	YOUR VARIABLE DECLARATION...
*/

wire [data_width-1:0] C_addsub;
wire OverflowFlag_addsub;
ALU_addsub #(16) alu_addsub (
	.A(A),
	.B(B),	
	.FuncCode(FuncCode),
	.C(C_addsub),
	.OverflowFlag(OverflowFlag_addsub)
);

initial begin
	C = 0;
	OverflowFlag = 0;
end   	

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')
/*
	YOUR ALU FUNCTIONALITY IMPLEMENTATION...
*/
// always(A OR B or FuncCode ? ????, ???? ??? ????? ?? ??? ???. C? ??? ??
// (*)? ?? ???? ??.

always @(*) begin
	case (FuncCode)
	`FUNC_ADD : begin
		C = C_addsub;
		OverflowFlag = OverflowFlag_addsub;
	end
	`FUNC_SUB : begin 
		C = C_addsub;
		OverflowFlag = OverflowFlag_addsub;
	end
	default : begin
		C = A;
		OverflowFlag = 1;
	end
	endcase
end

endmodule

