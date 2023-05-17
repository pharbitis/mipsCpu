module top (
    clk,
    rst,
    currentIAddr, 
    nextIAddr,
    rs,
    rt,
    ReadData1,  //寄存器堆读取的数据1
    ReadData2,
    ALU_result, //ALU运算结果
    DataBus     //DBR输出的结果
);
    input clk, rst;
    input [31:0] currentIAddr, nextIAddr;
    output [4:0] rs, rt;
    output [31:0] ReadData1, ReadData2, ALU_result, DataBus;

    //中间的连线
    //控制信号
    wire ALUSrcA, ALUSrcB, DBDataSrc, WrRegSrc,
     mRD, ExtSelPCWre, mWR, RegWre, InsMemRW, IRWre;
    wire [1:0] PCSrc, RegDst;
    wire [2:0] ALUOp;

    //其他中间量
    wire [31:0] instruction, num1, num2, DataAddr,
     DataIn, DataOut, extendOut, WriteData, IDataOut,
     ADR_out, BDR_out, ALUOutDR_out, DataBus_before;
    wire [4:0] WriteReg, rd;
    wire [5:0] opcode, func;
    wire [15:0] imm;
    wire zero, sign;

    //将instruction各部分赋值
    assign opcode = instruction[31:26];
    assign func = instruction[5:0];
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];
    assign imm = instruction[15:0];

    //实例化各个组件
    ControlUnit ControlUnit(.clk(clk), .rst(rst), .opcode(opcode), .func(func),
    .zero(zero), .sign(sign), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB),
    .DBDataSrc(DBDataSrc), .WrRegSrc(WrRegSrc), .mRD(mRD), .ExtSel(ExtSel),
    .PCSrc(PCSrc), .RegDst(RegDst), .ALUOp(ALUOp), .PCWre(PCWre), .IRWre(IRWre),
    .mWR(mWR), .RegWre(RegWre), .InsMemRW(InsMemRW));

    ALU ALU(.ALUOp(ALUOp), .num1(num1), .num2(num2), .result(ALU_result),
    .zero(zero), .sign(sign));

    DataMemory DataMemory(.clk(clk), .DataAddr(DataAddr), .DataIn(DataIn), 
    .RD(mRD), .WR(mWR), .DataOut(DataOut));

    IM IM(.IAddr(currentIAddr), .IDataOut(IDataOut));

    ImmediateExtend ImmediateExtend(.imm(imm), .ExtSel(ExtSel), .extendOut(extendOut));

    PC PC(.clk(clk), .rst(rst), .PCWre(PCWre), .currentIAddr(currentIAddr), .nextIAddr(nextIAddr));

    RegisterFile RegisterFile(.clk(clk), .rst(rst), .RegWre(RegWre), 
    .ReadReg1(rs), .ReadReg2(rt), .WriteReg(WriteReg), .WriteData(WriteData), .ReadData1(ReadData1), .ReadData2(ReadData2));

    //多周期cpu的寄存器
    //指令暂存
    IR IR(.clk(clk), .IRWre(IRWre), .InsIn(IDataOut), .InsOut(instruction));

    //寄存器堆读取的第一个数据
    DFF_32bits ADR(.clk(clk), .rst(rst), .in(ReadData1), .out(ADR_out));

    //寄存器堆读取的第二个数据
    DFF_32bits BDR(.clk(clk), .rst(rst), .in(ReadData2), .out(BDR_out));

    //alu运算结果暂存
    DFF_32bits ALUOutDR(.clk(clk), .rst(rst), .in(ALU_result), .out(ALUOutDR_out));

    //即将写回寄存器的值
    DFF_32bits DBDR(.clk(clk), .rst(rst), .in(DataBus_before), .out(DataBus));

    //多路选择器

    //下一条指令地址
    Mux4_32bits Mux_nextIAddr(.choice(PCSrc), .a(currentIAddr + 4), .b(currentIAddr + 4 + (extendOut << 2)),
    .c(ReadData1), .d({currentIAddr[31:28], instruction[25:0], 2'b00}), .out(nextIAddr));

    //写入寄存器编号
    Mux4_5bits Mux_WriteReg(.choice(RegDst), .a(5'd31), .b(rt), .c(rd),
    .d(5'bzzzzz), .out(WriteReg));

    //写入寄存器的值
    Mux2_32bits Mux_WriteData(.choice(WrRegSrc), .a(currentIAddr + 4), .b(DataBus), .out(WriteData));

    //alu操作数1
    Mux2_32bits Mux_ALUInA(.choice(ALUSrcA), .a(ADR_out), .b({27'd0, instruction[10:6]}), .out(num1));

    //alu操作数2
    Mux2_32bits Mux_ALUInB(.choice(ALUSrcB), .a(BDR_out), .b(extendOut), .out(num2));
    
    //DBAR输入
    Mux2_32bits Mux_DBAR(.choice(DBDataSrc), .a(ALU_result), .b(DataOut), .out(DataBus_before));


endmodule