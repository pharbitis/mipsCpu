module RegisterFile (
    clk,
    rst,
    RegWre,     //寄存器写使能信号:1有效
    ReadReg1,   //需要读的第一个寄存器编号
    ReadReg2,
    WriteReg,   //写寄存器编号
    WriteData,
    ReadData1,  //读取的数据
    ReadData2   
);
    input clk, rst, RegWre;
    input [4:0] ReadReg1, ReadReg2, WriteReg;
    input [31:0] WriteData;
    output [31:0] ReadData1, ReadData2;

    reg [31:0] reFi [31:0];     //32个通用寄存器
    integer i;

    //下降沿写回
    always @(negedge clk or negedge rst) begin
        if (rst == 0)
        begin
            for (i = 0; i < 32; i = i + 1)
                reFi[i] <= 0;
        end    
        else if (RegWre && WriteReg != 0)        //需要写寄存器(0寄存器不可写)
            reFi[WriteReg] <= WriteData;
    end

    assign ReadData1 = (ReadReg1 == 0) ? 0 : reFi[ReadReg1];
    assign ReadData2 = (ReadReg2 == 0) ? 0 : reFi[ReadReg2];

endmodule