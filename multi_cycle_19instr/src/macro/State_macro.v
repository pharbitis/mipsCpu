//定义多周期执行的不同状态
`define IF 3'd0    //取指:每个指令均需要执行
`define ID 3'd1    //指令译码
`define EXE_SL 3'd2 //sw和lw指令
`define MEM 3'd3    //读取或写存储
`define WB_LW 3'd4     //lw将结果写回寄存器

`define EXE_BR 3'd5   //beq, bne等转移指令
`define EXE_NR 3'd6   //普通运算指令
`define WB_NR 3'd7    //将运算结果写回寄存器





