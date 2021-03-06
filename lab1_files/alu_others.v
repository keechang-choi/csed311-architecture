`include "alu_func.v"
module ALU_others #(parameter data_width = 16) (
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
	`FUNC_ID : begin
		C = A;
		OverflowFlag = 0 ;
	end
	`FUNC_TCP : begin 
		C = ~A + 16'h1;
		OverflowFlag = 0;
	end
	`FUNC_ZERO: begin
		C = 0;
		OverflowFlag = 0 ;
	end
	default : begin
		C = A;
		OverflowFlag = 1;
	end
	endcase
end

endmodule

