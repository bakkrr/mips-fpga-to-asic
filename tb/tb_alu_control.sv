`timescale 1ns/1ps
module tb_alu_control;
    logic [1:0] alu_op;
    logic [5:0] funct;
    logic [2:0] ctrl;
    int errors = 0;

    alu_control dut (.i_alu_op(alu_op), .i_funct(funct), .o_alu_ctrl(ctrl));

    task automatic check(input [1:0] op, input [5:0] f, input [2:0] exp);
        alu_op = op; funct = f; #1;
        if (ctrl !== exp) begin
            errors++;
            $display("FAIL: aluop=%b funct=%b -> %b (exp %b)", op, f, ctrl, exp);
        end
    endtask

    initial begin
        check(2'b00, 6'b000000, 3'b010);  // addi/lw/sw -> ADD
        check(2'b01, 6'b000000, 3'b110);  // beq -> SUB
        check(2'b11, 6'b000000, 3'b000);  // andi -> AND
        check(2'b10, 6'b100000, 3'b010);  // add
        check(2'b10, 6'b100010, 3'b110);  // sub
        check(2'b10, 6'b100100, 3'b000);  // and
        check(2'b10, 6'b100101, 3'b001);  // or
        check(2'b10, 6'b101010, 3'b111);  // slt
        // funct must be ignored for non-R-type ALUOp
        for (int f = 0; f < 64; f++) begin
            check(2'b00, f[5:0], 3'b010);
            check(2'b01, f[5:0], 3'b110);
            check(2'b11, f[5:0], 3'b000);
        end

        if (errors == 0) $display("tb_alu_control: PASS");
        else             $display("tb_alu_control: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
