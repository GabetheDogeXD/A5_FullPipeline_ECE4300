module signExtend(
    input wire [15:0] immediate,
    output wire [31:0] extended
);
    // pre-pend immediate with 16 bits of the MSB
    // Hint) {} concatenate or replicate operator 
    // Concatenate {111,100} -> 111000
    // Replicate {4{1}} -> 1111    
    assign extended = {{16{immediate[15]}}, immediate};
    
endmodule
