import lc3b_types::*;

module l2cache
(
   input clk,

   /* Physical Memory signals */
	input pmem_resp,
   input logic[255:0] pmem_rdata,
   output logic pmem_read,
   output logic pmem_write,
   output lc3b_word pmem_address,
   output logic[255:0] pmem_wdata,
	 
	/* Cache Memory signals */
   input mem_read,
   input mem_write,
   input lc3b_word mem_address,
   input lc3b_cline mem_wdata,
   output logic mem_resp,
   output lc3b_cline mem_rdata,
	output logic dirty_mux_out
);

/* Instantiate interconnect signals here */
logic load_d;
logic load_tag;
logic evict;
logic hit;

l2cache_datapath datapath_inst
(
	.*
);

l2cache_control control_inst
(
	.*
);



endmodule : l2cache
