`timescale 1ns/1ps
module tb_imm_extender;
    logic [15:0] imm;
    logic        zext;
    logic [31:0] out;
    int errors = 0;

    imm_extender dut (.i_immediate(imm), .i_zero_extend(zext), .o_immediate_ext(out));

    initial begin
        // exhaustive over all 16-bit values, both modes
        for (int z = 0; z < 2; z++) begin
            for (int i = 0; i < 65536; i++) begin
                imm = i[15:0]; zext = z[0]; #1;
                if (out !== (zext ? {16'd0, imm} : {{16{imm[15]}}, imm})) begin
                    errors++;
                    if (errors < 10) $display("FAIL: imm=%h zext=%b out=%h", imm, zext, out);
                end
            end
        end
        // spot checks from the spec programs
        imm = 16'hFFFF; zext = 0; #1; if (out !== 32'hFFFFFFFF) errors++;
        imm = 16'h8001; zext = 1; #1; if (out !== 32'h00008001) errors++;

        if (errors == 0) $display("tb_imm_extender: PASS");
        else             $display("tb_imm_extender: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
