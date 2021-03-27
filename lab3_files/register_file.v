module register_file( read_out1, read_out2, read1, read2, write_reg, write_data, reg_write, clk); 
    output [15:0] read_out1;
    output [15:0] read_out2;
    input [1:0] read1;
    input [1:0] read2;
    input [1:0] write_reg;
    input [15:0] write_data;
    input reg_write;
    input clk;
    // sibal
    reg [15:0] registers [3:0];

/*    always @(*) begin
        read_out1 = registers[read1];
    end

    always @(*) begin
        read_out2 = registers[read2];
    end
*/
	initial begin
		registers[0] = 0;
		registers[1] = 0;
		registers[2] = 0;
		registers[3] = 0;
	end
	assign read_out1 = registers[read1];
	assign read_out2 = registers[read2];
// Is posedge correct?
	always @(posedge clk) begin
		$display("~~~~register write : %d ",write_data);
		$display("~~~~register : %d %d %d %d",registers[0],registers[1],registers[2],registers[3]);
      
	end
    always @(negedge clk ) begin
	if(reg_write) begin
            registers[write_reg] <= write_data;    
        end
	$display("~~~~register write : %d ",write_data);
	$display("~~~~register : %d %d %d %d",registers[0],registers[1],registers[2],registers[3]);
      
    end
    
endmodule

