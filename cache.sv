import lc3b_types::*;

module cache
(
   input clk,

   /* Physical Memory signals */
	input pmem_resp,
   input logic[127:0] pmem_rdata,
   output logic pmem_read,
   output logic pmem_write,
   output lc3b_word pmem_address,
   output logic[127:0] pmem_wdata,
	 
	/* Cache Memory signals */
   input mem_read,
   input mem_write,
   input lc3b_mem_wmask mem_byte_enable,
   input lc3b_word mem_address,
   input lc3b_word mem_wdata,
   output logic mem_resp,
   output lc3b_word mem_rdata
);

/* Instantiate interconnect signals here */
logic load_d;
logic load_tag;
logic evict;
logic hit;

cache_datapath datapath_inst
(
	.*
);

cache_control control_inst
(
	.*
);



endmodule : cache
