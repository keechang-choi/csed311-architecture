
`include "vending_machine_def.v"
	

module calculate_current_state(i_input_coin,i_select_item,item_price,coin_value,current_total,
input_total, output_total, return_total,current_total_nxt,wait_time,o_return_coin,o_available_item,
o_output_item,i_trigger_return);


	input i_trigger_return;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;			
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [`kTotalBits-1:0] current_total;
	input [31:0] wait_time;
	output reg [`kNumItems-1:0] o_available_item,o_output_item;
	output reg  [`kTotalBits-1:0] input_total, output_total, return_total,current_total_nxt;
	output reg o_return_coin;
	integer i;	
	

	reg mask;

	

	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		// Calculate the next current_total state.

		
		if (i_input_coin  == 3'b001) begin
			input_total = coin_value[0];
		end
		else if (i_input_coin  == 3'b010) begin
			input_total = coin_value[1];
		end
		else if (i_input_coin  == 3'b100) begin
			input_total = coin_value[2];
		end
		else begin
			input_total = 0;
		end
		
		if (i_select_item  == 4'b0001) begin
			output_total = item_price[0];
		end
		else if (i_select_item  == 4'b0010) begin
			output_total = item_price[1];
		end
		else if (i_select_item  == 4'b0100) begin
			output_total = item_price[2];
		end
		else if (i_select_item  == 4'b1000) begin
			output_total = item_price[3];
		end
		else begin
			output_total = 0;
		end
		
		if (current_total + input_total >= output_total) begin
			current_total_nxt = current_total + input_total - output_total;
		end
		else begin
			current_total_nxt = current_total + input_total;
		end
		/*$display("@@@@@@@@@@@@@@@@@");
		$display("input_coin   @@ %b @@",i_input_coin);
		$display("select_item  @@ %b @@",i_select_item);
		$display("input_total  @@ %d @@",input_total);		
		$display("output_total @@ %d @@",output_total);
		$display("current      @@ %d @@",current_total);
	 	$display("nxt current  @@ %d @@",current_total_nxt);*/
	end

	always@(*)begin
		if(wait_time <=0 &&current_total>0) begin
			current_total_nxt = current_total - coin_value[0];
			o_return_coin = 'b001;
		end
	end

	always @(*) begin
		if(i_trigger_return > 0)begin
			current_total_nxt = current_total - coin_value[0];
			o_return_coin = 'b001;
		end
		
	end


	// Combinational logic for the outputs
	always @(*) begin
		// TODO: o_available_item
		// TODO: o_output_item

		if (current_total >= item_price[3]) begin
			o_available_item = 4'b1111;
		end
		else if (current_total >= item_price[2]) begin
			o_available_item = 4'b0111;
		end
		else if (current_total >= item_price[1]) begin
			o_available_item = 4'b0011;	
		end
		else if (current_total >= item_price[0]) begin
			o_available_item = 4'b0001;
		end
		else begin
			o_available_item = 4'b0000;
		end

		if (o_return_coin  == 3'b001) begin
			return_total = coin_value[0];
		end
		else if (o_return_coin  == 3'b010) begin
			return_total = coin_value[1];
		end
		else begin
			return_total = coin_value[2];
		end


		

		o_output_item = i_select_item & o_available_item;
	end
 

endmodule 