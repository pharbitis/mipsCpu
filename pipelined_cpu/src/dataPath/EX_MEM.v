module EX_MEM(
    clk,
    rstn,
    ex_regWriteEn,
    ex_regWriteAddr,
    ex_regWriteData,
    ex_memWriteEn,
    ex_memOp,
    ex_regData2,            //保存load指令需要存储的数据
    ex_memAddr,
    mem_regWriteEn,
    mem_regWriteAddr,
    mem_regWriteData,
    mem_memWriteEn,
    mem_memOp,
    mem_regData2,
    mem_memAddr
);
    input clk, rstn, ex_regWriteEn, ex_memWriteEn;
    input [2:0] ex_memOp;
    input [4:0] ex_regWriteAddr;
    input [31:0] ex_regWriteData, ex_regData2, ex_memAddr;

    output reg mem_regWriteEn, mem_memWriteEn;
    output reg [2:0] mem_memOp;
    output reg [4:0] mem_regWriteAddr;
    output reg [31:0] mem_regWriteData, mem_regData2, mem_memAddr;

    //regWriteEn
    always @(posedge clk) begin
        if (!rstn)
            mem_regWriteEn <= 0;
        else
            mem_regWriteEn <= ex_regWriteEn;
    end

    //regWriteAddr
    always @(posedge clk) begin
        if (!rstn)
            mem_regWriteAddr <= 0;
        else
            mem_regWriteAddr <= ex_regWriteAddr;
    end

    //regWriteData
    always @(posedge clk) begin
        if (!rstn)
            mem_regWriteData <= 0;
        else
            mem_regWriteData <= ex_regWriteData;
    end

    //memWriteEn
    always @(posedge clk) begin
        if (!rstn)
            mem_memWriteEn <= 0;
        else
            mem_memWriteEn <= ex_memWriteEn;
    end
    
    //memOp
    always @(posedge clk) begin
        if (!rstn)
            mem_memOp <= 0;
        else
            mem_memOp <= ex_memOp;
    end

    //regData2
    always @(posedge clk) begin
        if (!rstn)
            mem_regData2 <= 0;
        else
            mem_regData2<= ex_regData2;
    end
    
    //memAddr
    always @(posedge clk) begin
        if (!rstn)
            mem_memAddr <= 0;
        else
            mem_memAddr <= ex_memAddr;
    end
    
endmodule