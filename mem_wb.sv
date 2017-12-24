import lc3b_types::*;

module mem_wb
(
	input clk, reset,
	input load_mem_wb,
	input lc3b_control_word cw_in,
	input lc3b_reg dest_in,
	input lc3b_word mdr_in,
	input indirect_in,
	output lc3b_control_word cw_out,
	output lc3b_reg dest_out,
	output lc3b_word mdr_out,
	output logic indirect_out
);

initial begin
	cw_out = 0;
	dest_out = 3'b0;
	mdr_out = 16'b0;
	indirect_out = 1'b0;
end

always_ff @(posedge clk) begin
	if(reset) begin
		cw_out <= 0;
		dest_out <= 3'b0;
		mdr_out <= 16'b0;
		indirect_out <= 1'b0;
	end	
	else begin
		if(load_mem_wb) begin
			cw_out <= cw_in;
			dest_out <= dest_in;
			mdr_out <= mdr_in;
			indirect_out <= indirect_in;
		end
	end
end

endmodule : mem_wb