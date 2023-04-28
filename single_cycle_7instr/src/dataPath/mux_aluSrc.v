module mux_aluSrc (
    busB,
    imm32,
    aluSrc,
    mux_alu_out
);
    input [31:0] busB, imm32;
    input aluSrc;
    output reg [31:0] mux_alu_out;

    always @(*) begin
        case (aluSrc)
            0:  mux_alu_out = busB;
            1:  mux_alu_out = imm32; 
            default: mux_alu_out = 0;
        endcase
    end
    
endmodule