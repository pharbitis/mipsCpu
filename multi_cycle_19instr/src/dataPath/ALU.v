`include "../macro/ALU_macro.v"

//完成ALU计算
module ALU (
    ALUOp,
    num1,          //操作数1
    num2,          //操作数2
    result,
    zero,       //零标志
    sign        //结果符号
);
    input [2:0] ALUOp;
    input [31:0] num1, num2;
    output reg [31:0] result;
    output zero, sign;

    always @(ALUOp or num1 or num2) begin
        case (ALUOp)
            `ADDU:  result = num1 + num2;
            `SUBU:  result = num1 - num2;
            `SLL:   result = num2 << num1;      //num2左移num1位
            `AND:   result = num1 & num2;
            `OR:    result = num1 | num2; 
            `SLTU:  result = (num1 < num2) ? 1 : 0;
            `SLT:   begin
                if (num1[31] == num2[31] && num1 < num2)    result = 1;
                else if (num1[31] == 1 && num2[31] == 0)    result = 1;
                else    result = 0;   
            end
            `XOR:   result = num1 ^ num2;
            default:result = 0;                 //当前指令集下不可能   
        endcase
    end

    assign zero = (result == 0) ? 1 : 0;
    assign sign = result[31];
    
endmodule