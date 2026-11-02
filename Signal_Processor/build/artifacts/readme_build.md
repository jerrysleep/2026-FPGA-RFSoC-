# 构建脚本使用说明

本目录中的 Tcl 用于 Vivado/Vitis 2021.2。PL 输入以原版 `Proj_SP`、不含 MTS 的设计为准，器件为 `xczu47dr-ffve1156-2-i`。工程根目录由脚本所在的 `build/artifacts` 自动推导，移动整个提交目录后无需修改盘符。

## 文件用途

| 文件 | 用途 |
| --- | --- |
| `source_manifest.tcl` | 原版工程输入清单，包含 38 个 RTL/头文件、31 个独立 IP、8 个 COE 和 2 个 XDC，以及 BD 路径。 |
| `recreate_project.tcl` | 从 `src/pl` 创建新的 Vivado 工程，检查 BD，生成 wrapper，恢复顶层与默认综合/实现策略。 |
| `run_build.tcl` | 重建工程后生成 IP 输出，运行综合、实现和 bit 生成，导出资源、时序、时钟、DRC、Methodology 和布线状态报告。 |
| `build_ps.tcl` | 使用本目录保留的旧版 XSA，为 A53_0 建立 64 位 FreeRTOS 平台并编译 `src/ps` 中的应用。 |

四个 Tcl 应放在同一个目录。PL 脚本复制所需输入到工作目录，生成文件不会写入 `src/pl`。旧的增量综合 DCP 和仿真测试台不作为 PL 构建输入。

## 保留的上板组合

按项目使用者的明确要求，`Signal_Processor_Top_Bram.xsa` 保留旧版本，用于 PS 平台；独立的 `Signal_Processor_Top.bit` 和 `Signal_Processor_Top.ltx` 采用原版工程已有的实现结果。旧 XSA 内嵌 bit 与独立 bit 的内容不同，这一组合由项目使用者选定，本次没有重新验证其上板兼容性。

以下四个归档文件保持原样，构建脚本默认不覆盖它们：

| 文件 | SHA-256 |
| --- | --- |
| `Signal_Processor_Top_Bram.xsa` | `5ee495a156d7564ae1d170fe3a869f57c498adea648fd1e2647e540200b4871b` |
| `Signal_Processor_Top.bit` | `750d33e98a968de47223615a16e15a70665934ba098dcbbc449213748cb7775d` |
| `Signal_Processor_Top.ltx` | `e44cb33ed931a66b84a1667a6477338e37ae5204a1b9347241d4d66024bcffb3` |
| `app.elf` | `1de9ae7bff3b8bada475b09246728a21b6bf3df87b739b00d18741d3270fed7a` |

## 先重建 Vivado 工程

打开 Vivado 2021.2 的命令行环境，进入提交目录的根目录，执行：

```text
vivado -mode batch -source build/artifacts/recreate_project.tcl
```

成功时输出 `SP_RECREATE_OK`。新工程为 `build/work/pl/project/signal_processor.xpr`。用 Vivado 打开它后，可以自行点击 Run Synthesis、Run Implementation 和 Generate Bitstream。

若从 Vivado GUI 的 Tcl Console 执行，应先关闭当前工程，再运行：

```tcl
set argv {}
source E:/Signal_Processor/build/artifacts/recreate_project.tcl
```

这段 GUI 示例中的路径按实际提交目录位置修改。工程重建成功只证明输入组织、BD/IP 读取等环节通过，不代表综合、时序或上板已通过。

## 自动运行 PL 综合与实现

```text
vivado -mode batch -source build/artifacts/run_build.tcl -tclargs --work-dir build/work/pl_full --jobs 4
```

选择独立的 `pl_full` 工作目录，可与前面的 GUI 重建工程同时保留。成功时输出 `SP_BUILD_OK`。

默认新产物位于 `build/rebuilt/pl`，原始报告位于其 `reports` 子目录，包含综合/布线后资源、时序、约束检查、DRC、Methodology、布线状态与时钟报告。`build_status.txt` 记录构建信息及最差建立/保持时间裕量。

可以设置 `--root <提交目录>`、`--work-dir <新工作目录>`、`--output-dir <新输出目录>`、`--jobs <正整数>`。工作目录必须为空；重复构建请换一个目录，保留旧结果以便比较。

默认不重新导出 XSA。若仅为分析新硬件而需要导出，可额外传入 `--export-xsa 1`；新文件名为 `build/rebuilt/pl/generated_hardware.xsa`，不会替换归档的旧 XSA，PS 脚本仍使用归档的旧 XSA。

bit 生成成功与时序收敛是不同的检查结果。应审阅 `timing_routed.rpt`、`check_timing.rpt`、`methodology_routed.rpt` 和 `drc_routed.rpt`。现有基线的报告含负裕量和约束警告，脚本保留实际结果，不宣称时序全部通过。

## 从 PS 源码构建 ELF

打开 Vitis 2021.2 的命令行环境，在提交目录根目录执行：

```text
xsct build/artifacts/build_ps.tcl
```

默认工作空间为 `build/work/ps`，应为空。新业务程序输出到 `build/rebuilt/ps/app.elf`，保留的业务 `app.elf` 不会被覆盖。

脚本采用归档 XSA，处理器为 `psu_cortexa53_0`，64 位，FreeRTOS；配置 `lwip211 1.6`、`SOCKET_API`、`xilffs 4.6`、原平台的堆与网络缓冲参数，并链接数学库 `m`。应用采用 `src/ps/lscript.ld`。平台生成的 FSBL、PMUFW、PS 初始化文件保留在新工作空间内。

支持 `--root`、`--work-dir` 和 `--output-dir`。此脚本负责编译，不连接板卡或启动调试；下载与实测步骤应放在 `board` 目录。

## 本次验证范围

本次在隔离临时目录使用 Vivado 2021.2 检查工程重建、BD、IP 状态及 HDL 语法，并检查四份 Tcl 的结构完整性。没有执行完整综合/实现、PS 完整编译或上板测试。重新构建不保证与历史 bit/ELF 二进制逐字节一致。

使用其他 Vivado/Vitis 版本时，需要单独验证 IP、BSP 和构建流程；脚本不自动升级 IP。
