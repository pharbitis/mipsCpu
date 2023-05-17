//32位四选一
module Mux4_32bits (
    choice,
    a,
    b,
    c,
    d,
    out
);
    input [1:0] choice;
    input [31:0] a, b, c, d;
    output reg [31:0] out;

    always @(*) begin
        case (choice)
            2'b00:  out = a;
            2'b01:  out = b;
            2'b10:  out = c;
            2'b11:  out = d; 
        endcase
    end
endmodule