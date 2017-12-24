package lc3b_types;

typedef logic [15:0] lc3b_word;
typedef logic  [7:0] lc3b_byte;

typedef logic  [8:0] lc3b_offset9;
typedef logic  [5:0] lc3b_offset6;

typedef logic  [2:0] lc3b_reg;
typedef logic  [2:0] lc3b_nzp;
typedef logic  [1:0] lc3b_mem_wmask;

typedef logic  [127:0] lc3b_cline;

typedef enum bit [3:0] {
    op_add  = 4'b0001,
    op_and  = 4'b0101,
    op_br   = 4'b0000,
    op_jmp  = 4'b1100,   /* also RET */
    op_jsr  = 4'b0100,   /* also JSRR */
    op_ldb  = 4'b0010,
    op_ldi  = 4'b1010,
    op_ldr  = 4'b0110,
    op_lea  = 4'b1110,
    op_not  = 4'b1001,
    op_rti  = 4'b1000,
    op_shf  = 4'b1101,
    op_stb  = 4'b0011,
    op_sti  = 4'b1011,
    op_str  = 4'b0111,
    op_trap = 4'b1111
} lc3b_opcode;

typedef enum bit [3:0] {
    alu_add,
    alu_and,
    alu_not,
    alu_pass,
    alu_sll,
    alu_srl,
    alu_sra
} lc3b_aluop;

typedef struct packed {
	lc3b_opcode opcode;
	lc3b_aluop aluop;
	logic load_cc;
	logic load_regfile;
	logic pc_mux_sel;
	logic lea_mux_sel;
	logic[1:0] instr_addr_mux_sel;
	logic jsr_mux_sel;
	logic op1_mux_sel;
	logic[2:0] op2_mux_sel;
	logic sr2_mux_sel;
	logic mar_mux_sel;
	logic[1:0] mdr_mux_sel;
	logic[2:0] aux_mdr_mux_sel;
	logic store_mux_sel;
	logic read;
	logic write;
	logic indirect_rw;
	logic[1:0] use_op;
} lc3b_control_word;

endpackage : lc3b_types
