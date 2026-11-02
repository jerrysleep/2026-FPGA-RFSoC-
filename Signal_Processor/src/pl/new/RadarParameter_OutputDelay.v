`timescale 1ns / 1ps

module RadarParameter_OutputDelay
   (
    input clk,
    input  pc_tx_on_off_in,
    output reg pc_tx_on_off_out,
    input  just_receive_in,
    output reg just_receive_out,
    input  pc_rst_in_in,
    output reg pc_rst_in_out,
    input  program_start_in,
    output reg program_start_out,
    input  program_reset_in,
    output reg program_reset_out,
    input  [1:0] detect_phase_state_in,
    output reg [1:0] detect_phase_state_out,
    input  [7:0] work_freq_dout_in,
    output reg [7:0] work_freq_dout_out,
    input  [7:0] Setup_para_mode_in,
    output reg [7:0] Setup_para_mode_out,
    input  [7:0] subarray_select_mode_in,
    output reg [7:0] subarray_select_mode_out,
    input  [7:0] use_PulseCompress_in,
    output reg [7:0] use_PulseCompress_out,
    input  [7:0] switch_range_gate_in,
    output reg [7:0] switch_range_gate_out,
    input  [7:0] far_decim_factor_in,
    output reg [7:0] far_decim_factor_out,
    input  [7:0] near_decim_factor_in,
    output reg [7:0] near_decim_factor_out,
    input  [31:0] result_download_length_dout_in,
    output reg [31:0] result_download_length_dout_out,
    input  [31:0] baud_div_in,
    output reg [31:0] baud_div_out,
    input  [31:0] PINC1_near_in,
    output reg [31:0] PINC1_near_out,
    input  [31:0] f0_scale_near_in,
    output reg [31:0] f0_scale_near_out,
    input  [31:0] mu_scale_near_in,
    output reg [31:0] mu_scale_near_out,
    input  [31:0] f0_scale2_near_in,
    output reg [31:0] f0_scale2_near_out,
    input  [31:0] mu_scale2_near_in,
    output reg [31:0] mu_scale2_near_out,
    input  [31:0] axi_chirp_width_near_in,
    output reg [31:0] axi_chirp_width_near_out,
    input  [31:0] axi_pulse_period_near_in,
    output reg [31:0] axi_pulse_period_near_out,
    input  [31:0] pulse_delay_in,
    output reg [31:0] pulse_delay_out,
    input  [31:0] PINC1_far_in,
    output reg [31:0] PINC1_far_out,
    input  [31:0] f0_scale_far_in,
    output reg [31:0] f0_scale_far_out,
    input  [31:0] mu_scale_far_in,
    output reg [31:0] mu_scale_far_out,
    input  [31:0] f0_scale2_far_in,
    output reg [31:0] f0_scale2_far_out,
    input  [31:0] mu_scale2_far_in,
    output reg [31:0] mu_scale2_far_out,
    input  [31:0] axi_chirp_width_far_in,
    output reg [31:0] axi_chirp_width_far_out,
    input  [31:0] axi_pulse_period_far_in,
    output reg [31:0] axi_pulse_period_far_out,
    input  [31:0] axi_fc_scale_far_in,
    output reg [31:0] axi_fc_scale_far_out,
    input  [31:0] axi_fc_scale_near_in,
    output reg [31:0] axi_fc_scale_near_out,
    input  [15:0] near_prt_period_in,
    output reg [15:0] near_prt_period_out,
    input  [15:0] near_prt_num_in,
    output reg [15:0] near_prt_num_out,
    input  [15:0] near_delay_tf_pm_in,
    output reg [15:0] near_delay_tf_pm_out,
    input  [15:0] near_length_tf_pm_in,
    output reg [15:0] near_length_tf_pm_out,
    input  [15:0] near_delay_tf_pc_in,
    output reg [15:0] near_delay_tf_pc_out,
    input  [15:0] near_length_tf_pc_in,
    output reg [15:0] near_length_tf_pc_out,
    input  [15:0] near_delay_tr_k_in,
    output reg [15:0] near_delay_tr_k_out,
    input  [15:0] near_length_tr_k_in,
    output reg [15:0] near_length_tr_k_out,
    input  [15:0] near_delay_ADC_in,
    output reg [15:0] near_delay_ADC_out,
    input  [15:0] near_length_ADC_in,
    output reg [15:0] near_length_ADC_out,
    input  [15:0] near_delay_PhaseRef_in,
    output reg [15:0] near_delay_PhaseRef_out,
    input  [15:0] near_length_PhaseRef_in,
    output reg [15:0] near_length_PhaseRef_out,
    input  [15:0] far_prt_period_in,
    output reg [15:0] far_prt_period_out,
    input  [15:0] far_prt_num_in,
    output reg [15:0] far_prt_num_out,
    input  [15:0] far_delay_tf_pm_in,
    output reg [15:0] far_delay_tf_pm_out,
    input  [15:0] far_length_tf_pm_in,
    output reg [15:0] far_length_tf_pm_out,
    input  [15:0] far_delay_tf_pc_in,
    output reg [15:0] far_delay_tf_pc_out,
    input  [15:0] far_length_tf_pc_in,
    output reg [15:0] far_length_tf_pc_out,
    input  [15:0] far_delay_tr_k_in,
    output reg [15:0] far_delay_tr_k_out,
    input  [15:0] far_length_tr_k_in,
    output reg [15:0] far_length_tr_k_out,
    input  [15:0] far_delay_ADC_in,
    output reg [15:0] far_delay_ADC_out,
    input  [15:0] far_length_ADC_in,
    output reg [15:0] far_length_ADC_out,
    input  [15:0] far_delay_PhaseRef_in,
    output reg [15:0] far_delay_PhaseRef_out,
    input  [15:0] far_length_PhaseRef_in,
    output reg [15:0] far_length_PhaseRef_out,
    input  [15:0] snr_door_dout_in,
    output reg [15:0] snr_door_dout_out,
    input  [15:0] detect_freq_low_near_dout_in,
    output reg [15:0] detect_freq_low_near_dout_out,
    input  [15:0] detect_freq_high_near_dout_in,
    output reg [15:0] detect_freq_high_near_dout_out,
    input  [15:0] detect_freq_low_far_dout_in,
    output reg [15:0] detect_freq_low_far_dout_out,
    input  [15:0] detect_freq_high_far_dout_in,
    output reg [15:0] detect_freq_high_far_dout_out,
    input  [15:0] RF_on_delay_dout_in,
    output reg [15:0] RF_on_delay_dout_out,
    input  [15:0] RF_on_work_dout_in,
    output reg [15:0] RF_on_work_dout_out,
    input  [31:0] near_frame_period_in,
    output reg [31:0] near_frame_period_out,
    input  [31:0] far_frame_period_in,
    output reg [31:0] far_frame_period_out
   );

always @(posedge clk) begin
    pc_tx_on_off_out <= pc_tx_on_off_in;
    just_receive_out <= just_receive_in;
    pc_rst_in_out <= pc_rst_in_in;
    program_start_out <= program_start_in;
    program_reset_out <= program_reset_in;
    detect_phase_state_out <= detect_phase_state_in;
    work_freq_dout_out <= work_freq_dout_in;
    Setup_para_mode_out <= Setup_para_mode_in;
    subarray_select_mode_out <= subarray_select_mode_in;
    use_PulseCompress_out <= use_PulseCompress_in;
    switch_range_gate_out <= switch_range_gate_in;
    far_decim_factor_out <= far_decim_factor_in;
    near_decim_factor_out <= near_decim_factor_in;
    result_download_length_dout_out <= result_download_length_dout_in;
    baud_div_out <= baud_div_in;
    PINC1_near_out <= PINC1_near_in;
    f0_scale_near_out <= f0_scale_near_in;
    mu_scale_near_out <= mu_scale_near_in;
    f0_scale2_near_out <= f0_scale2_near_in;
    mu_scale2_near_out <= mu_scale2_near_in;
    axi_chirp_width_near_out <= axi_chirp_width_near_in;
    axi_pulse_period_near_out <= axi_pulse_period_near_in;
    pulse_delay_out <= pulse_delay_in;
    PINC1_far_out <= PINC1_far_in;
    f0_scale_far_out <= f0_scale_far_in;
    mu_scale_far_out <= mu_scale_far_in;
    f0_scale2_far_out <= f0_scale2_far_in;
    mu_scale2_far_out <= mu_scale2_far_in;
    axi_chirp_width_far_out <= axi_chirp_width_far_in;
    axi_pulse_period_far_out <= axi_pulse_period_far_in;
    axi_fc_scale_far_out <= axi_fc_scale_far_in;
    axi_fc_scale_near_out <= axi_fc_scale_near_in;
    near_prt_period_out <= near_prt_period_in;
    near_prt_num_out <= near_prt_num_in;
    near_delay_tf_pm_out <= near_delay_tf_pm_in;
    near_length_tf_pm_out <= near_length_tf_pm_in;
    near_delay_tf_pc_out <= near_delay_tf_pc_in;
    near_length_tf_pc_out <= near_length_tf_pc_in;
    near_delay_tr_k_out <= near_delay_tr_k_in;
    near_length_tr_k_out <= near_length_tr_k_in;
    near_delay_ADC_out <= near_delay_ADC_in;
    near_length_ADC_out <= near_length_ADC_in;
    near_delay_PhaseRef_out <= near_delay_PhaseRef_in;
    near_length_PhaseRef_out <= near_length_PhaseRef_in;
    far_prt_period_out <= far_prt_period_in;
    far_prt_num_out <= far_prt_num_in;
    far_delay_tf_pm_out <= far_delay_tf_pm_in;
    far_length_tf_pm_out <= far_length_tf_pm_in;
    far_delay_tf_pc_out <= far_delay_tf_pc_in;
    far_length_tf_pc_out <= far_length_tf_pc_in;
    far_delay_tr_k_out <= far_delay_tr_k_in;
    far_length_tr_k_out <= far_length_tr_k_in;
    far_delay_ADC_out <= far_delay_ADC_in;
    far_length_ADC_out <= far_length_ADC_in;
    far_delay_PhaseRef_out <= far_delay_PhaseRef_in;
    far_length_PhaseRef_out <= far_length_PhaseRef_in;
    snr_door_dout_out <= snr_door_dout_in;
    detect_freq_low_near_dout_out <= detect_freq_low_near_dout_in;
    detect_freq_high_near_dout_out <= detect_freq_high_near_dout_in;
    detect_freq_low_far_dout_out <= detect_freq_low_far_dout_in;
    detect_freq_high_far_dout_out <= detect_freq_high_far_dout_in;
    RF_on_delay_dout_out <= RF_on_delay_dout_in;
    RF_on_work_dout_out <= RF_on_work_dout_in;
    near_frame_period_out <= near_frame_period_in;
    far_frame_period_out <= far_frame_period_in;
end

endmodule
