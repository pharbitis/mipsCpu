//根据控制信号IRWre判断是否需要更改当前执行指令
//为了系统稳定，需要在时钟下降沿写入:与PC更新相差半个周期

module IR (
    clk,
    IRWre,
    InsIn,
    InsOut
);
    input clk, IRWre;
    input [31:0] InsIn;
    output reg [31:0] InsOut;

    always @(negedge clk) begin
        if (IRWre)
            InsOut <= InsIn;
        else
            InsOut <= InsOut;       //指令不变
    end

endmodule