`timescale 1ns/1ns

module test;
    reg clk, rst;

    //实例化mips
    mips MIPS(.clk(clk), .rst(rst));

    initial begin
        rst = 0;
        clk = 1;
        #1 rst = 1;
        #2 rst = 0;

        //读取指令
        $readmemh("E:/modelsimProject/mipsCode/code.txt", MIPS.IFU.IM);
    end
    
    always  #30 clk = ~clk;
    
endmodule