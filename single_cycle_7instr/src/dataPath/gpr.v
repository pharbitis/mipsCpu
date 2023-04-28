module gpr (
    clk,
    rst,
    rw,         //写入端
    ra,         //读入端一
    rb,         //读入端二
    regWrite,      //是否写入寄存器信号
    busW,       //写入的值
    isJal,      //判断只能是jal指令时才更新返回地址
    ra_jal,     //jal指令的返回地址
    busA,       //输出端一
    busB,       //输出端二
    data_in    //写入存储器的变量
);
    input [4:0] rw, ra, rb;
    input regWrite, clk, rst, isJal;
    input [31:0] busW, ra_jal;
    output [31:0] busA, busB, data_in;

    reg [31:0] regFi [31:0];    //32个32位寄存器的寄存器堆

    //初始化寄存器堆
    integer i;
    always @(posedge rst) begin
        if (rst)
            for (i = 0; i < 32; i = i + 1)
                regFi[i] <= 0;
    end

    //给输出端赋值
    assign busA = regFi[ra];    
    assign busB = regFi[rb];
    assign data_in = busB;

    //写入
    always @(posedge clk) begin
        if (regWrite) begin
            regFi[rw] <= busW;
            regFi[0] <= 0;      //0寄存器不能被更改
        end
    end

    //如果遇到jal需要更改ra值
    always @(isJal) begin
        if (isJal)
            regFi[31] <= ra_jal;
    end

endmodule