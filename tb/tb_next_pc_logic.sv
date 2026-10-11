`timescale 1ns/1ps
module tb_next_pc_logic;
    // exercises pc_target_gen + next_pc_logic together
    logic [31:0] pc, instr, pc4, btarget, jtarget, next_pc;
    logic branch_taken, jump;
    int errors = 0;

    pc_target_gen tg (.i_pc(pc), .i_instruction(instr), .o_pc_plus_4(pc4),
                      .o_branch_target(btarget), .o_jump_target(jtarget));
    next_pc_logic dut (.i_pc_plus_4(pc4), .i_branch_target(btarget), .i_jump_target(jtarget),
                       .i_branch_taken(branch_taken), .i_jump(jump), .o_next_pc(next_pc));

    task automatic check(input string name, input [31:0] exp);
        #1;
        if (next_pc !== exp) begin
            errors++;
            $display("FAIL: %s next_pc=%h exp=%h", name, next_pc, exp);
        end
    endtask

    initial begin
        // Appendix A.3 values
        pc = 32'h08; instr = 32'h10220002; branch_taken = 0; jump = 0;
        check("pc+4", 32'h0C);
        branch_taken = 1;
        check("beq taken -> 0x14", 32'h14);
        pc = 32'h10; instr = 32'h08000009; branch_taken = 0; jump = 1;
        check("j finish -> 0x24", 32'h24);
        // jump has priority over a taken branch
        branch_taken = 1;
        check("jump priority", 32'h24);
        // Appendix A.4: beq R2,R0,done at 0x1C offset +2 -> 0x28
        pc = 32'h1C; instr = 32'h10400002; jump = 0; branch_taken = 1;
        check("A.4 beq -> 0x28", 32'h28);
        // backward branch (offset -1 from pc=0x20: target = 0x24 - 4 = 0x20)
        pc = 32'h20; instr = 32'h1000FFFF; branch_taken = 1;
        check("negative offset", 32'h20);
        // j end in A.1: 0800000A at 0x28 -> 0x28
        pc = 32'h28; instr = 32'h0800000A; jump = 1; branch_taken = 0;
        check("A.1 j end", 32'h28);
        // jump upper bits come from PC+4[31:28]
        pc = 32'h1000_0000; instr = 32'h08000003; jump = 1;
        check("jump upper nibble", 32'h1000_000C);

        // randomized check against a behavioral model
        for (int i = 0; i < 3000; i++) begin
            pc = {$urandom} & 32'hFFFF_FFFC;
            instr = $urandom;
            branch_taken = $urandom_range(0,1);
            jump = $urandom_range(0,1);
            #1;
            begin
                logic [31:0] p4, bt, jt, e;
                p4 = pc + 4;
                bt = p4 + ({{16{instr[15]}}, instr[15:0]} << 2);
                jt = {p4[31:28], instr[25:0], 2'b00};
                e = jump ? jt : (branch_taken ? bt : p4);
                check("random", e);
            end
        end

        if (errors == 0) $display("tb_next_pc_logic: PASS");
        else             $display("tb_next_pc_logic: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
