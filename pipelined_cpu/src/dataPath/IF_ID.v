//IF模块与ID模块间的寄存器
//暂存上一阶段的相关值:pc与指令
module IF_ID(
    clk,
    rstn,
    if_PC,
    if_instr,
    id_PC,
    id_instr
);
    input clk, rstn;
    input [31:0] if_PC, if_instr;
    output reg [31:0] id_PC, id_instr;

    //传递pc的值
    always @(posedge clk) begin
        if (!rstn) 
            id_PC <= 32'h3000;
        else
            id_PC <= if_PC;
    end

    //传递instruction的值
    always @(posedge clk) begin
        if (!rstn) 
            id_instr <= 0;
        else
            id_instr <= if_instr;
    end

endmodule