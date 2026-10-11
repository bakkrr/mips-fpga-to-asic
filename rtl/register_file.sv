// 32 x 32 register file: 2 combinational read ports, 1 synchronous write port.
// R0 always reads as zero; writes to R0 are ignored.
module register_file (
    input  logic        clk,
    input  logic        i_reg_write,
    input  logic [4:0]  i_raddr1,
    input  logic [4:0]  i_raddr2,
    input  logic [4:0]  i_waddr,
    input  logic [31:0] i_wdata,
    output logic [31:0] o_rdata1,
    output logic [31:0] o_rdata2
);
    logic [31:0] regs [0:31];

    // Simulation/FPGA power-up value only (ignored/harmless for ASIC flow)
    initial begin
        for (int i = 0; i < 32; i++) regs[i] = 32'd0;
    end

    always_ff @(posedge clk) begin
        if (i_reg_write && (i_waddr != 5'd0))
            regs[i_waddr] <= i_wdata;
    end

    assign o_rdata1 = (i_raddr1 == 5'd0) ? 32'd0 : regs[i_raddr1];
    assign o_rdata2 = (i_raddr2 == 5'd0) ? 32'd0 : regs[i_raddr2];
endmodule
