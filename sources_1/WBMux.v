module WBMux(
    input wire [31:0] ReadData,
    input wire [31:0] MEM_ALU_Result,
    input wire MemToReg,
    output wire [31:0] WriteData
);

assign WriteData = MemToReg ? ReadData : MEM_ALU_Result;

endmodule