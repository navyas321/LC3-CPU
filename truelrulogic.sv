import lc3b_types::*;

module truelrulogic
(
	input [1:0] hit,
	input [5:0] cState,
	output logic [1:0] lru,
	output logic [5:0] newState
);

logic [1:0] a, b, c, missing;

assign missing = a ^ b ^ c;
assign a = cState[5:4];
assign b = cState[3:2];
assign c = cState[1:0];
assign lru = cState[1:0];

always_comb begin
	newState = cState;
	if((a==c) | (a==b) | (b==c)) begin
		newState = 6'h24;
	end
	else if(hit == a) begin
		newState = {missing, b, c};
	end
	else if(hit == b) begin
		newState = {missing, a, c};
	end
	else if(hit == c) begin
		newState = {missing, a, b};
	end
end



endmodule : truelrulogic