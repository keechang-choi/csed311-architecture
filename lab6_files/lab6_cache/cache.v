`define WORD_SIZE 16

module cache (clk, reset_n, read_c, write_c, ready_m, address_c, data_c, data_m, address_m, read_m, write_m, ready_c, num_access, num_hit);
	input clk;
	input reset_n;
	input read_c;
	input write_c;
	input ready_m;
	
	input [`WORD_SIZE-1:0] address_c;

	output [`WORD_SIZE-1:0] data_c;
	reg [`WORD_SIZE-1:0] data_c;
	inout [`WORD_SIZE * 4 -1:0] data_m;

	output [`WORD_SIZE-1:0] address_m;
	reg [`WORD_SIZE-1:0] address_m;
	output read_m;
	reg read_m;
	output write_m;
	output reg ready_c;
	output reg [`WORD_SIZE-1:0] num_access;
	output reg [`WORD_SIZE-1:0] num_hit;

	
	reg [4*`WORD_SIZE-1:0] cache_lines[3:0];
	reg [`WORD_SIZE-1-4:0] tag_lines[3:0];
	reg [3:0] valid;
	reg [3:0] dirty;


	wire [1:0] index;
	wire [`WORD_SIZE-1-4:0] tag;
	wire [1:0] bo;
	
	reg hit;
	
	
	assign bo = address_c[1:0];
	assign index = address_c[3:2];
	assign tag = address_c[`WORD_SIZE-1:4];
	
	
	// assign hit = valid[index] && tag_lines[index];


	always @(posedge clk) begin
		if(!reset_n) begin
			hit <= 0;
			data_c <= 0;
			num_hit <= 0;
			num_hit <= 0;
			ready_c <= 0;
			read_m <= 0;
			address_m <= 0;
			cache_lines[0] <= 0;
			cache_lines[1] <= 0;
			cache_lines[2] <= 0;
			cache_lines[3] <= 0;

			tag_lines[0] <= 0;
			tag_lines[1] <= 0;
			tag_lines[2] <= 0;
			tag_lines[3] <= 0;

			valid[0] <= 0;
			valid[1] <= 0;
			valid[2] <= 0;
			valid[3] <= 0;

			dirty[0] <= 0;
			dirty[1] <= 0;
			dirty[2] <= 0;
			dirty[3] <= 0;
		end
	end

	always @(posedge clk ) begin
		hit <= valid[index] && (tag == tag_lines[index]);
	end

	always @(posedge clk) begin
		if(write_c) begin
			if (hit) begin
				cache_lines[index][`WORD_SIZE * signed'(bo+1) -1 -: `WORD_SIZE ] <= data_m[`WORD_SIZE-1:0];
				valid[index] = 1;
			end
			if (!hit) begin
			end
		end
		if(read_c) begin
			if (hit) begin
				$display("###### read hit");
				data_c <= cache_lines[index][`WORD_SIZE * (bo) +: `WORD_SIZE];
				ready_c <= 1 ;
				num_access <= num_access + 1;
				read_m <= 0;
			end
			else begin
				$display("###### read miss");
				if(ready_m) begin
					cache_lines[index][`WORD_SIZE*1-1 : `WORD_SIZE*0] <= data_m[`WORD_SIZE*1-1 : `WORD_SIZE*0];
					cache_lines[index][`WORD_SIZE*2-1 : `WORD_SIZE*1] <= data_m[`WORD_SIZE*2-1 : `WORD_SIZE*1];
					cache_lines[index][`WORD_SIZE*3-1 : `WORD_SIZE*2] <= data_m[`WORD_SIZE*3-1 : `WORD_SIZE*2];
					cache_lines[index][`WORD_SIZE*4-1 : `WORD_SIZE*3] <= data_m[`WORD_SIZE*4-1 : `WORD_SIZE*3];
					tag_lines[index] <= tag;
					data_c <= data_m[`WORD_SIZE * signed'(bo) +: `WORD_SIZE];
					ready_c <= 1;
					read_m <= 0;
				end
				else begin
					read_m <= 1;
					address_m <= address_c;
					ready_c <= 0;
				end
			end
		end
		else begin
			ready_c <= 0;
		end
		
	end
	// always @(*) begin
	// 	read_c
	// 	write_c
	// 	ready_c

	// end

endmodule