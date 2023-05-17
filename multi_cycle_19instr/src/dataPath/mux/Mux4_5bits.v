module Mux4_5bits (
    choice,
    a, 
    b,
    c,
    d,
    out
);
    input [1:0] choice;
    input [4:0] a, b, c, d;
    output reg [4:0] out;

    always @(*) begin
        case (choice)
            2'b00:  out = a;
            2'b01:  out = b;
            2'b10:  out = c;
            2'b11:  out = d; 
        endcase
    end
endmodule