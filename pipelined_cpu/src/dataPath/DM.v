//数据存储DRAM
module DM(
    rstn,
    MemEn,          //DM使能信号
    clk,            
    data_i,         
    addr,           //访问地址
    MemWriteEn,     //写使能
    Mem_sel,        //选择字节
    data_o          //读取的数据
);
    input MemEn, clk, MemWriteEn, rstn;
    input [3:0] Mem_sel;
    input [31:0] data_i, addr;

    output reg [31:0] data_o;

    reg [31:0] dm [0:127];       //512kb的数据存储
    integer i;

    //读操作
    always @(*) begin
        //写使能无效时读
        if (!MemEn || MemWriteEn)
            data_o <= 0;
        else
            data_o <= dm[addr[8:2]];
    end

    //写操作
    //添加复位
    always @(posedge clk) begin
        if (!rstn) begin
            for (i = 0; i < 128; i = i + 1)
                dm[i] <= 0; 
        end
        else begin
            if (MemEn && MemWriteEn) begin
                if (Mem_sel[0] == 1)
                    dm[addr[8:2]][7:0] <= data_i[7:0];
                if (Mem_sel[1] == 1)
                    dm[addr[8:2]][15:8] <= data_i[15:8];
                if (Mem_sel[2] == 1)
                    dm[addr[8:2]][23:16]<= data_i[23:16];
                if (Mem_sel[3] == 1)
                    dm[addr[8:2]][31:24] <= data_i[31:24];    
            end
        end
    end
    
endmodule