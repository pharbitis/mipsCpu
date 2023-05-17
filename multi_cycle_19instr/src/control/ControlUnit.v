`include "../macro/ControlUnit_macro.v"
`include "../macro/State_macro.v"

//根据当前指令码以及当前状态确定控制信号
module ControlUnit (
    clk,
    rst,
    opcode,     //指令的op字段
    func,       //指令的func字段
    zero,       //零标志
    sign,       //运算结果符号
    ALUSrcA,    //alu输入一:来自于寄存器堆data1还是移位数sa
    ALUSrcB,    //alu输入二:来自于寄存器堆data2还是拓展后立即数
    DBDataSrc,  //寄存器输入来自于alu运算输出还是存储器
    WrRegSrc,   //写入寄存器值来自于pc+4还是alu运算结果或存储器
    mRD,        //存储器读使能信号
    ExtSel,     //零扩展还是符号扩展
    PCSrc,      //pc+4 / pc+4+符号扩展立即数 / rs / jump跳转地址
    RegDst,     //写寄存器组的寄存器地址
    ALUOp,       //alu操作码
    PCWre,      //当前PC值是否可以改变(除halt指令外均有效)
    IRWre,      //控制当前指令是否改变(与PCWre类似)
    mWR,        //存储器写使能信号
    RegWre,      //寄存器写使能信号
    InsMemRW    //0:写指令存储器, 1:读指令寄存器
);
    input clk, rst, zero, sign;
    input [5:0] opcode, func;
    //无需写操作的信号均为指令状态无关->只由指令操作决定
    output reg ALUSrcA, ALUSrcB, DBDataSrc, WrRegSrc, mRD, ExtSel;
    output reg [1:0] PCSrc, RegDst;
    output reg [2:0] ALUOp;
    //写操作相关信号
    output reg PCWre, mWR, RegWre, IRWre;
    output InsMemRW;

    assign InsMemRW = 1;     //指令存储器只读

    reg [2:0] state;      //状态量

    //状态转移
    always @(posedge clk or negedge rst) begin
        //将状态重置，并重置
        if (rst == 0)   begin
            state <= `IF;
            PCWre <= 1;     //可以取新地址
            IRWre <= 1;     //更新指令
        end
        //根据当前状态和操作码更新状态
        case (state)
            `IF:        state <= `ID;   
            `ID:    begin   //根据操作码确定下一个状态
                case (opcode)
                    `BEQ, `BNE, `SPE_BRA:           state <= `EXE_BR;
                    `SW, `LW:                       state <= `EXE_SL;
                    `J, `JAL, `HALT:                state <= `IF;       //执行结束
                    `R: begin
                        case (func)
                            `JR:                    state <= `IF; 
                            default:                state <= `EXE_NR;
                        endcase 
                    end
                    default:                        state <= `EXE_NR;        
                endcase
            end 
            `EXE_NR:                                state <= `WB_NR;
            `EXE_BR:                                state <= `IF;
            `EXE_SL:                                state <= `MEM;
            `WB_NR, `WB_LW, `MEM:                   state <= `IF;
        endcase
    end

    //根据当前状态和opcode为写信号赋值

    //PCWre
    //PCWre信号需在前一个状态时钟下降沿改变
    always @(negedge clk) begin
        //如果下一个指令是`IF，PCWre有效
        case (state)
            `WB_LW, `WB_NR, `EXE_BR: PCWre <= 1;
            `MEM:                    PCWre <= (opcode == `LW) ? 1 : 0;    //如果是sw下个状态为IF
            `ID:    begin
                case (opcode)
                    `J, `JAL:        PCWre <= 1;
                    `R:              PCWre <= (func == `JR) ? 1 : 0;
                    default:         PCWre <= 0;
                endcase
            end
            default:                 PCWre <= 0;        //包括halt指令 
        endcase
    end

    //mWR
    //当前指令为sw且当前状态为MEM时为1
    always @(opcode or state) begin
        if (state == `MEM && opcode == `SW)
            mWR = 1;
        else
            mWR = 0;
    end

    //IRWre
    //IR寄存器写使能:读指令码, 一直有效
    always @(state) begin
        IRWre <= 1;
    end   

    //RegWre
    //R指令和I型指令WB状态有效, jal的ID状态也需要写寄存器
    always @(state or opcode) begin
        case (state)
            `WB_NR, `WB_LW: RegWre = 1;
            `ID:            RegWre = (opcode == `JAL) ? 1 : 0;   //jal指令有效 
            default:        RegWre = 0;
        endcase
    end


    //与状态无关的其他信号

    //ALUSrcA
    //sll为1:操作数为移位数
    always @(opcode or func) begin
        case (func)
            `SLL:       ALUSrcA = 1; 
            default:    ALUSrcA = 0;
        endcase
    end

    //ALUSrcB
    //I型运算指令为1:来自于立即数
    always @(opcode or func) begin
        case (opcode)
            `ADDIU, `ANDI, `ORI, `XORI, `SLTI, `SW, `LW:       ALUSrcB = 1; 
            default:    ALUSrcB = 0;
        endcase
    end

    //DBDataSrc
    //lw为1:代表来自于存储器中的结果
    always @(opcode or func) begin
        case (opcode)
            `LW:        DBDataSrc = 1; 
            default:    DBDataSrc = 0;
        endcase
    end

    //WrRegSrc
    //jal为0:表示写入寄存器堆的值是pc+4
    always @(opcode or func) begin
        case (opcode)
            `JAL:       WrRegSrc = 0; 
            default:    WrRegSrc = 1;
        endcase
    end

    //mRD
    //lw为1:表示需要读取存储器的值
    always @(opcode or func) begin
        case (opcode)
            `LW:       mRD = 1; 
            default:   mRD = 0;
        endcase
    end

    //ExtSel
    //部分I型指令和branch指令需要符号扩展
    always @(opcode or func) begin
        case (opcode)
            `ADDIU, `SLTI, `SW, `LW, `BEQ, `BNE, `SPE_BRA:       ExtSel = 1; 
            default:    ExtSel = 0;
        endcase
    end

    //PCSrc
    //00为正常情况:pc+4, 01为branch跳转地址, 10为jr:寄存器地址, 11为jump
    always @(opcode or func or zero or sign) begin
        case (opcode)
            `BEQ:   PCSrc = zero == 1 ? 1 : 0;
            `BNE:   PCSrc = zero == 0 ? 1 : 0;
            `SPE_BRA:   begin
                case (func)
                    `BLTZ:   PCSrc = sign == 1 ? 1 : 0; 
                    default: PCSrc = (sign == 0 && zero == 0) ? 1 : 0;  //bgez  
                endcase
            end
            `J, `JAL:        PCSrc = 3;
            `R: begin
                case (func)
                    `JR:     PCSrc = 2; 
                    default: PCSrc = 0;
                endcase
            end
            default:         PCSrc = 0;
        endcase
    end

    //RegDst
    //jal为0:31号寄存器, 1:rt字段:I型指令, 2:rd字段:R型指令, 3:暂留
    always @(opcode or func) begin
        case (opcode)
            `ADDIU, `ANDI, `ORI, `XORI, `SLTI, `LW: RegDst = 1;
            `R: begin
                case (func)
                    `ADDU, `SUBU, `AND, `SLT, `SLL: RegDst = 2;
                    default:    RegDst = 0;
                endcase
            end 
            default:    RegDst = 0;
        endcase
    end

    //ALUOp
    //按照运算对应编码填写
    always @(opcode or func) begin
        case (opcode)
            `BEQ, `BNE:         ALUOp = 1;
            `ORI:               ALUOp = 3;
            `ANDI:              ALUOp = 4;
            `SLTI:              ALUOp = 6;
            `XORI:              ALUOp = 7;
            `R: begin
                case (func)
                    `SUBU:      ALUOp = 1; 
                    `SLL:       ALUOp = 2;
                    `AND:       ALUOp = 4;
                    `SLT:       ALUOp = 6;
                    default:    ALUOp = 0;
                endcase
            end
            default:            ALUOp = 0;
        endcase    
    end

endmodule