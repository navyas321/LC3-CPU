import lc3b_types::*;

module control_logic
(
	input lc3b_opcode opcode,
	input logic bit11, bit5, bit4, br_pr,
	output lc3b_control_word out
);

always_comb begin
	out.opcode = opcode;
	out.load_cc = 1'b0;
	out.load_regfile = 1'b0;
	out.aluop = alu_pass;
	out.pc_mux_sel = 1'b0;
	out.lea_mux_sel = 1'b0;
	out.instr_addr_mux_sel = 2'b0;
	out.jsr_mux_sel = 1'b0;
	out.op1_mux_sel = 1'b0;
	out.op2_mux_sel = 3'b0;
	out.sr2_mux_sel = 1'b0;
	out.mar_mux_sel = 1'b0;
	out.mdr_mux_sel = 2'b0;
	out.aux_mdr_mux_sel = 2'b0;
	out.store_mux_sel = 1'b0;
	out.read = 1'b0;
	out.write = 1'b0;
	out.indirect_rw = 1'b0;
	out.use_op = 2'b0;
	
	case(opcode)
		op_add: begin
			out.op2_mux_sel = bit5;
			out.aluop = alu_add;
			out.load_cc = 1;
			out.load_regfile = 1;
			out.use_op = {1'b1, ~bit5};
		end
		op_and: begin
			out.op2_mux_sel = bit5;
			out.aluop = alu_and;
			out.load_cc = 1;
			out.load_regfile = 1;
			out.use_op = {1'b1, ~bit5};
		end
		op_not: begin
			out.aluop = alu_not;
			out.load_cc = 1;
			out.load_regfile = 1;
			out.use_op = 2'b10;
		end
		op_ldr: begin
			out.op2_mux_sel = 4;
			out.aluop = alu_add;
			out.read = 1;
			out.mdr_mux_sel = 1;
			out.aux_mdr_mux_sel = 1;
			out.load_cc = 1;
			out.load_regfile = 1;
			out.use_op = 2'b10;
		end
		op_str: begin
			out.op2_mux_sel = 4;
			out.aluop = alu_add;
			out.write = 1;
			out.sr2_mux_sel = 1;
			out.use_op = 2'b11;
		end
		op_br: begin
			out.instr_addr_mux_sel = {1'b0, br_pr};
			out.lea_mux_sel = ~br_pr;
			out.op1_mux_sel = 1;
			out.aluop = alu_pass;
		end
		op_jmp: begin
			out.instr_addr_mux_sel = 2;			
			out.use_op = 2'b10;
		end
		op_jsr: begin
			out.instr_addr_mux_sel = {~bit11, bit11};
			out.op1_mux_sel = 1;
			out.aluop = alu_pass;
			out.jsr_mux_sel = 1;
			out.store_mux_sel = 1;
			out.load_regfile = 1;
			out.use_op = {~bit11, 1'b0};
		end
		op_ldb: begin
			out.op2_mux_sel = 3;
			out.aluop = alu_add;
			out.read = 1;
			out.mdr_mux_sel = 2;
			out.aux_mdr_mux_sel = 1;
			out.load_cc = 1;
			out.load_regfile = 1;
			out.use_op = 2'b10;
		end
		op_ldi: begin
			out.op2_mux_sel = 4;
			out.aluop = alu_add;
			out.read = 1;
			out.mdr_mux_sel = 1;
			out.aux_mdr_mux_sel = 1;
			out.load_cc = 1;
			out.load_regfile = 1;
			out.indirect_rw = 1;
			out.use_op = 2'b10;
		end
		op_lea: begin
			out.lea_mux_sel = 1;
			out.op1_mux_sel = 1;
			out.aluop = alu_pass;
			out.load_cc = 1;
			out.load_regfile = 1;
		end
		op_shf: begin
			out.op2_mux_sel = 2;
			out.load_cc = 1;
			out.load_regfile = 1;
			if(~bit4) begin
				out.aluop = alu_sll;
			end
			else if(~bit5)
				out.aluop = alu_srl;
			else	
				out.aluop = alu_sra;
			out.use_op = 2'b10;
		end
		op_stb: begin
			out.op2_mux_sel = 3;
			out.aluop = alu_add;
			out.write = 1;
			out.sr2_mux_sel = 1;
			out.aux_mdr_mux_sel = 2;
			out.use_op = 2'b11;
		end
		op_sti: begin
			out.op2_mux_sel = 4;
			out.aluop = alu_add;
			out.write = 1;
			out.mdr_mux_sel = 1;
			out.aux_mdr_mux_sel = 0;
			out.indirect_rw = 1;
			out.sr2_mux_sel = 1;
			out.use_op = 2'b11;
		end
		op_trap: begin
			out.op1_mux_sel = 1;
			out.pc_mux_sel = 1;
			out.instr_addr_mux_sel = 3;
			out.aluop = alu_pass;
			out.store_mux_sel = 1;
			out.load_regfile = 1;
			out.lea_mux_sel = 0;
		end
		default: ;
	endcase	
end

endmodule : control_logic