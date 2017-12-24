import lc3b_types::*;

module cache_datapath
(
    input clk,
	 
    /* declare more ports here */

    /* Physical Memory signals */
    input logic[127:0] pmem_rdata,
    output lc3b_word pmem_address,
    output logic[127:0] pmem_wdata,
	 
	 /* Cache Memory signals */
    input lc3b_mem_wmask mem_byte_enable,
    input lc3b_word mem_address,
    input lc3b_word mem_wdata,
    output lc3b_word mem_rdata,
	 
	 /* Cache signals */
	 input load_tag,
	 input load_d,
	 input mem_resp,
	 input pmem_write,
	 output logic evict,
	 output logic hit
);

/* declare internal signals */
logic[8:0] tag;
logic[2:0] index;
logic[2:0] offset;

logic[8:0] tag0_out, tag1_out;
logic[127:0] data0_out, data1_out;
logic valid0_out, valid1_out;
logic dirty0_out, dirty1_out;
logic lru_out;

logic load_d_mux_out;
logic[127:0] datain_mux_out, dataout_mux_out, concat_out;
logic[8:0] tag_mux_out;
lc3b_word pmem_address_mux_out, mem_rdata_mux_out;
logic hit0, hit1;
logic dirty_mux_out;

assign tag = mem_address[15:7];
assign index = mem_address[6:4];
assign offset = mem_address[3:1];

assign hit0 = valid0_out & (tag == tag0_out);
assign hit1 = valid1_out & (tag == tag1_out);
logic[127:0] mask, concat_wdata, concat_data;
assign mask = ~({112'h0, {{8{mem_byte_enable[1]}}, {8{mem_byte_enable[0]}}}} << ({5'h0, offset} << 4));
assign concat_wdata = ({112'h0, mem_wdata & {{8{mem_byte_enable[1]}}, {8{mem_byte_enable[0]}}}}) << ({5'h0, offset} << 4);
assign concat_data = mask & dataout_mux_out;
assign concat_out = concat_wdata | concat_data;

assign hit = hit0 | hit1;
assign evict = valid0_out & valid1_out & dirty_mux_out;
assign pmem_address = pmem_address_mux_out;
assign pmem_wdata = dataout_mux_out;
assign mem_rdata = mem_rdata_mux_out;

mux #(.width(16), .selects(3)) mem_rdata_mux
(
	.sel(3'h7 - offset),
	.in(dataout_mux_out),
	.out(mem_rdata_mux_out)
);

mux2 #(.width(16)) pmem_address_mux
(
	.sel(pmem_write),
	.a({tag, index, 4'h0}),
	.b({tag_mux_out, index, 4'h0}),
	.f(pmem_address_mux_out)
);

mux2 #(.width(9)) tag_mux
(
	.sel(lru_out),
	.a(tag0_out),
	.b(tag1_out),
	.f(tag_mux_out)
);

mux2 #(.width(128)) datain_mux
(
	.sel(mem_resp),
	.a(pmem_rdata),
	.b(concat_out),
	.f(datain_mux_out)
);

mux2 #(.width(128)) dataout_mux
(
	.sel(load_d_mux_out),
	.a(data0_out),
	.b(data1_out),
	.f(dataout_mux_out)
);

mux2 #(.width(1)) dirty_mux
(
	.sel(lru_out),
	.a(dirty0_out),
	.b(dirty1_out),
	.f(dirty_mux_out)
);

mux2 #(.width(1)) load_d_mux
(
	.sel(mem_resp),
	.a(lru_out),
	.b(hit1),
	.f(load_d_mux_out)
);

array #(.width(9)) tag0
(
	.clk,
	.write((~lru_out) & load_tag),
	.index,
	.datain(tag),
	.dataout(tag0_out)
);

array #(.width(9)) tag1
(
	.clk,
	.write(lru_out & load_tag),
	.index,
	.datain(tag),
	.dataout(tag1_out)
);

array #(.width(128)) data0
(
	.clk,
	.write((~load_d_mux_out) & load_d),
	.index,
	.datain(datain_mux_out),
	.dataout(data0_out)
);

array #(.width(128)) data1
(
	.clk,
	.write(load_d_mux_out & load_d),
	.index,
	.datain(datain_mux_out),
	.dataout(data1_out)
);

array #(.width(1)) valid0
(
	.clk,
	.write((~lru_out) & load_tag),
	.index,
	.datain(1'b1),
	.dataout(valid0_out)
);

array #(.width(1)) valid1
(
	.clk,
	.write(lru_out & load_tag),
	.index,
	.datain(1'b1),
	.dataout(valid1_out)
);

array #(.width(1)) dirty0
(
	.clk,
	.write((~load_d_mux_out) & load_d),
	.index,
	.datain(mem_resp),
	.dataout(dirty0_out)
);

array #(.width(1)) dirty1
(
	.clk,
	.write(load_d_mux_out & load_d),
	.index,
	.datain(mem_resp),
	.dataout(dirty1_out)
);

array #(.width(1)) lru
(
	.clk,
	.write(mem_resp),
	.index,
	.datain(hit0),
	.dataout(lru_out)
);


endmodule : cache_datapath
