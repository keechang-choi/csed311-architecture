
`include "vending_machine_def.v"
	

module calculate_current_state(i_input_coin,i_select_item,item_price,coin_value,current_total,
input_total, output_total, return_total,current_total_nxt,wait_time,o_return_coin,o_available_item,o_output_item);


	
	input [`kNumCoins-1:0] i_input_coin,o_return_coin;
	input [`kNumItems-1:0]	i_select_item;			
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [`kTotalBits-1:0] current_total;
	input [31:0] wait_time;
	output reg [`kNumItems-1:0] o_available_item,o_output_item;
	output reg  [`kTotalBits-1:0] input_total, output_total, return_total,current_total_nxt;
	integer i;	
	

	reg mask;

	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		// Calculate the next current_total state.
		input_total = 0;
		for(i=0;i<`kNumCoins;i=i+1) begin
			mask = 'b001;
			mask = mask << i;
			if ((i_input_coin & mask) == mask) begin
				input_total = input_total + coin_value[i];
			end
		end
		output_total = 0;
		for(i=0;i<`kNumItems;i=i+1) begin
			mask = 'b0001;
			mask = mask << i;
			if ((i_select_item & mask) == mask) begin
				output_total = output_total + item_price[i];
			end
		end
		current_total_nxt = current_total + input_total - output_total;
	end

	
	
	// Combinational logic for the outputs
	always @(*) begin
		// TODO: o_available_item
		// TODO: o_output_item
		return_total = 0;
		for(i=0;i<`kNumCoins;i=i+1) begin
			mask = 'b001;
			mask = mask << i;
			if ((o_return_coin & mask) == mask) begin
				return_total = return_total + coin_value[i];
			end
		end
	end

	always @(*) begin
		o_available_item = 'b0;
		for(i=0;i<`kNumItems;i=i+1) begin
			mask = 'b0001;
			mask = mask << i;
			if (item_price[i] <= current_total) begin
				o_available_item = o_available_item | mask;	
			end
		end
		o_output_item = i_select_item & o_available_item;
	end
 
	


endmodule 