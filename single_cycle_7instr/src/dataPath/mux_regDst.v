module mux_regDst (
    rd,
    rt,
    regDst,
    rw
);
    input [4:0] rd, rt;
    input regDst;
    output reg [4:0] rw;

    always @(*) begin
        case (regDst)
            0:  rw = rt;
            1:  rw = rd; 
            default: rw = rt;
        endcase
    end

endmodule