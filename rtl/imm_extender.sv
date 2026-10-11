// 16 -> 32 bit immediate extension (sign or zero).
module imm_extender (
    input  logic [15:0] i_immediate,
    input  logic        i_zero_extend,
    output logic [31:0] o_immediate_ext
);
    assign o_immediate_ext = i_zero_extend ? {16'd0, i_immediate}
                                           : {{16{i_immediate[15]}}, i_immediate};
endmodule
