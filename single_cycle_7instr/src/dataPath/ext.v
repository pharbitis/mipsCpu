module ext (
    imm16,          //16位立即数
    extOp,          //0进行无符号扩展1进行符号扩展
    imm32
);
    input [15:0] imm16;
    input extOp;
    output reg [31:0] imm32;

    parameter ZERO = 0, SIGN = 1;   

    always @(*) begin
        case (extOp)
            ZERO:   imm32 = {16'b0, imm16};             //无符号扩展拼接16个0
            SIGN:   imm32 = {{16{imm16[15]}}, imm16};   //符号扩展拼接符号位
            default: imm32 = 0;
        endcase    
    end
    
endmodule