# Vivado/Vitis 工程复现与证据核验技能包

本技能包从 Signal Processor 工程的迁移、仿真、Vitis 建项和上板调试经历中提炼，面向 **已有 Vivado 工程 + PS 软件** 的复现与问题定位。它可以用于其他 RFSoC/Zynq 项目：复用检查顺序、证据分级和排障方法；具体模块、路径与参数需替换为目标工程的实际值。

本目录符合《AMD 选题指南》自主选题赛道 3.3.5.2 的技能包格式要求：目录名和文件名为英文，`README.md` 说明适用范围、用法、失效条件、验证效果及经验来源。它是提交材料中的**技能包部分**，不等同于完整工程包或板级实测报告。

## 条目

| 条目 | 适用范围与使用方法 | 已验证效果 | 失效条件 / 边界 | 经验来源 |
|---|---|---|---|---|
| [`vivado-vitis-repro/SKILL.md`](vivado-vitis-repro/SKILL.md) | 新对话理解工程、迁移目录、定位 Vivado/Vitis 构建问题、规划仿真或上板复现时加载。先确认目标和证据，再按实际任务选择检查。 | 本工程非 RFDC 主要 RTL/IP 已完成单项仿真，见 `../sim/README.md` 与 16 份 CSV；复位、控制、缓存、FFT、脉冲压缩、Chirp 等均有可查看输出。 | 无法用仿真证明模拟 RFDC、外部时钟芯片锁定、PS 网络通信或板上功能；现有 CSV 也不是所有算法的黄金逐点比对。 | 原工程迁移后绝对路径、XSim 兼容问题、RFDC/MTS 与 FreeRTOS BSP 冲突，以及调试中“编译通过不等于上板工作”的观察。 |
| [`references/diagnostics.md`](vivado-vitis-repro/references/diagnostics.md) | 出现 XSA/BSP、编译链接、时序、JTAG 或仿真异常时，按“症状 → 证据 → 下一步”查阅。 | `ff.h` 缺失与 BSP 库配置相关；`sin/cos/atan2` 未定义引用与链接 `m` 相关；串口发送在 CSV 中解出 `ABCD`。 | 不是故障自动修复清单；尤其不能把 `Failed to generate cmake files Windows` 直接归因为路径长度，需查看日志与当前 XSA。 | 本工程 Vitis 构建报错、XSim 报错、硬件管理器和串口调试记录。 |
| [`references/project-context.md`](vivado-vitis-repro/references/project-context.md) | **仅用于本工程**。新对话先读取，再核对磁盘现状；其他队伍替换其中的路径、模块图和状态。 | 已定位原始 RFDC 顶层实例、FreeRTOS 工程与仿真入口；标记了当前平台配置中仍存在的绝对 XSA 路径。 | 文件是 2026-10-29 的快照，复制、导出 XSA、重新生成 bit 或改 PS 工程后会过时。 | 直接检查本次提交目录中的 `.v`、`.xci`、`.spr`、`.bit` 和 `sim/` 文件。 |

## 在新对话使用

本技能包位于项目内，**不保证被 Codex 自动发现**。开启新对话时，建议直接发送：

> 请使用 `E:\Signal_Processor\skill\vivado-vitis-repro\SKILL.md`。先读取其中的 `references/project-context.md`，核对当前磁盘文件，再处理我接下来的问题。请区分源码、仿真、实现、bit/XSA、PS 程序和板上实测的证据，不要把旧的 MTS 试验当作当前原始工程。

若在其他项目使用，把路径换成该项目技能包的位置，并提供其工程根目录。若需要让 Codex 自动选择该技能，可另外将 `vivado-vitis-repro/` 安装到本机 Codex 技能目录；项目内这份仍应保留供提交与迁移。

## 复用和更新

1. 先阅读 [`SKILL.md`](vivado-vitis-repro/SKILL.md)，只在处理本项目时读取 `project-context.md`，遇到具体错误再读 `diagnostics.md`。
2. 变更工程后，更新项目快照中的 **日期、XPR、XSA、bit、PS 平台路径、测试结论**；不要只改措辞而保留过期结果。
3. 在设计报告中分别说明技能从哪些失败或观察中提炼、如何验证、哪些情况仍不适用。《AMD 选题指南》还要求工程、仿真/验证、综合实现报告、上板实测、构建脚本和大模型协作记录；本目录不代替这些提交物。
