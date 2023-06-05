//指令存储器IM (ROM)
//根据读使能信号确定是否需要读入
module IM(
    rstn,
    IMreadEn,
    pc,             //指令地址
    instr           //获得的指令
);
    input rstn, IMreadEn;
    input [31:0] pc;
    output reg [31:0] instr;

    reg [7:0] ROM [511:0];              //512字节的IM
    integer i;
    wire [8:0] pointer;

    assign pointer = pc[8:0];    //只需要9位地址

    //初始化
    always @(*) begin
        if (!rstn) begin
            for (i = 0; i < 128; i = i + 1)
                ROM[i] <= 0;
        end
    end

    //instr
    always @(*) begin
        if (!IMreadEn)
            instr <= 0;
        //小端机
        else 
            instr <= {ROM[pointer], ROM[pointer + 1], ROM[pointer + 2], ROM[pointer + 3]};
    end

endmodule
