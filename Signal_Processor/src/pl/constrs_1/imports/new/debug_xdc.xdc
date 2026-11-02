






create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list PL_SYS_CLK_INST/inst/clk_out2]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 6 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {U10_top_fft/u_pulse_peak_gate_detect/pulse_peak_bomen_dout[0]} {U10_top_fft/u_pulse_peak_gate_detect/pulse_peak_bomen_dout[1]} {U10_top_fft/u_pulse_peak_gate_detect/pulse_peak_bomen_dout[2]} {U10_top_fft/u_pulse_peak_gate_detect/pulse_peak_bomen_dout[3]} {U10_top_fft/u_pulse_peak_gate_detect/pulse_peak_bomen_dout[4]} {U10_top_fft/u_pulse_peak_gate_detect/pulse_peak_bomen_dout[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 10 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {U10_top_fft/max_freq_dout[0]} {U10_top_fft/max_freq_dout[1]} {U10_top_fft/max_freq_dout[2]} {U10_top_fft/max_freq_dout[3]} {U10_top_fft/max_freq_dout[4]} {U10_top_fft/max_freq_dout[5]} {U10_top_fft/max_freq_dout[6]} {U10_top_fft/max_freq_dout[7]} {U10_top_fft/max_freq_dout[8]} {U10_top_fft/max_freq_dout[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 6 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {U10_top_fft/max_bomen_dout[0]} {U10_top_fft/max_bomen_dout[1]} {U10_top_fft/max_bomen_dout[2]} {U10_top_fft/max_bomen_dout[3]} {U10_top_fft/max_bomen_dout[4]} {U10_top_fft/max_bomen_dout[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {m20_axis_tdata[0]} {m20_axis_tdata[1]} {m20_axis_tdata[2]} {m20_axis_tdata[3]} {m20_axis_tdata[4]} {m20_axis_tdata[5]} {m20_axis_tdata[6]} {m20_axis_tdata[7]} {m20_axis_tdata[8]} {m20_axis_tdata[9]} {m20_axis_tdata[10]} {m20_axis_tdata[11]} {m20_axis_tdata[12]} {m20_axis_tdata[13]} {m20_axis_tdata[14]} {m20_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {m23_axis_tdata[0]} {m23_axis_tdata[1]} {m23_axis_tdata[2]} {m23_axis_tdata[3]} {m23_axis_tdata[4]} {m23_axis_tdata[5]} {m23_axis_tdata[6]} {m23_axis_tdata[7]} {m23_axis_tdata[8]} {m23_axis_tdata[9]} {m23_axis_tdata[10]} {m23_axis_tdata[11]} {m23_axis_tdata[12]} {m23_axis_tdata[13]} {m23_axis_tdata[14]} {m23_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {m13_axis_tdata[0]} {m13_axis_tdata[1]} {m13_axis_tdata[2]} {m13_axis_tdata[3]} {m13_axis_tdata[4]} {m13_axis_tdata[5]} {m13_axis_tdata[6]} {m13_axis_tdata[7]} {m13_axis_tdata[8]} {m13_axis_tdata[9]} {m13_axis_tdata[10]} {m13_axis_tdata[11]} {m13_axis_tdata[12]} {m13_axis_tdata[13]} {m13_axis_tdata[14]} {m13_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 16 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {m32_axis_tdata[0]} {m32_axis_tdata[1]} {m32_axis_tdata[2]} {m32_axis_tdata[3]} {m32_axis_tdata[4]} {m32_axis_tdata[5]} {m32_axis_tdata[6]} {m32_axis_tdata[7]} {m32_axis_tdata[8]} {m32_axis_tdata[9]} {m32_axis_tdata[10]} {m32_axis_tdata[11]} {m32_axis_tdata[12]} {m32_axis_tdata[13]} {m32_axis_tdata[14]} {m32_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 16 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {m12_axis_tdata[0]} {m12_axis_tdata[1]} {m12_axis_tdata[2]} {m12_axis_tdata[3]} {m12_axis_tdata[4]} {m12_axis_tdata[5]} {m12_axis_tdata[6]} {m12_axis_tdata[7]} {m12_axis_tdata[8]} {m12_axis_tdata[9]} {m12_axis_tdata[10]} {m12_axis_tdata[11]} {m12_axis_tdata[12]} {m12_axis_tdata[13]} {m12_axis_tdata[14]} {m12_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 16 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {m30_axis_tdata[0]} {m30_axis_tdata[1]} {m30_axis_tdata[2]} {m30_axis_tdata[3]} {m30_axis_tdata[4]} {m30_axis_tdata[5]} {m30_axis_tdata[6]} {m30_axis_tdata[7]} {m30_axis_tdata[8]} {m30_axis_tdata[9]} {m30_axis_tdata[10]} {m30_axis_tdata[11]} {m30_axis_tdata[12]} {m30_axis_tdata[13]} {m30_axis_tdata[14]} {m30_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 16 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {m21_axis_tdata[0]} {m21_axis_tdata[1]} {m21_axis_tdata[2]} {m21_axis_tdata[3]} {m21_axis_tdata[4]} {m21_axis_tdata[5]} {m21_axis_tdata[6]} {m21_axis_tdata[7]} {m21_axis_tdata[8]} {m21_axis_tdata[9]} {m21_axis_tdata[10]} {m21_axis_tdata[11]} {m21_axis_tdata[12]} {m21_axis_tdata[13]} {m21_axis_tdata[14]} {m21_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 16 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {m22_axis_tdata[0]} {m22_axis_tdata[1]} {m22_axis_tdata[2]} {m22_axis_tdata[3]} {m22_axis_tdata[4]} {m22_axis_tdata[5]} {m22_axis_tdata[6]} {m22_axis_tdata[7]} {m22_axis_tdata[8]} {m22_axis_tdata[9]} {m22_axis_tdata[10]} {m22_axis_tdata[11]} {m22_axis_tdata[12]} {m22_axis_tdata[13]} {m22_axis_tdata[14]} {m22_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 16 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {m31_axis_tdata[0]} {m31_axis_tdata[1]} {m31_axis_tdata[2]} {m31_axis_tdata[3]} {m31_axis_tdata[4]} {m31_axis_tdata[5]} {m31_axis_tdata[6]} {m31_axis_tdata[7]} {m31_axis_tdata[8]} {m31_axis_tdata[9]} {m31_axis_tdata[10]} {m31_axis_tdata[11]} {m31_axis_tdata[12]} {m31_axis_tdata[13]} {m31_axis_tdata[14]} {m31_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 16 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {m33_axis_tdata[0]} {m33_axis_tdata[1]} {m33_axis_tdata[2]} {m33_axis_tdata[3]} {m33_axis_tdata[4]} {m33_axis_tdata[5]} {m33_axis_tdata[6]} {m33_axis_tdata[7]} {m33_axis_tdata[8]} {m33_axis_tdata[9]} {m33_axis_tdata[10]} {m33_axis_tdata[11]} {m33_axis_tdata[12]} {m33_axis_tdata[13]} {m33_axis_tdata[14]} {m33_axis_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 32 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {U9_Buffer/ping_pang_switch_ch5/dout[0]} {U9_Buffer/ping_pang_switch_ch5/dout[1]} {U9_Buffer/ping_pang_switch_ch5/dout[2]} {U9_Buffer/ping_pang_switch_ch5/dout[3]} {U9_Buffer/ping_pang_switch_ch5/dout[4]} {U9_Buffer/ping_pang_switch_ch5/dout[5]} {U9_Buffer/ping_pang_switch_ch5/dout[6]} {U9_Buffer/ping_pang_switch_ch5/dout[7]} {U9_Buffer/ping_pang_switch_ch5/dout[8]} {U9_Buffer/ping_pang_switch_ch5/dout[9]} {U9_Buffer/ping_pang_switch_ch5/dout[10]} {U9_Buffer/ping_pang_switch_ch5/dout[11]} {U9_Buffer/ping_pang_switch_ch5/dout[12]} {U9_Buffer/ping_pang_switch_ch5/dout[13]} {U9_Buffer/ping_pang_switch_ch5/dout[14]} {U9_Buffer/ping_pang_switch_ch5/dout[15]} {U9_Buffer/ping_pang_switch_ch5/dout[16]} {U9_Buffer/ping_pang_switch_ch5/dout[17]} {U9_Buffer/ping_pang_switch_ch5/dout[18]} {U9_Buffer/ping_pang_switch_ch5/dout[19]} {U9_Buffer/ping_pang_switch_ch5/dout[20]} {U9_Buffer/ping_pang_switch_ch5/dout[21]} {U9_Buffer/ping_pang_switch_ch5/dout[22]} {U9_Buffer/ping_pang_switch_ch5/dout[23]} {U9_Buffer/ping_pang_switch_ch5/dout[24]} {U9_Buffer/ping_pang_switch_ch5/dout[25]} {U9_Buffer/ping_pang_switch_ch5/dout[26]} {U9_Buffer/ping_pang_switch_ch5/dout[27]} {U9_Buffer/ping_pang_switch_ch5/dout[28]} {U9_Buffer/ping_pang_switch_ch5/dout[29]} {U9_Buffer/ping_pang_switch_ch5/dout[30]} {U9_Buffer/ping_pang_switch_ch5/dout[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 16 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {U9_Buffer/ping_pang_switch_ch5/din_i[0]} {U9_Buffer/ping_pang_switch_ch5/din_i[1]} {U9_Buffer/ping_pang_switch_ch5/din_i[2]} {U9_Buffer/ping_pang_switch_ch5/din_i[3]} {U9_Buffer/ping_pang_switch_ch5/din_i[4]} {U9_Buffer/ping_pang_switch_ch5/din_i[5]} {U9_Buffer/ping_pang_switch_ch5/din_i[6]} {U9_Buffer/ping_pang_switch_ch5/din_i[7]} {U9_Buffer/ping_pang_switch_ch5/din_i[8]} {U9_Buffer/ping_pang_switch_ch5/din_i[9]} {U9_Buffer/ping_pang_switch_ch5/din_i[10]} {U9_Buffer/ping_pang_switch_ch5/din_i[11]} {U9_Buffer/ping_pang_switch_ch5/din_i[12]} {U9_Buffer/ping_pang_switch_ch5/din_i[13]} {U9_Buffer/ping_pang_switch_ch5/din_i[14]} {U9_Buffer/ping_pang_switch_ch5/din_i[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 16 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {U9_Buffer/ping_pang_switch_ch5/din_q[0]} {U9_Buffer/ping_pang_switch_ch5/din_q[1]} {U9_Buffer/ping_pang_switch_ch5/din_q[2]} {U9_Buffer/ping_pang_switch_ch5/din_q[3]} {U9_Buffer/ping_pang_switch_ch5/din_q[4]} {U9_Buffer/ping_pang_switch_ch5/din_q[5]} {U9_Buffer/ping_pang_switch_ch5/din_q[6]} {U9_Buffer/ping_pang_switch_ch5/din_q[7]} {U9_Buffer/ping_pang_switch_ch5/din_q[8]} {U9_Buffer/ping_pang_switch_ch5/din_q[9]} {U9_Buffer/ping_pang_switch_ch5/din_q[10]} {U9_Buffer/ping_pang_switch_ch5/din_q[11]} {U9_Buffer/ping_pang_switch_ch5/din_q[12]} {U9_Buffer/ping_pang_switch_ch5/din_q[13]} {U9_Buffer/ping_pang_switch_ch5/din_q[14]} {U9_Buffer/ping_pang_switch_ch5/din_q[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 16 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {U9_Buffer/ping_pang_switch_ch1/din_i[0]} {U9_Buffer/ping_pang_switch_ch1/din_i[1]} {U9_Buffer/ping_pang_switch_ch1/din_i[2]} {U9_Buffer/ping_pang_switch_ch1/din_i[3]} {U9_Buffer/ping_pang_switch_ch1/din_i[4]} {U9_Buffer/ping_pang_switch_ch1/din_i[5]} {U9_Buffer/ping_pang_switch_ch1/din_i[6]} {U9_Buffer/ping_pang_switch_ch1/din_i[7]} {U9_Buffer/ping_pang_switch_ch1/din_i[8]} {U9_Buffer/ping_pang_switch_ch1/din_i[9]} {U9_Buffer/ping_pang_switch_ch1/din_i[10]} {U9_Buffer/ping_pang_switch_ch1/din_i[11]} {U9_Buffer/ping_pang_switch_ch1/din_i[12]} {U9_Buffer/ping_pang_switch_ch1/din_i[13]} {U9_Buffer/ping_pang_switch_ch1/din_i[14]} {U9_Buffer/ping_pang_switch_ch1/din_i[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 16 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {U9_Buffer/ping_pang_switch_ch1/din_q[0]} {U9_Buffer/ping_pang_switch_ch1/din_q[1]} {U9_Buffer/ping_pang_switch_ch1/din_q[2]} {U9_Buffer/ping_pang_switch_ch1/din_q[3]} {U9_Buffer/ping_pang_switch_ch1/din_q[4]} {U9_Buffer/ping_pang_switch_ch1/din_q[5]} {U9_Buffer/ping_pang_switch_ch1/din_q[6]} {U9_Buffer/ping_pang_switch_ch1/din_q[7]} {U9_Buffer/ping_pang_switch_ch1/din_q[8]} {U9_Buffer/ping_pang_switch_ch1/din_q[9]} {U9_Buffer/ping_pang_switch_ch1/din_q[10]} {U9_Buffer/ping_pang_switch_ch1/din_q[11]} {U9_Buffer/ping_pang_switch_ch1/din_q[12]} {U9_Buffer/ping_pang_switch_ch1/din_q[13]} {U9_Buffer/ping_pang_switch_ch1/din_q[14]} {U9_Buffer/ping_pang_switch_ch1/din_q[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 16 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {U9_Buffer/ping_pang_switch_ch1/rd_addr[0]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[1]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[2]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[3]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[4]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[5]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[6]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[7]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[8]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[9]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[10]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[11]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[12]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[13]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[14]} {U9_Buffer/ping_pang_switch_ch1/rd_addr[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 16 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {U9_Buffer/ping_pang_switch_ch1/wr_addr[0]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[1]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[2]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[3]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[4]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[5]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[6]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[7]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[8]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[9]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[10]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[11]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[12]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[13]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[14]} {U9_Buffer/ping_pang_switch_ch1/wr_addr[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 32 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {U9_Buffer/ping_pang_switch_ch1/dout[0]} {U9_Buffer/ping_pang_switch_ch1/dout[1]} {U9_Buffer/ping_pang_switch_ch1/dout[2]} {U9_Buffer/ping_pang_switch_ch1/dout[3]} {U9_Buffer/ping_pang_switch_ch1/dout[4]} {U9_Buffer/ping_pang_switch_ch1/dout[5]} {U9_Buffer/ping_pang_switch_ch1/dout[6]} {U9_Buffer/ping_pang_switch_ch1/dout[7]} {U9_Buffer/ping_pang_switch_ch1/dout[8]} {U9_Buffer/ping_pang_switch_ch1/dout[9]} {U9_Buffer/ping_pang_switch_ch1/dout[10]} {U9_Buffer/ping_pang_switch_ch1/dout[11]} {U9_Buffer/ping_pang_switch_ch1/dout[12]} {U9_Buffer/ping_pang_switch_ch1/dout[13]} {U9_Buffer/ping_pang_switch_ch1/dout[14]} {U9_Buffer/ping_pang_switch_ch1/dout[15]} {U9_Buffer/ping_pang_switch_ch1/dout[16]} {U9_Buffer/ping_pang_switch_ch1/dout[17]} {U9_Buffer/ping_pang_switch_ch1/dout[18]} {U9_Buffer/ping_pang_switch_ch1/dout[19]} {U9_Buffer/ping_pang_switch_ch1/dout[20]} {U9_Buffer/ping_pang_switch_ch1/dout[21]} {U9_Buffer/ping_pang_switch_ch1/dout[22]} {U9_Buffer/ping_pang_switch_ch1/dout[23]} {U9_Buffer/ping_pang_switch_ch1/dout[24]} {U9_Buffer/ping_pang_switch_ch1/dout[25]} {U9_Buffer/ping_pang_switch_ch1/dout[26]} {U9_Buffer/ping_pang_switch_ch1/dout[27]} {U9_Buffer/ping_pang_switch_ch1/dout[28]} {U9_Buffer/ping_pang_switch_ch1/dout[29]} {U9_Buffer/ping_pang_switch_ch1/dout[30]} {U9_Buffer/ping_pang_switch_ch1/dout[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 16 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {U9_Buffer/ping_pang_switch_ch3/din_i[0]} {U9_Buffer/ping_pang_switch_ch3/din_i[1]} {U9_Buffer/ping_pang_switch_ch3/din_i[2]} {U9_Buffer/ping_pang_switch_ch3/din_i[3]} {U9_Buffer/ping_pang_switch_ch3/din_i[4]} {U9_Buffer/ping_pang_switch_ch3/din_i[5]} {U9_Buffer/ping_pang_switch_ch3/din_i[6]} {U9_Buffer/ping_pang_switch_ch3/din_i[7]} {U9_Buffer/ping_pang_switch_ch3/din_i[8]} {U9_Buffer/ping_pang_switch_ch3/din_i[9]} {U9_Buffer/ping_pang_switch_ch3/din_i[10]} {U9_Buffer/ping_pang_switch_ch3/din_i[11]} {U9_Buffer/ping_pang_switch_ch3/din_i[12]} {U9_Buffer/ping_pang_switch_ch3/din_i[13]} {U9_Buffer/ping_pang_switch_ch3/din_i[14]} {U9_Buffer/ping_pang_switch_ch3/din_i[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 16 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {U9_Buffer/ping_pang_switch_ch2/din_i[0]} {U9_Buffer/ping_pang_switch_ch2/din_i[1]} {U9_Buffer/ping_pang_switch_ch2/din_i[2]} {U9_Buffer/ping_pang_switch_ch2/din_i[3]} {U9_Buffer/ping_pang_switch_ch2/din_i[4]} {U9_Buffer/ping_pang_switch_ch2/din_i[5]} {U9_Buffer/ping_pang_switch_ch2/din_i[6]} {U9_Buffer/ping_pang_switch_ch2/din_i[7]} {U9_Buffer/ping_pang_switch_ch2/din_i[8]} {U9_Buffer/ping_pang_switch_ch2/din_i[9]} {U9_Buffer/ping_pang_switch_ch2/din_i[10]} {U9_Buffer/ping_pang_switch_ch2/din_i[11]} {U9_Buffer/ping_pang_switch_ch2/din_i[12]} {U9_Buffer/ping_pang_switch_ch2/din_i[13]} {U9_Buffer/ping_pang_switch_ch2/din_i[14]} {U9_Buffer/ping_pang_switch_ch2/din_i[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 16 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {U9_Buffer/ping_pang_switch_ch4/din_i[0]} {U9_Buffer/ping_pang_switch_ch4/din_i[1]} {U9_Buffer/ping_pang_switch_ch4/din_i[2]} {U9_Buffer/ping_pang_switch_ch4/din_i[3]} {U9_Buffer/ping_pang_switch_ch4/din_i[4]} {U9_Buffer/ping_pang_switch_ch4/din_i[5]} {U9_Buffer/ping_pang_switch_ch4/din_i[6]} {U9_Buffer/ping_pang_switch_ch4/din_i[7]} {U9_Buffer/ping_pang_switch_ch4/din_i[8]} {U9_Buffer/ping_pang_switch_ch4/din_i[9]} {U9_Buffer/ping_pang_switch_ch4/din_i[10]} {U9_Buffer/ping_pang_switch_ch4/din_i[11]} {U9_Buffer/ping_pang_switch_ch4/din_i[12]} {U9_Buffer/ping_pang_switch_ch4/din_i[13]} {U9_Buffer/ping_pang_switch_ch4/din_i[14]} {U9_Buffer/ping_pang_switch_ch4/din_i[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list prt_ref_ADC]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list U9_Buffer/ping_pang_switch_ch1/rd_en]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list U10_top_fft/target_state]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list U9_Buffer/ping_pang_switch_ch1/wr_en]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list U4_RF_Timer/frame_ref]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list U4_RF_Timer/gate_buff]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list U4_RF_Timer/prt_ref]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_250M]
