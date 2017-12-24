import lc3b_types::*;

module cpu
(
	input clk,
	input lc3b_word instr_rdata, data_rdata,
	input instr_resp, data_resp,
	output lc3b_word instr_addr, data_addr, data_wdata,
	output logic instr_read, data_read, data_write,
	output lc3b_mem_wmask data_mask
);

parameter local_size = 8;
parameter global_size = 6;

/* Global Signals */
logic reset, stall;
logic ld_if_id, ld_id_ex, ld_ex_mem, ld_mem_wb;
logic r_if_id, r_id_ex, r_ex_mem, r_mem_wb;

initial reset = 0;

/* Instruction Fetch */
lc3b_word pc_mux_out;
lc3b_word pc_out, ir_out, lea_out;
lc3b_word instr_addr_mux_out, lea_mux_out;
logic bran_pred, br_pr_out;
lc3b_word br_add_out, old_mux_out;

/* Instruction Decode */
lc3b_control_word id_cw;
lc3b_word sr1_out, sr2_out;
lc3b_word adj9_out, adj11_out;
lc3b_word op1_mux_out, op2_mux_out;
lc3b_word jsr_mux_out;
lc3b_reg sr2_mux_out;
logic df1, df2, jmp_con;
logic[1:0] df1_mux_sel, df2_mux_sel;
lc3b_word df1_mux_out, df2_mux_out, jmp_mux_out;

/* Execute */
lc3b_control_word ex_cw;
lc3b_reg ex_dest_out;
lc3b_word op1_out, op2_out, ex_sr2_out;
lc3b_word alu_out, mar_mux_out;
logic ex_br_taken;
logic[1:0] if_pred, id_pred, ex_pred, mem_pred;
logic[local_size-1:0] id_local_index, ex_local_index, mem_local_index;
logic[global_size-1:0] if_global_index, id_global_index, ex_global_index, mem_global_index;

/* Memory */
lc3b_control_word mem_cw;
lc3b_word mar_out, mem_mdr_out, mdr_mux_out, aux_mdr_mux_out, dat_addr_mux_out;
lc3b_reg mem_dest_out;
logic[2:0] gencc_out, cc_out;
logic cc_check_out, br_taken, indirect_out, indirect_op;

/* Write Back */
lc3b_control_word wb_cw;
lc3b_word wb_mdr_out;
lc3b_reg wb_dest_out, store_mux_out;


/* Assignments */
assign instr_addr = old_mux_out;
assign data_addr = dat_addr_mux_out;
assign data_wdata = aux_mdr_mux_out;
assign instr_read = ~reset & ~jmp_con;
assign data_read = (mem_cw.read & ~indirect_op) | indirect_op;
assign data_write = mem_cw.write & ~indirect_op;
assign data_mask = {~(mem_cw.aux_mdr_mux_sel[1] & ~data_addr[0]), ~(mem_cw.aux_mdr_mux_sel[1] & data_addr[0])};
assign br_add_out = pc_out + jsr_mux_out;
assign cc_check_out = (mem_cw.opcode == op_br) & (br_taken ^ (|(mem_dest_out & cc_out)));

assign ld_if_id = ld_id_ex | (cc_check_out & instr_resp);
assign ld_id_ex = instr_resp & ~(df1 | df2 | (jmp_con & (id_cw.instr_addr_mux_sel == 2))) & ld_ex_mem;
assign ld_ex_mem = ld_mem_wb & ~indirect_op;
assign ld_mem_wb = (~(mem_cw.write | mem_cw.read) | data_resp) & ~cc_check_out;
assign r_if_id = reset;
assign r_id_ex = reset | cc_check_out | (ld_ex_mem & ~ld_id_ex);
assign r_ex_mem = reset | (cc_check_out & instr_resp) | (ld_mem_wb & ~ld_ex_mem & ~indirect_op);
assign r_mem_wb = reset | (~ld_mem_wb & ~indirect_out);
assign indirect_op = ~indirect_out & mem_cw.indirect_rw;


/* Instruction Fetch */

mux #(.width(16)) pc_mux
(
	.sel(id_cw.pc_mux_sel),
	.in({old_mux_out + 16'h2, instr_rdata}),
	.out(pc_mux_out)
);

mux #(.width(16), .selects(2)) instr_addr_mux
(
	.sel(id_cw.instr_addr_mux_sel),
	.in({pc_out, br_add_out, jmp_mux_out, adj9_out}),
	.out(instr_addr_mux_out)
);

mux #(.width(16), .selects(1)) lea_mux
(
	.sel(id_cw.lea_mux_sel),
	.in({pc_out, br_add_out}),
	.out(lea_mux_out)
);

mux #(.width(16)) old_mux
(
	.sel(cc_check_out),
	.in({instr_addr_mux_out, mar_out}),
	.out(old_mux_out)
);

branch_predictor #(.gs(global_size), .ls(local_size)) br_pr
(
	.clk,
	.nzp(instr_rdata[11:9] & ~{3{(id_cw.opcode == op_trap)}}),
	.cc((gencc_out & {3{mem_cw.load_cc}}) | (cc_out & {3{~mem_cw.load_cc}})),
	.ex_ld_cc(id_cw.load_cc & ~cc_check_out),
	.mem_ld_cc(ex_cw.load_cc & ~cc_check_out),
	.out(bran_pred),
	.update((mem_cw.opcode == op_br) & (mem_cw.aluop == alu_pass) & (ld_ex_mem | r_ex_mem)),
	.result(|(mem_dest_out & cc_out)),
	.l_index(instr_addr[local_size:1]),
	.lup_index(mem_local_index),
	.gup_index(mem_global_index),
	.g_index(if_global_index),
	.pred_in(mem_pred),
	.pred_out(if_pred)
);

if_id #(.gs(global_size), .ls(local_size)) if_id
(
	.clk, 
	.reset(r_if_id),
	.load_if_id(ld_if_id),
	.pc_in(pc_mux_out),
	.ir_in(instr_rdata & ~{16{(id_cw.opcode == op_trap)}}),
	.br_pr_in(bran_pred),
	.pc_out(pc_out),
	.ir_out(ir_out),
	.br_pr_out(br_pr_out),
	.local_index_in(instr_addr[local_size:1]),
	.local_index_out(id_local_index),
	.global_index_in(if_global_index),
	.global_index_out(id_global_index),
	.pred_in(if_pred),
	.pred_out(id_pred)
);

/* Instruction Decode */

mux #(.width(16)) jsr_mux
(
	.sel(id_cw.jsr_mux_sel),
	.in({ adj9_out, adj11_out}),
	.out(jsr_mux_out)
);

adj #(.width(9)) adj9
(
	.in(ir_out[8:0]),
	.out(adj9_out)
);

adj #(.width(11)) adj11
(
	.in(ir_out[10:0]),
	.out(adj11_out)
);

mux #(.width(3)) store_mux
(
	.sel(id_cw.store_mux_sel),
	.in({ir_out[11:9], 3'b111}),
	.out(store_mux_out)
);

control_logic cl
(
	.opcode(lc3b_opcode'(ir_out[15:12])),
	.bit11(ir_out[11]),
	.bit5(ir_out[5]),
	.bit4(ir_out[4]),
	.br_pr(br_pr_out),
	.out(id_cw)
);

mux #(.width(16)) op1_mux
(
	.sel(id_cw.op1_mux_sel),
	.in({df1_mux_out, lea_mux_out}),
	.out(op1_mux_out)
);

mux #(.width(16), .selects(3)) op2_mux
(
	.sel(id_cw.op2_mux_sel),
	.in({df2_mux_out, {{11{ir_out[4]}}, ir_out[4:0]}, {12'b0, ir_out[3:0]}, {{10{ir_out[5]}}, ir_out[5:0]}, {{9{ir_out[5]}}, ir_out[5:0], 1'b0}, 48'b0}),
	.out(op2_mux_out)
);

mux #(.width(3)) sr2_mux
(
	.sel(id_cw.sr2_mux_sel),
	.in({ir_out[2:0], ir_out[11:9]}),
	.out(sr2_mux_out)
);

data_forward op1_df
(
	.use_op(id_cw.use_op[1]),
	.sr_reg(ir_out[8:6]),
	.ld_reg_ex(ex_cw.load_regfile),
	.ld_reg_mem(mem_cw.load_regfile),
	.ld_reg_wb(wb_cw.load_regfile),
	.dest_ex(ex_dest_out),
	.dest_mem(mem_dest_out),
	.dest_wb(wb_dest_out),
	.indirect(indirect_out),
	.r_ex(ex_cw.read),
	.r_mem(mem_cw.read),
	.indirect_op,
	.mem_resp(data_resp),
	.conflict(df1), 
	.df_mux_sel(df1_mux_sel),
	.jmp_conflict(jmp_con)
);

data_forward op2_df
(
	.use_op(id_cw.use_op[0]),
	.sr_reg(sr2_mux_out),
	.ld_reg_ex(ex_cw.load_regfile),
	.ld_reg_mem(mem_cw.load_regfile),
	.ld_reg_wb(wb_cw.load_regfile),
	.dest_ex(ex_dest_out),
	.dest_mem(mem_dest_out),
	.dest_wb(wb_dest_out),
	.indirect(indirect_out),
	.r_ex(ex_cw.read),
	.r_mem(mem_cw.read),
	.indirect_op,
	.mem_resp(data_resp),
	.conflict(df2), 
	.df_mux_sel(df2_mux_sel)
);

mux #(.width(16), .selects(2)) df1_mux
(
	.sel(df1_mux_sel),
	.in({sr1_out, alu_out, mdr_mux_out, wb_mdr_out}),
	.out(df1_mux_out)
);

mux #(.width(16), .selects(2)) df2_mux
(
	.sel(df2_mux_sel),
	.in({sr2_out, alu_out, mdr_mux_out, wb_mdr_out}),
	.out(df2_mux_out)
);

mux #(.width(16), .selects(2)) jmp_mux
(
	.sel(df1_mux_sel),
	.in({sr1_out, 16'h0, mar_out, wb_mdr_out}),
	.out(jmp_mux_out)
);

id_ex #(.gs(global_size), .ls(local_size)) id_ex
(
	.clk, 
	.reset(r_id_ex),
	.load_id_ex(ld_id_ex),
	.cw_in(id_cw),
	.dest_in(store_mux_out),
	.op1_in(op1_mux_out),
	.op2_in(op2_mux_out),
	.sr2_in(df2_mux_out),
	.cw_out(ex_cw),
	.dest_out(ex_dest_out),
	.op1_out(op1_out),
	.op2_out(op2_out),
	.sr2_out(ex_sr2_out),
	.br_taken_in(br_pr_out),
	.br_taken_out(ex_br_taken),
	.local_index_in(id_local_index),
	.local_index_out(ex_local_index),
	.global_index_in(id_global_index),
	.global_index_out(ex_global_index),
	.pred_in(id_pred),
	.pred_out(ex_pred)
);

/* Execute */

alu alu
(
	.aluop(ex_cw.aluop),
	.a(op1_out),
	.b(op2_out),
	.f(alu_out)
);

mux #(.width(16)) mar_mux
(
	.sel(ex_cw.mar_mux_sel),
	.in({alu_out, data_rdata}),
	.out(mar_mux_out)
);

ex_mem #(.gs(global_size), .ls(local_size)) ex_mem
(
	.clk, 
	.reset(r_ex_mem),
	.load_ex_mem(ld_ex_mem),
	.cw_in(ex_cw),
	.dest_in(ex_dest_out),
	.mar_in(mar_mux_out),
	.mdr_in(ex_sr2_out),
	.cw_out(mem_cw),
	.dest_out(mem_dest_out),
	.mar_out(mar_out),
	.mdr_out(mem_mdr_out),
	.br_taken_in(ex_br_taken),
	.br_taken_out(br_taken),
	.local_index_in(ex_local_index),
	.local_index_out(mem_local_index),
	.global_index_in(ex_global_index),
	.global_index_out(mem_global_index),
	.pred_in(ex_pred),
	.pred_out(mem_pred)
);

/* Memory */

mux #(.width(16), .selects(2)) aux_mdr_mux
(
	.sel({mem_cw.aux_mdr_mux_sel[1], indirect_op | ((~mem_cw.aux_mdr_mux_sel[1] & mem_cw.aux_mdr_mux_sel[0]) | (mem_cw.aux_mdr_mux_sel[1] & mar_out[0]))}),
	.in({mem_mdr_out, data_rdata, {8'b0, mem_mdr_out[7:0]}, {mem_mdr_out[7:0], 8'b0}}),
	.out(aux_mdr_mux_out)
);

mux #(.width(16), .selects(2)) mdr_mux
(
	.sel({mem_cw.mdr_mux_sel[1], ((~mem_cw.mdr_mux_sel[1] & mem_cw.mdr_mux_sel[0]) | (mem_cw.mdr_mux_sel[1] & mar_out[0]))}),
	.in({mar_out, aux_mdr_mux_out, {8'b0, aux_mdr_mux_out[7:0]}, {8'b0, aux_mdr_mux_out[15:8]}}),
	.out(mdr_mux_out)
);

mux #(.width(16)) dat_addr_mux
(
	.sel(indirect_out),
	.in({mar_out, wb_mdr_out}),
	.out(dat_addr_mux_out)
);

gencc gencc
(
	.in(mdr_mux_out),
	.out(gencc_out)
);

register #(.width(3)) cc
(
	.clk,
	.load((mem_cw.load_cc) & ~indirect_op),
	.in(gencc_out),
	.out(cc_out)
);

mem_wb mem_wb
(
	.clk, 
	.reset(r_mem_wb),
	.load_mem_wb(ld_mem_wb),
	.cw_in(mem_cw),
	.dest_in(mem_dest_out),
	.mdr_in(mdr_mux_out),
	.indirect_in(indirect_op),
	.cw_out(wb_cw),
	.dest_out(wb_dest_out),
	.mdr_out(wb_mdr_out),
	.indirect_out(indirect_out)
);

/* Write Back */

regfile rf
(
	.clk,
   .load(wb_cw.load_regfile & ~indirect_out),
   .in(wb_mdr_out),
   .src_a(ir_out[8:6]), 
	.src_b(sr2_mux_out), 
	.dest(wb_dest_out),
   .reg_a(sr1_out), 
	.reg_b(sr2_out)
);


endmodule : cpu