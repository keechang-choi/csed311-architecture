`include "opcodes.v"

module control_unit(opcode, func_code, clk, reset_n, pc_write_cond, pc_write, i_or_d, mem_read, mem_to_reg, mem_write, ir_write, pc_to_reg, pc_src, halt, wwd, new_inst, reg_write, alu_src_A, alu_src_B, alu_op);
  input [3:0] opcode;
  input [5:0] func_code;
  input clk;
  input reset_n;

  output reg pc_write_cond, pc_write, i_or_d, mem_read, mem_to_reg, mem_write, ir_write, pc_src;
  //additional control signals. pc_to_reg: to support JAL, JRL. halt: to support HLT. wwd: to support WWD. new_inst: new instruction start
  output reg pc_to_reg, halt, wwd, new_inst;
  output reg [1:0] alu_src_B;
  output reg  reg_write, alu_src_A;
  output reg alu_op;


   //TODO: implement control unit
  	reg [3:0] state;
  	parameter s_IF = 4'd0;
	parameter s_ID = 4'd1;	
  	parameter s_MEMAD = 4'd2;
	parameter s_EXR = 4'd3;	
  	parameter s_EXI = 4'd4;
	parameter s_BR = 4'd5;	
	parameter s_J = 4'd6;		
	parameter s_JL = 4'd7;	
	parameter s_HLT = 4'd8;	
	parameter s_WWD = 4'd9;	
	parameter s_MEMR = 4'd10;	
	parameter s_MEMW = 4'd11;	
	parameter s_WBM = 4'd12;
	parameter s_WBA = 4'd13;		

	initial begin
		//need to reset?? 
		pc_write_cond <= 0;
		pc_write <= 1;
		i_or_d <= 0;
		mem_read <= 1;
		mem_to_reg <= 0;
		mem_write <= 0;
		ir_write <= 1;
		pc_src <= 0;

		pc_to_reg <= 0;
		halt <= 0;
		wwd <= 0;
		new_inst <= 1;

		reg_write <= 0;
		alu_src_A <= 0; // pc
	 	alu_src_B <= 2'b01;  // 4

		alu_op <= 0 ;
		state = s_IF;
	end

	always @(posedge clk) begin
		$display("~~~~~~state : %d", state);
		$display("~~~~~~opcode : %b", opcode);
		if(!reset_n) begin
			
			state = s_IF;
		end
		else begin
		case(state)
			s_IF : begin
				pc_write_cond <= 0;
				pc_write <= 1;
				i_or_d <= 0;
				mem_read <= 1;
				mem_to_reg <= 0;
				mem_write <= 0;
				ir_write <= 1;
				pc_src <= 0;

				pc_to_reg <= 0;
				halt <= 0;
				wwd <= 0;
				new_inst <= 1;

				reg_write <= 0;
				alu_src_A <= 0; // pc
	 			alu_src_B <= 2'b01;  // 1

				alu_op <= 0 ;

				state <= s_ID;
			end
			s_ID : begin
				pc_write_cond <= 0;
				pc_write <= 0;
				i_or_d <= 0;
				mem_read <= 0;
				mem_to_reg <= 0;
				mem_write <= 0;
				ir_write <= 0;
				pc_src <= 0;

				pc_to_reg <= 0;
				halt <= 0;
				wwd <= 0;
				new_inst <= 0;

				reg_write <= 0;
				alu_src_A <= 0; // pc
	 			alu_src_B <= 2'b10;  // imm

				alu_op <= 0 ;
				
				//case
				if(opcode==`JAL_OP ||
				(opcode==`JRL_OP&& func_code == `INST_FUNC_JRL)) begin
					state <= s_JL;

				end
				else if(opcode==`JMP_OP || opcode==`JPR_OP) begin
					state <= s_J;
				end
				else if(opcode==`BNE_OP || opcode==`BEQ_OP ||
				opcode==`BGZ_OP ||opcode==`BLZ_OP) begin
					state <= s_BR;

				end
				else if(opcode==`ADI_OP ||opcode==`ORI_OP || opcode==`LHI_OP) begin
					state <= s_EXI;
				end
				else if(opcode==`WWD_OP && func_code == `INST_FUNC_WWD) begin
					state <= s_WWD;
				end
				else if(opcode==`HLT_OP && func_code == `INST_FUNC_WWD) begin
					state <= s_HLT;
				end
				else if((opcode==`LWD_OP ) || (opcode==`SWD_OP )) begin
					state <= s_MEMAD;
				end
				//  alu R type
				else begin
					state <= s_EXR;
				end
				

			end
			s_MEMAD : begin
				pc_write_cond <= 0;
				pc_write <= 0;
				i_or_d <= 0;
				mem_read <= 0;
				mem_to_reg <= 0;
				mem_write <= 0;
				ir_write <= 0;
				pc_src <= 0;

				pc_to_reg <= 0;
				halt <= 0;
				wwd <= 0;
				new_inst <= 0;

				reg_write <= 0;
				alu_src_A <= 1; 
	 			alu_src_B <= 2'b10; // imm

				alu_op <= 0 ;
				if(opcode == `LWD_OP) begin
					state <= s_MEMR;
				end
				else begin
					state <= s_MEMW;
				end
			end
			s_MEMR : begin
				pc_write_cond <= 0;
				pc_write <= 0;
				i_or_d <= 1;
				mem_read <= 1;
				mem_to_reg <= 0;
				mem_write <= 0;
				ir_write <= 0;
				pc_src <= 0;

				pc_to_reg <= 0;
				halt <= 0;
				wwd <= 0;
				new_inst <= 0;

				reg_write <= 0;
				alu_src_A <= 0; 
	 			alu_src_B <= 2'b00;

				alu_op <= 0 ;

				state <= s_WBM;
			end
			s_MEMW : begin
				pc_write_cond <= 0;
				pc_write <= 0;
				i_or_d <= 1;
				mem_read <= 0;
				mem_to_reg <= 0;
				mem_write <= 1;
				ir_write <= 0;
				pc_src <= 0;

				pc_to_reg <= 0;
				halt <= 0;
				wwd <= 0;
				new_inst <= 0;

				reg_write <= 0;
				alu_src_A <= 0; 
	 			alu_src_B <= 2'b00;

				alu_op <= 0 ;

				state <= s_IF;
			end
			s_WBM : begin
				pc_write_cond <= 0;
				pc_write <= 0;
				i_or_d <= 0;
				mem_read <= 0;
				mem_to_reg <= 1;
				mem_write <= 0;
				ir_write <= 0;
				pc_src <= 0;

				pc_to_reg <= 0;
				halt <= 0;
				wwd <= 0;
				new_inst <= 0;

				reg_write <= 1;
				alu_src_A <= 0; 
	 			alu_src_B <= 2'b00;

				alu_op <= 0 ;

				state <= s_IF;
			end
			s_EXR : begin
				pc_write_cond <= 0;
				pc_write <= 0;
				i_or_d <= 0;
				mem_read <= 0;
				mem_to_reg <= 0;
				mem_write <= 0;
				ir_write <= 0;
				pc_src <= 0;

				pc_to_reg <= 0;
				halt <= 0;
				wwd <= 0;
				new_inst <= 0;

				reg_write <= 0;
				alu_src_A <= 1; 
	 			alu_src_B <= 2'b00;

				alu_op <= 0; // 0 for func

				state <= s_WBA;
			end
			s_EXI : begin
				pc_write_cond <= 0;
				pc_write <= 0;
				i_or_d <= 0;
				mem_read <= 0;
				mem_to_reg <= 0;
				mem_write <= 0;
				ir_write <= 0;
				pc_src <= 0;

				pc_to_reg <= 0;
				halt <= 0;
				wwd <= 0;
				new_inst <= 0;

				reg_write <= 0;
				alu_src_A <= 1; 
	 			alu_src_B <= 2'b10;

				alu_op <= 1; // alu op for ADI ORI ...
				state <= s_WBA;
			end
			s_WBA : begin
				pc_write_cond <= 0;
				pc_write <= 0;
				i_or_d <= 0;
				mem_read <= 0;
				mem_to_reg <= 1;
				mem_write <= 0;
				ir_write <= 0;
				pc_src <= 0;

				pc_to_reg <= 0;
				halt <= 0;
				wwd <= 0;
				new_inst <= 0;

				reg_write <= 1;
				alu_src_A <= 0; 
	 			alu_src_B <= 2'b00;

				alu_op <= 0 ;
				state <= s_IF;
			end
			s_BR : begin
				pc_write_cond <= 1; // update condition
				pc_write <= 0;
				i_or_d <= 0;
				mem_read <= 0;
				mem_to_reg <= 0;
				mem_write <= 0;
				ir_write <= 0;
				pc_src <= 1; // from ALU output register

				pc_to_reg <= 0;
				halt <= 0;
				wwd <= 0;
				new_inst <= 0;

				reg_write <= 0;
				alu_src_A <= 1; // next PC val is calculated on ID 
	 			alu_src_B <= 2'b00;

				alu_op <= 1; // Branch ALU OP

				state <= s_IF;
			end
			s_J : begin
				pc_write_cond <= 0;
				pc_write <= 1; // jump write
				i_or_d <= 0;
				mem_read <= 0;
				mem_to_reg <= 0;
				mem_write <= 0;
				ir_write <= 0;
				// how to do jpr ??
				pc_src <= 1; // from ALU register? jmp case : dont care

				pc_to_reg <= 0;
				halt <= 0;
				wwd <= 0;
				new_inst <= 0;

				reg_write <= 0;
				alu_src_A <= 0;
	 			alu_src_B <= 2'b00;

				alu_op <= 0;
				state <= s_IF;
			end
			s_JL : begin
				pc_write_cond <= 0;
				pc_write <= 1; // jump write
				i_or_d <= 0;
				mem_read <= 0;
				mem_to_reg <= 1;
				mem_write <= 0;
				ir_write <= 0;
				pc_src <= 1; // from ALU register? jmp, jpr case : dont care

				pc_to_reg <= 1;
				halt <= 0;
				wwd <= 0;
				new_inst <= 0;

				reg_write <= 1;
				alu_src_A <= 0;
	 			alu_src_B <= 2'b00;

				alu_op <= 0;

				state <= s_IF;
			end
			s_HLT : begin
				pc_write_cond <= 0;
				pc_write <= 0;
				i_or_d <= 0;
				mem_read <= 0;
				mem_to_reg <= 0;
				mem_write <= 0;
				ir_write <= 0;
				pc_src <= 0;

				pc_to_reg <= 0;
				halt <= 1;
				wwd <= 0;
				new_inst <= 0;

				reg_write <= 0;
				alu_src_A <= 0; 
	 			alu_src_B <= 2'b00;

				alu_op <= 0 ;
				state <= s_IF;
			end
			s_WWD : begin
				pc_write_cond <= 0;
				pc_write <= 0;
				i_or_d <= 0;
				mem_read <= 0;
				mem_to_reg <= 0;
				mem_write <= 0;
				ir_write <= 0;
				pc_src <= 0;

				pc_to_reg <= 0;
				halt <= 0;
				wwd <= 1;
				new_inst <= 0;

				reg_write <= 0;
				alu_src_A <= 0; 
	 			alu_src_B <= 2'b00;

				alu_op <= 0 ;
				state <= s_IF;
			end

			//??
			default : begin
			end
		endcase
		end
	end


endmodule
