import lc3b_types::*;

module if_id #(parameter ls = 8, parameter gs = 6)
(
	input clk, reset,
	input load_if_id,
	input lc3b_word pc_in,
	input lc3b_word ir_in,
	input br_pr_in,
	output lc3b_word pc_out,
	output lc3b_word ir_out,
	output logic br_pr_out,
	input logic[1:0] pred_in,
	output logic[1:0] pred_out,
	input logic[ls-1:0] local_index_in,
	output logic[ls-1:0] local_index_out,
	input logic[gs-1:0] global_index_in,
	output logic[gs-1:0] global_index_out
);

initial begin
	pc_out = 0;
	ir_out = 0;
	br_pr_out = 0;
	pred_out = 0;
	local_index_out = 0;
	global_index_out = 0;
end

always_ff @(posedge clk) begin
	if(reset) begin
		pc_out <= 16'b0;
		ir_out <= 16'b0;
		br_pr_out <= 1'b0;
		pred_out <= 0;
		local_index_out <= 0;
		global_index_out <= 0;
	end	
	else begin
		if(load_if_id) begin
			pc_out <= pc_in;
			ir_out <= ir_in;
			br_pr_out <= br_pr_in;
			pred_out <= pred_in;
			local_index_out <= local_index_in;
			global_index_out <= global_index_in;
		end
	end
end

endmodule : if_id