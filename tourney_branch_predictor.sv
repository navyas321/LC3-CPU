module tourney_branch_predictor #(parameter k = 4)
(
	input clk,
	input update, result,
	input logic[1:0] predictions,
	input logic[k-1:0] up_index, pr_index,
	output logic select
);

set_branch_predictor #(.k(k)) set_pr
(
	.clk,
	.pr_index(pr_index),
	.out(select),
	.up_index,
	.update(update & ^predictions),
	.result(result ^ predictions[0])
);

endmodule : tourney_branch_predictor