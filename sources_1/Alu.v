`timescale 1ns / 1ps
/*
ALU for execute stage
Takes in rdata1 as its input as well as "b," which is the output of top_mux.
It outputs result, later known as aluout, and zero, which is then aluzero for ex_mem.v.
This handles the logical and arithmetic correspondence.
*/

module alu(               // alu moduele is good
    input wire [31:0] a,        // source from register
    input wire [31:0] b,        // target from register
    input wire [2:0] control,   // select from alu_control
    output reg [31:0] result,   // goes to MEM Data memory and MEM/WB latch
    output wire zero            // goes to MEM Branch
    );
 
 /*   
        This lab section mismatches the alu instructions 
 
// Based on Lab 3-2 Instruction Operation and ALU control
parameter ALUadd = 3'b010,
    ALUsub = 3'b110,
    ALUand = 3'b000,     
    ALUor = 3'b001,
    ALUslt = 3'b111;
// Handles negative inputs
wire sign_mismatch; // 1 bit
//assign sign_mismatch = 1'b0; // Set this up so that the ALUslt conditions match
assign sign_mismatch = a[31]^b[31]; //XOR operation; only returns 1 if bits are different 
initial
    result <= 0;
*/

            //local params replaces the segment above 
localparam ALUand = 3'b000;     //000 is and
localparam ALUor  = 3'b001;     //001 is or
localparam ALUadd = 3'b010;     //010 is add
localparam ALUsub = 3'b110;     //110 is subtract
localparam ALUslt = 3'b111;     //111 is set on less than
localparam ALUx   = 3'b011;     //011 invalid sets to x as originally written below

always@(*) begin                //added begin to this always block
    case(control)               //the following segment is rearanged to fit new parameters
        ALUand: result = a & b; // changed to bit-wise AND, should not be logical AND
        ALUor: result  = a | b; // changes to bit-wise OR,  should not be logical OR
        ALUadd: result = a + b;
        ALUsub: result = a - b;
        ALUslt: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; //a better way to phrase the stl logic
        default: result = 32'd0; // control = ALUx | *
        
        //ALUslt: result = a < b ? 1 - sign_mismatch // (1)  original 
        //                      : 0 + sign_mismatch; // (0)
       
    endcase
end

// check to see if result is equal to zero. if it is assign it true (1), false (0) otherwise, meaning it is a non-zero number
/* result = (condition1) ? rA :
(condition2) ? rB :
                                 rC) 
assign zero = (result == 0) ? 1 : 0;
*/

assign zero = (result == 32'd0); //fixed this assign 0

endmodule

//If the input information does not correspond to any valid instruction,
//aluop = 2'b11 which sets control = ALUx = 3'b011 
//and ALU output is 32 x's





//All of bottom mux doesnt work
/*
Bottom Mux (5 bit)
`timescale 1ns / 1ps
Implements a multiplexer that selects from two inputs (5 bits), a and b, based 
on the sel input. 
Its inputs are instrout_1511 and instrout_2016 from ID/EX latch, and regdst.
The output is muxout, which is sent to EX/MEM latch. 
module bottom_mux(
//#(parameter BITS = 32)(
output wire [4:0] y, //[BITS-1:0] y, Output of Multiplexer
input wire [4:0] a, //[BITS-1:0] a, Input 1 of Multiplexer b, // Input 0 of Multiplexer
input wire sel // Select Input
   );   
   assign y = sel ? a : b;
endmodule // mux
*/