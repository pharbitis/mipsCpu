//IF模块与ID模块间的寄存器
//暂存上一阶段的相关值:pc与指令
module IF_ID(
    clk,
    rstn,
    if_PC,
    if_instr,
    br_flag,    //如果需要跳转需要清除正在取指的指令
    load_stop_request,
    id_PC,
    id_instr
);
    input clk, rstn, br_flag, load_stop_request;
    input [31:0] if_PC, if_instr;
    output reg [31:0] id_PC, id_instr;

    //传递pc的值
    always @(posedge clk) begin
        if (!rstn) 
            id_PC <= 32'h3000;
        //暂停取指
        else if (br_flag || load_stop_request)
            id_PC <= id_PC;
        else 
            id_PC <= if_PC;
    end

    //传递instruction的值
    //取指为0即可
    always @(posedge clk) begin
        if (!rstn || br_flag) 
            id_instr <= 0;
        else if (load_stop_request)
            id_instr <= id_instr;
        else
            id_instr <= if_instr;
    end

endmodule