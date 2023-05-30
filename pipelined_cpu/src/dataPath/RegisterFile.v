//寄存器堆
//根据信号读取寄存器的值并写入寄存器

module RegisterFile(
    clk,
    rstn,
    RegReadAddr1,      //第一个读的寄存器地址
    RegReadEn1,     //第一个寄存器读使能信号
    RegReadAddr2,      //第二个读的寄存器地址
    RegReadEn2,
    RegWriteAddr,      //写寄存器地址
    RegWriteData,
    RegWriteEn,
    readData1,      //读出的数据1
    readData2
);
    input clk, rstn, RegReadEn1, RegReadEn2, RegWriteEn;
    input [4:0] RegReadAddr1, RegReadAddr2, RegWriteAddr;
    input [31:0] RegWriteData;
    output reg [31:0] readData1, readData2;

    reg [31:0] reFi [0:31]; //32个通用寄存器
    integer i;              //遍历用

    //读寄存器
    //为了解决数据冒险中，相隔两条指令之间的相关问题，对读操作进行改动
    //此时需要写的一定是之前的指令的WB阶段
    //如果下个上升沿需要写的寄存器与当前需要读的寄存器一致，那么直接读取需要写的值

    //读寄存器1
    always @(*) begin
        if (!rstn || !RegReadEn1)
            readData1 <= 0;
        //如果写使能有效且需要读的寄存器地址与写寄存器地址一致，直接传递需要写的值
        else begin
            if (RegWriteEn && (RegReadAddr1 == RegWriteAddr))
                readData1 <= RegWriteData;
            else
                readData1 <=  reFi[RegReadAddr1];
        end
    end

    //读寄存器2
    always @(*) begin
        if (!rstn || !RegReadEn2)
            readData2 <= 0;
        else begin
            if (RegWriteEn && (RegReadAddr2 == RegWriteAddr))
                readData2 <= RegWriteData;
            else
                readData2 <=  reFi[RegReadAddr2];
        end
    end

    //写寄存器
    always @(posedge clk) begin
        //寄存器初值
        if (!rstn) begin
            for (i = 0; i < 32; i = i + 1) begin
                reFi[i] <= 0;
            end
        end
        else if (RegWriteEn && RegWriteAddr)
            reFi[RegWriteAddr] <= RegWriteData;
    end
    
endmodule