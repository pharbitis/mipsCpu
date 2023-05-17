//根据PCWri信号完成对指令地址的更新

module PC (
    clk,
    rst,            //reset为0有效
    PCWre,          //0表示为halt指令(PC不变)，1时PC正常更新呢
    nextIAddr,             //当前指令地址
    currentIAddr          //下一条指令地址
);
    input clk, rst, PCWre;
    input [31:0] nextIAddr;     //上一条指令的npc
    output reg [31:0] currentIAddr;

    always @(posedge clk or negedge rst) begin
        if (rst == 0)
            currentIAddr <= 32'h00003000;   //Mars中text段初始地址
        else if (PCWre)
            currentIAddr <= nextIAddr;      //PC接收新地址
        else
            currentIAddr <= currentIAddr;       //地址不变
    end 
endmodule