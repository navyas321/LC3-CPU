import lc3b_types::*;

module ex_mem #(parameter ls = 8, parameter gs = 6)
(
	input clk, reset,
	input load_ex_mem,
	input lc3b_control_word cw_in,
	input lc3b_reg dest_in,
	input lc3b_word mar_in,
	input lc3b_word mdr_in,
	input br_taken_in,
	output logic br_taken_out,
	output lc3b_control_word cw_out,
	output lc3b_reg dest_out,
	output lc3b_word mar_out,
	output lc3b_word mdr_out,
	input logic[1:0] pred_in,
	output logic[1:0] pred_out,
	input logic[ls-1:0] local_index_in,
	output logic[ls-1:0] local_index_out,
	input logic[gs-1:0] global_index_in,
	output logic[gs-1:0] global_index_out
);

initial begin
	br_taken_out = 0;
	cw_out = 0;
	dest_out = 3'b0;
	mar_out = 16'b0;
	mdr_out = 16'b0;
	pred_out = 0;
	local_index_out = 0;
	global_index_out = 0;
end

always_ff @(posedge clk) begin
	if(reset) begin
		br_taken_out <= 0;
		cw_out <= 0;
		dest_out <= 3'b0;
		mar_out <= 16'b0;
		mdr_out <= 16'b0;
		pred_out <= 0;
		local_index_out <= 0;
		global_index_out <= 0;
	end	
	else begin
		if(load_ex_mem) begin
			br_taken_out <= br_taken_in;
			cw_out <= cw_in;
			dest_out <= dest_in;
			mar_out <= mar_in;
			mdr_out <= mdr_in;
			pred_out <= pred_in;
			local_index_out <= local_index_in;
			global_index_out <= global_index_in;
		end
	end
end

endmodule : ex_mem