`timescale 1ns/1ps
module tb_pc_reg;
    logic clk = 0, rst_n = 0;
    logic [31:0] next_pc, pc;
    int errors = 0;

    pc_reg dut (.clk(clk), .rst_n(rst_n), .i_next_pc(next_pc), .o_pc(pc));
    always #5 clk = ~clk;

    task automatic expect_pc(input [31:0] exp, input string msg);
        if (pc !== exp) begin
            errors++;
            $display("FAIL: %s pc=%h exp=%h", msg, pc, exp);
        end
    endtask

    initial begin
        next_pc = 32'h0000_0100;
        #12 expect_pc(0, "held in reset");
        @(negedge clk); rst_n = 1;
        @(posedge clk); #1 expect_pc(32'h100, "capture 1");
        next_pc = pc + 4;
        @(posedge clk); #1 expect_pc(32'h104, "capture 2");
        next_pc = 32'hCAFE_BABC;
        @(posedge clk); #1 expect_pc(32'hCAFE_BABC, "capture 3");
        // async reset mid-cycle
        #1 rst_n = 0; #1 expect_pc(0, "async reset");
        @(posedge clk); #1 expect_pc(0, "stays in reset");
        rst_n = 1; next_pc = 32'h8;
        @(posedge clk); #1 expect_pc(32'h8, "resume after reset");

        if (errors == 0) $display("tb_pc_reg: PASS");
        else             $display("tb_pc_reg: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
