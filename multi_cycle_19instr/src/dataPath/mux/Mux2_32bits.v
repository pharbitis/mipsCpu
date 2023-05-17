module Mux2_32bits (
    choice,
    a, 
    b,
    out
);
    input choice;
    input [31:0] a, b;
    output reg [31:0] out;

    always @(*) begin
        case (choice)
            1'b0:   out = a;
            1'b1:   out = b; 
        endcase
    end
endmodule