`timescale 1ns/1ns
`define WORD_SIZE 16
// data and address word size

`include "datapath.v"

module cpu(clk, reset_n, read_m1, address1, data1, read_m2, write_m2, address2, data2, num_inst, output_port, is_halted, ready_m1, ready_m2);

	input clk;
	input reset_n;

	output read_m1;
	output [`WORD_SIZE-1:0] address1;
	output read_m2;
	output write_m2;
	output [`WORD_SIZE-1:0] address2;

	input [`WORD_SIZE * 4 -1:0] data1;
	inout [4*`WORD_SIZE-1:0] data2;
	input ready_m1;
	input ready_m2;
	output [`WORD_SIZE-1:0] num_inst;
	output [`WORD_SIZE-1:0] output_port;
	output is_halted;



	wire read_c_m1;
	wire read_c_m2;
	wire [`WORD_SIZE-1:0] address_c_1;
	wire [`WORD_SIZE-1:0] address_c_2;
	wire write_c_m2;
	wire ready_c_m1;
	wire ready_c_m2;
	wire [`WORD_SIZE-1:0] data1_c;
	wire [`WORD_SIZE-1:0] data2_c;

	wire dummy1;
	wire dummy2;


	wire [`WORD_SIZE-1:0] data2_dp;

	assign data2_dp = read_c_m2 ? data2_c : 16'bz;
	assign data2_c = write_c_m2 ? data2_dp : 16'bz;


	// TODO: pc input mux;
	// pc도 datapath 안에 있어야하나?
	// cache data_cache_module(
	// 	.clk(clk), 
	// 	.reset_n(reset_n), 
	// 	.read_c(read_c_m2), 
	// 	.write_c(write_c_m2), 
	// 	.ready_m(ready_m2), 
	// 	.address_c(address_c_2), 
	// 	.data_c(data2_c), // TODO: check data connection!!!
	// 	.data_m(data2), // TODO: check data connection!!!

	// 	.address_m(address2), 
	// 	.read_m(read_m2), 
	// 	.write_m(write_m2), 
	// 	.ready_c(ready_c_m2)
	// 	);
	always @(posedge clk ) begin
		$display("@@@@@@@@@@ data1: %b", data1);
	end

	cache inst_cache_module(
		.clk(clk), 
		.reset_n(reset_n), 
		.read_c(read_c_m1), 
		.write_c(0), 
		.ready_m(ready_m1), 
		.address_c(address_c_1), 
		.data_c(data1_c), // TODO: check data connection!!!
		.data_m(data1),	// TODO: check data connection!!!

		.address_m(address1), 
		.read_m(read_m1), 
		.write_m(dummy2), 
		.ready_c(ready_c_m1)
		);
	cache data_cache_module(
		.clk(clk), 
		.reset_n(reset_n), 
		.read_c(read_c_m2), 
		.write_c(write_c_m2), 
		.ready_m(ready_m2), 
		.address_c(address_c_2), 
		.data_c(data2_c), // TODO: check data connection!!!
		.data_m(data2),	// TODO: check data connection!!!

		.address_m(address2), 
		.read_m(read_m2), 
		.write_m(write_m2), 
		.ready_c(ready_c_m2)
		);
	datapath datapath_module(
	 	.clk(clk), 
	 	.reset_n(reset_n),  
	 	.data1(data1_c), // TODO: check data connection!!!
		.ready_m1(ready_c_m1),
		.ready_m2(ready_c_m2), 
	 	
	 	.data2(data2_dp), // TODO: check data connection!!!
	 	.num_inst(num_inst), 
	 	.output_port(output_port), 
	 	.is_halted(is_halted),
		
		.read_m1(read_c_m1),
		.read_m2(read_c_m2),  
	 	.address1(address_c_1),
		.address2(address_c_2),
	 	.write_m2(write_c_m2));


endmodule


