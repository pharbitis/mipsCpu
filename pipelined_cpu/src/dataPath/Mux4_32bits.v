//32位四路选择器
module Mux4_32bits(
    a,
    b,
    c,
    d,
    choice,
    out
);

    input [31:0] a, b, c, d;
    input [1:0] choice;
    output reg [31:0] out;

    always @(*) begin
        case (choice)
            0:      out <= a; 
            1:      out <= b;
            2:      out <= c;
            default: out <= d;
        endcase
    end

endmodule