module dm (
    data_in,        //写入存储的变量
    memWrite,          //写入信号:1表示需要写入
    addr,           //写入存储中的地址
    clk,
    rst,            //用于初始化存储
    dm_out          //读取存储得到的变量
);
    input [31:0] data_in, addr;
    input memWrite, clk, rst;
    output reg [31:0] dm_out;

    reg [31:0] dataMem [255:0];     //1kb的存储空间
    wire [7:0] pointer;

    assign pointer = addr[7:0];     //存储空间只需要低8位即可

    //进行存储初始化
    integer i;
    always @(posedge rst) begin
        if (rst)
            for (i = 0; i < 256; i = i + 1)
                dataMem[i] <= 0;
    end

    //写入
    always @(posedge clk) begin
        if (memWrite)
            dataMem[pointer] <= data_in;
    end

    //读取(任意时刻均可读数)
    always @(*) begin
        dm_out = dataMem[pointer];
    end
    
endmodule