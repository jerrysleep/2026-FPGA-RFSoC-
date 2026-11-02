# XSCT 2021.2. Build the FreeRTOS A53 application against the retained legacy XSA.
set script_dir [file dirname [file normalize [info script]]]
set root [file normalize [file join $script_dir ../..]]
set workspace {}
set output_dir {}
if {[llength $argv] % 2} {error "Each option requires a value"}
foreach {key value} $argv {
    switch -- $key {
        --root {set root [file normalize $value]}
        --work-dir {set workspace [file normalize $value]}
        --output-dir {set output_dir [file normalize $value]}
        default {error "Unknown option $key. Supported: --root --work-dir --output-dir"}
    }
}
if {$workspace eq {}} {set workspace [file join $root build work ps]}
if {$output_dir eq {}} {set output_dir [file join $root build rebuilt ps]}
set xsa [file join $root build artifacts Signal_Processor_Top_Bram.xsa]
set source_dir [file join $root src ps]
foreach input [list $xsa [file join $source_dir main.c] [file join $source_dir lscript.ld]] {
    if {![file isfile $input]} {error "Missing PS build input: $input"}
}
if {[file exists $workspace] && [llength [glob -nocomplain -directory $workspace * .*]] > 2} {
    error "PS workspace must be new and empty: $workspace. Select another --work-dir."
}
if {[file exists [file join $output_dir app.elf]]} {error "Output app.elf exists. Select another --output-dir."}
file mkdir $workspace
setws $workspace
platform create -name sp_platform -hw $xsa -arch {64-bit} -fsbl-target psu_cortexa53_0 -out $workspace
platform write
domain create -name freertos_domain -os freertos10_xilinx -proc psu_cortexa53_0 -runtime cpp -arch {64-bit} -support-app freertos_lwip_udp_perf_server
platform active sp_platform
domain active freertos_domain
bsp setlib -name lwip211 -ver 1.6
bsp setlib -name xilffs -ver 4.6
foreach {parameter value} {
    total_heap_size 262140
    api_mode SOCKET_API
    default_udp_recvmbox_size 4096
    dhcp_does_arp_check true
    lwip_dhcp true
    lwip_tcpip_core_locking_input true
    mem_size 524288
    memp_n_pbuf 1024
    memp_num_netbuf 4096
    n_rx_descriptors 512
    pbuf_pool_size 20480
    tcpip_mbox_size 4096
} {
    bsp config $parameter $value
}
bsp write
platform generate
app create -name app -platform sp_platform -domain freertos_domain -template {Empty Application(C)}
importsources -name app -path $source_dir
file copy -force -- [file join $source_dir lscript.ld] [file join $workspace app src lscript.ld]
app config -name app build-config Debug
app config -name app -add libraries m
app build -name app
set elf [file join $workspace app Debug app.elf]
if {![file isfile $elf]} {error "Build ended without the expected application ELF: $elf"}
file mkdir $output_dir
file copy -- $elf [file join $output_dir app.elf]
set status [open [file join $output_dir build_status.txt] w]
puts $status "XSA: $xsa"
puts $status "Processor: psu_cortexa53_0; architecture: 64-bit; OS: freertos10_xilinx"
puts $status "Libraries: lwip211 1.6 (SOCKET_API), xilffs 4.6, libm"
puts $status "Application sources: $source_dir"
puts $status "Built ELF: $elf"
puts $status "The original archived app.elf and legacy XSA were retained."
close $status
puts "SP_PS_BUILD_OK: [file join $output_dir app.elf]"
