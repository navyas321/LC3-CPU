import lc3b_types::*;

module branch_predictor #(parameter ls = 8, parameter gs = 6)
(
	input clk,
	input logic[2:0] nzp, cc,
	input logic ex_ld_cc, mem_ld_cc,
	input logic[1:0] pred_in,
	output logic[1:0] pred_out,
	output logic out,
	input update, result, 
	input logic[ls-1:0] l_index, lup_index, 
	input logic[gs-1:0]gup_index,
	output logic[gs-1:0] g_index
);

logic local_pr, global_pr, tourney_select;

always_comb begin
pred_out = {global_pr, local_pr};
out = (tourney_select & global_pr) | (~tourney_select & local_pr);
if(~(ex_ld_cc | mem_ld_cc))
	out = |(nzp & cc);
if(&nzp)
	out = 1;
if(~|nzp)
	out = 0;
end

set_branch_predictor #(.k(ls)) lpred
(
	.clk,
	.pr_index(l_index),
	.out(local_pr),
	.up_index(lup_index),
	.update,
	.result
);

global_branch_predictor #(.k(gs)) gpred
(
	.clk,
	.out(global_pr),
	.update,
	.result,
	.up_index(gup_index),
	.down_index(g_index)
);

tourney_branch_predictor #(.k(ls)) tpred
(
	.clk,
	.update,
	.result,
	.predictions(pred_in),
	.up_index(lup_index),
	.pr_index(l_index),
	.select(tourney_select)
);

endmodule : branch_predictor
