module instrMem
(
    input  wire [31:0] addr,
    output wire [31:0] data
);

   reg [31:0] memory [0:255];

  initial begin
        $readmemb("instr.txt", memory);
  end

       // word addressed instruction memory
    assign data = memory[addr[31:2]];

endmodule