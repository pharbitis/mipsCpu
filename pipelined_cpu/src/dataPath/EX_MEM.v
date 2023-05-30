module EX_MEM(
    clk,
    rstn,
    ex_regWriteEn,
    ex_regWriteAddr,
    ex_regWriteData,
    mem_regWriteEn,
    mem_regWriteAddr,
    mem_regWriteData
);
    input clk, rstn, ex_regWriteEn;
    input [4:0] ex_regWriteAddr;
    input [31:0] ex_regWriteData;

    output reg mem_regWriteEn;
    output reg [4:0] mem_regWriteAddr;
    output reg [31:0] mem_regWriteData;

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

    
endmodule