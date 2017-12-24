import lc3b_types::*;

module array #(parameter width = 128, parameter height = 3)
(
	input clk,
	input write,
   input logic[height-1:0] index,
   input [width-1:0] datain,
   output logic [width-1:0] dataout

);

logic [width-1:0] data [(1<<height)-1:0];

/* Initialize array */
initial
begin
	for (int i = 0; i < $size(data); i++)
   begin
      data[i] = 1'b0;
   end
end

always_ff @(posedge clk)
begin
	if (write == 1)
	begin
		data[index] = datain;
   end
end

assign dataout = data[index];

endmodule : array