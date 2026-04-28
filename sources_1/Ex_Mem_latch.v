`timescale 1ns / 1ps
/*
This is the latch that receives signals form all the modules of the execute stage. 
Its outputs go to MEM/WB and FETCH.
*/

module ex_mem(
    //there were a bunch of _out wires listed to the inputs and no clk as canvas said
    input wire        clk,
    input wire rst,
    input wire [1:0]  ctlwb_in,
    input wire [2:0]  ctlm_in,
    input wire [31:0] add_result_in,
    input wire        zero_in,
    input wire [31:0] alu_result_in,
    input wire [31:0] rdata2_in,
    input wire [4:0]  muxout_in,

    output reg  [1:0]  ctlwb_out,
    output reg  [2:0]  ctlm_out,
    output reg  [31:0] add_result_out,
    output reg         zero_out,
    output reg  [31:0] alu_result_out,
    output reg  [31:0] rdata2_out,
    output reg  [4:0]  muxout_out
);

//Removed initial and changed always @(*) to always @(posedge clk) to follow the pipeline better.
always @(posedge clk or posedge rst) begin
    if (rst) begin
        ctlwb_out      <= 2'd0;
        ctlm_out       <= 3'd0;
        add_result_out <= 32'd0;
        zero_out       <= 1'b0;
        alu_result_out <= 32'd0;
        rdata2_out     <= 32'd0;
        muxout_out     <= 5'd0;
    end
    else begin
        ctlwb_out      <= ctlwb_in;
        ctlm_out       <= ctlm_in;
        add_result_out <= add_result_in;
        zero_out       <= zero_in;
        alu_result_out <= alu_result_in;
        rdata2_out     <= rdata2_in;
        muxout_out     <= muxout_in;
    end
end

endmodule