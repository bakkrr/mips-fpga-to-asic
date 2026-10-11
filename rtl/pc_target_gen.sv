// PC+4, branch-target and jump-target generation (combinational).
// Small helper so the top level stays clean; may also be inlined in mips_single_cycle.
module pc_target_gen (
    input  logic [31:0] i_pc,
    input  logic [31:0] i_instruction,
    output logic [31:0] o_pc_plus_4,
    output logic [31:0] o_branch_target,
    output logic [31:0] o_jump_target
);
    assign o_pc_plus_4     = i_pc + 32'd4;
    assign o_branch_target = o_pc_plus_4 + ({{16{i_instruction[15]}}, i_instruction[15:0]} << 2);
    assign o_jump_target   = {o_pc_plus_4[31:28], i_instruction[25:0], 2'b00};
endmodule
