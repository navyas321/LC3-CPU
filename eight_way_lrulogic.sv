module eight_way_lrulogic
(
	input [2:0] hit,
	input [20:0] cState,
	output logic [2:0] lru,
	output logic [20:0] newState
);

logic [2:0] a, b, c, d, e, f, g, m;

assign m = a ^ b ^ c ^ d ^ e ^ f ^ g;
assign a = cState[20:18];
assign b = cState[17:15];
assign c = cState[14:12];
assign d = cState[11:9];
assign e = cState[8:6];
assign f = cState[5:3];
assign g = cState[2:0];
assign lru = cState[2:0];

always_comb begin
	newState = cState;
	if((m==a) | (m==b) | (m==c) | (m==d) | (m==e) | (m==f) | (m==g)) begin
		newState = 21'h1ac688;	// 1.10 10.1 100 .011 0.10 00.1 000
	end
	else if(hit == a) begin
		newState = {m, b, c, d, e, f, g};
	end
	else if(hit == b) begin
		newState = {m, a, c, d, e, f, g};
	end
	else if(hit == c) begin
		newState = {m, a, b, d, e, f, g};
	end
	else if(hit == d) begin
		newState = {m, a, b, c, e, f, g};
	end
	else if(hit == e) begin
		newState = {m, a, b, c, d, f, g};
	end
	else if(hit == f) begin
		newState = {m, a, b, c, d, e, g};
	end
	else if(hit == g) begin
		newState = {m, a, b, c, d, e, f};
	end
end



endmodule : eight_way_lrulogic