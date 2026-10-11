// Next-PC selection. Priority: jump > taken branch > PC+4.
module next_pc_logic (
    input  logic [31:0] i_pc_plus_4,
    input  logic [31:0] i_branch_target,
    input  logic [31:0] i_jump_target,
    input  logic        i_branch_taken,
    input  logic        i_jump,
    output logic [31:0] o_next_pc
);
    always_comb begin
        if (i_jump)               o_next_pc = i_jump_target;
        else if (i_branch_taken)  o_next_pc = i_branch_target;
        else                      o_next_pc = i_pc_plus_4;
    end
endmodule
