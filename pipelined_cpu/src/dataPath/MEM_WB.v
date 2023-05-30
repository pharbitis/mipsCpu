//MEM模块和WB模块间的暂存寄存器
//存储是否要写寄存器以及写入的值

module MEM_WB(
    clk, 
    rstn,
    mem_regWriteEn,
    mem_regWriteAddr,
    mem_regWriteData,
    wb_regWriteEn,
    wb_regWriteAddr,
    wb_regWriteData
);
    input clk, rstn, mem_regWriteEn;
    input [4:0] mem_regWriteAddr;
    input [31:0] mem_regWriteData;

    output reg wb_regWriteEn;
    output reg [4:0] wb_regWriteAddr;
    output reg [31:0] wb_regWriteData;

    //regWriteAddr
    always @(posedge clk) begin
        if (!rstn)
            wb_regWriteAddr <= 0;
        else
            wb_regWriteAddr <= mem_regWriteAddr;
    end

    //regWriteEn
    always @(posedge clk) begin
        if (!rstn)
            wb_regWriteEn <= 0;
        else
            wb_regWriteEn <= mem_regWriteEn;
    end

    //regWriteData
    always @(posedge clk) begin
        if (!rstn)
            wb_regWriteData <= 0;
        else
            wb_regWriteData <= mem_regWriteData;
    end


endmodule