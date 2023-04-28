module alu (
    busA,           //操作数一
    busB,           //操作数二
    aluCtr,         //确定alu的具体操作
    zero_flag,      //零标志
    alu_out,        //运算结果
    addr            //索引存储器中的地址
);
    input [1:0] aluCtr;
    input [31:0] busA, busB;
    output [31:0] zero_flag, addr;
    output reg [31:0] alu_out;

    //定义操作变量
    parameter ADD = 2'b00, SUB = 2'b01, OR = 2'b10;

    //根据aluCtr对应操作计算结果
    always @(*) begin
        case (aluCtr)
            ADD:    alu_out = busA + busB;
            SUB:    alu_out = busA - busB;
            OR:     alu_out = busA | busB; 
            default: alu_out = 0;
        endcase        
    end

    //给标志和地址变量赋值
    assign zero_flag = !alu_out;
    assign addr = alu_out;

endmodule