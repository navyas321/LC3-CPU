import lc3b_types::*;

module set_branch_predictor #(parameter k = 4)
(
	input clk,
	input logic[k-1:0] pr_index,
	output logic out,
	input logic[k-1:0] up_index,
	input update, result
);

logic[1:0] array [(1<<k)-1:0], array_in [(1<<k)-1:0];
logic[1:0] change;

initial array = '{default:0};

always_comb begin
	out = array[pr_index][1];
	array_in = array;
	case({result, array[up_index]})
		3'b000: change = 2'b01;
		3'b001: change = 2'b01;
		3'b010: change = 2'b00;
		3'b011: change = 2'b10;
		3'b100: change = 2'b10;
		3'b101: change = 2'b00;
		3'b110: change = 2'b11;
		3'b111: change = 2'b11;
	endcase
	if(update)
		array_in[up_index] = change;
end

always_ff @ (posedge clk) begin
	array <= array_in;
end

endmodule : set_branch_predictor
