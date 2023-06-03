//指令部分按照功能以及字母顺序给出

`define R 6'b000000 //R型指令的op字段

//特殊R型指令:mul op段
`define MUL 6'b011100

//R型指令func段
`define ADD 6'b100000 
`define ADDU 6'b100001
`define SUB 6'b100010
`define SUBU 6'b100011
`define MULT 6'b011000  //乘
`define MULTU 6'b011001
`define DIV 6'b011010   //除
`define DIVU 6'b011011  
`define SLT 6'b101010   //小于置1
`define SLTU 6'b101011  
`define SLL 6'b000000   //逻辑左移
`define SRL 6'b000010   //逻辑右移
`define SRA 6'b000011   //算术右移
`define SLLV 6'b000100  //逻辑可变左移
`define SRLV 6'b000110  //逻辑可变右移
`define SRAV 6'b000111  //算术可变右移
`define AND 6'b100100   
`define OR 6'b100101
`define XOR 6'b100110
`define NOR 6'b100111

`define JALR 6'b001001  //跳转并链接寄存器
`define JR 6'b001000

//传输
`define MFHI 6'b010000  //读HI寄存器
`define MFLO 6'b010010  //读LO寄存器
`define MTHI 6'b010001  //写HI寄存器
`define MTLO 6'b010011  //写LO寄存器

//I型指令op段

//加载
`define LB 6'b100000    //加载字节
`define LBU 6'b100100   
`define LH 6'b100001    //加载半字
`define LHU 6'b100101   
`define LW 6'b100011    //加载字

//保存
`define SB 6'b101000    //存储字节
`define SH 6'b101001    //存储半字
`define SW 6'b101011    //存储字

//与立即数运算
`define ADDI 6'b001000
`define ADDIU 6'b001001
`define ANDI 6'b001100
`define ORI 6'b001101
`define XORI 6'b001110
`define LUI 6'b001111   //立即数加载至高位
`define SLTI 6'b001010  //小于立即数置1
`define SLTIU 6'b001011

//分支
`define BEQ 6'b000100
`define BNE 6'b000101
`define BLEZ 6'b000110  //小于等于0转移
`define BGTZ 6'b000111

//特殊编码的branch指令
`define SPE_BRA 6'b000001  //两种branch的op段
`define BLTZ 5'b00000     //rt段 (小于0转移)
`define BGEZ 5'b00001

//J型指令的op段
`define J 6'b000010
`define JAL 6'b000011   //跳转并链接

