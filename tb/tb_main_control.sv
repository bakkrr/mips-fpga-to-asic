`timescale 1ns/1ps
module tb_main_control;
    logic [5:0] opcode;
    logic reg_dst, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump, imm_zext;
    logic [1:0] alu_op;
    int errors = 0;

    main_control dut (.i_opcode(opcode), .o_reg_dst(reg_dst), .o_reg_write(reg_write),
        .o_alu_src(alu_src), .o_mem_read(mem_read), .o_mem_write(mem_write),
        .o_mem_to_reg(mem_to_reg), .o_branch(branch), .o_jump(jump),
        .o_imm_zero_ext(imm_zext), .o_alu_op(alu_op));

    // order: RegDst RegWrite ALUSrc MemRead MemWrite MemToReg Branch Jump ImmZeroExt ALUOp[1:0]
    task automatic check(input string name, input [5:0] op, input [11:0] exp);
        logic [11:0] got;
        opcode = op; #1;
        got = {reg_dst, reg_write, alu_src, mem_read, mem_write, mem_to_reg,
               branch, jump, imm_zext, alu_op};
        if (got !== exp) begin
            errors++;
            $display("FAIL: %s got=%b exp=%b", name, got, exp);
        end
    endtask

    initial begin
        //                         Dst Wr Src Rd Wr2 M2R Br Jmp Zx  ALUOp
        check("R-type", 6'b000000, {1'b1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,2'b10});
        check("addi",   6'b001000, {1'b0,1'b1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,2'b00});
        check("andi",   6'b001100, {1'b0,1'b1,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,2'b11});
        check("lw",     6'b100011, {1'b0,1'b1,1'b1,1'b1,1'b0,1'b1,1'b0,1'b0,1'b0,2'b00});
        check("sw",     6'b101011, {1'b0,1'b0,1'b1,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,2'b00});
        check("beq",    6'b000100, {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,2'b01});
        check("j",      6'b000010, {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,2'b00});

        // every unsupported opcode must be a harmless NOP (no write, no branch, no jump)
        for (int i = 0; i < 64; i++) begin
            if (!(i inside {6'b000000, 6'b001000, 6'b001100, 6'b100011,
                            6'b101011, 6'b000100, 6'b000010})) begin
                opcode = i[5:0]; #1;
                if (reg_write || mem_write || branch || jump) begin
                    errors++; $display("FAIL: opcode %b not a NOP", opcode);
                end
            end
        end

        if (errors == 0) $display("tb_main_control: PASS");
        else             $display("tb_main_control: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
