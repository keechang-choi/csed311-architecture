module cache (clk, reset_n, read_c, write_c, ready_m, address_c, data_c, data_m, address_m, read_m, write_m, ready_c, num_access, num_hit);
	input clk;
	input reset_n;
	input read_c;
	input write_c;
	input ready_m;
	input [`WORD_SIZE-1:0] address_c;

	inout [`WORD_SIZE-1:0] data_c;
	inout [`WORD_SIZE-1:0] data_m;

	output [`WORD_SIZE-1:0] address_m;
	output read_m;
	output write_m;
	output reg ready_c;
	output reg [`WORD_SIZE-1:0] num_access;
	output reg [`WORD_SIZE-1:0] num_hit;

	
	reg [4*`WORD_SIZE-1:0] cache_lines[3:0];

	reg [3:0] valid;
	reg [3:0] dirty;

	wire [1:0] index;
	wire [`WORD_SIZE-1-4:0] tag;
	wire [1:0] bo;
	
	assign bo = address_c[1:0];
	assign index = address_c[3:2];
	assign tag = address_c[`WORD_SIZE-1:4];
	
		

end module