//ID模块与EX模块中间的暂存寄存器
//保存运算类型，两个操作数，相关信号等

module ID_EX(
    clk,
    rstn,
    id_num1,            //第一个操作数
    id_num2,            //第二个操作数
    id_regWriteEn,      //写寄存器使能
    id_regWriteAddr,    //写寄存器地址
    id_aluOp,           //操作类型
    id_linkAddr,        //链接地址
    id_memWriteEn,      //写存储使能
    id_memOp,           //访存类型
    id_memAddr,        //rt寄存器内容
    load_stop_request,  //流水线暂停请求
    ex_num1,
    ex_num2,
    ex_regWriteEn,      
    ex_regWriteAddr,
    ex_aluOp,
    ex_linkAddr,
    ex_memWriteEn,
    ex_memOp,
    ex_memAddr
);
    input clk, rstn, id_regWriteEn, id_memWriteEn, load_stop_request;
    input [2:0] id_memOp;
    input [3:0] id_aluOp;
    input [4:0] id_regWriteAddr;
    input [31:0] id_num1, id_num2, id_linkAddr, id_memAddr;

    output reg ex_regWriteEn, ex_memWriteEn;
    output reg [2:0] ex_memOp;
    output reg [3:0] ex_aluOp;
    output reg [4:0] ex_regWriteAddr;
    output reg [31:0] ex_num1, ex_num2, ex_linkAddr, ex_memAddr;

    //num1
    always @(posedge clk) begin
        if (!rstn || load_stop_request)
            ex_num1 <= 0;
        else
            ex_num1 <= id_num1;
    end

    //num2
    always @(posedge clk) begin
        if (!rstn || load_stop_request)
            ex_num2 <= 0;
        else
            ex_num2 <= id_num2;
    end

    //regWriteEn
    always @(posedge clk) begin
        if (!rstn || load_stop_request)
            ex_regWriteEn <= 0;
        else
            ex_regWriteEn <= id_regWriteEn;
    end

    //regWriteAddr
    always @(posedge clk) begin
        if (!rstn || load_stop_request)
            ex_regWriteAddr <= 0;
        else
            ex_regWriteAddr <= id_regWriteAddr;
    end

    //aluOp
    always @(posedge clk) begin
        if (!rstn || load_stop_request)
            ex_aluOp <= 0;
        else
            ex_aluOp <= id_aluOp;
    end
    
    //linkAddr
    always @(posedge clk) begin
        if (!rstn || load_stop_request)
            ex_linkAddr <= 0;
        else
            ex_linkAddr <= id_linkAddr;
    end
    
    //memWriteEn
    always @(posedge clk) begin
        if (!rstn || load_stop_request)
            ex_memWriteEn <= 0;
        else
            ex_memWriteEn <= id_memWriteEn;
    end

    //memOp
    always @(posedge clk) begin
        if (!rstn || load_stop_request)
            ex_memOp <= 0;
        else
            ex_memOp <= id_memOp;
    end

    //memAddr
    always @(posedge clk) begin
        if (!rstn || load_stop_request)
            ex_memAddr <= 0;
        else
            ex_memAddr <= id_memAddr;
    end
    
endmodule