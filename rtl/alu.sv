// ALU: AND / OR / ADD / SUB / SLT(signed)
module alu (
    input  logic [31:0] i_operand_a,
    input  logic [31:0] i_operand_b,
    input  logic [2:0]  i_alu_ctrl,
    output logic [31:0] o_result,
    output logic        o_zero
);
    always_comb begin
        o_result = 32'd0;                       // safe default (no latch)
        unique case (i_alu_ctrl)
            3'b000:  o_result = i_operand_a & i_operand_b;
            3'b001:  o_result = i_operand_a | i_operand_b;
            3'b010:  o_result = i_operand_a + i_operand_b;
            3'b110:  o_result = i_operand_a - i_operand_b;
            3'b111:  o_result = ($signed(i_operand_a) < $signed(i_operand_b)) ? 32'd1 : 32'd0;
            default: o_result = 32'd0;
        endcase
    end

    assign o_zero = (o_result == 32'd0);
endmodule
