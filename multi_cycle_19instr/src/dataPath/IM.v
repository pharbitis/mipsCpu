//从im中取指

module IM (
    IAddr,      //指令地址
    IDataOut        //输出32位指令码
);
    input [31:0] IAddr;
    output [31:0] IDataOut;
    wire [6:0] pointer;         //只需要低10位即可
    reg [7:0] ROM [127:0];      //128kb，可以存放32条指令
    
    assign pointer = IAddr[6:0];

    //小端机，每次取一个字节
    assign IDataOut[31:24] = ROM[pointer];
    assign IDataOut[23:16] = ROM[pointer + 1];
    assign IDataOut[15:8] = ROM[pointer + 2];
    assign IDataOut[7:0] = ROM[pointer + 3];

endmodule