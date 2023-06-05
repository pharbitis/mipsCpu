//单位ns，精度ps
`timescale 1ns/1ps

module tb_test;
    reg clk, rstn;

    //实例化top
    top top(.clk(clk), .rstn(rstn));

    always #50 clk = ~clk;

    initial begin
        clk = 0;
        rstn = 0;
        #195
        rstn = 1;   //开始

        $readmemh("E:/vscodeProject/mipsCpu/pipelined_cpu/sim/test_load_relate.txt", top.IM.ROM);
        #1000
        $stop;
    end


endmodule