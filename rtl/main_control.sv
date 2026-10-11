// Main control unit (purely combinational).
module main_control (
    input  logic [5:0] i_opcode,
    output logic       o_reg_dst,
    output logic       o_reg_write,
    output logic       o_alu_src,
    output logic       o_mem_read,
    output logic       o_mem_write,
    output logic       o_mem_to_reg,
    output logic       o_branch,
    output logic       o_jump,
    output logic       o_imm_zero_ext,
    output logic [1:0] o_alu_op
);
    always_comb begin
        // safe defaults (no latches; unknown opcodes behave as NOP)
        o_reg_dst      = 1'b0;
        o_reg_write    = 1'b0;
        o_alu_src      = 1'b0;
        o_mem_read     = 1'b0;
        o_mem_write    = 1'b0;
        o_mem_to_reg   = 1'b0;
        o_branch       = 1'b0;
        o_jump         = 1'b0;
        o_imm_zero_ext = 1'b0;
        o_alu_op       = 2'b00;

        case (i_opcode)
            6'b000000: begin // R-type
                o_reg_dst   = 1'b1;
                o_reg_write = 1'b1;
                o_alu_op    = 2'b10;
            end
            6'b001000: begin // addi
                o_reg_write = 1'b1;
                o_alu_src   = 1'b1;
            end
            6'b001100: begin // andi
                o_reg_write    = 1'b1;
                o_alu_src      = 1'b1;
                o_imm_zero_ext = 1'b1;
                o_alu_op       = 2'b11;
            end
            6'b100011: begin // lw
                o_reg_write  = 1'b1;
                o_alu_src    = 1'b1;
                o_mem_read   = 1'b1;
                o_mem_to_reg = 1'b1;
            end
            6'b101011: begin // sw
                o_alu_src   = 1'b1;
                o_mem_write = 1'b1;
            end
            6'b000100: begin // beq
                o_branch = 1'b1;
                o_alu_op = 2'b01;
            end
            6'b000010: begin // j
                o_jump = 1'b1;
            end
            default: ;
        endcase
    end
endmodule
