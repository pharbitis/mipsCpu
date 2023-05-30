//输入clk与rst得到当前PC与IR使能信号
module PC(
    clk,
    rstn,        
    pc,                //当前PC值
    IMreadEn          //IM读使能
);
    input clk, rstn;
    output reg [31:0] pc;       //指令地址
    output reg IMreadEn;

    //得到pc值
    always @(posedge clk) begin
        //根据IM使能情况判断是否更新pc
        if (!IMreadEn)
            pc <= 32'h3000;
        else
            pc <= pc + 4;  
    end

    //当复位时IMreadEn禁用
    always @(posedge clk) begin
        if (!rstn)
            IMreadEn <= 0;
        else
            IMreadEn <= 1;
    end

endmodule