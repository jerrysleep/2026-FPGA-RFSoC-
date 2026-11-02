# Signal Processor 仿真记录

本目录使用 `../src/` 中的原始 Vivado 工程进行 RTL / IP 功能仿真，**不模拟 RFDC 的 ADC/DAC 模拟采样、时钟芯片的物理锁定，也不证明上板时序收敛**。仿真工具为 Vivado / XSim 2021.2。测试输入由 `tb/` 和 `input/` 提供，结果保存在 `results/`，未修改 `src/`。

## 目录

| 路径 | 内容 |
|---|---|
| `run_xsim.ps1` | 可重复运行的 XSim 编译、仿真、CSV 收集脚本；运行后清理 `_xsim_work/`。 |
| `tb/` | 各模块测试台，包括激励和基本断言。 |
| `input/` | 脉冲压缩单元的远、近程合成复数输入。 |
| `compat/` | 仅用于 XSim 编译的两份等价 RTL 副本，详见下文。 |
| `results/` | 本次仿真得到的 CSV，不含构建缓存。 |

## 复现方法

保持 `sim/` 和 `src/` 为同级目录，在 Windows PowerShell 中运行：

```powershell
cd E:\Signal_Processor\sim
.\run_xsim.ps1 -Case all
```

也可选择单项：`reset`、`sysrst`、`clock`、`control`、`serial`、`buffer`、`fft`、`pulse_unit`、`pulse5`、`chirp`。例如 `./run_xsim.ps1 -Case fft`。若 Vivado 不在 `E:\Vivado\Vivado\2021.2`，先把环境变量 `XILINX_VIVADO` 设为安装目录。若 `src/` 不与 `sim/` 同级，可使用 `-SourceRoot <src目录>`。需要 `../src/Proj_SignalProcessor_781.gen/sources_1/ip/` 中已生成的 IP 仿真网表；DDS 的 VHDL 仿真模型会由脚本在临时目录重新生成。

脚本会覆盖同名 `results/*.csv`；每次运行结束会删除 `sim/_xsim_work/`。如运行中断且此目录仍在，确认没有仿真进程后再移走它，随后重试。

## 覆盖范围和结果

| 项目 / 源 RTL | 测试和结果 CSV | 本次观察与断言 |
|---|---|---|
| `Rst_Sync.v` | `tb_reset.v` → `reset.csv` | 异步复位后同步释放，重新置位后输出恢复复位态；10 行。 |
| `Gen_Sys_Rst.v` | `tb_sysrst.v` → `sysrst.csv` | 锁定信号稳定后，等待计数结束释放系统复位；PC 复位会重新拉起；143 行。 |
| `clk_spi_ge.v`、`LMK04828_config.v`、`cfg_si5341.v` 及两个 SPI 子模块 | `tb_clock_startup.v` → `clock_startup.csv` | 时钟输出出现 148 个上升沿；LMK、SI 都发起 SPI 传输且片选有效；589 行。时钟芯片配置仅做启动阶段检查。 |
| `Analysis_RadarParameter.v`、`RadarParameter_OutputDelay.v`、`Processor_Ctrl.v`、`RF_Timer.v` 及其子模块 | `tb_control.v` → `control.csv` | 对参数地址 `0x108` 的写入传播到脉冲压缩选择；发射控制、远近程切换、帧和 PRT 脉冲通过断言；120 行，2 帧、8 个 PRT 脉冲。 |
| `Serial_Comm.v` 及 UART/RAM/FIFO 子模块 | `tb_serial.v` → `serial.csv`、`serial_decoded.csv` | 串行发送解码为 `41 42 43 44`（ASCII `ABCD`）；波形 1488 行，解码 4 行。 |
| `Buffer_top.v` 及 ping-pong RAM 子模块 | `tb_buffer.v` → `buffer.csv` | 两次写窗口，共 140 次写使能、50 次有效读；至少一组五通道 I/Q 数据和测试激励的偏移关系一致；226 行。 |
| `top_fft.v`、`fft_chal.v`、`pulse_peak_gate_detect.v` 及其 IP | `tb_fft.v` → `fft.csv` | `All_WaveNum=2` 时缓存读出 1024 点，通道 1 FFT IP 出现 499 个有效输出；CSV 为抽样波形加所有有效输出，共 706 行。 |
| `ch_pulse_compression_unit_debug.v` 及 FFT、ROM、乘法、IFFT IP | `tb_pulse_repro.v` + `input/*.csv` → `fifo_fft_in.csv`、`fft_out.csv`、`mul_out.csv`、`ifft_out.csv`、`dout_out.csv`、`status_out.csv` | 各取一组远、近程合成输入。FFT、乘法、IFFT 各记录 256 行（两组各 128 点）；最终输出远程 61 点、近程 48 点；状态中未见 overflow/halt。 |
| `top_5ch_pulse_compression.v`、`ch_pulse_compression.v`、`ch_pulse_compression_unit.v` | `tb_pulse5.v` → `pulse5.csv` | 五通道顶层有 366 个 `valid` 周期，记录的五组 I/Q 均为已知值；534 行。 |
| `chirp_top.v`、`Chirp_Gen_Ctrl.v`、`ChirpGen_user.v`、`ChirpGenUnit.v`、`dds_phase_mes.v` 及 DDS/位宽转换 IP | `tb_chirp.v` → `chirp.csv` | 合成参数下有 424 个主输出和 424 个位宽转换有效周期，输出数据为已知值；549 行。 |

CSV 第一行是列名。`cycle` 是测试台时钟周期，不是板上实测时间。波形 CSV 为控制事件附近、定期样本及有效数据的记录，**行数不等于持续周期数**。`*_hex` 和 `raw_hex` 保留原始位模式；脉冲压缩的 `I/Q` 列为有符号十进制。`buffer.csv` 中每个 32 位通道字按 `{Q[15:0], I[15:0]}` 打包。`fft.csv` 中 `fft_output_hex` 为通道 1 FFT IP 的输出，`fft_bin` 为其 bin 索引。`chirp.csv` 的 `converter_hex` 是 256 位总线，`mm_ch0_hex`、`mm_ch1_hex` 为主输出总线的前两个 32 位片段。

## 判读边界与发现

1. **通过表示所列激励下的基本接口行为符合断言。** 脉冲压缩与 FFT 输出尚未和 MATLAB/NumPy 的逐点黄金结果比对；五通道脉冲压缩测试检查了输出存在且无 `X`，尚未证明五通道相位或幅度一致。`top_fft` 测试未出现 `max_dout_en` 或 `ps_int`，因此检测结果和 PS 中断链未被这组激励验证。串口测试只覆盖 TX，未覆盖 RX。
2. `top_fft.v` 先计算 `All_WaveNum_d = All_WaveNum - 1`，再据此设置读数深度。测试值 1 只读出 512 点，没有满足内部 FIFO 的 FFT 启动计数条件；测试值 2 才观察到 FFT 输出。这里记录的是当前 RTL 的行为，不据此推断所有实际工作参数都正确。
3. `clk_spi_ge.v` 在 `cnt == 100` 时翻转输出。以顶层所接的 50 MHz `clk_50m_sys` 计，计算输出频率为 `50 MHz / (2 × 101) ≈ 247.5 kHz`，与源码注释中的“1 MHz”不同。测试台将加速的时钟直接送入 LMK/SI 状态机以缩短启动仿真时间；因此 `clock_startup.csv` 不代表实际 SPI 时间尺度，也不能证明外部器件完成配置或锁相。
4. 原始 `ch_pulse_compression_unit.v` 在 `reading` 声明前使用它，原始 `chirp_top.v` 在端口宽度中使用稍后才定义的 `C_DDS_CHNL_NUM`。XSim 对这两处报编译错误。`compat/` 内前者只提前声明 `reading`，后者把等价宽度表达式写为 `[1023:0]`；仿真时使用这两份副本，**原始 `src/` 文件未改动**。这些是编译兼容处理，不能代替修改设计源文件和重新综合验证。
5. RFDC、PS/Vitis 程序、外部模拟信号、LMK/SI 芯片反馈以及端到端上板功能均不属于这组 RTL/IP 仿真的验证范围。板级实测仍需 bitstream、PS 程序和实际仪器。
