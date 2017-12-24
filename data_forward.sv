import lc3b_types::*;

module data_forward 
(
	input use_op,
	input[2:0] sr_reg,
	input ld_reg_ex, ld_reg_mem, ld_reg_wb,
	input[2:0] dest_ex, dest_mem, dest_wb,
	input indirect, r_ex, r_mem, indirect_op, mem_resp,
	output logic conflict, jmp_conflict,
	output logic[1:0] df_mux_sel
);

logic ex_con, mem_con, wb_con;
logic use_ex, use_mem, use_wb;

assign ex_con = use_op & ld_reg_ex & (sr_reg == dest_ex);
assign mem_con = use_op & ld_reg_mem & (sr_reg == dest_mem);
assign wb_con = use_op & ld_reg_wb & (sr_reg == dest_wb);
assign use_ex = ex_con & ~r_ex;
assign use_mem = mem_con & ~ex_con & (~r_mem | mem_resp & ~indirect_op);
assign use_wb = wb_con & ~mem_con & ~ex_con & ~indirect;

assign conflict = (ex_con | mem_con | wb_con) & ~(use_ex | use_mem | use_wb);
assign df_mux_sel = {use_wb | use_mem, use_wb | use_ex};
assign jmp_conflict = (ex_con | mem_con | wb_con);

endmodule : data_forward