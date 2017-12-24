import lc3b_types::*;

module arbiter
(
	 input clk,
	 input lc3b_word i_addr, d_addr,
	 input i_read, d_read,
	 input d_write,
	 input lc3b_cline d_wdata,
	 input l2_resp, 
	 input lc3b_cline l2_rdata,
	 output logic i_resp, d_resp,
	 output lc3b_cline i_rdata, d_rdata,
	 output lc3b_word l2_addr,
	 output logic l2_read,
	 output logic l2_write,
	 output lc3b_cline l2_wdata
);

lc3b_word addr;

enum int unsigned {
    /* List of states */
	 resp,
	 data_read,
	 data_write,
	 instr_read
} state, next_state;

always_comb
begin
	 i_resp = 0;
	 d_resp = 0;
	 i_rdata = 0;
	 d_rdata = 0;
	 addr = 0;
	 l2_read = 0;
	 l2_write = 0;
	 l2_wdata = d_wdata;
	 i_rdata = l2_rdata;
	 d_rdata = l2_rdata;
	 
	if(d_read == 1'b1)
		addr = d_addr;
	else if(d_write == 1'b1)
		addr = d_addr;
	else if(i_read == 1'b1)
		addr = i_addr;
		
	 if(state == instr_read) begin
		addr = i_addr;
		l2_read = 1'b1;
		i_resp = l2_resp;
	 end
	 
	 if(data_read == state) begin
		addr = d_addr;
		l2_read = 1'b1;
		d_resp = l2_resp;
	 end
	 
	 if(data_write == state) begin
		addr = d_addr;
		l2_write = 1'b1;
		d_resp = l2_resp;
	 end
end

always_comb
begin
	case(state)
		resp: begin
			if(d_read == 1'b1)
				next_state = data_read;
			else if(d_write == 1'b1)
				next_state = data_write;
			else if(i_read == 1'b1)
				next_state = instr_read;
			else 
				next_state = state;				
		end
		data_read: begin
			if(l2_resp == 1'b1)
				next_state = resp;
			else
				next_state = state;
		end
		data_write: begin
			if(l2_resp == 1'b1)
				next_state = resp;
			else
				next_state = state;
		end		
		instr_read: begin
			if(l2_resp == 1'b1)
				next_state = resp;
			else
				next_state = state;		
		end		
		default: /* Do nothing */;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
	 l2_addr <= addr;
end

endmodule : arbiter