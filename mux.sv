module mux #(parameter width = 16, parameter selects = 1)
(
input [selects-1:0] sel,
input [0:(1<<selects)-1][width-1:0] in,
output logic [width-1:0] out
);
always_comb
begin
out = in[sel];
end
endmodule : mux