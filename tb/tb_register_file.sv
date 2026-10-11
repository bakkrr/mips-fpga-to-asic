`timescale 1ns/1ps
module tb_register_file;
    logic clk = 0;
    logic we;
    logic [4:0] ra1, ra2, wa;
    logic [31:0] wd, rd1, rd2;
    logic [31:0] ref_regs [32];
    int errors = 0;

    register_file dut (.clk(clk), .i_reg_write(we), .i_raddr1(ra1), .i_raddr2(ra2),
                       .i_waddr(wa), .i_wdata(wd), .o_rdata1(rd1), .o_rdata2(rd2));

    always #5 clk = ~clk;

    task automatic expect_rd(input [4:0] a1, a2);
        ra1 = a1; ra2 = a2; #1;
        if (rd1 !== ref_regs[a1] || rd2 !== ref_regs[a2]) begin
            errors++;
            $display("FAIL: read r%0d=%h (exp %h), r%0d=%h (exp %h)",
                     a1, rd1, ref_regs[a1], a2, rd2, ref_regs[a2]);
        end
    endtask

    task automatic write(input [4:0] a, input [31:0] d, input en);
        @(negedge clk);
        we = en; wa = a; wd = d;
        @(posedge clk); #1;
        if (en && a != 0) ref_regs[a] = d;
        we = 0;
    endtask

    initial begin
        for (int i = 0; i < 32; i++) ref_regs[i] = 32'd0;
        we = 0; wa = 0; wd = 0; ra1 = 0; ra2 = 0;
        #12;

        // all registers read zero initially
        for (int i = 0; i < 32; i++) expect_rd(i, 31 - i);

        // write every register with a distinct pattern (including r0 attempt)
        for (int i = 0; i < 32; i++) write(i, 32'hA5A50000 + i, 1);
        for (int i = 0; i < 32; i++) expect_rd(i, 31 - i);

        // r0 must still be zero
        expect_rd(0, 0);
        if (rd1 !== 32'd0) begin errors++; $display("FAIL: r0 not zero"); end

        // write enable low -> no change
        write(5'd7, 32'hDEADBEEF, 0);
        expect_rd(7, 7);

        // write is synchronous: value must not appear before the clock edge
        @(negedge clk);
        we = 1; wa = 5'd9; wd = 32'h12345678; ra1 = 5'd9; #1;
        if (rd1 === 32'h12345678) begin errors++; $display("FAIL: write not synchronous"); end
        @(posedge clk); #1; we = 0; ref_regs[9] = 32'h12345678;
        expect_rd(9, 9);

        // random traffic
        for (int i = 0; i < 2000; i++) begin
            write($urandom_range(0,31), $urandom, $urandom_range(0,1));
            expect_rd($urandom_range(0,31), $urandom_range(0,31));
        end

        if (errors == 0) $display("tb_register_file: PASS");
        else             $display("tb_register_file: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
