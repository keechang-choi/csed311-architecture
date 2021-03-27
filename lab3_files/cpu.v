`include "opcodes.v" 	   


module cpu (readM, writeM, address, data, ackOutput, inputReady, reset_n, clk);
	output reg readM;									
	output reg writeM;								
	output reg [`WORD_SIZE-1:0] address;	
	inout [`WORD_SIZE-1:0] data;		
	input ackOutput;								
	input inputReady;								
	input reset_n;									
	input clk;			


	reg [`WORD_SIZE-1:0]pc;
	wire [7:0] immediate_value;
	wire [3:0] opcode;
	wire [5:0] funcode;
	wire [1:0] write_reg;
	reg bcond;
	// alu input & output
	wire [`WORD_SIZE-1:0] alu_input_1;
	wire [`WORD_SIZE-1:0] alu_input_2;
	wire [`WORD_SIZE-1:0] alu_output;
	reg [5:0] alu_op;
	wire [11:0] target_address;

	//  control_unit output
	wire alu_src;
	wire reg_write;
	wire mem_read;
	wire mem_to_reg;
	wire mem_write;
	wire jp;
	wire branch;

	// register input & output
	reg [`WORD_SIZE-1:0] write_data;
	wire [1:0] read1;
	wire [1:0] read2;
	wire [`WORD_SIZE-1:0] read_out1;
	wire [`WORD_SIZE-1:0] read_out2;
	wire [15:0] extended_imm_value;

	reg [`WORD_SIZE-1:0] inst;
	reg mem_rw;

	initial begin
		mem_rw = 0;
		inst = 0;
		pc = 0;
	end

	assign immediate_value = inst[7:0];
	assign read1 = inst[11:10];
	assign read2 = inst[9:8];
	//assign write_reg = (opcode == `JAL_OP)? 2'b10 : inst[7:6];
	MUX4 mux_write_reg(.in0(inst[7:6]), .in1(2'b10), .in2(inst[9:8]), .in3(inst[9:8]), 
		.ctrl( { (alu_src),(opcode==`JAL_OP)} ), 
		.out(write_reg));
	assign opcode = inst[15:12];
	assign funcode = (alu_src == 1) ? alu_op : inst[5:0];
	assign target_address = inst[11:0];
	assign extended_imm_value = {{8{immediate_value[7]}}, immediate_value[7:0]};


	register_file register_file_module(
		.read_out1(read_out1),
		.read_out2(read_out2),
		.read1(read1),
		.read2(read2),
		.write_reg(write_reg),
		.write_data(write_data),
		.reg_write(reg_write),
		.clk(clk));

	assign alu_input_1 = read_out1;
	assign alu_input_2 = alu_src > 0 ? extended_imm_value : read_out2;
	// edit after implemeting data memory & jump


	assign data = mem_rw ? read_out2 : 16'bz;

	alu alu_module(.alu_input_1(alu_input_1),
  					.alu_input_2(alu_input_2),
					.func_code(funcode),
					.alu_output(alu_output));



	control_unit control_unit_module(
		.instr(inst),
		.alu_src(alu_src),
		.reg_write(reg_write),
		.mem_read(mem_read),
		.mem_to_reg(mem_to_reg),
		.mem_write(mem_write),
		.jp(jp),
		.branch(branch));

	always @(*) begin
		case (opcode)
		`ADI_OP: alu_op = `FUNC_ADD;
		`ORI_OP: alu_op = `FUNC_ORR;  
		`LWD_OP: alu_op = `FUNC_ADD; 
		`SWD_OP: alu_op = `FUNC_ADD;
		`BNE_OP: alu_op = `FUNC_SUB;
		`BEQ_OP: alu_op = `FUNC_SUB;
		endcase
	end
		// assign write_data = mem_to_reg > 0 ? data :((opcode==`JAL_OP) ? pc+1 : alu_output);//mem_to_reg > 0 ? alu_output;

	always @(*) begin
		if(mem_to_reg) begin
			if(inputReady) begin
				readM = 0;
				write_data = data;
			end
		end
		else begin
			write_data = (opcode ==`JAL_OP) ? pc+1 : alu_output;
		end
	end

	
	// fetch instruction
	always @(*) begin
		//$display("~~@@@@read_out1 : %d", read_out1);
		//$display("~~@@@@write_data : %d", write_data);
	end

	// push data from memory to register
	always @(*) begin
		if(inputReady == 1 )begin
			readM = 0;
			//read data(inst) remains for a short time.
			//save it to inst
			if(address < 30) begin
				inst = data;
			end
			else begin
				inst = 0;
			end
		end
	end

	// reset writeM
	always @(*) begin
		if(ackOutput == 1)begin
			writeM = 0;
			mem_rw = 0;
		end
	end

	always @(*) begin
		// jump cases. Needs to change pc 
	end
	always @(posedge reset_n)
	begin
		pc <= 0 ;
	end
	
	// load instruction
	always @(posedge clk) begin
		// do something
		$display("pppppppppppppppppppppppppppppppppp");
		$display("!!!!! pc : %d ", pc);
		$display("@@@@write_data : %d", write_data);
		$display("@@@@inst : %b",inst);
		$display("@@@@alu : %d %d %d ",alu_input_1, alu_input_2,alu_output);

		if(reset_n) begin
			address <= pc;
			readM <= 1;
		end
	end

	// load data from memory to register
	always @(negedge clk) begin
		$display("nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
		$display("@@@@write_data : %d", write_data);
		$display("@@@@inst : %b",inst);
		$display("@@@@alu : %d %d %d ",alu_input_1, alu_input_2,alu_output);

		if(mem_read > 0) begin
			address <= alu_output;
			readM <= 1;
		end
	end

	// write to memory 
	always @(negedge clk)  begin
		if(mem_write > 0) begin
			address <= alu_output;
			writeM <= 1;
			mem_rw <= 1;
		end
	end
	// pc value not correct after 5 cycle
	// need to use pc module and mux
	always @(negedge clk) begin
		// if(opcode == `JMP_OP) begin
		// 	pc <=  target_address;
		// end
		// else if(opcode == `JAL_OP)begin
		// 	pc <= target_address;
		// //	write_reg <= 2;
		// //	write_data <= pc + 1;
		// end
		// else if(opcode ==`JPR_OP) begin
		// 	pc <= read_out1;
		// end
		// else if(branch & bcond) begin
		// 	pc <= pc + immediate_value +1;
		// end
		// else begin
			pc <= pc+1;
		// end
	end
/*
	always @(*) begin
		if(clk != 0 && !(opcode == `JAL_OP || opcode ==`JRL_OP)) begin
			write_data =  data;
		end
	end
*/
	always @(*) begin
		case (opcode)
		`BNE_OP: bcond = alu_output == 0 ? 0 : 1;
		`BEQ_OP: bcond = alu_output == 0 ? 1 : 0;  
		`BGZ_OP: bcond = read1 > 0 ? 1 : 0;
		`BLZ_OP: bcond = read1 < 0 ? 1 : 0;
		endcase
	end

																																					  
endmodule		

module MUX2(in0, in1, ctrl, out);
	input [`WORD_SIZE-1:0] in0;
	input [`WORD_SIZE-1:0] in1;
	input ctrl;
	output [`WORD_SIZE-1:0] out;

	assign out = ctrl ? in1: in0;
endmodule

module MUX4(in0, in1,in2, in3, ctrl, out);
	input [`WORD_SIZE-1:0] in0;
	input [`WORD_SIZE-1:0] in1;
	input [`WORD_SIZE-1:0] in2;
	input [`WORD_SIZE-1:0] in3;
	
	input [1:0] ctrl;
	output [`WORD_SIZE-1:0] out;

	assign out = ctrl[1] ? (ctrl[0] ? in3 : in2) : (ctrl[0] ? in1 : in0);
endmodule


module PC(PC_in, PC_out, reset_n, clk);
	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] PC_in;
	output reg [`WORD_SIZE-1:0] PC_out;

	initial begin
		PC_out = 0;
	end
	
	always @(posedge reset_n)
	begin
		PC_out <= 0 ;
	end
	
	always @(posedge clk) 
	begin
		PC_out <= PC_in;
	end
endmodule


					  																		  