`include "alu_func.v"
module ALU_shift #(parameter data_width = 16) (
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
	`FUNC_LLS : begin
		C = A << 1;
		OverflowFlag = 0 ;
	end
	`FUNC_LRS : begin 
		C = A >> 1;
		OverflowFlag = 0;
	end
	`FUNC_ALS: begin
		C = A <<< 1;
		OverflowFlag = 0;
	end
	`FUNC_ARS: begin
		C = A >>> 1;
		OverflowFlag = 0;
	end
	default : begin
		C = A;
		OverflowFlag = 1;
	end

	endcase
end

endmodule

