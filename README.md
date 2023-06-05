# mipsCpu

逐步实现基于mips指令集的cpu

- 进行仿真时需更改tb_top中的指令文件地址

1. 实现单周期cpu:含有基本7条指令
   - addu, subu, ori, lw, sw, beq, jal

2. 在1的基础上增加一些指令，支持mipsC指令:共42条指令

3. 实现支持基础mips指令的五级流水线cpu

   - 包括逻辑运算、算术运算、移位运算、转移与加载指令共42条指令

   

