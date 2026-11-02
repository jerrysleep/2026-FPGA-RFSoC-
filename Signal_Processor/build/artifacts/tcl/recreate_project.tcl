# Vivado 2021.2. Reconstruct the original non-MTS PL project from packaged inputs.
namespace eval ::sp {
    variable script_dir [file dirname [file normalize [info script]]]
}
source [file join $::sp::script_dir source_manifest.tcl]

proc ::sp::options {arguments} {
    variable script_dir
    set cfg [dict create root [file normalize [file join $script_dir ../..]] work_dir {} output_dir {} jobs 4 export_xsa 0]
    foreach {key value} $arguments {
        switch -- $key {
            --root {dict set cfg root [file normalize $value]}
            --work-dir {dict set cfg work_dir [file normalize $value]}
            --output-dir {dict set cfg output_dir [file normalize $value]}
            --jobs {
                if {![string is integer -strict $value] || $value < 1} {error "--jobs requires a positive integer"}
                dict set cfg jobs $value
            }
            --export-xsa {
                if {$value ni {0 1}} {error "--export-xsa must be 0 or 1"}
                dict set cfg export_xsa $value
            }
            default {error "Unknown option $key. Options require values: --root --work-dir --output-dir --jobs --export-xsa"}
        }
    }
    if {[llength $arguments] % 2} {error "Every option requires a value"}
    if {[dict get $cfg work_dir] eq {}} {dict set cfg work_dir [file join [dict get $cfg root] build work pl]}
    if {[dict get $cfg output_dir] eq {}} {dict set cfg output_dir [file join [dict get $cfg root] build rebuilt pl]}
    return $cfg
}

proc ::sp::stage_file {source_root stage_root relative} {
    set source [file join $source_root $relative]
    if {![file isfile $source]} {error "Required source is missing: $source"}
    set target [file join $stage_root $relative]
    file mkdir [file dirname $target]
    file copy -force -- $source $target
    return $target
}

proc ::sp::create {cfg} {
    variable rtl_files
    variable ip_files
    variable coefficient_files
    variable constraint_files
    variable bd_file
    if {![string match 2021.2* [version -short]]} {
        error "This script requires Vivado 2021.2. Current version: [version -short]"
    }
    if {[llength [get_projects -quiet]]} {error "Run in a fresh Vivado process or close the open project first"}
    set source_root [file join [dict get $cfg root] src pl]
    foreach relative [concat $rtl_files $ip_files $coefficient_files $constraint_files [list $bd_file]] {
        if {![file isfile [file join $source_root $relative]]} {error "Missing input: $relative"}
    }
    set work_dir [dict get $cfg work_dir]
    if {[file exists $work_dir] && [llength [glob -nocomplain -directory $work_dir * .*]] > 2} {
        error "Work directory is not empty: $work_dir. Select a new --work-dir to retain previous runs."
    }
    file mkdir $work_dir
    set stage_root [file join $work_dir inputs]
    foreach relative [concat $rtl_files $ip_files $coefficient_files $constraint_files] {
        ::sp::stage_file $source_root $stage_root $relative
    }
    # Copy the BD together with its IP configuration and layout companions.
    set bd_relative_dir [file dirname $bd_file]
    file mkdir [file dirname [file join $stage_root $bd_relative_dir]]
    file copy -- [file join $source_root $bd_relative_dir] [file join $stage_root $bd_relative_dir]

    create_project signal_processor [file join $work_dir project] -part xczu47dr-ffve1156-2-i
    set_property target_language Verilog [current_project]
    set_property simulator_language Mixed [current_project]
    set_property default_lib xil_defaultlib [current_project]
    set_property include_dirs [list [file join $stage_root new]] [get_filesets sources_1]
    set rtl_paths {}
    foreach relative $rtl_files {lappend rtl_paths [file join $stage_root $relative]}
    add_files -norecurse $rtl_paths
    set_property file_type {Verilog Header} [get_files [file join $stage_root new define.vh]]
    foreach relative $ip_files {add_files -norecurse [file join $stage_root $relative]}
    foreach relative $coefficient_files {add_files -norecurse [file join $stage_root $relative]}
    set bd_path [file join $stage_root $bd_file]
    add_files -norecurse $bd_path
    open_bd_design $bd_path
    validate_bd_design
    save_bd_design
    set wrapper [make_wrapper -files [get_files $bd_path] -top]
    add_files -norecurse $wrapper
    close_bd_design [current_bd_design]
    foreach relative $constraint_files {add_files -fileset constrs_1 -norecurse [file join $stage_root $relative]}
    set_property top Signal_Processor_Top [get_filesets sources_1]
    set_property strategy {Vivado Synthesis Defaults} [get_runs synth_1]
    set_property strategy {Vivado Implementation Defaults} [get_runs impl_1]
    # Rebuild from RTL/IP; do not depend on the old incremental synthesis DCP.
    set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs synth_1]
    set_property INCREMENTAL_CHECKPOINT {} [get_runs synth_1]
    update_compile_order -fileset sources_1
    file mkdir [file join $work_dir checks]
    report_ip_status -file [file join $work_dir checks ip_status.rpt]
    report_compile_order -used_in synthesis -file [file join $work_dir checks compile_order.rpt]
    set locked {}
    foreach ip [get_ips -quiet] {
        if {[get_property IS_LOCKED $ip]} {lappend locked $ip}
    }
    if {[llength $locked]} {error "Locked IP must be resolved with Vivado 2021.2: $locked"}
    puts "SP_RECREATE_OK: [file join [get_property DIRECTORY [current_project]] signal_processor.xpr]"
    puts "Standalone IPs: [llength $ip_files]; RTL/header inputs: [llength $rtl_files]"
    return [dict merge $cfg [dict create bd_path $bd_path stage_root $stage_root]]
}

if {![info exists ::sp::library_only]} {
    ::sp::create [::sp::options $::argv]
}
