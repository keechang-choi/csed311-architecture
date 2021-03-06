`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,i_select_item,clk,reset_n,wait_time);
	input clk;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	output reg [31:0] wait_time;

	// initiate values
	initial begin
		// TODO: initiate values 
		wait_time = `kWaitTime;
	end


	// update coin return time
	always @(i_input_coin, i_select_item) begin
		// TODO: update coin return time
		if(i_input_coin > 0 || i_select_item > 0) begin
			wait_time <= `kWaitTime;
		end
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// TODO: reset all states.
			wait_time <= `kWaitTime;
		end
		else begin
		// TODO: update all states.
			wait_time <= wait_time - 1;
		end
	end
endmodule 