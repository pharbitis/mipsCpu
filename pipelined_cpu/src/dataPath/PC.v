//输入clk与rst得到当前PC与IR使能信号
module PC(
    clk,
    rstn,     
    br_flag,              //选择pc来源
    br_addr,            //待转移的地址   
    load_stop_request,  //暂停流水线请求
    pc,                //当前PC值
    IMreadEn          //IM读使能
);
    input clk, rstn, br_flag, load_stop_request;
    input [31:0] br_addr;
    output reg [31:0] pc;       //指令地址
    output reg IMreadEn;

    //得到pc值
    always @(posedge clk) begin
        //根据IM使能情况判断是否更新pc
        if (!IMreadEn)
            pc <= 32'h3000;
        else begin
            if (br_flag)
                pc <= br_addr;
            else if (!load_stop_request)
                pc <= pc + 4; 
        end
    end

    //当复位时IMreadEn禁用
    always @(posedge clk) begin
        if (!rstn)
            IMreadEn <= 0;
        else
            IMreadEn <= 1;
    end

endmodule