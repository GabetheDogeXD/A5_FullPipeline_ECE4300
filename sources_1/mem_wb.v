/* This is the latch that receives signals form all the modules of the memory stage. Its outputs go to mux of WRITE-BACK Stage and FETCH.
*/
module mem_wb(
//input
input wire clk,
input wire rst,
input wire [1:0] control_wb_in,
input wire [31:0] read_data_in, alu_result_in,
input wire [4:0] write_reg_in,

//output
output reg regwrite, memtoreg, //1 bit wire
output reg [31:0] read_data, mem_alu_result,
output reg [4:0] mem_write_reg
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        regwrite       <= 1'b0;
        memtoreg       <= 1'b0;
        read_data      <= 32'd0;
        mem_alu_result <= 32'd0;
        mem_write_reg  <= 5'd0;
    end
    else begin
        regwrite       <= control_wb_in[1];
        memtoreg       <= control_wb_in[0];
        read_data      <= read_data_in;
        mem_alu_result <= alu_result_in;
        mem_write_reg  <= write_reg_in;
    end
end

endmodule