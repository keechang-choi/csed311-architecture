`include "opcodes.v" 	   

module cpu (readM, writeM, address, data, ackOutput, inputReady, reset_n, clk);
	output readM;									
	output writeM;								
	output [`WORD_SIZE-1:0] address;	
	inout [`WORD_SIZE-1:0] data;		
	input ackOutput;								
	input inputReady;								
	input reset_n;									
	input clk;			


	reg pc;
	reg immediate_value;
	reg opcode;
	reg funcode;
	// alu input & output
	wire alu_input_1;
	wire alu_input_2;
	wire alu_output;

	//  control_unit output
	wire alu_src;
	wire reg_write;
	wire mem_read;
	wire mem_to_reg;
	wire mem_write;
	wire jp;
	wire branch;

	// register input & output
	reg write_data;
	reg read1;
	reg read2;
	wire read_out1;
	wire read_out2;


	assign alu_input_1 = read_out1;
	assign alu_input2 = alu_src > 0 ? immediate_value : read_out2;
	assign alu_output = address;
	assign write_data = data;

	initial begin
		// need?
		pc = 0;
	end
	

	always @(posedge clk) begin
		pc <= pc +1;
		if(inputReady) begin			
			immediate_value <= data[7:0];
			read1 <= data[11:10];
			read2 <= data[9:8];
			write_reg <= data[7:6];
			op_code <= data[15:12];
			funcode <= data[5:0];
		end
	end

	always @(*)  begin

	end

	alu alu_module(.alu_input_1(alu_input_1),
  					.alu_input_2(alu_input_2),
					.func_code(funcode),
					.alu_output(alu_output));

	register_file register_file_module(
		.read_out1(read_out1),
		.read_out2(read_out2),
		.read1(read1),
		.read2(read2),
		.write_reg(data[7:6]),
		.write_data(write_data),
		.reg_write(reg_write),
		.clk(clk));

	control_unit control_unit_module(
		.instr(opcode),
		.alu_src(alu_src),
		.reg_write(reg_write),
		.mem_read(mem_read),
		.mem_to_reg(mem_to_reg),
		.mem_write(mem_write),
		.jp(jp),
		.branch(branch));

	

																																					  
endmodule							  																		  