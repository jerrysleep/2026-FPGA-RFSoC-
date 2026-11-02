# Vivado 2021.2. Build into build/work and build/rebuilt; preserve archived artifacts.
namespace eval ::sp {variable library_only 1}
source [file join [file dirname [file normalize [info script]]] recreate_project.tcl]
unset ::sp::library_only

proc ::sp::wait_for {run_name} {
    wait_on_run $run_name
    set status [get_property STATUS [get_runs $run_name]]
    if {![string match {*Complete*} $status] || [string match -nocase {*error*} $status]} {
        error "Run $run_name failed or did not complete: $status. Inspect its runme.log."
    }
    puts "SP_RUN_COMPLETE: ${run_name}: $status"
}

set cfg [::sp::create [::sp::options $::argv]]
set output_dir [dict get $cfg output_dir]
set report_dir [file join $output_dir reports]
if {[file exists [file join $output_dir Signal_Processor_Top.bit]]} {
    error "Output already contains a rebuilt bitstream. Select a new --output-dir."
}
file mkdir $report_dir
set ip_paths {}
foreach relative $::sp::ip_files {lappend ip_paths [file join [dict get $cfg stage_root] $relative]}
generate_target all [get_files $ip_paths]
generate_target all [get_files [dict get $cfg bd_path]]
create_ip_run [get_files [concat $ip_paths [list [dict get $cfg bd_path]]]]
launch_runs synth_1 -jobs [dict get $cfg jobs]
::sp::wait_for synth_1
open_run synth_1
report_utilization -file [file join $report_dir utilization_synth.rpt]
report_timing_summary -report_unconstrained -file [file join $report_dir timing_synth.rpt]
close_design
launch_runs impl_1 -to_step write_bitstream -jobs [dict get $cfg jobs]
::sp::wait_for impl_1
open_run impl_1
report_utilization -file [file join $report_dir utilization_routed.rpt]
report_methodology -file [file join $report_dir methodology_routed.rpt]
report_timing_summary -report_unconstrained -max_paths 10 -file [file join $report_dir timing_routed.rpt]
check_timing -verbose -file [file join $report_dir check_timing.rpt]
report_drc -file [file join $report_dir drc_routed.rpt]
report_route_status -file [file join $report_dir route_status.rpt]
report_clocks -file [file join $report_dir clocks.rpt]
report_clock_utilization -file [file join $report_dir clock_utilization.rpt]
set bit_path [file join [get_property DIRECTORY [get_runs impl_1]] Signal_Processor_Top.bit]
if {![file isfile $bit_path]} {error "Implementation completed without the expected bitstream: $bit_path"}
file copy -- $bit_path [file join $output_dir Signal_Processor_Top.bit]
write_debug_probes -force [file join $output_dir Signal_Processor_Top.ltx]
if {[dict get $cfg export_xsa]} {
    write_hw_platform -fixed -include_bit -force -file [file join $output_dir generated_hardware.xsa]
}
set summary [open [file join $output_dir build_status.txt] w]
puts $summary "Vivado: [version -short]"
puts $summary "Part: [get_property PART [current_project]]"
puts $summary "Sources: [file join [dict get $cfg root] src pl]"
foreach {label kind} {setup max hold min} {
    set path [get_timing_paths -quiet -delay_type $kind -max_paths 1]
    if {[llength $path]} {
        set slack [get_property SLACK $path]
        puts $summary "$label worst slack (ns): $slack"
        if {$slack < 0} {puts "WARNING: $label timing has negative slack ($slack ns). See reports; timing closure is not claimed."}
    }
}
puts $summary "Check check_timing.rpt, timing_routed.rpt, methodology_routed.rpt and drc_routed.rpt before timing signoff."
puts $summary "The archived XSA/bit/LTX/ELF in build/artifacts were retained."
close $summary
puts "SP_BUILD_OK: $output_dir"
