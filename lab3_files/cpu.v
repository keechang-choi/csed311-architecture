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

	wire [`WORD_SIZE-1:0] pc_in;
	wire [`WORD_SIZE-1:0] pc_out;
	wire [`WORD_SIZE-1:0] pc_plus_1;
	wire [`WORD_SIZE-1:0] pc_plus_imm;
	wire [`WORD_SIZE-1:0] pc_jump;

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

	MUX2 mux_pc_jump(.in0( read_out1 ), .in1({pc_out[15:12], target_address}),
			.ctrl( (opcode==`JAL_OP||opcode==`JMP_OP) ),
			.out(pc_jump));
	assign pc_plus_1 = pc_out + 16'b1;
	assign pc_plus_imm = pc_plus_1 + extended_imm_value;

	PC program_counter(.pc_in(pc_in), .pc_out(pc_out), .clk(clk), .reset_n(reset_n));

	MUX4 mux_pc_in(.in0(pc_plus_1), .in1(pc_plus_imm), .in2(pc_jump), .in3(pc_jump),
			.ctrl( {jp, (branch & bcond)} ),
			.out(pc_in));

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
	assign alu_input_2 = (alu_src > 0 && branch != 1)? extended_imm_value : read_out2;


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

	always @(*) begin
		if(mem_to_reg) begin
			if(inputReady) begin
				readM = 0;
				write_data = data;
			end
		end
		else begin
			write_data = (opcode == `JAL_OP) ? pc_plus_1 : ((opcode == `LHI_OP)? extended_imm_value<<8 : alu_output);
		end
	end

	
	always @(*) begin
		if(inputReady == 1 )begin
			readM = 0;
			if(address < 30) begin
				inst = data;
			end
		end
	end

	always @(*) begin
		if(ackOutput == 1)begin
			writeM = 0;
			mem_rw = 0;
		end
	end

	always @(posedge reset_n)
	begin
		pc <= 0 ;
	end
	
	always @(*) begin
		address = pc_out;
		readM = 1;
	end

	always @(negedge clk) begin
		if(mem_read > 0) begin
			address <= alu_output;
			readM <= 1;
		end
	end

	always @(negedge clk)  begin
		if(mem_write > 0) begin
			address <= alu_output;
			writeM <= 1;
			mem_rw <= 1;
		end
	end
	
	always @(*) begin
		case (opcode)
		`BNE_OP: bcond = alu_output == 0 ? 0 : 1;
		`BEQ_OP: bcond = alu_output == 0 ? 1 : 0;  
		`BGZ_OP: bcond = read1 > 0 ? 1 : 0;
		`BLZ_OP: bcond = read1 < 0 ? 1 : 0;
		default : bcond = 0;
		endcase
	end

																																					  
endmodule		



															  