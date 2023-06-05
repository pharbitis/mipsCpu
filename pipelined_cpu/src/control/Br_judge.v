//为ControlUnit生成辅助信号br_flag确定是否需要跳转，并确定转移地址
`include "../macro/ControlUnit_macro.v"

module Br_judge(
    rstn,
    pc,
    instr,
    readData1,      //rs寄存器读取的值
    readData2,      //rt寄存器读取的值
    br_flag,
    br_addr,
    linkAddr       //链接地址
);
    input rstn;
    input [31:0] pc, instr, readData1, readData2;
    output reg br_flag;
    output reg [31:0] br_addr, linkAddr;

    wire [5:0] op, func, temp;
    wire [31:0] pc_4, pc_8;

    assign pc_4 = pc + 4;
    assign pc_8 = pc + 8;

    assign op = instr[31:26];
    assign func = instr[5:0];
    assign temp = instr[20:16];

    //br_flag
    always @(*) begin
        if (!rstn)
            br_flag <= 0;
        else begin
            case (op)
                `J, `JAL:   br_flag <= 1;

                `BEQ: begin
                    if (readData1 == readData2)
                        br_flag <= 1;
                    else
                        br_flag <= 0;
                end

                `BNE: begin
                    if (readData1 != readData2)
                        br_flag <= 1;
                    else
                        br_flag <= 0;
                end

                `BLEZ: begin
                    if (readData1[31] == 1'b1 || readData1 == 0)
                        br_flag <= 1;
                    else
                        br_flag <= 0;
                end

                `BGTZ: begin
                    if (readData1[31] == 1'b0 && readData1 != 0)
                        br_flag <= 1;
                    else
                        br_flag <= 0;
                end

                `R: begin
                    case (func)
                        `JALR, `JR: br_flag <= 1; 
                        default:    br_flag <= 0;
                    endcase
                end

                `SPE_BRA: begin
                    case (temp)
                        `BLTZ: begin
                            if (readData1[31] == 1'b1)
                                br_flag <= 1;
                            else
                                br_flag <= 0;
                        end 

                        `BGEZ: begin
                            if (readData1[31] == 1'b0)
                                br_flag <= 1;
                            else
                                br_flag <= 0;
                        end
                        default:    br_flag <= 0;
                    endcase
                end

                default:    br_flag <= 0;
            endcase
        end    
    end

    //br_addr
    always @(*) begin
        if (!rstn || !br_flag)
            br_addr <= 0;
        else begin
            case (op)
                `J, `JAL:   br_addr <= {pc_4[31:28], instr[25:0], 2'b0};
                `R: begin
                    case (func)
                        `JR, `JALR: br_addr <= readData1; 
                        default: br_addr <= 0;
                    endcase
                end 
                `BEQ, `BNE, `BGTZ, `BLEZ, `SPE_BRA:   br_addr <= pc_4 + {{14{instr[15]}}, instr[15:0], 2'b0};
                default: br_addr <= 0;
            endcase
        end
    end
    
    //linkAddr
    //为jal和jalr设置链接地址
    always @(*) begin
        if (!rstn)
            linkAddr <= 0;
        //链接地址为添加延迟槽的情况
        else begin
            case (op)
                `JAL:   linkAddr <= pc_8;
                `R: begin
                    case (func)
                        `JALR:  linkAddr <= pc_8; 
                        default: linkAddr <= 0;
                    endcase
                end 
                default: linkAddr <= 0;
            endcase
        end
    end
endmodule