# 从本工程提炼的诊断条目

以下是可迁移的**检查方法**，不是保证适用于所有 FPGA 工程的修复命令。遇到症状时先确认版本、当前 XSA/bit/ELF 和完整日志，再选择下一步；所有结论注明证据层级。

| 症状 / 触发条件 | 先取什么证据，如何排查 | 本工程观察与适用边界 |
|---|---|---|
| 复制工程后仍出现旧盘符、旧目录或 Vitis `platform file not found` | 搜 `.xpr`、`.spr`、`.prj`、Tcl 和 `xparameters.h` 中的绝对路径；区分 Vivado 实际使用的源文件与弃用引用。确认平台导入的是目标 XSA、其内部副本和应用链接的平台相同。 | 当前 `src/ps/plat/platform.spr` 的 `platHandOff` 仍指 `E:/Vivado_vitis_works/Proj_SP/...`；这是待核查项。路径字符串存在不必然说明运行失败。 |
| FreeRTOS domain 生成失败，日志含 `sw_rfdc...generate`、`generate_libmetal`、`Failed to generate cmake files Windows` | 保存完整 HSI/BSP 日志；比较原 XSA 与新增 RFDC 后 XSA 的驱动和地址映射。先在短、英文路径创建独立平台做最小复现，再检验 Vitis/SDK 版本和 CMake 环境。不要从弹窗推断根因。 | 该错误发生在**旧 MTS 试验 XSA**，原始 XSA 可建工程；后来“先建平台、再加 FreeRTOS domain”曾成功。无法仅凭现有证据证明是路径长度。当前基线无 MTS。 |
| `metal/init.h` 或 `ff.h` 缺失 | 查应用目标 domain 的 BSP、include path、是否生成 RFDC/libmetal 与 `xilffs`；从第一条编译错误开始，而非按 Problems 数量判断。 | `ff.h` 与启用 `xilffs` 有关；MTS 试验中的 `metal/init.h` 与 RFDC BSP 生成有关。不能直接把头文件复制进应用来掩盖 BSP 不匹配。 |
| 链接时 `sin`、`cos`、`atan2`、`sqrt`、`log10` 等未定义 | 看最后链接命令及库顺序。在 Vitis ARM gcc linker 的 Libraries 中填 `m`，使最终命令含 `-lm`，然后重建。 | 本工程加入数学库后这组链接错误消失。`m` 是 `-l` 后的库名，不填 `libm`。 |
| XSim 无法分析原 RTL，报重复声明或端口常量未定义 | 对照源文件找到首次使用和声明位置；先在 `sim/compat/` 做只供仿真的最小等价副本，记录与原文件差异。若要改正式设计，再综合和验证。 | `ch_pulse_compression_unit.v` 中 `reading` 声明位置、`chirp_top.v` 中 `C_DDS_CHNL_NUM` 端口宽度触发过 XSim 错误。当前仿真使用 `compat/`，`src/` 未据此改动。 |
| FFT 读缓存但无 `fft_out_tvalid` | 把 `All_WaveNum`、读使能、FIFO 写计数、FFT 输入 valid/last、配置通道握手同时采集；由 RTL 计算所需深度。 | 测试 `All_WaveNum=1` 时读了 512 点但未见 FFT 输出，改为 2 后读了 1024 点并见到 499 个输出 valid。仅为本测试激励的观察，不推断最终检测精度。 |
| Vivado `[Timing 38-282]` / WNS 为负 | 打开具体 setup/hold 路径，记录起点、终点、时钟关系、约束、逻辑与布线延迟、扇出；修复后重跑实现并比较。 | 曾看到 `clk_out2_PL_SYS_CLK` 到 `clk_out3_PL_SYS_CLK` 的跨时钟 setup 路径、高扇出。用户目前选择保留原始基线并暂不处理该小幅违例；不能把“能生成 bit”写成“已满足时序”。 |
| Vitis log 显示 `fpga -file`、`dow ...elf`、`con`，但看不到结果 | 这些日志只证明配置、下载和继续执行命令完成；另外检查目标串口输出、PS 网络收发、PL ILA 或应用任务状态。JTAG 线并不自动把 UART 字节显示在 Vitis Log。 | 当前项目 PS 输出与 Qt/UDP 的端到端实测没有包含在 `sim/` 证据中。 |

## 将经验写进报告

每个条目推荐保留四项：原始错误或观察、候选原因与排除证据、实际改动/验证命令、仍未验证的边界。这样能对应《AMD 选题指南》所要求的“技能包提炼过程”和“大模型协作自我纠错轨迹”，也便于其他队伍判断是否适用。
