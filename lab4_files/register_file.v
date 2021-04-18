module register_file(read_out1, read_out2, read1, read2, write_reg, write_data, reg_write, clk); 
    input [1:0] read1;
    input [1:0] read2;
    input [1:0] write_reg;
    input [15:0] write_data;
    input reg_write;
    input clk;
    output [15:0] read_out1;
    output [15:0] read_out2;

    //TODO: implement register file
    reg [15:0] registers [3:0];

	initial begin
		registers[0] = 0;
		registers[1] = 0;
		registers[2] = 0;
		registers[3] = 0;
	end
	assign read_out1 = registers[read1];
	assign read_out2 = registers[read2];
    
	always @(posedge clk) begin
        	if(reg_write) begin
            		registers[write_reg] <= write_data;    
        	end
      
	end
	always @(negedge clk) begin
		$display("!!!!! reg %d, %d, %d, %d", registers[0], registers[1], registers[2], registers[3]);
	end
endmodule