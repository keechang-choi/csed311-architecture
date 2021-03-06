`include "alu_func.v"
module ALU_bitwise #(parameter data_width = 16) (
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
	`FUNC_NOT : begin 
		C = ~A;
		OverflowFlag = 0;
	end
	`FUNC_AND : begin 
		C = A & B;
		OverflowFlag = 0;
	end
	`FUNC_OR : begin 
		C = A | B;
		OverflowFlag = 0;
	end
	`FUNC_NAND : begin 
		C = ~(A & B);
		OverflowFlag = 0;
	end
	`FUNC_NOR : begin 
		C = ~(A | B);
		OverflowFlag = 0;
	end
	`FUNC_XOR : begin 
		C = A ^ B;
		OverflowFlag = 0;
	end
	`FUNC_XNOR : begin 
		C = A ^~ B;
		OverflowFlag = 0;
	end
	default : begin
		C = A;
		OverflowFlag = 1;
	end
	endcase
end

endmodule

