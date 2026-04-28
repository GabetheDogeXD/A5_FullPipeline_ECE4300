`timescale 1ns / 1ps
/*
Takes in 6 bit of s_extendout with alu_op and outputs select, which is the control.
for alu.v This bridges machine language with assembly language.
*/
module alu_control(         //correctly 
    input wire [5:0] funct, //from ID/EX latch
    input wire [1:0] aluop,
    output reg [2:0] select
);

/*
ALU Control:
ALUOp = 00 -> add    (lw, sw)
ALUOp = 01 -> sub    (beq)
ALUOp = 10 -> use funct field (R-type)
ALUOp = 11 -> invalid

The ALU parameters were completely replaced as they could 
*/

localparam ALUand = 3'b000;
localparam ALUor  = 3'b001;
localparam ALUadd = 3'b010;
localparam ALUx   = 3'b011;
localparam ALUsub = 3'b110;
localparam ALUslt = 3'b111;

localparam FUNCTadd = 6'b100000;
localparam FUNCTsub = 6'b100010;
localparam FUNCTand = 6'b100100;
localparam FUNCTor  = 6'b100101;
localparam FUNCTslt = 6'b101010;

always @(*) begin
    case (aluop)
        2'b00: select = ALUadd;   // lw, sw
        2'b01: select = ALUsub;   // beq
        2'b10: begin               // R-type
            case (funct)
                FUNCTadd: select = ALUadd;
                FUNCTsub: select = ALUsub;
                FUNCTand: select = ALUand;
                FUNCTor : select = ALUor;
                FUNCTslt: select = ALUslt;
                default : select = ALUx;
            endcase
        end
        default: select = ALUx;
    endcase
end

endmodule