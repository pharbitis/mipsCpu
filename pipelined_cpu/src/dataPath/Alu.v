//EX模块重要部分
//对操作数进行运算

//纯组合逻辑
`include "../macro/ALU_macro.v"

module Alu(
    rstn,
    num1,   //两个操作数
    num2,
    AluOp,          //alu操作类型
    RegWriteEn_i,   //需要传递的变量
    RegWriteAddr_i,
    linkAddr,
    RegWriteEn_o,
    RegWriteAddr_o,
    RegWriteData_o  //需要写入寄存器的结果
);
    input rstn, RegWriteEn_i;
    input [3:0] AluOp;
    input [4:0] RegWriteAddr_i;
    input [31:0] num1, num2, linkAddr;

    output reg RegWriteEn_o;
    output [4:0] RegWriteAddr_o;
    output [31:0] RegWriteData_o;

    reg overFlow;
    reg carry;      //保留进位
    reg [31:0] res;

    //写地址直接赋值即可
    assign RegWriteAddr_o = RegWriteAddr_i;

    //计算结果
    //移位运算形式为: num2 op num1
    always @(*) begin
        if (!rstn)
            res <= 0;
        else begin
            case (AluOp)
            `ADDU:  res <= num1 + num2;
            //保留进位结果，方便判断溢出
            `ADD:   {carry, res} <= {num1[31], num1} + {num2[31], num2};    
            `SUB:   {carry, res} <= {num1[31], num1} - {num2[31], num2};
            `SLT:   res <= $signed(num1) < $signed(num2) ? 1 : 0;
            `MUL:   res <= num1 * num2;
            `AND:   res <= num1 & num2;
            `OR:    res <= num1 | num2;
            `XOR:   res <= num1 ^ num2; 
            `NOR:   res <= ~(num1 | num2);
            `SLL:   res <= num2 << num1[4:0];
            `SRL:   res <= num2 >> num1[4:0];
            //SRA使用函数
            `SRA:   res <= $signed(num2) >>> num1[4:0];
            //`SRA:   res <= ({32{num2[31]}} << (6'd32 - {1'b0, num1[4:0]})) | (num2 >> num1[4:0]);
            `LINK:  res <= linkAddr;
            default: res <= 0;
            endcase    
        end
    end

    assign RegWriteData_o = res;
    
    //判断是否溢出
    always @(*) begin
        case (AluOp)
            `ADD, `SUB: begin
                if ({carry, res} == {res[31], res})
                    overFlow <= 0;
                else
                    overFlow <= 1;
            end
            default:    overFlow <= 0;
        endcase
    end

    //如果溢出:寄存器写使能为0
    always @(*) begin
        if (!overFlow)
            RegWriteEn_o <= RegWriteEn_i;
        else
            RegWriteEn_o <= 0;
    end

endmodule