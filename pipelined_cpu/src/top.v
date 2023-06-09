//将所有模块进行连接
module top(
    input clk,
    input rstn
);

    wire IMreadEn, RegReadEn1, RegReadEn2, RegWriteEn,
        ex_regWriteEn, alu_regWriteEn_o, br_flag,
        mem_regWriteEn, mem_regWriteEn_o, wb_regWriteEn,
        MemWriteEn, ex_memWriteEn, mem_memWriteEn, MemEn,
        load_stop_request;
    wire [1:0] AluSrc1, AluSrc2;
    wire [2:0] MemOp, ex_memOp, mem_memOp;
    wire [3:0] AluOp, ex_aluOp, Mem_sel;
    wire [4:0] RegWriteAddr, ex_regWriteAddr, mem_regWriteAddr,
        mem_regWriteAddr_o, wb_regWriteAddr, alu_regWriteAddr_o;
    wire [31:0] pc, instr, id_PC, id_instr,
        imm, id_num1, id_num2, RegWriteData, readData1, readData2,
        ex_num1, ex_num2, alu_regWriteData_o, mem_regWriteData,
        mem_regWriteData_o, wb_regWriteData, linkAddr, ex_linkAddr,
        br_addr, MemReadData, MemAddr_o, MemWriteData, MemAddr,
        mem_memAddr, mem_regData2, ex_memAddr;
    
//IF模块实例化
    //IM
    IM IM(.rstn(rstn), .IMreadEn(IMreadEn), .pc(pc), .instr(instr));

    //PC
    PC PC(.clk(clk), .rstn(rstn), .br_flag(br_flag), .br_addr(br_addr),
        .pc(pc), .IMreadEn(IMreadEn), .load_stop_request(load_stop_request));

    //IF_ID
    IF_ID IF_ID(.clk(clk), .rstn(rstn), .if_PC(pc), .if_instr(instr),
        .id_PC(id_PC), .id_instr(id_instr),
        .load_stop_request(load_stop_request));

    //流水线每个阶段需要传递上个阶段的信息
//ID模块实例化
    //ControlUnit
    ControlUnit ControlUnit(.rstn(rstn), .instr(id_instr),
        .RegReadEn1(RegReadEn1), .RegReadEn2(RegReadEn2), .RegWriteEn(RegWriteEn),
        .AluOp(AluOp), .AluSrc1(AluSrc1), .AluSrc2(AluSrc2), .imm(imm), .RegWriteAddr(RegWriteAddr),
        .daHa_ex_regWrEn(alu_regWriteEn_o), .daHa_ex_regWrAddr(alu_regWriteAddr_o),
        .daHa_mem_regWrEn(mem_regWriteEn), .daHa_mem_regWrAddr(mem_regWriteAddr), .MemOp(MemOp),
        .regData1(readData1), .MemAddr(MemAddr), .daHa_ex_memOp(ex_memOp), .load_stop_request(load_stop_request));
    
    //RegisterFile
    RegisterFile RegisterFile(.clk(clk), .rstn(rstn), .RegReadAddr1(id_instr[25:21]),
        .RegReadAddr2(id_instr[20:16]), .RegReadEn1(RegReadEn1), .RegReadEn2(RegReadEn2),
        .RegWriteAddr(wb_regWriteAddr), .RegWriteData(wb_regWriteData), .RegWriteEn(wb_regWriteEn),
        .readData1(readData1), .readData2(readData2));

    //选择alu的第一个操作数
    //1:立即数 2:寄存器1 3:EX阶段数据前推 4:MEM阶段数据前推
    Mux4_32bits Alu_mux1(.a(imm), .b(readData1), .c(alu_regWriteData_o), .d(mem_regWriteData_o),
        .choice(AluSrc1), .out(id_num1));

    //选择alu的第二个操作数
    Mux4_32bits Alu_mux2(.a(imm), .b(readData2), .c(alu_regWriteData_o), .d(mem_regWriteData_o),
        .choice(AluSrc2), .out(id_num2));

    //Br_judge
    Br_judge Br_judge(.rstn(rstn), .pc(id_PC), .instr(id_instr), .readData1(id_num1),
        .readData2(id_num2), .br_flag(br_flag), .br_addr(br_addr), .linkAddr(linkAddr));

    //ID_EX
    ID_EX ID_EX(.clk(clk), .rstn(rstn), .id_num1(id_num1), .id_num2(id_num2),
        .id_regWriteEn(RegWriteEn), .id_regWriteAddr(RegWriteAddr), .id_aluOp(AluOp),
        .id_linkAddr(linkAddr), .ex_num1(ex_num1), .ex_num2(ex_num2),
        .ex_regWriteEn(ex_regWriteEn), .ex_regWriteAddr(ex_regWriteAddr), .ex_aluOp(ex_aluOp),
        .ex_linkAddr(ex_linkAddr), .id_memWriteEn(MemWriteEn), .ex_memWriteEn(ex_memWriteEn),
        .id_memOp(MemOp), .ex_memOp(ex_memOp), .id_memAddr(MemAddr), .ex_memAddr(ex_memAddr),
        .load_stop_request(load_stop_request));
    
//EX模块
    //Alu
    Alu Alu(.rstn(rstn), .num1(ex_num1), .num2(ex_num2), .AluOp(ex_aluOp),
        .RegWriteEn_i(ex_regWriteEn), .RegWriteEn_o(alu_regWriteEn_o),
        .RegWriteAddr_i(ex_regWriteAddr), .RegWriteAddr_o(alu_regWriteAddr_o),
        .RegWriteData_o(alu_regWriteData_o), .linkAddr(ex_linkAddr));
    
    //EX_MEM
    EX_MEM EX_MEM(.clk(clk), .rstn(rstn), .ex_regWriteEn(alu_regWriteEn_o),
        .ex_regWriteAddr(ex_regWriteAddr), .ex_regWriteData(alu_regWriteData_o),
        .mem_regWriteEn(mem_regWriteEn), .mem_regWriteAddr(mem_regWriteAddr),
        .mem_regWriteData(mem_regWriteData), .ex_memWriteEn(ex_memWriteEn),
        .mem_memWriteEn(mem_memWriteEn), .ex_memOp(ex_memOp), .mem_memOp(mem_memOp),
        .ex_memAddr(ex_memAddr), .mem_memAddr(mem_memAddr), .ex_regData2(ex_num2),
        .mem_regData2(mem_regData2));

//MEM模块
    //Mem
    Mem Mem(.rstn(rstn), .RegWriteEn_i(mem_regWriteEn), .RegWriteAddr_i(mem_regWriteAddr),
        .RegWriteData_i(mem_regWriteData), .RegWriteEn_o(mem_regWriteEn_o), 
        .RegWriteAddr_o(mem_regWriteAddr_o), .RegWriteData_o(mem_regWriteData_o),
        .MemOp(mem_memOp), .MemAddr_i(mem_memAddr), .MemReadData(MemReadData),
        .MemAddr_o(MemAddr_o), .MemWriteEn(MemWriteEn), .Mem_sel(Mem_sel),
        .MemWriteData(MemWriteData), .MemEn(MemEn), .regData2(mem_regData2));
    
    //DM
    DM DM(.MemEn(MemEn), .clk(clk), .data_i(MemWriteData), .addr(MemAddr_o),
        .MemWriteEn(MemWriteEn), .Mem_sel(Mem_sel), .data_o(MemReadData), .rstn(rstn));


    //MEM_WB
    MEM_WB MEM_WB(.clk(clk), .rstn(rstn), .mem_regWriteEn(mem_regWriteEn_o), 
        .mem_regWriteAddr(mem_regWriteAddr_o), .mem_regWriteData(mem_regWriteData_o),
        .wb_regWriteEn(wb_regWriteEn), .wb_regWriteAddr(wb_regWriteAddr), .wb_regWriteData(wb_regWriteData));

endmodule