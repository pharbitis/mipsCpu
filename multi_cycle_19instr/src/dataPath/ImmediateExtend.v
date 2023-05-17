module ImmediateExtend (
    imm,            //16位立即数
    ExtSel,         //0扩展还是符号扩展
    extendOut       //结果
);
    input [15:0] imm;
    input ExtSel;
    output reg [31:0] extendOut;

    always @(*) begin
        if (ExtSel == 0 || imm[15] == 0)
            extendOut = {16'd0, imm};
        else
            extendOut = {16'hffff, imm};
    end
endmodule