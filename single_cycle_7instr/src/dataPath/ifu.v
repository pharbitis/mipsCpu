module ifu (
    clk,
    rst,
    nPC_sel,                            //是否为跳转指令    
    zero_flag,                          //alu结果0标志
    instruction,                        //输出32位指令码
    ra_jal,                              //如果是jal指令需要更改返回地址
    isJal                               //判断是否为jal指令
);                      

    input clk, rst;          
    input [31:0] zero_flag;  
    input [1:0] nPC_sel;                   
    output [31:0] instruction, ra_jal;   
    output isJal;       

    //最小单位是字节(地址)
    reg [31:0] IM [255:0];              //大小为1kb的指令存储，每条指令32bits:最多PC后8位
    reg [31:0] PC;                      //当前PC值
    reg [31:0] nPC;                     //下一条指令PC
    wire [31:0] temp;
    wire [31:0] extOutB;                //beq的符号扩展
    wire [31:0] extOutJ;                //j的符号扩展
    wire [15:0] imm16;                  //16位立即数
    wire [25:0] imm26;                  //26位立即数

    //重置
    always @(posedge clk, posedge rst) begin
        if (rst)
            PC <= 32'h00003000;
        else
            PC <= nPC;        
    end     

    //取指(PC后连续的四段)，将字节地址转化为32位地址
    assign instruction = {IM[PC[9:2]]};

    //辅助变量
    assign imm16 = instruction[15:0];
    assign imm26 = instruction[25:0];
    assign temp = PC + 4;               //地址加4
    assign extOutB = {{16{imm16[15]}}, imm16, 2'b00};     //进行beq符号扩展  
    assign extOutJ = {PC[31:28], imm26, 2'b00};           //进行j符号扩展

    //如果是jal指令需要更改ra寄存器
    assign ra_jal = nPC_sel == 2 ? temp : 0;
    assign isJal = nPC_sel == 2 ? 1 : 0;

    //根据是否需要跳转更改PC值
    always @(*) begin
        case (nPC_sel)
            0:  nPC = temp;
            1:  
                if (zero_flag)
                    nPC = temp + extOutB;
                else
                    nPC = temp;
            default: nPC = extOutJ;         //j指令
        endcase
    end

    

endmodule
    


