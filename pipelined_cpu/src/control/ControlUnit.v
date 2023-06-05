//ID模块的重要部分:生成各种控制信号
//对指令进行译码

`include "../macro/ControlUnit_macro.v"

module ControlUnit(
    rstn,
    instr,              //当前指令
    daHa_ex_regWrEn,    //为解决数据冒险引入EX阶段的数据前推
    daHa_ex_regWrAddr,
    daHa_mem_regWrEn,   //MEM阶段数据前推
    daHa_mem_regWrAddr,
    daHa_ex_memOp,    //EX阶段是否为load指令:可能发生load相关
    regData1,
    RegReadEn1,
    RegReadEn2,
    RegWriteEn,
    AluOp,              //alu操作类型
    AluSrc1,            //alu第一个操作数来源
    AluSrc2,
    imm,                //拓展后立即数
    RegWriteAddr,        //写寄存器的地址
    MemOp,               //区分访存相关指令类型
    MemAddr,             //访存地址
    load_stop_request   //发生load相关后提出的流水线暂停请求:需要将此时取指和译码阶段暂停
);

    input rstn, daHa_ex_regWrEn, daHa_mem_regWrEn;
    input [2:0] daHa_ex_memOp;
    input [4:0] daHa_ex_regWrAddr, daHa_mem_regWrAddr;
    input [31:0] instr, regData1;
    output reg RegReadEn1, RegReadEn2, RegWriteEn, load_stop_request;
    output reg [1:0] AluSrc1, AluSrc2;
    output reg [2:0] MemOp;
    output reg [3:0] AluOp;
    output reg [4:0] RegWriteAddr;
    output reg [31:0] imm, MemAddr;      //直接进行扩展

    wire [4:0] RegReadAddr1, RegReadAddr2;  //读寄存器地址
    wire [5:0] op, func; //op段和func段
    wire pre_is_load;   //判断前一条指令是否是load指令

    assign RegReadAddr1 = instr[25:21];
    assign RegReadAddr2 = instr[20:16];
    assign op = instr[31:26];
    assign func = instr[5:0];
    

    //RegWriteAddr
    //rd或rt
    //需要链接的跳转指令为链接寄存器
    always @(*) begin
        if (!rstn)
            RegWriteAddr <= 0;      //虽然赋值为0但无法写入
        else begin
            case (op)
                `ORI, `ANDI, `LUI, `XORI, `ADDI, `ADDIU, `LB, `LW:   RegWriteAddr <= instr[20:16];   //I型指令选择rt 
                `JAL:   RegWriteAddr <= 5'd31;
                `R, `MUL: RegWriteAddr <= instr[15:11];   //R型指令选择rd
                default: RegWriteAddr <= 0; 
            endcase
        end
            
    end

    //imm
    //根据指令类型获得需要进行运算的立即数
    //I型移位指令移位数直接加载到立即数中
    always @(*) begin
        if (!rstn)
            imm <= 0;
        else begin
            case (op)
                `ORI, `ANDI, `XORI, `LB, `LW, `SB, `SW:   imm <= {16'b0, instr[15:0]}; 
                `LUI:                 imm <= {instr[15:0], 16'b0};       //将lui转换为ori指令
                `ADDI, `ADDIU:        imm <= {{16{instr[15]}}, instr[15:0]};    //符号扩展
                `R: begin
                    case (func)
                        `SLL, `SRA, `SRL:           imm <= {27'b0, instr[10:6]};
                        default: imm <= 0;
                    endcase
                end
                default: imm <= 0; 
            endcase
        end
            
    end

    //RegReadEn1
    always @(*) begin
        if (!rstn)
            RegReadEn1 <= 0;    //默认无效
        else begin
            case (op)
                `J, `JAL:   RegReadEn1 <= 0;
                `R: begin
                    case (func)
                        `SLL, `SRA, `SRL:   RegReadEn1 <= 0;     
                        default: RegReadEn1 <= 1;
                    endcase
                end
                default: RegReadEn1 <= 1;   
            endcase
        end
    end

    //RegReadEn2
    always @(*) begin
        if (!rstn)
            RegReadEn2 <= 0;    //默认无效
        else begin
            case (op)
                `MUL, `BEQ, `BNE, `SB, `SW:      RegReadEn2 <= 1;   //store指令需要读取rt寄存器的值
                `R: begin
                    case (func)
                        `JR, `JALR: RegReadEn2 <= 0; 
                        default:    RegReadEn2 <= 1;
                    endcase
                end
                default: RegReadEn2 <= 0;
            endcase
        end
    end

    //RegWriteEn
    always @(*) begin
        if (!rstn)
            RegWriteEn <= 0;    //默认无效
        else begin
            case (op)
                `JAL, `MUL, `LB, `LW:     RegWriteEn <= 1;
                `R: begin
                    case (func)
                        `JR:  RegWriteEn <= 0; 
                        default: RegWriteEn <= 1;
                    endcase
                end
                `ORI, `ANDI, `LUI, `XORI, `ADDI, `ADDIU:    RegWriteEn <= 1;
                default: RegWriteEn <= 0;
            endcase
        end
    end

    //AluSrc1
    //0:来自立即数 1:来自寄存器 2:来自EX阶段数据前推 3:来自MEM阶段数据前推
    always @(*) begin
        if (!rstn)
            AluSrc1 <= 0;
        //先判断是否存在数据冒险    
        else begin
            //EX与ID数据相关
            if (daHa_ex_regWrEn && RegReadEn1 && (daHa_ex_regWrAddr == RegReadAddr1))
                AluSrc1 <= 2;
            //MEM与ID数据相关
            else if (daHa_mem_regWrEn && RegReadEn1 && (daHa_mem_regWrAddr == RegReadAddr1))
                AluSrc1 <= 3;
            else begin
                case (op)     
                    `R: begin
                        case (func)
                            `SLL, `SRL, `SRA:   AluSrc1 <= 0;   //移位数 
                            default: AluSrc1 <= 1;
                        endcase
                    end
                    default: AluSrc1 <= 1;
                endcase
            end
        end
    end

    //AluSrc2
    //0:来自立即数 1:来自寄存器 2:来自EX阶段数据前推 3:来自MEM阶段数据前推
    always @(*) begin
        if (!rstn)
            AluSrc2 <= 0;    
        //先判断是否存在数据冒险    
        else begin
            //EX与ID数据相关
            if (daHa_ex_regWrEn && RegReadEn2 && (daHa_ex_regWrAddr == RegReadAddr2)) begin
                AluSrc2 <= 2;
            end
            //MEM与ID数据相关
            else if (daHa_mem_regWrEn && RegReadEn2 && (daHa_mem_regWrAddr == RegReadAddr2)) begin
                AluSrc2 <= 3;
            end
            else begin
                case (op)
                `ORI, `ANDI, `LUI, `XORI, `ADDI, `ADDIU:   AluSrc2 <= 0;  
                `LB, `LW, `SB, `SW: AluSrc2 <= 1;       //获取rt寄存器的值 
                `R, `MUL: AluSrc2 <= 1;    
                default: AluSrc2 <= 1;
                endcase
            end
        end
    end

    //AluOp
    //addu:0, subu: 1,...见ALU_macro
    always @(*) begin
        if (!rstn)
            AluOp <= 0;    
        else begin
            case (op)
                `ADDIU: AluOp <= 0;
                `LB, `LW, `SB, `SW: AluOp <= 0; //基址加偏移
                `ORI, `LUI:   AluOp <= 2;       //lui转换为ori
                `ANDI:  AluOp <= 3;
                `MUL:   AluOp <= 4;             //特殊R型指令
                `XORI:  AluOp <= 6;
                `ADDI:  AluOp <= 11;
                `JAL:   AluOp <= 12;
                `R: begin
                    //R型指令 
                    case (func)
                        `ADDU:  AluOp <= 0;
                        `SUB:   AluOp <= 1;
                        `OR:    AluOp <= 2;
                        `AND:   AluOp <= 3;
                        `SLT:   AluOp <= 5;
                        `XOR:   AluOp <= 6; 
                        `NOR:   AluOp <= 7;
                        `SLL, `SLLV:    AluOp <= 8;
                        `SRL, `SRLV:    AluOp <= 9;
                        `SRA, `SRAV:    AluOp <= 10;
                        `ADD:           AluOp <= 11;
                        `JALR:  AluOp <= 12;
                        default: AluOp <= 0;
                    endcase       
                end
                default: AluOp <= 0;
            endcase
        end
    end

    //MemOp
    always @(*) begin
        if (!rstn)
            MemOp <= 0;
        else begin
            case (op)
                `LB:    MemOp <= 1;
                `LW:    MemOp <= 2;
                `SB:    MemOp <= 3;
                `SW:    MemOp <= 4; 
                default: MemOp <= 0;
            endcase
        end
    end
    
    //MemAddr
    always @(*) begin
        if (!rstn)
            MemAddr <= 0;
        else begin
            case (op)
                `LB, `LW, `SB, `SW: MemAddr <= imm + regData1; 
                default: MemAddr <= 0;
            endcase
        end
    end

    //判断上一条指令是否为load
    assign pre_is_load = (daHa_ex_memOp == 1) || (daHa_ex_memOp == 2);

    //load_stop_request
    always @(*) begin
        if (!rstn || !pre_is_load)
            load_stop_request <= 0;
        //如果load需要写的寄存器与译码阶段指令需要读的任意一个寄存器相同:需要暂停
        else begin
            if ((RegReadEn1 && (daHa_ex_regWrAddr == RegReadAddr1)) || (RegReadEn2 && (daHa_ex_regWrAddr == RegReadAddr2)))
                load_stop_request <= 1;
            else
                load_stop_request <= 0;
        end
    end

endmodule