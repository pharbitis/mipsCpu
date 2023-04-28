module mips (
    clk,
    rst
);
    input clk, rst;
    //用wire类型实例化其他模块
    wire [31:0] instruction, zero_flag, busA, busB, imm32, ra_jal;
    wire [31:0] data_in, addr, dm_out, alu_out, mux_alu_out, mux_memToReg_out;
    wire regDst, aluSrc, memToReg, regWrite, memWrite, extOp, isJal;
    wire [1:0] nPC_sel, aluCtr;
    wire [4:0] rw, rs, rt, rd;

    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign rd = instruction[15:11];

    //实例化控制部分
    ctrl CTRL(.instruction(instruction), .regDst(regDst), .aluSrc(aluSrc), 
    .memToReg(memToReg), .regWrite(regWrite), .memWrite(memWrite),
    .nPC_sel(nPC_sel), .extOp(extOp), .aluCtr(aluCtr));

    //实例化ifu
    ifu IFU(.clk(clk), .rst(rst), .zero_flag(zero_flag), .nPC_sel(nPC_sel),
     .instruction(instruction), .ra_jal(ra_jal), .isJal(isJal));

    //实例化gpr
    gpr GPR(.rw(rw), .ra(rs), .rb(rt), .regWrite(regWrite), .clk(clk),
    .rst(rst), .busW(mux_memToReg_out), .busA(busA), .ra_jal(ra_jal),
    .busB(busB), .data_in(data_in), .isJal(isJal));

    //实例化alu
    alu ALU(.aluCtr(aluCtr), .busA(busA), .busB(mux_alu_out), 
    .zero_flag(zero_flag), .addr(addr), .alu_out(alu_out));

    //实例化ext
    ext EXT(.imm16(instruction[15:0]), .extOp(extOp), .imm32(imm32));

    //实例化dm
    dm DM(.data_in(data_in), .memWrite(memWrite), .addr(addr), .clk(clk),
    .rst(rst), .dm_out(dm_out));
    
    //实例化mux_aluSrc
    mux_aluSrc MUX_ALUSRC(.busB(busB), .imm32(imm32), .aluSrc(aluSrc),
    .mux_alu_out(mux_alu_out));

    //实例化mux_regDst
    mux_regDst MUX_REGDST(.rd(rd), .rt(rt), .regDst(regDst), .rw(rw));

    //实例化mux_memToReg
    mux_memToReg MUX_MEMTOREG(.alu_out(alu_out), .dm_out(dm_out), 
    .memToReg(memToReg), .mux_memToReg_out(mux_memToReg_out));

    


endmodule