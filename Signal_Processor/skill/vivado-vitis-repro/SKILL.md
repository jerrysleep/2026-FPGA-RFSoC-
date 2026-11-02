---
name: vivado-vitis-repro
description: Reproduce and debug an existing Vivado/Vitis FPGA or RFSoC project by tracing RTL/IP/BD/PS interfaces, checking XSA and build evidence, running scoped simulations, and distinguishing software, timing, and board results. Use for project migration, validation, and failure diagnosis; adapt hardware-specific facts from the project reference.
---

# Vivado/Vitis 工程复现

目标是让下一位工程师能指出：**正在使用哪份源码与硬件导出、哪些模块已被什么证据验证、失败发生在哪个阶段**。保留用户选择的基线与范围；不要把过去实验分支的结论自动套到当前工程。

## 工作顺序

1. **确定工程身份。** 找到实际根目录、`.xpr`、顶层、BD、关键 `.xci`、约束、bit、XSA、PS 平台/应用工程。记录它们的路径和时间/哈希；同名不代表同一版本。先检查项目自带 README，再根据当前任务追踪源文件。若是 `E:\Signal_Processor`，读取 [项目快照](references/project-context.md)并核对磁盘。
2. **画清接口边界。** 从顶层实例沿端口追踪到 BD/IP 与 PS 程序，写明时钟/复位、数据位宽、valid/ready、通道映射和寄存器地址。对 RFDC 等专用 IP，分别检查 `.xci` 配置、PL 端口与驱动初始化；不要把同频时钟、MTS 配置位、PS 驱动执行和模拟相位同步视为同一件事。
3. **按证据分级核验。** 区分语法/编译、RTL/IP 仿真、综合、布局布线与时序、bit/XSA 一致性、PS ELF 运行、板上输入输出。上一层通过不能替代下一层。报告测试激励、断言、CSV/日志和未覆盖接口；仿真有 `valid` 只说明数据流出现，算法正确性还需黄金参考或明确性质检查。
4. **修改后闭环。** 先保存基线，作最小范围改动；若改动影响 BD、RFDC、PS 可访问寄存器或时钟/复位，应重新生成相关输出并导出匹配的 XSA，随后更新 Vitis 平台/BSP、重建应用，再核对 bit/ELF 的来源。对时序违例从具体路径、扇出和约束查起，不单凭 WNS 数字决定是否可以上板。
5. **交付可复现材料。** 给出命令或 GUI 步骤、输入与期望输出、文件位置、工具版本、实际运行结果及限制。临时网表、日志、脚本放在隔离目录；验证后清理，保留正式测试台、结果和复现入口。

## 选用参考

- 本项目目录与已验证状态：[references/project-context.md](references/project-context.md)。只在本项目或用户明确要求延续该项目时读取。
- 编译、仿真、Vitis 与上板的实际踩坑：[references/diagnostics.md](references/diagnostics.md)。出现相应症状时读取，不把案例直接当作通用根因。

## 输出习惯

向初学者说明模块作用时，引用真实文件与代码位置，分开解释“配置”“数据路径”“控制路径”。遇到未验证项直接标记，不推断成功。迁移到另一块板或不同 Vivado/Vitis 版本时，重新核对器件、IP 版本、XDC、BSP 和外设连接；本技能包中的工程数值不是通用默认值。
