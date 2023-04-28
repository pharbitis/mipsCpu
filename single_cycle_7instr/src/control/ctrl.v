module ctrl (
    instruction,            //32位指令码
    regDst,                 //写入寄存器的编号(区分R型与I型)
    aluSrc,                 //alu运算的第二个操作数来源于rt还是立即数
    memToReg,               //选择送入寄存器的值来源于alu输出还是存储器
    regWrite,               //是否需要将读取存储器的内容写入寄存器
    memWrite,               //是否需要将寄存器中的值写入存储
    nPC_sel,                //确定PC正常加4还是进行跳转
    extOp,                  //对于立即数进行零扩展还是符号扩展
    aluCtr                  //确定alu运算类型(add, sub, ori)对应0,1,2
);

    input [31:0] instruction;
    output reg [1:0] nPC_sel, aluCtr;   //nPC_sel需要选择正常情况，beq还是j
    output reg regDst, aluSrc, memToReg, regWrite, memWrite, extOp;

    parameter R = 6'b000000;        //R型指令op均为全0
    //R型指令func段
    parameter ADDU = 6'b100001;      
    parameter SUBU = 6'b100011;      
    //I型指令op段
    parameter ORI = 6'b001101;
    parameter LW = 6'b100011;
    parameter SW = 6'b101011;
    parameter BEQ = 6'b000100;
    //JAL的op段
    parameter JAL = 6'b000011;

    //regDst
    //R型选择1->rd, I型选择0->rt(其余情况也置为0)
    always @(*) begin
        case (instruction[31:26])
            R:       regDst = 1;     
            default: regDst = 0;
        endcase
    end

    //aluSrc
    //ori, lw, sw为1:选择立即数，其余置零
    always @(*) begin
        case (instruction[31:26])
            ORI, LW, SW:    aluSrc = 1;     
            default:        aluSrc = 0;
        endcase
    end

    //memToReg
    //lw为1:选择从存储中读取的值送给寄存器,其余置零
    always @(*) begin
        case (instruction[31:26])
            LW:         memToReg = 1;     
            default:    memToReg = 0;
        endcase
    end

    //regWrite
    //add, sub, ori, lw为1:需要将值写入寄存器，其余置零
    always @(*) begin
        case (instruction[31:26])
            R, ORI, LW:    regWrite = 1;     
            default:       regWrite = 0;    
        endcase
    end

    //memWrite
    //sw为1:需要将寄存器的值存入存储，其余为零
    always @(*) begin
        case (instruction[31:26])
            SW:         memWrite = 1;     
            default:    memWrite = 0;    
        endcase
    end

    //nPC_sel
    //beq为1，j为2:两种跳转类型，其余为零
    always @(*) begin
        case (instruction[31:26])
            BEQ:        nPC_sel = 1;
            JAL:          nPC_sel = 2;     
            default:    nPC_sel = 0;    
        endcase
    end

    //extOp
    //lw, sw为1:需要符号扩展，其余为零  注:beq和j的符号扩展在ifu中完成
    always @(*) begin
        case (instruction[31:26])
            LW, SW:     extOp = 1;   
            default:    extOp = 0;    
        endcase
    end

    //aluCtr
    //add, sub, ori为各自值，lw, sw为0:add(基址加偏移)，beq为1:需要比较两个数的值，j默认为0
    always @(*) begin
        case (instruction[31:26])
            R:  //根据后六位区分
                case (instruction[5:0])
                    ADDU:    aluCtr = 0; 
                    default: aluCtr = 1;    //sub
                endcase   
            ORI:    aluCtr = 2;
            LW, SW: aluCtr = 0;
            BEQ:    aluCtr = 1;
            default:    aluCtr = 0;         //j    
        endcase
    end
    
endmodule