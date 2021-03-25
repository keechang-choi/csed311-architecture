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
	// alu input & output
	wire [`WORD_SIZE-1:0] alu_input_1;
	wire [`WORD_SIZE-1:0] alu_input_2;
	wire [`WORD_SIZE-1:0] alu_output;

	//  control_unit output
	wire alu_src;
	wire reg_write;
	wire mem_read;
	wire mem_to_reg;
	wire mem_write;
	wire jp;
	wire branch;

	// register input & output
	wire [`WORD_SIZE-1:0] write_data;
	wire [1:0] read1;
	wire [1:0] read2;
	wire [`WORD_SIZE-1:0] read_out1;
	wire [`WORD_SIZE-1:0] read_out2;

	reg [`WORD_SIZE-1:0] inst;

	initial begin
		inst = 0;
		pc = 0;
	end

	assign immediate_value = inst[7:0];
	assign read1 = inst[11:10];
	assign read2 = inst[9:8];
	assign write_reg = inst[7:6];
	assign opcode = inst[15:12];
	assign funcode = inst[5:0];

	assign alu_input_1 = read_out1;
	assign alu_input_2 = alu_src > 0 ? immediate_value : read_out2;
	// edit after implemeting data memory & jump
	assign write_data = mem_to_reg > 0 ? alu_output : pc;

	alu alu_module(.alu_input_1(alu_input_1),
  					.alu_input_2(alu_input_2),
					.func_code(funcode),
					.alu_output(alu_output));

	register_file register_file_module(
		.read_out1(read_out1),
		.read_out2(read_out2),
		.read1(read1),
		.read2(read2),
		.write_reg(write_reg),
		.write_data(write_data),
		.reg_write(reg_write),
		.clk(clk));

	control_unit control_unit_module(
		.instr(inst),
		.alu_src(alu_src),
		.reg_write(reg_write),
		.mem_read(mem_read),
		.mem_to_reg(mem_to_reg),
		.mem_write(mem_write),
		.jp(jp),
		.branch(branch));


	
	// fetch instruction
	always @(*) begin

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
		if(reset_n) begin
			address <= pc;
			readM <= 1;
		end
	end

	// load data from memory to register
	always @(negedge clk) begin
		$display("@@@@alu_src : %d", alu_src);
		$display("@@@@imme : %d",immediate_value);
		$display("@@@@inst : %b",inst);
		$display("@@@@alu : %d %d %d ",alu_input_1, alu_input_2,alu_output);

		if(mem_read > 0) begin
			address <= alu_output;
			readM <= 1;
		end
	end

	// write to memory 
	always @(negedge clk)  begin
		if(mem_write > 0)begin
			address <= alu_output;
			writeM <= 1;
		end
		pc <= pc + 1;
	end

																																					  
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


					  																		  