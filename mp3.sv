import lc3b_types::*;

module mp3
(
   input clk,
	input [255:0] pmem_rdata,
	input pmem_resp,
   output lc3b_word pmem_address,
	output logic [255:0] pmem_wdata,
	output logic pmem_read,
	output logic pmem_write
);


lc3b_word instr_rdata, data_rdata;
logic instr_resp, data_resp, l2_resp, victim_resp;
lc3b_word instr_addr, data_addr, data_wdata, l2_addr, victim_address;
logic instr_read, data_read, data_write, l2_read, l2_write, victim_read, victim_write;
lc3b_mem_wmask data_mask;
logic a_instr_resp;
logic [127:0] a_instr_rdata, a_instr_wdata;
logic a_instr_read, a_instr_write;
lc3b_word a_instr_addr;
logic a_data_resp;
logic [127:0] a_data_rdata, l2_rdata;
logic a_data_read;
logic a_data_write;
lc3b_word a_data_addr;
logic [127:0] a_data_wdata, l2_wdata;
logic [255:0] victim_rdata, victim_wdata;
logic dirty;


cpu cpu
(
	.*
);

cache instr_cache
(
	 .clk(clk),
	 .pmem_resp(a_instr_resp),
    .pmem_rdata(a_instr_rdata),
    .pmem_read(a_instr_read),
    .pmem_write(a_instr_write),
    .pmem_address(a_instr_addr),
    .pmem_wdata(a_instr_wdata),
    .mem_read(instr_read),
    .mem_write(1'b0),
    .mem_byte_enable(2'b11),
    .mem_address(instr_addr),
    .mem_wdata(16'b0),
    .mem_resp(instr_resp),
    .mem_rdata(instr_rdata)
);

cache data_cache
(
	 .clk(clk),
	 .pmem_resp(a_data_resp),
    .pmem_rdata(a_data_rdata),
    .pmem_read(a_data_read),
    .pmem_write(a_data_write),
    .pmem_address(a_data_addr),
    .pmem_wdata(a_data_wdata),
    .mem_read(data_read),
    .mem_write(data_write),
    .mem_byte_enable(data_mask),
    .mem_address(data_addr),
    .mem_wdata(data_wdata),
    .mem_resp(data_resp),
    .mem_rdata(data_rdata)
);

arbiter arbiter
(
	 .clk(clk),
	 .i_addr(a_instr_addr),
	 .d_addr(a_data_addr),
	 .i_read(a_instr_read),
	 .d_read(a_data_read),
	 .d_write(a_data_write),
	 .d_wdata(a_data_wdata),
	 .l2_resp(l2_resp), 
	 .l2_rdata(l2_rdata),
	 .i_resp(a_instr_resp),
	 .d_resp(a_data_resp),
	 .i_rdata(a_instr_rdata),
	 .d_rdata(a_data_rdata),
	 .l2_addr(l2_addr),
	 .l2_read(l2_read),
	 .l2_write(l2_write),
	 .l2_wdata(l2_wdata)
);

l2cache l2_cache
(
	.clk(clk),
	.pmem_resp(victim_resp),
   .pmem_rdata(victim_rdata),
   .pmem_read(victim_read),
   .pmem_write(victim_write),
   .pmem_address(victim_address),
   .pmem_wdata(victim_wdata),
   .mem_read(l2_read),
   .mem_write(l2_write),
   .mem_address(l2_addr),
   .mem_wdata(l2_wdata),
   .mem_resp(l2_resp),
   .mem_rdata(l2_rdata),
	.dirty_mux_out(dirty)
);

victimcache victimcache
(
	.clk(clk),
	.pmem_resp(pmem_resp),
   .pmem_rdata(pmem_rdata),
   .pmem_read(pmem_read),
   .pmem_write(pmem_write),
   .pmem_address(pmem_address),
   .pmem_wdata(pmem_wdata),
   .mem_read(victim_read),
   .mem_write(victim_write),
   .mem_address(victim_address),
   .mem_wdata(victim_wdata),
	.mem_resp(victim_resp),
   .mem_rdata(victim_rdata),
	.dirty(dirty)
);

endmodule : mp3
