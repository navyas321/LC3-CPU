
module l2cache_control
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
   output logic mem_resp,
	 
	/* Datapath Signals */
	input hit,
	input evict,
   output logic load_d,
   output logic load_tag
);

enum int unsigned {
   /* List of states */
	resp,
	write,
	read
} state, next_state;

always_comb
begin : state_actions
   /* Default output assignments */
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	mem_resp = 1'b0;
	load_d = 1'b0;
	load_tag = 1'b0;
   /* Actions for each state */
	case(state)
		resp: begin
			mem_resp = hit;
			load_d = hit & mem_write;
		end
		write: begin
			pmem_write = 1'b1;
		end
		read: begin
			pmem_read = 1'b1;
			load_tag = pmem_resp;
			load_d = pmem_resp;
		end
		default: /* Do nothing */;
	endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	next_state = resp;
	case(state)
		resp: begin
			if(mem_read | mem_write) begin
				if(hit == 1'b0) begin
					if(evict)
						next_state = write;
					else
						next_state = read;
				end
			end	
		end
		write: begin
			if(mem_read | mem_write) begin
				if(hit == 1'b0) begin
					next_state = read;
					if(pmem_resp == 1'b0)
						next_state = write;
				end
			end	
		end
		read: begin
			if(mem_read | mem_write) begin
				if(hit == 1'b0) begin
					next_state = resp;
					if(pmem_resp == 1'b0)
						next_state = read;
				end
			end
		end
		default: /* Do nothing */;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
   /* Assignment of next state on clock edge */
   state <= next_state;
end

endmodule : l2cache_control