// ALU control: ALUOp + funct -> 3-bit ALU control.
module alu_control (
    input  logic [1:0] i_alu_op,
    input  logic [5:0] i_funct,
    output logic [2:0] o_alu_ctrl
);
    always_comb begin
        o_alu_ctrl = 3'b010; // safe default: ADD
        case (i_alu_op)
            2'b00: o_alu_ctrl = 3'b010;          // addi, lw, sw
            2'b01: o_alu_ctrl = 3'b110;          // beq
            2'b11: o_alu_ctrl = 3'b000;          // andi
            2'b10: begin                         // R-type
                case (i_funct)
                    6'b100000: o_alu_ctrl = 3'b010; // add
                    6'b100010: o_alu_ctrl = 3'b110; // sub
                    6'b100100: o_alu_ctrl = 3'b000; // and
                    6'b100101: o_alu_ctrl = 3'b001; // or
                    6'b101010: o_alu_ctrl = 3'b111; // slt
                    default:   o_alu_ctrl = 3'b010;
                endcase
            end
            default: o_alu_ctrl = 3'b010;
        endcase
    end
endmodule
