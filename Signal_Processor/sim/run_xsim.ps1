param(
    [ValidateSet('all','reset','sysrst','clock','control','serial','buffer','fft','pulse_unit','pulse5','chirp')]
    [string]$Case = 'all',
    [string]$SourceRoot
)

$ErrorActionPreference = 'Stop'
$simRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $simRoot
$srcRoot = if ($SourceRoot) { [IO.Path]::GetFullPath($SourceRoot) } else { Join-Path $projectRoot 'src' }
$rtl = Join-Path $srcRoot 'Proj_SignalProcessor_781.srcs'
$ipGen = Join-Path $srcRoot 'Proj_SignalProcessor_781.gen\sources_1\ip'
$tb = Join-Path $simRoot 'tb'
$compat = Join-Path $simRoot 'compat'
$results = Join-Path $simRoot 'results'
$work = Join-Path $simRoot '_xsim_work'
$vivadoRoot = if ($env:XILINX_VIVADO) { $env:XILINX_VIVADO } else { 'E:\Vivado\Vivado\2021.2' }
$bin = Join-Path $vivadoRoot 'bin'

# Keep each IP-heavy case in a fresh XSim library. A shared library made
# five-channel elaboration grow substantially after the FFT case.
if ($Case -eq 'all') {
    foreach ($part in @('reset','sysrst','clock','control','serial','buffer','fft','pulse_unit','pulse5','chirp')) {
        & $MyInvocation.MyCommand.Path -Case $part -SourceRoot $srcRoot
    }
    return
}

foreach ($name in @('xvlog.bat','xvhdl.bat','xelab.bat','xsim.bat','vivado.bat')) {
    if (-not (Test-Path -LiteralPath (Join-Path $bin $name))) {
        throw "Vivado tool missing: $(Join-Path $bin $name). Set XILINX_VIVADO."
    }
}
if (-not (Test-Path -LiteralPath $rtl)) { throw "RTL source missing: $rtl" }
if (Test-Path -LiteralPath $work) { throw "Temporary work directory already exists: $work" }
New-Item -ItemType Directory -Path $work,$results -Force | Out-Null

function IpFile([string]$name) {
    Join-Path (Join-Path $ipGen $name) ($name + '_sim_netlist.v')
}
function RtlFile([string]$folder,[string]$name) {
    Join-Path (Join-Path $rtl $folder) $name
}
function Tool([string]$name,[string]$log,[string[]]$toolArgs) {
    $exe = Join-Path $bin $name
    & $exe @toolArgs *> $log
    if ($LASTEXITCODE -ne 0) {
        $tail = (Get-Content -LiteralPath $log -Tail 12) -join "`n"
        throw "$name failed ($LASTEXITCODE):`n$tail"
    }
}
function RunCase([string]$name,[string]$top,[string[]]$sources,[string[]]$outputs,[string[]]$libs=@()) {
    Write-Host "Running $name ..."
    $snapshot = 'sim_' + $name
    $glbl = Join-Path $vivadoRoot 'data\verilog\src\glbl.v'
    Tool 'xvlog.bat' "$name.xvlog.log" ($sources + @($glbl))
    $elabArgs = @($top,'glbl','-s',$snapshot,'-mt','off','-L','unisims_ver','-L','unimacro_ver','-L','secureip') + $libs
    Tool 'xelab.bat' "$name.xelab.log" $elabArgs
    Tool 'xsim.bat' "$name.xsim.log" @($snapshot,'-runall')
    $runLog = Get-Content -LiteralPath "$name.xsim.log" -Raw
    if ($runLog -match 'Fatal:' -or $runLog -notmatch [regex]::Escape($name.ToUpper() + ' PASS')) {
        if ($name -ne 'pulse_unit' -or $runLog -notmatch 'SIM DONE') {
            throw "Simulation check failed for ${name}: $($runLog.Substring([Math]::Max(0,$runLog.Length-600)))"
        }
    }
    foreach ($file in $outputs) {
        if (-not (Test-Path -LiteralPath $file)) { throw "Missing CSV: $file" }
        Copy-Item -LiteralPath $file -Destination (Join-Path $results (Split-Path -Leaf $file)) -Force
    }
    Write-Host "$name PASS"
}
function Decode-Serial {
    $rows = @(Import-Csv 'serial.csv')
    $edges = @()
    $previous = '1'
    foreach ($row in $rows) {
        if ($previous -eq '1' -and $row.txd_fc -eq '0') { $edges += [int]$row.cycle }
        $previous = $row.txd_fc
    }
    $starts = @()
    foreach ($edge in $edges) {
        if ($starts.Count -eq 0 -or $edge -ge $starts[-1] + 900) { $starts += $edge }
    }
    if ($starts.Count -lt 4) { throw "Only $($starts.Count) UART frames detected" }
    $decoded = for ($index=0; $index -lt 4; $index++) {
        $value = 0
        for ($bit=0; $bit -lt 8; $bit++) {
            $targetCycle = $starts[$index] + 150 + 100*$bit
            $sample = $rows | Sort-Object { [Math]::Abs([int]$_.cycle - $targetCycle) } | Select-Object -First 1
            if ($sample.txd_fc -eq '1') { $value = $value -bor (1 -shl $bit) }
        }
        [pscustomobject]@{ frame=$index; start_cycle=$starts[$index]; byte_decimal=$value; byte_hex=('{0:X2}' -f $value) }
    }
    for ($i=0; $i -lt 4; $i++) {
        if ($decoded[$i].byte_decimal -ne 65+$i) { throw "UART byte $i mismatch: $($decoded[$i].byte_decimal)" }
    }
    $decoded | Export-Csv (Join-Path $results 'serial_decoded.csv') -NoTypeInformation -Encoding UTF8
}

try {
    Push-Location $work
    $n = 'new'
    if ($Case -in @('all','reset')) {
        RunCase 'reset' 'tb_reset' @((RtlFile $n 'Rst_Sync.v'),(Join-Path $tb 'tb_reset.v')) @('reset.csv')
    }
    if ($Case -in @('all','sysrst')) {
        RunCase 'sysrst' 'tb_sysrst' @((RtlFile $n 'Gen_Sys_Rst.v'),(Join-Path $tb 'tb_sysrst.v')) @('sysrst.csv')
    }
    if ($Case -in @('all','clock')) {
        $clockFiles = @(
            (RtlFile $n 'clk_spi_ge.v'),
            (RtlFile 'lmk04828' 'data_transmit_spi_16a_8d.v'),
            (RtlFile 'lmk04828' 'LMK04828_config.v'),
            (RtlFile 'si5341' 'data_transmit_spi_a8_d8.v'),
            (RtlFile 'si5341' 'cfg_si5341.v'),
            (Join-Path $tb 'tb_clock_startup.v')
        )
        RunCase 'clock' 'tb_clock_startup' $clockFiles @('clock_startup.csv')
    }
    if ($Case -in @('all','control')) {
        $files = @('Analysis_RadarParameter.v','RadarParameter_OutputDelay.v','Radar_Processor.v','Parameter_Ctrl.v','Processor_Ctrl.v','timing_ref.v','timing_cell.v','gate_buff_ctrl.v','RF_Timer.v') | ForEach-Object { RtlFile $n $_ }
        Tool 'xvlog.bat' 'control.xvlog.log' (@('-i',(Join-Path $rtl $n)) + $files + (Join-Path $tb 'tb_control.v'))
        Tool 'xelab.bat' 'control.xelab.log' @('tb_control','-s','sim_control','-mt','off')
        Tool 'xsim.bat' 'control.xsim.log' @('sim_control','-runall')
        if ((Get-Content 'control.xsim.log' -Raw) -notmatch 'CONTROL PASS') { throw 'CONTROL did not pass' }
        Copy-Item 'control.csv' (Join-Path $results 'control.csv') -Force
    }
    if ($Case -in @('all','serial')) {
        $files = @('uart_core_ram.v','uart_core_fifo.v','time_module.v','Serial_Comm.v') | ForEach-Object { RtlFile $n $_ }
        RunCase 'serial' 'tb_serial' (@((IpFile 'uart_ram_8x512'),(IpFile 'Fifo_Serial_Comm_8x512'),(IpFile 'bram_422_32x256')) + $files + (Join-Path $tb 'tb_serial.v')) @('serial.csv')
        Decode-Serial
    }
    if ($Case -in @('all','buffer')) {
        $files = @('wr_ram_ctrl.v','ping_pang_switch.v','Buffer_top.v') | ForEach-Object { RtlFile 'buffer' $_ }
        RunCase 'buffer' 'tb_buffer' (@((IpFile 'buffer_ram')) + $files + (Join-Path $tb 'tb_buffer.v')) @('buffer.csv')
    }
    if ($Case -in @('all','fft')) {
        $names = @('fifo_adc_32x2048','mult_16sx16us','mult_16sx16s','fft_ip','ram_32bx512','fft_win_1024','fft_win_512','ram_52bx512','ram_64x512x32','snr_div','ram_48bx64','arctan_ip','ram_32bx2x64','ram_64x8x16b')
        $files = $names | ForEach-Object { IpFile $_ }
        RunCase 'fft' 'tb_fft' ($files + @((RtlFile $n 'pulse_peak_gate_detect.v'),(RtlFile $n 'fft_chal.v'),(RtlFile $n 'top_fft.v'),(Join-Path $tb 'tb_fft.v'))) @('fft.csv')
    }
    if ($Case -in @('all','pulse_unit','pulse5')) {
        $pulseIp = @('PulseCompressfifo_32x256','xfft_128','ROM_ff_far','ROM_ff_near','complex_mult_16x16') | ForEach-Object { IpFile $_ }
        if ($Case -in @('all','pulse_unit')) {
            Copy-Item (Join-Path $simRoot 'input\far_input.csv') 'far_input.csv'
            Copy-Item (Join-Path $simRoot 'input\near_input.csv') 'near_input.csv'
            New-Item -ItemType Directory -Path 'pulse_out' -Force | Out-Null
            RunCase 'pulse_unit' 'tb_pulse_repro' ($pulseIp + @((RtlFile 'sim_1\imports\fpga_sim' 'ch_pulse_compression_unit_debug.v'),(Join-Path $tb 'tb_pulse_repro.v'))) @('pulse_out\dout_out.csv','pulse_out\fft_out.csv','pulse_out\mul_out.csv','pulse_out\ifft_out.csv','pulse_out\status_out.csv','pulse_out\fifo_fft_in.csv')
            if ((Import-Csv 'pulse_out\dout_out.csv').Count -lt 1) { throw 'Pulse unit produced no samples' }
        }
        if ($Case -in @('all','pulse5')) {
            RunCase 'pulse5' 'tb_pulse5' ($pulseIp + @((Join-Path $compat 'ch_pulse_compression_unit_simfix.v'),(RtlFile 'Pulse_Compress' 'ch_pulse_compression.v'),(RtlFile $n 'FrameRef_delay_ctrl.v'),(RtlFile 'Pulse_Compress' 'top_5ch_pulse_compression.v'),(Join-Path $tb 'tb_pulse5.v'))) @('pulse5.csv')
        }
    }
    if ($Case -in @('all','chirp')) {
        $ipSource = (Join-Path $rtl 'sources_1\ip').Replace('\','/')
        $tcl = "create_project -force dds_sim_ip [file normalize ./dds_sim_ip] -part xczu47dr-ffve1156-2-i`nset source_root [file normalize {$ipSource}]`nforeach name {dds_compiler_0 dds_compiler_1} { import_ip [file join `$source_root `$name `${name}.xci] }`ngenerate_target simulation [get_ips]`nclose_project`n"
        [IO.File]::WriteAllText((Join-Path $work 'generate_dds_sim.tcl'),$tcl)
        Tool 'vivado.bat' 'dds_generate.log' @('-mode','batch','-source','generate_dds_sim.tcl','-log','dds_tool.log','-journal','dds_tool.jou')
        $dds = Join-Path $work 'dds_sim_ip\dds_sim_ip.gen\sources_1\ip'
        Tool 'xvhdl.bat' 'chirp.xvhdl.log' @((Join-Path $dds 'dds_compiler_0\sim\dds_compiler_0.vhd'),(Join-Path $dds 'dds_compiler_1\sim\dds_compiler_1.vhd'))
        $chirpIp = @('fifo_312_625','axis_dwidth_converter') | ForEach-Object { IpFile $_ }
        $chirpRtl = @('dds_phase_mes.v','ChirpGenUnit.v','ChirpGen_user.v','Chirp_Gen_Ctrl.v') | ForEach-Object { RtlFile 'chirp' $_ }
        RunCase 'chirp' 'tb_chirp' ($chirpIp + $chirpRtl + @((Join-Path $compat 'chirp_top_simfix.v'),(Join-Path $tb 'tb_chirp.v'))) @('chirp.csv') @('-L','dds_compiler_v6_0_21')
    }
}
finally {
    Pop-Location
    $target = [IO.Path]::GetFullPath($work).TrimEnd('\')
    $parent = [IO.Path]::GetFullPath($simRoot).TrimEnd('\')
    if (-not $target.StartsWith($parent + '\',[StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to clean outside sim: $target"
    }
    if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
}
