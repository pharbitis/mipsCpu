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
    ex_num1,
    ex_num2,
    ex_regWriteEn,      
    ex_regWriteAddr,
    ex_aluOp
);
    input clk, rstn, id_regWriteEn;
    input [3:0] id_aluOp;
    input [4:0] id_regWriteAddr;
    input [31:0] id_num1, id_num2;

    output reg ex_regWriteEn;
    output reg [3:0] ex_aluOp;
    output reg [4:0] ex_regWriteAddr;
    output reg [31:0] ex_num1, ex_num2;

    //num1
    always @(posedge clk) begin
        if (!rstn)
            ex_num1 <= 0;
        else
            ex_num1 <= id_num1;
    end

    //num2
    always @(posedge clk) begin
        if (!rstn)
            ex_num2 <= 0;
        else
            ex_num2 <= id_num2;
    end

    //regWriteEn
    always @(posedge clk) begin
        if (!rstn)
            ex_regWriteEn <= 0;
        else
            ex_regWriteEn <= id_regWriteEn;
    end

    //regWriteAddr
    always @(posedge clk) begin
        if (!rstn)
            ex_regWriteAddr <= 0;
        else
            ex_regWriteAddr <= id_regWriteAddr;
    end

    //aluOp
    always @(posedge clk) begin
        if (!rstn)
            ex_aluOp <= 0;
        else
            ex_aluOp <= id_aluOp;
    end
    
endmodule