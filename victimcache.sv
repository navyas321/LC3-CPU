import lc3b_types::*;

module victimcache
(
	input clk,
	input pmem_resp,
	input [255:0] pmem_rdata,
	output logic pmem_read,
	output logic pmem_write,
	output lc3b_word pmem_address,
	output logic[255:0] pmem_wdata,
   input mem_read,
   input mem_write,
   input lc3b_word mem_address,
   input [255:0] mem_wdata,
	output logic mem_resp,
   output logic[255:0] mem_rdata,
	input dirty
);

logic evict, hit, control_resp, r_mux_sel, w_mux_sel;

victimcache_datapath datapath
(
	.*
);

victimcache_control control
(
	.*
);



endmodule : victimcache