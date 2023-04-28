module mux_memToReg (
    alu_out,
    dm_out,
    memToReg,
    mux_memToReg_out
);
    input [31:0] alu_out, dm_out;
    input memToReg;
    output reg [31:0] mux_memToReg_out;

    always @(*) begin
        case (memToReg)
            0:  mux_memToReg_out = alu_out;
            1:  mux_memToReg_out = dm_out; 
            default: mux_memToReg_out = 0;
        endcase
    end

endmodule