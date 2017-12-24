import lc3b_types::*;

module l2cache_datapath
(
   input clk,
	 
   /* declare more ports here */

   /* Physical Memory signals */
   input logic[255:0] pmem_rdata,
   output lc3b_word pmem_address,
   output logic[255:0] pmem_wdata,
	 
	/* Cache Memory signals */
   input lc3b_word mem_address,
   input lc3b_cline mem_wdata,
   output lc3b_cline mem_rdata,
	 
	/* Cache signals */
	input load_tag,
	input load_d,
	input mem_resp,
	input pmem_write,
	output logic evict,
	output logic hit,
	output logic dirty_mux_out
);

/* declare internal signals */
logic[5:0] tag;
logic[4:0] index;
logic offset;

logic[5:0] tag0_out, tag1_out, tag2_out, tag3_out, tag4_out, tag5_out, tag6_out, tag7_out;
logic[255:0] data0_out, data1_out, data2_out, data3_out, data4_out, data5_out, data6_out, data7_out;
logic valid0_out, valid1_out, valid2_out, valid3_out, valid4_out, valid5_out, valid6_out, valid7_out;
logic dirty0_out, dirty1_out, dirty2_out, dirty3_out, dirty4_out, dirty5_out, dirty6_out, dirty7_out;
logic[2:0] lru_out, hit_id;
logic[20:0] truelrulogic_out, lruarray_out;

logic [2:0] load_d_mux_out;
logic[255:0] datain_mux_out, dataout_mux_out, concat_out;
logic[5:0] tag_mux_out;
lc3b_word pmem_address_mux_out;
lc3b_cline mem_rdata_mux_out;
logic hit0, hit1, hit2, hit3, hit4, hit5, hit6, hit7;

assign tag = mem_address[15:10];
assign index = mem_address[9:5];
assign offset = mem_address[4];

assign hit0 = valid0_out & (tag == tag0_out);
assign hit1 = valid1_out & (tag == tag1_out);
assign hit2 = valid2_out & (tag == tag2_out);
assign hit3 = valid3_out & (tag == tag3_out);
assign hit4 = valid4_out & (tag == tag4_out);
assign hit5 = valid5_out & (tag == tag5_out);
assign hit6 = valid6_out & (tag == tag6_out);
assign hit7 = valid7_out & (tag == tag7_out);
assign hit_id = {(hit7 | hit6 | hit5 | hit4), (hit7 | hit6 | hit3 | hit2), (hit7 | hit5 | hit3 | hit1)};
logic[255:0] mask, concat_wdata, concat_data;
assign mask = {{128{~offset}}, {128{offset}}};
assign concat_wdata = {mem_wdata, mem_wdata} & (~mask);
assign concat_data = mask & dataout_mux_out;
assign concat_out = concat_wdata | concat_data;

assign hit = hit0 | hit1 | hit2 | hit3 | hit4 | hit5 | hit6 | hit7;
assign evict = valid0_out & valid1_out & valid2_out & valid3_out & valid4_out & valid5_out & valid6_out & valid7_out;
assign pmem_address = pmem_address_mux_out;
assign pmem_wdata = dataout_mux_out;
assign mem_rdata = mem_rdata_mux_out;

mux #(.width(128), .selects(1)) mem_rdata_mux
(
	.sel(~offset),
	.in(dataout_mux_out),
	.out(mem_rdata_mux_out)
);

mux2 #(.width(16)) pmem_address_mux
(
	.sel(pmem_write),
	.a({tag, index, 5'h0}),
	.b({tag_mux_out, index, 5'h0}),
	.f(pmem_address_mux_out)
);

mux #(.width(6), .selects(3)) tag_mux
(
	.sel(lru_out),
	.in({tag0_out, tag1_out, tag2_out, tag3_out, tag4_out, tag5_out, tag6_out, tag7_out}),
	.out(tag_mux_out)
);

mux2 #(.width(256)) datain_mux
(
	.sel(mem_resp),
	.a(pmem_rdata),
	.b(concat_out),
	.f(datain_mux_out)
);

mux #(.width(256), .selects(3)) dataout_mux
(
	.sel(load_d_mux_out),
	.in({data0_out, data1_out, data2_out, data3_out, data4_out, data5_out, data6_out, data7_out}),
	.out(dataout_mux_out)
);

mux #(.width(1), .selects(3)) dirty_mux
(
	.sel(lru_out),
	.in({dirty0_out, dirty1_out, dirty2_out, dirty3_out, dirty4_out, dirty5_out, dirty6_out, dirty7_out}),
	.out(dirty_mux_out)
);

mux #(.width(3)) load_d_mux
(
	.sel(mem_resp),
	.in({lru_out, hit_id}),
	.out(load_d_mux_out)
);

array #(.width(6), .height(5)) tag0
(
	.clk,
	.write((lru_out == 3'b000) & load_tag),
	.index,
	.datain(tag),
	.dataout(tag0_out)
);

array #(.width(6), .height(5)) tag1
(
	.clk,
	.write((lru_out == 3'b001) & load_tag),
	.index,
	.datain(tag),
	.dataout(tag1_out)
);

array #(.width(6), .height(5)) tag2
(
	.clk,
	.write((lru_out == 3'b010) & load_tag),
	.index,
	.datain(tag),
	.dataout(tag2_out)
);

array #(.width(6), .height(5)) tag3
(
	.clk,
	.write((lru_out == 3'b011) & load_tag),
	.index,
	.datain(tag),
	.dataout(tag3_out)
);

array #(.width(256), .height(5)) data0
(
	.clk,
	.write((load_d_mux_out == 3'b000) & load_d),
	.index,
	.datain(datain_mux_out),
	.dataout(data0_out)
);

array #(.width(256), .height(5)) data1
(
	.clk,
	.write((load_d_mux_out == 3'b001) & load_d),
	.index,
	.datain(datain_mux_out),
	.dataout(data1_out)
);

array #(.width(256), .height(5)) data2
(
	.clk,
	.write((load_d_mux_out == 3'b010) & load_d),
	.index,
	.datain(datain_mux_out),
	.dataout(data2_out)
);

array #(.width(256), .height(5)) data3
(
	.clk,
	.write((load_d_mux_out == 3'b011) & load_d),
	.index,
	.datain(datain_mux_out),
	.dataout(data3_out)
);

array #(.width(1), .height(5)) valid0
(
	.clk,
	.write((lru_out == 3'b000) & load_tag),
	.index,
	.datain(1'b1),
	.dataout(valid0_out)
);

array #(.width(1), .height(5)) valid1
(
	.clk,
	.write((lru_out == 3'b001) & load_tag),
	.index,
	.datain(1'b1),
	.dataout(valid1_out)
);

array #(.width(1), .height(5)) valid2
(
	.clk,
	.write((lru_out == 3'b010) & load_tag),
	.index,
	.datain(1'b1),
	.dataout(valid2_out)
);

array #(.width(1), .height(5)) valid3
(
	.clk,
	.write((lru_out == 3'b011) & load_tag),
	.index,
	.datain(1'b1),
	.dataout(valid3_out)
);

array #(.width(1), .height(5)) dirty0
(
	.clk,
	.write((load_d_mux_out == 3'b000) & load_d),
	.index,
	.datain(mem_resp),
	.dataout(dirty0_out)
);

array #(.width(1), .height(5)) dirty1
(
	.clk,
	.write((load_d_mux_out == 3'b001) & load_d),
	.index,
	.datain(mem_resp),
	.dataout(dirty1_out)
);

array #(.width(1), .height(5)) dirty2
(
	.clk,
	.write((load_d_mux_out == 3'b010) & load_d),
	.index,
	.datain(mem_resp),
	.dataout(dirty2_out)
);

array #(.width(1), .height(5)) dirty3
(
	.clk,
	.write((load_d_mux_out == 3'b011) & load_d),
	.index,
	.datain(mem_resp),
	.dataout(dirty3_out)
);

array #(.width(6), .height(5)) tag4
(
	.clk,
	.write((lru_out == 3'b100) & load_tag),
	.index,
	.datain(tag),
	.dataout(tag4_out)
);

array #(.width(6), .height(5)) tag5
(
	.clk,
	.write((lru_out == 3'b101) & load_tag),
	.index,
	.datain(tag),
	.dataout(tag5_out)
);

array #(.width(6), .height(5)) tag6
(
	.clk,
	.write((lru_out == 3'b110) & load_tag),
	.index,
	.datain(tag),
	.dataout(tag6_out)
);

array #(.width(6), .height(5)) tag7
(
	.clk,
	.write((lru_out == 3'b111) & load_tag),
	.index,
	.datain(tag),
	.dataout(tag7_out)
);

array #(.width(256), .height(5)) data4
(
	.clk,
	.write((load_d_mux_out == 3'b100) & load_d),
	.index,
	.datain(datain_mux_out),
	.dataout(data4_out)
);

array #(.width(256), .height(5)) data5
(
	.clk,
	.write((load_d_mux_out == 3'b101) & load_d),
	.index,
	.datain(datain_mux_out),
	.dataout(data5_out)
);

array #(.width(256), .height(5)) data6
(
	.clk,
	.write((load_d_mux_out == 3'b110) & load_d),
	.index,
	.datain(datain_mux_out),
	.dataout(data6_out)
);

array #(.width(256), .height(5)) data7
(
	.clk,
	.write((load_d_mux_out == 3'b111) & load_d),
	.index,
	.datain(datain_mux_out),
	.dataout(data7_out)
);

array #(.width(1), .height(5)) valid4
(
	.clk,
	.write((lru_out == 3'b100) & load_tag),
	.index,
	.datain(1'b1),
	.dataout(valid4_out)
);

array #(.width(1), .height(5)) valid5
(
	.clk,
	.write((lru_out == 3'b101) & load_tag),
	.index,
	.datain(1'b1),
	.dataout(valid5_out)
);

array #(.width(1), .height(5)) valid6
(
	.clk,
	.write((lru_out == 3'b110) & load_tag),
	.index,
	.datain(1'b1),
	.dataout(valid6_out)
);

array #(.width(1), .height(5)) valid7
(
	.clk,
	.write((lru_out == 3'b111) & load_tag),
	.index,
	.datain(1'b1),
	.dataout(valid7_out)
);

array #(.width(1), .height(5)) dirty4
(
	.clk,
	.write((load_d_mux_out == 3'b100) & load_d),
	.index,
	.datain(mem_resp),
	.dataout(dirty4_out)
);

array #(.width(1), .height(5)) dirty5
(
	.clk,
	.write((load_d_mux_out == 3'b101) & load_d),
	.index,
	.datain(mem_resp),
	.dataout(dirty5_out)
);

array #(.width(1), .height(5)) dirty6
(
	.clk,
	.write((load_d_mux_out == 3'b110) & load_d),
	.index,
	.datain(mem_resp),
	.dataout(dirty6_out)
);

array #(.width(1), .height(5)) dirty7
(
	.clk,
	.write((load_d_mux_out == 3'b111) & load_d),
	.index,
	.datain(mem_resp),
	.dataout(dirty7_out)
);

eight_way_lrulogic eight_way_lrulogic
(
	.hit(hit_id),
	.cState(lruarray_out),
	.lru(lru_out),
	.newState(truelrulogic_out)
);

array #(.width(21), .height(5)) lru
(
	.clk,
	.write(mem_resp),
	.index,
	.datain(truelrulogic_out),
	.dataout(lruarray_out)
);

endmodule : l2cache_datapath
