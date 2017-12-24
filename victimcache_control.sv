
module victimcache_control
(
    /* Input and output port declarations */

	 input clk,

	/* Datapath controls */

    /* Physical Memory signals */
	 input pmem_resp,
    output logic pmem_read,
    output logic pmem_write,
	 
	 /* Cache Memory signals */
    input mem_read,
    input mem_write,
	 
	 /* Datapath Signals */
	 input hit,
	 input evict,
	 output logic control_resp,
	 output logic r_mux_sel,
	 output logic w_mux_sel
);

enum int unsigned {
    /* List of states */
	 resp,
	 write,
	 read,
	 done_read
} state, next_state;

always_comb
begin : state_actions
   /* Default output assignments */
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	control_resp = 1'b0;
	r_mux_sel = 1'b0;
	w_mux_sel = 1'b0;
	
	
   /* Actions for each state */
	case(state)
		resp: begin

		end
		write: begin
			pmem_write = 1'b1;
			w_mux_sel = 1'b1;
		end
		read: begin
			pmem_read = 1'b1;
		end
		done_read: begin
			control_resp = 1'b1;
			r_mux_sel = 1'b1;
		end
		default: /* Do nothing */;
	endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	 next_state = state;
	case(state)
		resp: begin
			if(mem_read & ~hit) begin
				next_state = read;
			end
			if(evict) begin
				next_state = write;
			end
		end
		write: begin
			next_state = resp;
			if(pmem_resp == 1'b0)
				next_state = write;
		end
		read: begin
			next_state = done_read;
			if(pmem_resp == 1'b0)
				next_state = read;
		end
		done_read: begin
			next_state = resp;
		end
		default: /* Do nothing */;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end

endmodule : victimcache_control
