//MEM模块
//访存

module Mem(
    rstn,
    RegWriteEn_i,
    RegWriteAddr_i,
    RegWriteData_i,
    RegWriteEn_o,
    RegWriteAddr_o,
    RegWriteData_o
);

    input rstn, RegWriteEn_i;
    input [4:0] RegWriteAddr_i;
    input [31:0] RegWriteData_i;

    output reg RegWriteEn_o;
    output reg [4:0] RegWriteAddr_o;
    output reg [31:0] RegWriteData_o;

    //RegWriteEn
    always @(*) begin
        if (!rstn)
            RegWriteEn_o <= 0;
        else
            RegWriteEn_o <= RegWriteEn_i;
    end

    //RegWriteAddr
    always @(*) begin
        if (!rstn)
            RegWriteAddr_o <= 0;
        else
            RegWriteAddr_o <= RegWriteAddr_i;
    end

    //RegWriteData
    always @(*) begin
        if (!rstn)
            RegWriteData_o <= 0;
        else
            RegWriteData_o <= RegWriteData_i;
    end

    
endmodule