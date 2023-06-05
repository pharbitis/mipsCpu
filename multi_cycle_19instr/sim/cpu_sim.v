`timescale 1ns/1ns

module cpu_sim;
    reg clk, rst;   //在sim中更改的信号为reg类型

    wire [31:0] currentIAddr, nextIAddr, ReadData1,
    ReadData2, ALU_result, DataBus;
    wire [4:0] rs, rt;

    //实例化
    top top(.clk(clk), .rst(rst), .currentIAddr(currentIAddr),
    .nextIAddr(nextIAddr), .rs(rs), .rt(rt), .ReadData1(ReadData1), .ReadData2(ReadData2),
    .ALU_result(ALU_result), .DataBus(DataBus));

    always #50 clk = ~clk;
    initial begin
        clk = 1;
        rst = 0;
        #25
        rst = 1;    //开始

        $readmemh("E:/vscodeProject/mipsCpu/multi_cycle_19instr/sim/output.txt", top.IM.ROM);
        #10000
        $stop;
    end

endmodule