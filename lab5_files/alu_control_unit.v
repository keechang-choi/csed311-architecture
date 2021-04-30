`include "opcodes.v"

module alu_control_unit(funct, opcode, ALUOp, funcCode, branchType);
  input  ALUOp;
  input [5:0] funct;
  input [3:0] opcode;

  output reg [3:0] funcCode;
  output reg [1:0] branchType;

   //TODO: implement ALU control unit
  always @(*) begin
   	case (ALUOp)
		0 : begin
       			case (opcode)
      				`ADI_OP: funcCode = `FUNC_ADD;
      				`ORI_OP: funcCode = `FUNC_ORR;  
      				`LWD_OP: funcCode = `FUNC_ADD; 
      				`SWD_OP: funcCode = `FUNC_ADD;
      				`BNE_OP: begin
        				funcCode = `FUNC_SUB;
        				branchType = 0;
      				end 
      				`BEQ_OP: begin
        				funcCode = `FUNC_SUB;
      					branchType = 1;
      				end
      				`BGZ_OP: begin
        				branchType = 2;
      				end
      				`BLZ_OP: begin
        				branchType = 3;
      				end
      				// `LHI_OP: funcCode <= `FUNC_SHL;
      				default: funcCode = `FUNC_ADD;
      			endcase
		end
		1 : begin
			funcCode = funct[3:0];
		end
		default : begin
			funcCode = `FUNC_ADD;
		end
    	endcase
  end

endmodule