//从DM中读数据、写数据
module DataMemory (
    clk,
    DataAddr,       //访问内存的索引
    DataIn,         //写入的内容
    RD,             //读使能信号,1有效
    WR,             //写使能信号
    DataOut         //读取的内容
);
    input clk, RD, WR;
    input [31:0] DataAddr, DataIn;
    output [31:0] DataOut;

    reg [7:0] DM [63:0];    //64kb数据

    //读取数据(依然是字节形式读取)
    assign DataOut[31:24] = (RD == 1) ? DM[DataAddr] : 8'bz;    //如果使能信号为0，则赋值状态为高阻抗
    assign DataOut[23:16] = (RD == 1) ? DM[DataAddr + 1] : 8'bz;
    assign DataOut[15:8] = (RD == 1) ? DM[DataAddr + 2] : 8'bz;
    assign DataOut[7:0] = (RD == 1) ? DM[DataAddr + 3] : 8'bz;

    //在时钟下降沿写入
    always @(negedge clk) begin
        if (WR)
        begin
            DM[DataAddr] <= DataIn[31:24];
            DM[DataAddr + 1] <= DataIn[23:16];
            DM[DataAddr + 2] <= DataIn[15:8];
            DM[DataAddr + 3] <= DataIn[7:0];
        end
    end

endmodule