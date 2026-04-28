/*This bit-wise ANDs the branch and zero, indicating if a jump to an address is necessary.
The output, PCSrc, goes to mux.v from the Fetch Stage. If PCSrc is true, then there is a branch jump,
otherwise there is not.  
*/
module AND(
input wire clk,
input wire membranch, zero,
output reg PCSrc
    );
always @(posedge clk) begin 
    PCSrc <= membranch & zero;
   end
endmodule