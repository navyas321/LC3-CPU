import lc3b_types::*;

module cccomp
(
    input lc3b_nzp in1,
	 input lc3b_nzp in2,
    output logic out
);

always_comb
begin
    if (in1[0] & in2[0] | in1[1] & in2[1] | in1[2] & in2[2])
        out = 1'b1;
    else
        out = 1'b0;
end

endmodule : cccomp
