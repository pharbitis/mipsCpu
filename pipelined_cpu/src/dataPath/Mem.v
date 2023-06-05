//MEM模块
//访存
`include "../macro/Mem_macro.v"

module Mem(
    rstn,
    RegWriteEn_i,
    RegWriteAddr_i,
    RegWriteData_i,     //如果是访存指令变量中存的就是访问地址
    regData2,          //rt寄存器值
    MemOp,              //确定访存类型
    MemAddr_i,          //计算得到的访存地址(就是alu输出)
    MemReadData,        //从数据存储器中读取的数据
    MemAddr_o,          //访存地址输出
    MemWriteEn,         //写使能
    Mem_sel,            //选择访问字节
    MemWriteData,       //写入存储的数据
    MemEn,              //数据存储器使能
    RegWriteEn_o,
    RegWriteAddr_o,
    RegWriteData_o
);

    input rstn, RegWriteEn_i;
    input [2:0] MemOp;
    input [4:0] RegWriteAddr_i;
    input [31:0] RegWriteData_i, regData2, MemReadData, MemAddr_i;

    output reg RegWriteEn_o, MemWriteEn, MemEn;
    output reg [3:0] Mem_sel;
    output reg [4:0] RegWriteAddr_o;
    output reg [31:0] RegWriteData_o, MemAddr_o, MemWriteData;

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
        else begin
            case (MemOp)
                `LB: begin
                    case (MemAddr_i[1:0])
                        2'b00:  RegWriteData_o <= {{24{MemReadData[7]}}, MemReadData[7:0]};
                        2'b01:  RegWriteData_o <= {{24{MemReadData[15]}}, MemReadData[15:8]};
                        2'b10:  RegWriteData_o <= {{24{MemReadData[23]}}, MemReadData[23:16]};
                        2'b11:  RegWriteData_o <= {{24{MemReadData[31]}}, MemReadData[31:24]};
                    endcase
                end
                `LW:     RegWriteData_o <= MemReadData;
                default: RegWriteData_o <= RegWriteData_i;
            endcase
        end       
    end

    //MemAddr_o
    always @(*) begin
        if (!rstn)
            MemAddr_o <= 0;
        else begin
            case (MemOp)
                `SB, `SW, `LB, `LW:   MemAddr_o <= MemAddr_i;     //地址保存在alu输出结果中  
                default: MemAddr_o <= 0;
            endcase
        end
    end

    //MemWriteEn
    always @(*) begin
        if (!rstn)
            MemWriteEn <= 0;
        else begin
            case (MemOp)
                `LB, `LW:   MemWriteEn <= 0;
                `SB, `SW:   MemWriteEn <= 1; 
                default: MemWriteEn <= 0;
            endcase
        end
    end

    //MemEn
    always @(*) begin
        if (!rstn)
            MemEn <= 0;
        else begin
            case (MemOp)
                `SB, `SW, `LB, `LW:   MemEn <= 1;     
                default: MemEn <= 0;
            endcase
        end
    end

    //Mem_sel   选择访问字节
    //根据访问地址的后两位确定访问字节
    //因为是小端机所以低地址对应低有效位
    always @(*) begin
        if (!rstn)
            Mem_sel <= 0;
        else begin
            case (MemOp)
                `LB, `SB: begin
                    case (MemAddr_i[1:0])
                        //根据实际地址选择对应字节
                        2'b00:  Mem_sel <= 4'b0001; 
                        2'b01:  Mem_sel <= 4'b0010;
                        2'b10:  Mem_sel <= 4'b0100; 
                        2'b11:  Mem_sel <= 4'b1000; 
                    endcase
                end  
                `LW, `SW:   Mem_sel <= 4'b1111;
                default: Mem_sel <= 0;
            endcase
        end
    end

    //MemWriteData
    always @(*) begin
        if (!rstn)
            MemWriteData <= 0;
        else begin
            case (MemOp)
                `SB:    MemWriteData <= {regData2[7:0], regData2[7:0], regData2[7:0], regData2[7:0]};
                `SW:    MemWriteData <= regData2;
                default: MemWriteData <= 0;
            endcase
        end
    end

endmodule