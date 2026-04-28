module control(
    input  wire [5:0] opcode,
    output reg  [1:0] wb,
    output reg  [2:0] mem,
    output reg  [3:0] ex
);

    parameter RTYPE = 6'b000000;
    parameter LW    = 6'b100011;
    parameter SW    = 6'b101011;
    parameter BEQ   = 6'b000100;

    always @(*) begin
        case (opcode)
            RTYPE: begin
                wb  = 2'b10;
                mem = 3'b000;
                ex  = 4'b1100;
            end

            LW: begin
                wb  = 2'b11;
                mem = 3'b010;
                ex  = 4'b0001;
            end

            SW: begin
                wb  = 2'b00;
                mem = 3'b001;
                ex  = 4'b0001;
            end

            BEQ: begin
                wb  = 2'b00;
                mem = 3'b100;
                ex  = 4'b0010;
            end

            default: begin
                // treat unknowns as bubble / nop
                wb  = 2'b00;
                mem = 3'b000;
                ex  = 4'b0000;
            end
        endcase
    end

endmodule