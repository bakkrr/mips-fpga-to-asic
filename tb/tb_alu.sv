`timescale 1ns/1ps
module tb_alu;
    logic [31:0] a, b, result;
    logic [2:0]  ctrl;
    logic        zero;
    int errors = 0;

    alu dut (.i_operand_a(a), .i_operand_b(b), .i_alu_ctrl(ctrl),
             .o_result(result), .o_zero(zero));

    task automatic check(input [31:0] exp);
        #1;
        if (result !== exp || zero !== (exp == 32'd0)) begin
            errors++;
            $display("FAIL: ctrl=%b a=%h b=%h -> result=%h zero=%b (exp %h)",
                     ctrl, a, b, result, zero, exp);
        end
    endtask

    function automatic [31:0] model(input [31:0] x, y, input [2:0] c);
        case (c)
            3'b000: model = x & y;
            3'b001: model = x | y;
            3'b010: model = x + y;
            3'b110: model = x - y;
            3'b111: model = ($signed(x) < $signed(y)) ? 32'd1 : 32'd0;
            default: model = 32'd0;
        endcase
    endfunction

    logic [2:0] ops [5] = '{3'b000, 3'b001, 3'b010, 3'b110, 3'b111};

    initial begin
        // directed
        ctrl = 3'b010; a = 7;  b = 3;  check(10);
        ctrl = 3'b110; a = 7;  b = 3;  check(4);
        ctrl = 3'b110; a = 5;  b = 5;  check(0);          // zero flag
        ctrl = 3'b000; a = 7;  b = 3;  check(3);
        ctrl = 3'b001; a = 7;  b = 3;  check(7);
        ctrl = 3'b111; a = 3;  b = 7;  check(1);
        ctrl = 3'b111; a = 7;  b = 3;  check(0);
        ctrl = 3'b111; a = 32'hFFFFFFFF; b = 1; check(1);  // -1 < 1 signed
        ctrl = 3'b111; a = 1; b = 32'hFFFFFFFF; check(0);
        ctrl = 3'b111; a = 32'h80000000; b = 32'h7FFFFFFF; check(1);
        ctrl = 3'b010; a = 32'hFFFFFFFF; b = 1; check(0);  // wrap
        ctrl = 3'b110; a = 0; b = 1; check(32'hFFFFFFFF);
        ctrl = 3'b011; a = 1; b = 1; check(0);             // undefined op -> 0

        // random vs. reference model
        for (int i = 0; i < 5000; i++) begin
            a = $urandom; b = $urandom; ctrl = ops[$urandom_range(0,4)];
            check(model(a, b, ctrl));
        end

        if (errors == 0) $display("tb_alu: PASS");
        else             $display("tb_alu: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
