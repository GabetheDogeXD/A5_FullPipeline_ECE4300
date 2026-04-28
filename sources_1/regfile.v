module regfile(
    input wire          clk,
                        rst,
                        regwrite,
    input wire [4:0]    rs,
                        rt,
                        rd,
    input wire [31:0]   writedata,
    output reg [31:0]   A_readdat1,
                        B_readdat2
);

reg [31:0] REG [31:0];
integer i;

// Initialize all registers to 0 for simulation
initial begin
    for (i = 0; i < 32; i = i + 1)
        REG[i] = 32'd0;
end

// Synchronous write, synchronous reset
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 32; i = i + 1)
            REG[i] <= 32'd0;
    end
    else begin
        if (regwrite && (rd != 5'd0))
            REG[rd] <= writedata;

        REG[0] <= 32'd0; // keep r0 hardwired to zero
    end
end

// Combinational reads
always @(*) begin
    A_readdat1 = REG[rs];
    B_readdat2 = REG[rt];
end

endmodule