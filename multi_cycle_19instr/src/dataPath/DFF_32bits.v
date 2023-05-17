//分割数据通路的寄存器(将上阶段数据存起来)
//32位触发器-对应ADR, BDR, DBDR
module DFF_32bits (
    clk,
    rst,        //rst 0有效
    in,
    out
);
    input clk, rst;
    input [31:0] in;
    output reg [31:0] out;

    always @(posedge clk or negedge rst) begin
        if (rst == 0)
            out <= 0;
        else
            out <= in;
    end    
endmodule