module global_branch_predictor #(parameter k = 4)
(
	input clk,
	output logic out,
	input update, result,
	input logic[k-1:0] up_index,
	output logic[k-1:0] down_index
);

logic[k-1:0] array, array_in;

initial array = '{default:0};

set_branch_predictor #(.k(k)) set_pr
(
	.clk,
	.pr_index(array),
	.out,
	.up_index,
	.update,
	.result
);

always_comb begin
	array_in = array;
	down_index = array;
	if(update)
		array_in = {array[k-2:0], result};
end

always_ff @ (posedge clk) begin
	array <= array_in;
end

endmodule : global_branch_predictor