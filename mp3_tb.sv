//import lc3b_types::*;

module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
logic pmem_resp;
logic pmem_read;
logic pmem_write;
logic [15:0] pmem_address;
logic [255:0] pmem_rdata;
logic [255:0] pmem_wdata;

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

mp3 dut
(
   .clk,
   .pmem_resp,
   .pmem_rdata,
   .pmem_read,
   .pmem_write,
   .pmem_address,
   .pmem_wdata
);

physical_memory memory
(
   .clk,
   .read(pmem_read),
   .write(pmem_write),
   .address(pmem_address),
   .wdata(pmem_wdata),
   .resp(pmem_resp),
   .rdata(pmem_rdata)
);


/*logic clk;
lc3b_word p_instr_rdata, p_data_rdata;
logic p_instr_resp, p_data_resp;
lc3b_word p_instr_addr, p_data_addr, p_data_wdata;
logic p_instr_read, p_data_read, p_data_write;
lc3b_mem_wmask data_mask;

// Clock generator 
initial clk = 0;
always #5 clk = ~clk;

mp3 dut
(
   .*
);

magic_memory_dp memory
(
	// Port A 
	.clk,
	.read_a(p_instr_read),
	.write_a(0),
	.wmask_a(0),
	.address_a(p_instr_addr),
	.wdata_a(0),
	.resp_a(p_instr_resp),
   .rdata_a(p_instr_rdata),

    // Port B 
    .read_b(p_data_read),
    .write_b(p_data_write),
    .wmask_b(data_mask),
    .address_b(p_data_addr),
    .wdata_b(p_data_wdata),
    .resp_b(p_data_resp),
    .rdata_b(p_data_rdata)
);*/

endmodule : mp3_tb
