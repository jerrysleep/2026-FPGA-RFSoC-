# Signal Processor 工程快照（2026-10-29）

本页只服务于 `E:\Signal_Processor`。新对话应先读这页，再检查磁盘；不要把它当成实时状态。该目录是用户为复现原始工程而建立的副本，**当前基线没有 MTS**。先前在 `E:\Vivado_vitis_works\Proj_SP_781_0625_NoTimingErr` 做过 MTS 试验，那是另一份工程。

## 目录与工具

| 位置 | 已检查到的内容 |
|---|---|
| `E:\Signal_Processor\src\Proj_SignalProcessor_781.xpr` | Vivado 工程入口；本机使用 Vivado 2021.2。 |
| `E:\Signal_Processor\src\Proj_SignalProcessor_781.srcs\new\Signal_Processor_Top.v` | PL 顶层。 |
| `E:\Signal_Processor\src\Proj_SignalProcessor_781.srcs\sources_1\ip\usp_rf_data_converter_0\usp_rf_data_converter_0.xci` | 原始 RFDC IP 配置，ADC Tile 0–3 的 MTS 均为 `false`。 |
| `E:\Signal_Processor\src\Proj_SignalProcessor_781.runs\impl_1\Signal_Processor_Top.bit` | 已存在 bit 文件；文件时间为 2026-06-25。存在不等于与后续源码/XSA/ELF 一致。 |
| `E:\Signal_Processor\src\Signal_Processor_Top_Bram.xsa` | 当前副本中的硬件导出文件。 |
| `E:\Signal_Processor\src\ps\` | Vitis 工作区，含 `plat/` 平台、`app/` 应用、`app_system/` 系统工程。`plat/platform.spr` 显示 FreeRTOS 10、`psu_cortexa53_0`、64-bit，加入 `xilffs` 和 `lwip211`。 |
| `E:\Signal_Processor\sim\` | 已交付非 RFDC 仿真包；参见 `README.md`、`run_xsim.ps1`、`tb/`、`results/`。 |

`src/ps/plat/platform.spr` 当前仍含 `platHandOff: E:/Vivado_vitis_works/Proj_SP/Signal_Processor_Top_Bram.xsa`，指向旧位置。这是**可移植性待核查项**；不要只凭它断言平台已经构建失败，因为平台还可能保存了一份内部硬件副本。若迁移或重建 PS 工程，应核对平台实际采用的 XSA、BSP 中 `xparameters.h` 和最新 bit 是否对应。

《AMD 选题指南》自主选题赛道推荐 Vivado/Vitis 2026.1 或 2025.2；本工程使用 2021.2，提交设计报告时须说明版本差异和脚本复现条件。推荐目录名/文件名只用英文；当前项目 `src/` 下的旧 Vivado 生成内容按原样保留，后续整理提交包时单独核对。

## 原始 PL 数据与控制路径

顶层文件中的关键实例（行号是本快照的搜索位置，代码变动后重新查找）：

| 顶层行附近 | 实例 | 用途 |
|---:|---|---|
| 589、628 | `LMK04828_config_inst`、`cfg_si5341_INST` | 板级时钟芯片 SPI 配置。 |
| 662 | `U_SysRst_Ctrl` | 系统复位。 |
| 1112 | `U7_rf_data_converter : usp_rf_data_converter_0` | RFDC ADC/DAC 转换 IP，直接在顶层实例化。 |
| 1320 | `U8_Pulse_Compression` | 五通道脉冲压缩。 |
| 1355 | `U9_Buffer` | 五通道缓存。 |
| 1401 | `U10_top_fft` | FFT/检测链。 |
| 1461 | `U12_Serial_Rs422` | RS-422 串口模块。 |
| 1487 | `u_design_1_wrapper` | PL 与 PS Block Design 的顶层封装接口。 |

从 RFDC 数字输出到脉冲压缩、缓存、FFT 是主要接收处理链。参数也会经 PS/PL 连接和控制模块进入处理链。不要把 `design_1_wrapper.v` 的生成封装视为业务算法，也不要从模块名字推断实际使能；应沿端口与寄存器写入追踪。

## 当前验证证据

`sim/README.md` 记录了 XSim 2021.2 的单项 RTL/IP 仿真，`sim/results/` 有 16 份 CSV：复位、LMK/SI 的 SPI 启动、参数控制、UART TX、五通道缓存、FFT、单通道及五通道脉冲压缩、Chirp。测试台对部分接口作断言；例如 UART 解出 ASCII `ABCD`，五通道缓存读出与激励偏移关系一致，FFT 通道出现有效输出。完整 `-Case all` 一键复跑在五通道 IP 展开处耗时过长而中断；不要把它记成“整套脚本一次通过”。

仿真尚未给出脉冲压缩/FFT 全链黄金逐点比对，没有验证 RFDC 模拟行为、MTS、外部时钟芯片锁定、PS 网络发送、Qt 上位机或此副本的板级实测。`build/`、`board/`、`data/`、`report/` 需按后续真实交付补充；技能包不能把这些空白视为已完成。

## 用户当前选择

用户选择保留最初工程作为竞赛复现基线，暂不继续 MTS，也暂不因小幅时序违例改动设计。下一轮对话应以**新请求**为准；若请求修改 MTS、DAC 或时序，应重新评估当前基线和证据，不自动沿用旧试验工程的修改。
