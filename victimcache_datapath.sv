import lc3b_types::*;

module victimcache_datapath
(
	input clk,
	input [255:0] pmem_rdata,
   input mem_read,
   input mem_write,
   input lc3b_word mem_address,
   input [255:0] mem_wdata,
	input control_resp,
	input r_mux_sel,
	input w_mux_sel,
	input dirty,
	output lc3b_word pmem_address,
	output logic[255:0] pmem_wdata,
	output logic mem_resp,
   output logic[255:0] mem_rdata,
	output logic hit, 
	output logic evict
);

logic [10:0] tag, tag0_out, tag1_out, tag2_out, tag3_out, tag4_out, tag5_out, tag6_out, tag7_out;
logic valid0_out, valid1_out, valid2_out, valid3_out, hit0, hit1, hit2, hit3, dirty0_out, dirty1_out, dirty2_out, dirty3_out;
logic valid4_out, valid5_out, valid6_out, valid7_out, hit4, hit5, hit6, hit7, dirty4_out, dirty5_out, dirty6_out, dirty7_out;
logic [255:0] data0_out, data1_out, data2_out, data3_out, data4_out, data5_out, data6_out, data7_out;
logic[20:0] truelrulogic_out, lruarray_out;
logic [2:0] hit_id, lru_out;
lc3b_word addr;
logic [255:0] data;

assign tag = mem_address[15:5];
assign hit0 = valid0_out & (tag == tag0_out);
assign hit1 = valid1_out & (tag == tag1_out);
assign hit2 = valid2_out & (tag == tag2_out);
assign hit3 = valid3_out & (tag == tag3_out);
assign hit4 = valid4_out & (tag == tag4_out);
assign hit5 = valid5_out & (tag == tag5_out);
assign hit6 = valid6_out & (tag == tag6_out);
assign hit7 = valid7_out & (tag == tag7_out);
assign hit_id = {(hit7 | hit6 | hit5 | hit4), (hit7 | hit6 | hit3 | hit2), (hit7 | hit5 | hit3 | hit1)};
assign hit = hit0 | hit1 | hit2 | hit3 | hit4 | hit5 | hit6 | hit7;
assign evict = mem_write & ~hit & valid0_out & valid1_out & valid2_out & valid3_out & valid4_out & valid5_out & valid6_out & valid7_out & ((lru_out == 3'b000 & dirty0_out) | (lru_out == 3'b001 & dirty1_out) | (lru_out == 3'b010 & dirty2_out) | (lru_out == 3'b011 & dirty3_out) | (lru_out == 3'b100 & dirty4_out) | (lru_out == 3'b101 & dirty5_out) | (lru_out == 3'b110 & dirty6_out) | (lru_out == 3'b111 & dirty7_out));
assign mem_resp = ((hit & ~evict) | control_resp) & (mem_read | mem_write) & ~w_mux_sel;

always_comb
begin
	mem_rdata = data0_out;
	data = data0_out;
	addr = mem_address;
	if(hit_id == 3'b001)
		mem_rdata = data1_out;
	if(hit_id == 3'b010)
		mem_rdata = data2_out;
	if(hit_id == 3'b011)
		mem_rdata = data3_out;	
	if(hit_id == 3'b100)
		mem_rdata = data4_out;	
	if(hit_id == 3'b101)
		mem_rdata = data5_out;
	if(hit_id == 3'b110)
		mem_rdata = data6_out;
	if(hit_id == 3'b111)
		mem_rdata = data7_out;		
	if(evict | w_mux_sel) begin
		if(lru_out == 3'b000) begin
			addr = {tag0_out, 5'b0};
		end
		else if(lru_out == 3'b001) begin
			addr = {tag1_out, 5'b0};
			data = data1_out;
		end	
		else if(lru_out == 3'b010) begin
			addr = {tag2_out, 5'b0};
			data = data2_out;
		end
		else if(lru_out == 3'b011) begin
			addr = {tag3_out, 5'b0};	
			data = data3_out;
		end	
		else if(lru_out == 3'b100) begin
			addr = {tag4_out, 5'b0};
			data = data4_out;
		end
		else if(lru_out == 3'b101) begin
			addr = {tag5_out, 5'b0};
			data = data5_out;
		end	
		else if(lru_out == 3'b110) begin
			addr = {tag6_out, 5'b0};
			data = data6_out;
		end
		else if(lru_out == 3'b111) begin
			addr = {tag7_out, 5'b0};	
			data = data7_out;
		end	
	end
	
	if(r_mux_sel) begin
		mem_rdata = pmem_rdata;
	end
end

always_ff @(posedge clk)
begin
	 pmem_address <= addr;
	 pmem_wdata <= data;
end

register #(.width(1)) valid0
(
	.clk,
	.load((lru_out == 3'b000) & mem_write),
	.in(1'b1),
	.out(valid0_out)
);


register #(.width(1)) valid1
(
	.clk,
	.load((lru_out == 3'b001) & mem_write),
	.in(1'b1),
	.out(valid1_out)
);

register #(.width(1)) valid2
(
	.clk,
	.load((lru_out == 3'b010) & mem_write),
	.in(1'b1),
	.out(valid2_out)
);

register #(.width(1)) valid3
(
	.clk,
	.load((lru_out == 3'b011) & mem_write),
	.in(1'b1),
	.out(valid3_out)
);

register #(.width(1)) dirty0
(
	.clk,
	.load((((lru_out == 3'b000) & mem_write & ~hit) | (hit & (hit_id == 3'b000) & mem_write) | w_mux_sel)),
	.in(dirty & ~w_mux_sel),
	.out(dirty0_out)
);


register #(.width(1)) dirty1
(
	.clk,
	.load((((lru_out == 3'b001) & mem_write & ~hit) | (hit & (hit_id == 3'b001) & mem_write) | w_mux_sel)),
	.in(dirty & ~w_mux_sel),
	.out(dirty1_out)
);

register #(.width(1)) dirty2
(
	.clk,
	.load((((lru_out == 3'b010) & mem_write & ~hit) | (hit & (hit_id == 3'b010) & mem_write) | w_mux_sel)),
	.in(dirty & ~w_mux_sel),
	.out(dirty2_out)
);

register #(.width(1)) dirty3
(
	.clk,
	.load((((lru_out == 3'b011) & mem_write & ~hit) | (hit & (hit_id == 3'b011) & mem_write) | w_mux_sel)),
	.in(dirty & ~w_mux_sel),
	.out(dirty3_out)
);


register #(.width(11)) tag0
(
	.clk,
	.load((((lru_out == 3'b000) & mem_write & ~hit) | (hit & (hit_id == 3'b000) & mem_write)) & (~evict & ~w_mux_sel)),	
	.in(tag),
	.out(tag0_out)
);

register #(.width(11)) tag1
(
	.clk,
	.load((((lru_out == 3'b001) & mem_write & ~hit) | (hit & (hit_id == 3'b001) & mem_write)) & (~evict & ~w_mux_sel)),
	.in(tag),
	.out(tag1_out)
);

register #(.width(11)) tag2
(
	.clk,
	.load((((lru_out == 3'b010) & mem_write & ~hit) | (hit & (hit_id == 3'b010) & mem_write)) & (~evict & ~w_mux_sel)),		
	.in(tag),
	.out(tag2_out)
);

register #(.width(11)) tag3
(
	.clk,
	.load((((lru_out == 3'b011) & mem_write & ~hit) | (hit & (hit_id == 3'b011) & mem_write)) & (~evict & ~w_mux_sel)),
	.in(tag),
	.out(tag3_out)
);

register #(.width(256)) data0
(
	.clk,
	.load((((lru_out == 3'b000) & mem_write & ~hit) | (hit & (hit_id == 3'b000) & mem_write)) & (~evict & ~w_mux_sel)),
	.in(mem_wdata),
	.out(data0_out)
);

register #(.width(256)) data1
(
	.clk,
	.load((((lru_out == 3'b001) & mem_write & ~hit) | (hit & (hit_id == 3'b001) & mem_write)) & (~evict & ~w_mux_sel)),
	.in(mem_wdata),
	.out(data1_out)
);

register #(.width(256)) data2
(
	.clk,
	.load((((lru_out == 3'b010) & mem_write & ~hit) | (hit & (hit_id == 3'b010) & mem_write)) & (~evict & ~w_mux_sel)),
	.in(mem_wdata),
	.out(data2_out)
);

register #(.width(256)) data3
(
	.clk,
	.load((((lru_out == 3'b011) & mem_write & ~hit) | (hit & (hit_id == 3'b011) & mem_write)) & (~evict & ~w_mux_sel)),	
	.in(mem_wdata),
	.out(data3_out)
);

register #(.width(1)) valid4
(
	.clk,
	.load((lru_out == 3'b100) & mem_write),
	.in(1'b1),
	.out(valid4_out)
);


register #(.width(1)) valid5
(
	.clk,
	.load((lru_out == 3'b101) & mem_write),
	.in(1'b1),
	.out(valid5_out)
);

register #(.width(1)) valid6
(
	.clk,
	.load((lru_out == 3'b110) & mem_write),
	.in(1'b1),
	.out(valid6_out)
);

register #(.width(1)) valid7
(
	.clk,
	.load((lru_out == 3'b111) & mem_write),
	.in(1'b1),
	.out(valid7_out)
);

register #(.width(1)) dirty4
(
	.clk,
	.load((((lru_out == 3'b100) & mem_write & ~hit) | (hit & (hit_id == 3'b100) & mem_write) | w_mux_sel)),
	.in(dirty & ~w_mux_sel),
	.out(dirty4_out)
);


register #(.width(1)) dirty5
(
	.clk,
	.load((((lru_out == 3'b101) & mem_write & ~hit) | (hit & (hit_id == 3'b101) & mem_write) | w_mux_sel)),
	.in(dirty & ~w_mux_sel),
	.out(dirty5_out)
);

register #(.width(1)) dirty6
(
	.clk,
	.load((((lru_out == 3'b110) & mem_write & ~hit) | (hit & (hit_id == 3'b110) & mem_write) | w_mux_sel)),
	.in(dirty & ~w_mux_sel),
	.out(dirty6_out)
);

register #(.width(1)) dirty7
(
	.clk,
	.load((((lru_out == 3'b111) & mem_write & ~hit) | (hit & (hit_id == 3'b111) & mem_write) | w_mux_sel)),
	.in(dirty & ~w_mux_sel),
	.out(dirty7_out)
);


register #(.width(11)) tag4
(
	.clk,
	.load((((lru_out == 3'b100) & mem_write & ~hit) | (hit & (hit_id == 3'b100) & mem_write)) & (~evict & ~w_mux_sel)),	
	.in(tag),
	.out(tag4_out)
);

register #(.width(11)) tag5
(
	.clk,
	.load((((lru_out == 3'b101) & mem_write & ~hit) | (hit & (hit_id == 3'b101) & mem_write)) & (~evict & ~w_mux_sel)),
	.in(tag),
	.out(tag5_out)
);

register #(.width(11)) tag6
(
	.clk,
	.load((((lru_out == 3'b110) & mem_write & ~hit) | (hit & (hit_id == 3'b110) & mem_write)) & (~evict & ~w_mux_sel)),		
	.in(tag),
	.out(tag6_out)
);

register #(.width(11)) tag7
(
	.clk,
	.load((((lru_out == 3'b111) & mem_write & ~hit) | (hit & (hit_id == 3'b111) & mem_write)) & (~evict & ~w_mux_sel)),
	.in(tag),
	.out(tag7_out)
);

register #(.width(256)) data4
(
	.clk,
	.load((((lru_out == 3'b100) & mem_write & ~hit) | (hit & (hit_id == 3'b100) & mem_write)) & (~evict & ~w_mux_sel)),
	.in(mem_wdata),
	.out(data4_out)
);

register #(.width(256)) data5
(
	.clk,
	.load((((lru_out == 3'b101) & mem_write & ~hit) | (hit & (hit_id == 3'b101) & mem_write)) & (~evict & ~w_mux_sel)),
	.in(mem_wdata),
	.out(data5_out)
);

register #(.width(256)) data6
(
	.clk,
	.load((((lru_out == 3'b110) & mem_write & ~hit) | (hit & (hit_id == 3'b110) & mem_write)) & (~evict & ~w_mux_sel)),
	.in(mem_wdata),
	.out(data6_out)
);

register #(.width(256)) data7
(
	.clk,
	.load((((lru_out == 3'b111) & mem_write & ~hit) | (hit & (hit_id == 3'b111) & mem_write)) & (~evict & ~w_mux_sel)),	
	.in(mem_wdata),
	.out(data7_out)
);


eight_way_lrulogic eight_way_lrulogic
(
	.hit(hit_id),
	.cState(lruarray_out),
	.lru(lru_out),
	.newState(truelrulogic_out)
);

register #(.width(21)) lru
(
	.clk,
	.load(mem_resp & ~control_resp),
	.in(truelrulogic_out),
	.out(lruarray_out)
);


endmodule : victimcache_datapath