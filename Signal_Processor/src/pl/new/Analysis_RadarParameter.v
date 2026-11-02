`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


module Analysis_RadarParameter
   (
    input				sys_clk					,	 
    input               bram_clk,
    input               rst,
	input				bram_rst	,		 
    input [12:0]        bram_addr,
    input               bram_en,
    input [3:0]         bram_we,
    input [31:0]        bram_wrdata,
    output reg [31:0]   bram_rddata,
	
     
	
    output reg 			pc_tx_on_off,						 
    output reg 		    just_receive,						 
    output reg 	    	pc_in_rst,							 
    output reg [1:0]	detect_phase_state,					 
	 
    output reg [31:0]   result_download_length_dout,		
    output reg [7:0]    work_freq_dout,
	 
    output reg [15:0]   PRT_near_dout,					 
    output reg [31:0]   frame_near_period_dout,			 
    output reg [15:0]   frame_near_pulse_dout,
    output reg [15:0]   TF_near_mod_delay_dout,
    output reg [15:0]   TF_near_mod_width_dout,
    output reg [15:0]   TF_near_pw_delay_dout,
    output reg [15:0]   TF_near_pw_width_dout,
    output reg [15:0]   TR_near_delay_dout,
    output reg [15:0]   TR_near_width_dout,
    output reg [15:0]   ADC_near_delay_dout,
    output reg [15:0]   ADC_near_width_dout,
    output reg [15:0]   phase_near_delay_dout,
    output reg [15:0]   phase_near_width_dout,
	output reg [7:0]	near_decim_factor_dout	,

	 
    output reg [15:0]   PRT_far_dout,
    output reg [31:0]   frame_far_period_dout,
    output reg [15:0]   frame_far_pulse_dout,
    output reg [15:0]   TF_far_mod_delay_dout,
    output reg [15:0]   TF_far_mod_width_dout,
    output reg [15:0]   TF_far_pw_delay_dout,
    output reg [15:0]   TF_far_pw_width_dout,
    output reg [15:0]   TR_far_delay_dout,
    output reg [15:0]   TR_far_width_dout,
    output reg [15:0]   ADC_far_delay_dout,
    output reg [15:0]   ADC_far_width_dout,
    output reg [15:0]   phase_far_delay_dout,
    output reg [15:0]   phase_far_width_dout,
	output reg [7:0]	far_decim_factor_dout	,
	 
    output reg [15:0]   snr_door_dout,
    output reg [15:0]   detect_freq_low_near_dout,
    output reg [15:0]   detect_freq_high_near_dout,
    output reg [15:0]   detect_freq_low_far_dout,
    output reg [15:0]   detect_freq_high_far_dout,
	 
    output reg [15:0]   RF_on_delay_dout,   
    output reg [15:0]   RF_on_work_dout,   
    output reg [31:0]   uart_baud_rate_dout, 
	 
     
    output reg [7:0]   mode_switch_distance_dout,
	output	reg			program_start			,		 
	output	reg			program_reset			,		 
	output	reg	[7:0]	Setup_para_mode         ,		 
	output	reg	[7:0]	subarray_select_mode			,	 
	output	reg	[7:0]	use_PulseCompress		,		 
	 
	output reg  [31:0]      PINC1_near_dout,            	 	 
    output reg  [31:0]      f0_scale_near_dout,         	 	 
    output reg  [31:0]      mu_scale_near_dout,            		 
    output reg  [31:0]      f0_scale2_near_dout,           		 
    output reg  [31:0]      mu_scale2_near_dout,          		 
    output reg  [31:0]      axi_chirp_width_near_dout,           
    output reg  [31:0]      axi_pulse_period_near_dout,          
    output reg  [31:0]      axi_fc_scale_near_dout,              
    output reg  [31:0]      pulse_delay_dout,                    
	output reg  [31:0]      PINC1_far_dout,              		 
    output reg  [31:0]      f0_scale_far_dout,           		 
    output reg  [31:0]      mu_scale_far_dout,            		 
    output reg  [31:0]      f0_scale2_far_dout,           		 
    output reg  [31:0]      mu_scale2_far_dout,          		 
    output reg  [31:0]      axi_chirp_width_far_dout,           
    output reg  [31:0]      axi_pulse_period_far_dout,          
    output reg  [31:0]      axi_fc_scale_far_dout,              
    
     
    input [5:0]             max_bomen_dout,
    input [9:0]             max_freq_dout,
    input [15:0]            max_snr_dout,
    input [31:0]            fft_result_bomen_before,
    input [31:0]            fft_result_bomen_middle,
    input [31:0]            fft_result_bomen_after,
    input [31:0]            fft_result_freq_before,
    input [31:0]            fft_result_freq_after,
    input                   CH_CHOOSE,
    input                   target_state,
    input [15:0]            zhen_cnt,
    input [15:0]            max_bomen_dout_before,
    input [15:0]            max_bomen_dout_middle,
    input [15:0]            max_bomen_dout_after,
    input [15:0]            max_freq_dout_before,
    input [15:0]            max_freq_dout_middle,
    input [15:0]            max_freq_dout_after,
    input [15:0]            max_snr_dout_before,
    input [15:0]            max_snr_dout_middle,
    input [15:0]            max_snr_dout_after,
    input [15:0]            max_IQ_ch1_dout,
    input [15:0]            max_IQ_ch2_dout,
    input [15:0]            max_IQ_ch3_dout,
    input [15:0]            max_IQ_ch4_dout,
    input [15:0]            max_IQ_ch5_dout,
    input [15:0]            ref_phase_ch1_dout,
    input [15:0]            ref_phase_ch2_dout,
    input [15:0]            ref_phase_ch3_dout,
    input [15:0]            ref_phase_ch4_dout,
    input [15:0]            ref_phase_ch5_dout
    );
    
    reg bram_en_d;
    reg [12:0] bram_addr_d;
    
    reg [7:0] parameter_reg;
    reg [7:0] TF_power_reg;
    reg [7:0] detect_en_reg;
    reg [7:0] system_rst_reg;
    reg [31:0] result_download_length_reg;
    reg [7:0] work_freq_reg;
    reg [15:0] PRT_near_reg;
    reg [31:0] frame_near_period_reg;
    reg [15:0] frame_near_pulse_reg;
    reg [15:0] TF_near_mod_delay_reg;
    reg [15:0] TF_near_mod_width_reg;
    reg [15:0] TF_near_pw_delay_reg;
    reg [15:0] TF_near_pw_width_reg;
    reg [15:0] TR_near_delay_reg;
    reg [15:0] TR_near_width_reg;
    reg [15:0] ADC_near_delay_reg;
    reg [15:0] ADC_near_width_reg;
    reg [15:0] phase_near_delay_reg;
    reg [15:0] phase_near_width_reg;
    reg [15:0] PRT_far_reg;
    reg [31:0] frame_far_period_reg;
    reg [15:0] frame_far_pulse_reg;
    reg [15:0] TF_far_mod_delay_reg;
    reg [15:0] TF_far_mod_width_reg;
    reg [15:0] TF_far_pw_delay_reg;
    reg [15:0] TF_far_pw_width_reg;
    reg [15:0] TR_far_delay_reg;
    reg [15:0] TR_far_width_reg;
    reg [15:0] ADC_far_delay_reg;
    reg [15:0] ADC_far_width_reg;
    reg [15:0] phase_far_delay_reg;
    reg [15:0] phase_far_width_reg;
    reg [15:0] snr_door_reg;
    reg [15:0] detect_freq_low_near_reg;
    reg [15:0] detect_freq_high_near_reg;
    reg [15:0] detect_freq_low_far_reg;
    reg [15:0] detect_freq_high_far_reg;
    reg [15:0] RF_on_delay_reg;   
    reg [15:0] RF_on_work_reg;   
    reg [31:0] uart_baud_rate_reg;   
    reg [15:0] radar_work_mode_reg;
    reg [7:0] mode_switch_distance_reg;
 	reg	[15:0]	program_start_reg			;	 
	reg			program_reset_reg			;	 
	reg	[7:0]	Setup_para_mode_reg			;	 
	reg	[7:0]	subarray_select_mode_reg	;
	reg [31:0]  PINC1_near_reg;               
    reg [31:0]  f0_scale_near_reg;            
    reg [31:0]  mu_scale_near_reg;             
    reg [31:0]  f0_scale2_near_reg;            
    reg [31:0]  mu_scale2_near_reg;           
    reg [31:0]  axi_chirp_width_near_reg;           
    reg [31:0]  axi_pulse_period_near_reg;           
    reg [31:0]  axi_fc_scale_near_reg;           
    reg [31:0]  pulse_delay_reg;                    
	reg [31:0]  PINC1_far_reg;               
    reg [31:0]  f0_scale_far_reg;            
    reg [31:0]  mu_scale_far_reg;             
    reg [31:0]  f0_scale2_far_reg;            
    reg [31:0]  mu_scale2_far_reg;           
    reg [31:0]  axi_chirp_width_far_reg;           
    reg [31:0]  axi_pulse_period_far_reg;           
    reg [31:0]  axi_fc_scale_far_reg;           
	
	reg [7:0]	near_decim_factor_reg	;
	reg [7:0]	far_decim_factor_reg	;
	
	reg [1:0] detect_phase_state_tmp;
	reg	[7:0]	use_PulseCompress_tmp	;
	reg CH_CHOOSE_tmp;
	reg target_state_tmp;
	reg [15:0] zhen_cnt_tmp;
	reg [15:0] max_bomen_dout_before_tmp,max_bomen_dout_middle_tmp,max_bomen_dout_after_tmp;
	reg [15:0] max_freq_dout_before_tmp,max_freq_dout_middle_tmp,max_freq_dout_after_tmp;
	reg [15:0] max_snr_dout_before_tmp,max_snr_dout_middle_tmp,max_snr_dout_after_tmp;
	reg [15:0] max_IQ_ch1_dout_tmp,max_IQ_ch2_dout_tmp,max_IQ_ch3_dout_tmp,max_IQ_ch4_dout_tmp,max_IQ_ch5_dout_tmp;
	reg [15:0] ref_phase_ch1_dout_tmp,ref_phase_ch2_dout_tmp,ref_phase_ch3_dout_tmp,ref_phase_ch4_dout_tmp,ref_phase_ch5_dout_tmp;
	reg [5:0] max_bomen_dout_tmp;
	reg [9:0] max_freq_dout_tmp;
	reg [15:0] max_snr_dout_tmp;
	reg [31:0] fft_result_bomen_before_tmp,fft_result_bomen_middle_tmp,fft_result_bomen_after_tmp,fft_result_freq_before_tmp,fft_result_freq_after_tmp;
    (* ASYNC_REG = "TRUE" *) reg [1:0] rst_bram_sync;

    reg param_update_toggle;
    (* ASYNC_REG = "TRUE" *) reg [2:0] param_update_toggle_sync;
    reg param_update_toggle_sys_d;
    reg [7:0] TF_power_reg_sys;
    reg [7:0] detect_en_reg_sys;
    reg [7:0] system_rst_reg_sys;
    reg [31:0] result_download_length_reg_sys;
    reg [7:0] work_freq_reg_sys;
    reg [15:0] PRT_near_reg_sys;
    reg [31:0] frame_near_period_reg_sys;
    reg [15:0] frame_near_pulse_reg_sys;
    reg [15:0] TF_near_mod_delay_reg_sys;
    reg [15:0] TF_near_mod_width_reg_sys;
    reg [15:0] TF_near_pw_delay_reg_sys;
    reg [15:0] TF_near_pw_width_reg_sys;
    reg [15:0] TR_near_delay_reg_sys;
    reg [15:0] TR_near_width_reg_sys;
    reg [15:0] ADC_near_delay_reg_sys;
    reg [15:0] ADC_near_width_reg_sys;
    reg [15:0] phase_near_delay_reg_sys;
    reg [15:0] phase_near_width_reg_sys;
    reg [15:0] PRT_far_reg_sys;
    reg [31:0] frame_far_period_reg_sys;
    reg [15:0] frame_far_pulse_reg_sys;
    reg [15:0] TF_far_mod_delay_reg_sys;
    reg [15:0] TF_far_mod_width_reg_sys;
    reg [15:0] TF_far_pw_delay_reg_sys;
    reg [15:0] TF_far_pw_width_reg_sys;
    reg [15:0] TR_far_delay_reg_sys;
    reg [15:0] TR_far_width_reg_sys;
    reg [15:0] ADC_far_delay_reg_sys;
    reg [15:0] ADC_far_width_reg_sys;
    reg [15:0] phase_far_delay_reg_sys;
    reg [15:0] phase_far_width_reg_sys;
    reg [15:0] snr_door_reg_sys;
    reg [15:0] detect_freq_low_near_reg_sys;
    reg [15:0] detect_freq_high_near_reg_sys;
    reg [15:0] detect_freq_low_far_reg_sys;
    reg [15:0] detect_freq_high_far_reg_sys;
    reg [15:0] RF_on_delay_reg_sys;
    reg [15:0] RF_on_work_reg_sys;
    reg [31:0] uart_baud_rate_reg_sys;
    reg [7:0] mode_switch_distance_reg_sys;
    reg [15:0] program_start_reg_sys;
    reg program_reset_reg_sys;
    reg [7:0] Setup_para_mode_reg_sys;
    reg [31:0] PINC1_near_reg_sys;
    reg [31:0] f0_scale_near_reg_sys;
    reg [31:0] mu_scale_near_reg_sys;
    reg [31:0] f0_scale2_near_reg_sys;
    reg [31:0] mu_scale2_near_reg_sys;
    reg [31:0] axi_chirp_width_near_reg_sys;
    reg [31:0] axi_pulse_period_near_reg_sys;
    reg [31:0] pulse_delay_reg_sys;
    reg [31:0] PINC1_far_reg_sys;
    reg [31:0] f0_scale_far_reg_sys;
    reg [31:0] mu_scale_far_reg_sys;
    reg [31:0] f0_scale2_far_reg_sys;
    reg [31:0] mu_scale2_far_reg_sys;
    reg [31:0] axi_chirp_width_far_reg_sys;
    reg [31:0] axi_pulse_period_far_reg_sys;
    reg [31:0] axi_fc_scale_near_reg_sys;
    reg [31:0] axi_fc_scale_far_reg_sys;
    reg [7:0] subarray_select_mode_reg_sys;
    reg [7:0] near_decim_factor_reg_sys;
    reg [7:0] far_decim_factor_reg_sys;
    reg [1:0] detect_phase_state_tmp_sys;
    reg [7:0] use_PulseCompress_tmp_sys;

    always @(posedge bram_clk) begin
        rst_bram_sync <= {rst_bram_sync[0], rst};
    end



    wire param_write_valid = (bram_we != 4'b0000) && (bram_addr >= 13'h0004) && (bram_addr <= 13'h0108);

    always @(posedge bram_clk) begin
        if (rst_bram_sync[1])
            param_update_toggle <= 1'b0;
        else if (param_write_valid)
            param_update_toggle <= ~param_update_toggle;
        else
            param_update_toggle <= param_update_toggle;
    end

    always @(posedge sys_clk) begin
        if (rst) begin
            param_update_toggle_sync <= 3'b000;
            param_update_toggle_sys_d <= 1'b0;
            TF_power_reg_sys <= TF_power_reg;
            detect_en_reg_sys <= detect_en_reg;
            system_rst_reg_sys <= system_rst_reg;
            result_download_length_reg_sys <= result_download_length_reg;
            work_freq_reg_sys <= work_freq_reg;
            PRT_near_reg_sys <= PRT_near_reg;
            frame_near_period_reg_sys <= frame_near_period_reg;
            frame_near_pulse_reg_sys <= frame_near_pulse_reg;
            TF_near_mod_delay_reg_sys <= TF_near_mod_delay_reg;
            TF_near_mod_width_reg_sys <= TF_near_mod_width_reg;
            TF_near_pw_delay_reg_sys <= TF_near_pw_delay_reg;
            TF_near_pw_width_reg_sys <= TF_near_pw_width_reg;
            TR_near_delay_reg_sys <= TR_near_delay_reg;
            TR_near_width_reg_sys <= TR_near_width_reg;
            ADC_near_delay_reg_sys <= ADC_near_delay_reg;
            ADC_near_width_reg_sys <= ADC_near_width_reg;
            phase_near_delay_reg_sys <= phase_near_delay_reg;
            phase_near_width_reg_sys <= phase_near_width_reg;
            PRT_far_reg_sys <= PRT_far_reg;
            frame_far_period_reg_sys <= frame_far_period_reg;
            frame_far_pulse_reg_sys <= frame_far_pulse_reg;
            TF_far_mod_delay_reg_sys <= TF_far_mod_delay_reg;
            TF_far_mod_width_reg_sys <= TF_far_mod_width_reg;
            TF_far_pw_delay_reg_sys <= TF_far_pw_delay_reg;
            TF_far_pw_width_reg_sys <= TF_far_pw_width_reg;
            TR_far_delay_reg_sys <= TR_far_delay_reg;
            TR_far_width_reg_sys <= TR_far_width_reg;
            ADC_far_delay_reg_sys <= ADC_far_delay_reg;
            ADC_far_width_reg_sys <= ADC_far_width_reg;
            phase_far_delay_reg_sys <= phase_far_delay_reg;
            phase_far_width_reg_sys <= phase_far_width_reg;
            snr_door_reg_sys <= snr_door_reg;
            detect_freq_low_near_reg_sys <= detect_freq_low_near_reg;
            detect_freq_high_near_reg_sys <= detect_freq_high_near_reg;
            detect_freq_low_far_reg_sys <= detect_freq_low_far_reg;
            detect_freq_high_far_reg_sys <= detect_freq_high_far_reg;
            RF_on_delay_reg_sys <= RF_on_delay_reg;
            RF_on_work_reg_sys <= RF_on_work_reg;
            uart_baud_rate_reg_sys <= uart_baud_rate_reg;
            mode_switch_distance_reg_sys <= mode_switch_distance_reg;
            program_start_reg_sys <= program_start_reg;
            program_reset_reg_sys <= program_reset_reg;
            Setup_para_mode_reg_sys <= Setup_para_mode_reg;
            PINC1_near_reg_sys <= PINC1_near_reg;
            f0_scale_near_reg_sys <= f0_scale_near_reg;
            mu_scale_near_reg_sys <= mu_scale_near_reg;
            f0_scale2_near_reg_sys <= f0_scale2_near_reg;
            mu_scale2_near_reg_sys <= mu_scale2_near_reg;
            axi_chirp_width_near_reg_sys <= axi_chirp_width_near_reg;
            axi_pulse_period_near_reg_sys <= axi_pulse_period_near_reg;
            pulse_delay_reg_sys <= pulse_delay_reg;
            PINC1_far_reg_sys <= PINC1_far_reg;
            f0_scale_far_reg_sys <= f0_scale_far_reg;
            mu_scale_far_reg_sys <= mu_scale_far_reg;
            f0_scale2_far_reg_sys <= f0_scale2_far_reg;
            mu_scale2_far_reg_sys <= mu_scale2_far_reg;
            axi_chirp_width_far_reg_sys <= axi_chirp_width_far_reg;
            axi_pulse_period_far_reg_sys <= axi_pulse_period_far_reg;
            axi_fc_scale_near_reg_sys <= axi_fc_scale_near_reg;
            axi_fc_scale_far_reg_sys <= axi_fc_scale_far_reg;
            subarray_select_mode_reg_sys <= subarray_select_mode_reg;
            near_decim_factor_reg_sys <= near_decim_factor_reg;
            far_decim_factor_reg_sys <= far_decim_factor_reg;
            detect_phase_state_tmp_sys <= detect_phase_state_tmp;
            use_PulseCompress_tmp_sys <= use_PulseCompress_tmp;
        end
        else begin
            param_update_toggle_sync <= {param_update_toggle_sync[1:0], param_update_toggle};
            param_update_toggle_sys_d <= param_update_toggle_sync[2];
            if (param_update_toggle_sync[2] != param_update_toggle_sys_d) begin
                TF_power_reg_sys <= TF_power_reg;
                detect_en_reg_sys <= detect_en_reg;
                system_rst_reg_sys <= system_rst_reg;
                result_download_length_reg_sys <= result_download_length_reg;
                work_freq_reg_sys <= work_freq_reg;
                PRT_near_reg_sys <= PRT_near_reg;
                frame_near_period_reg_sys <= frame_near_period_reg;
                frame_near_pulse_reg_sys <= frame_near_pulse_reg;
                TF_near_mod_delay_reg_sys <= TF_near_mod_delay_reg;
                TF_near_mod_width_reg_sys <= TF_near_mod_width_reg;
                TF_near_pw_delay_reg_sys <= TF_near_pw_delay_reg;
                TF_near_pw_width_reg_sys <= TF_near_pw_width_reg;
                TR_near_delay_reg_sys <= TR_near_delay_reg;
                TR_near_width_reg_sys <= TR_near_width_reg;
                ADC_near_delay_reg_sys <= ADC_near_delay_reg;
                ADC_near_width_reg_sys <= ADC_near_width_reg;
                phase_near_delay_reg_sys <= phase_near_delay_reg;
                phase_near_width_reg_sys <= phase_near_width_reg;
                PRT_far_reg_sys <= PRT_far_reg;
                frame_far_period_reg_sys <= frame_far_period_reg;
                frame_far_pulse_reg_sys <= frame_far_pulse_reg;
                TF_far_mod_delay_reg_sys <= TF_far_mod_delay_reg;
                TF_far_mod_width_reg_sys <= TF_far_mod_width_reg;
                TF_far_pw_delay_reg_sys <= TF_far_pw_delay_reg;
                TF_far_pw_width_reg_sys <= TF_far_pw_width_reg;
                TR_far_delay_reg_sys <= TR_far_delay_reg;
                TR_far_width_reg_sys <= TR_far_width_reg;
                ADC_far_delay_reg_sys <= ADC_far_delay_reg;
                ADC_far_width_reg_sys <= ADC_far_width_reg;
                phase_far_delay_reg_sys <= phase_far_delay_reg;
                phase_far_width_reg_sys <= phase_far_width_reg;
                snr_door_reg_sys <= snr_door_reg;
                detect_freq_low_near_reg_sys <= detect_freq_low_near_reg;
                detect_freq_high_near_reg_sys <= detect_freq_high_near_reg;
                detect_freq_low_far_reg_sys <= detect_freq_low_far_reg;
                detect_freq_high_far_reg_sys <= detect_freq_high_far_reg;
                RF_on_delay_reg_sys <= RF_on_delay_reg;
                RF_on_work_reg_sys <= RF_on_work_reg;
                uart_baud_rate_reg_sys <= uart_baud_rate_reg;
                mode_switch_distance_reg_sys <= mode_switch_distance_reg;
                program_start_reg_sys <= program_start_reg;
                program_reset_reg_sys <= program_reset_reg;
                Setup_para_mode_reg_sys <= Setup_para_mode_reg;
                PINC1_near_reg_sys <= PINC1_near_reg;
                f0_scale_near_reg_sys <= f0_scale_near_reg;
                mu_scale_near_reg_sys <= mu_scale_near_reg;
                f0_scale2_near_reg_sys <= f0_scale2_near_reg;
                mu_scale2_near_reg_sys <= mu_scale2_near_reg;
                axi_chirp_width_near_reg_sys <= axi_chirp_width_near_reg;
                axi_pulse_period_near_reg_sys <= axi_pulse_period_near_reg;
                pulse_delay_reg_sys <= pulse_delay_reg;
                PINC1_far_reg_sys <= PINC1_far_reg;
                f0_scale_far_reg_sys <= f0_scale_far_reg;
                mu_scale_far_reg_sys <= mu_scale_far_reg;
                f0_scale2_far_reg_sys <= f0_scale2_far_reg;
                mu_scale2_far_reg_sys <= mu_scale2_far_reg;
                axi_chirp_width_far_reg_sys <= axi_chirp_width_far_reg;
                axi_pulse_period_far_reg_sys <= axi_pulse_period_far_reg;
                axi_fc_scale_near_reg_sys <= axi_fc_scale_near_reg;
                axi_fc_scale_far_reg_sys <= axi_fc_scale_far_reg;
                subarray_select_mode_reg_sys <= subarray_select_mode_reg;
                near_decim_factor_reg_sys <= near_decim_factor_reg;
                far_decim_factor_reg_sys <= far_decim_factor_reg;
                detect_phase_state_tmp_sys <= detect_phase_state_tmp;
                use_PulseCompress_tmp_sys <= use_PulseCompress_tmp;
            end
        end
    end

    always @(posedge bram_clk)
    begin
        if (bram_rst) begin
            bram_en_d <= 'b0;
            bram_addr_d <= 'b0;
        end
        else begin
            bram_en_d <= bram_en;
            bram_addr_d <= bram_addr;
        end
    end

    always @(posedge bram_clk)
    begin
        if (bram_rst) begin
            CH_CHOOSE_tmp <= 'b0;
            target_state_tmp <= 'b0;
            zhen_cnt_tmp <= 'b0;
            max_bomen_dout_before_tmp <= 'b0;
            max_bomen_dout_middle_tmp <= 'b0;
            max_bomen_dout_after_tmp <= 'b0;
            max_freq_dout_before_tmp <= 'b0;
            max_freq_dout_middle_tmp <= 'b0;
            max_freq_dout_after_tmp <= 'b0;
            max_snr_dout_before_tmp <= 'b0;
            max_snr_dout_middle_tmp <= 'b0;
            max_snr_dout_after_tmp <= 'b0;
        end
        else begin
            CH_CHOOSE_tmp <= CH_CHOOSE;
            target_state_tmp <= target_state;
            zhen_cnt_tmp <= zhen_cnt;
            max_bomen_dout_before_tmp <= max_bomen_dout_before;
            max_bomen_dout_middle_tmp <= max_bomen_dout_middle;
            max_bomen_dout_after_tmp <=  max_bomen_dout_after;
            max_freq_dout_before_tmp <= max_freq_dout_before;
            max_freq_dout_middle_tmp <= max_freq_dout_middle;
            max_freq_dout_after_tmp <= max_freq_dout_after;
            max_snr_dout_before_tmp <= max_snr_dout_before;
            max_snr_dout_middle_tmp <= max_snr_dout_middle;
            max_snr_dout_after_tmp <= max_snr_dout_after;
        end
    end

    always @(posedge bram_clk)
    begin
        if (bram_rst) begin
            max_IQ_ch1_dout_tmp <= 'b0;
            max_IQ_ch2_dout_tmp <= 'b0;
            max_IQ_ch3_dout_tmp <= 'b0;
            max_IQ_ch4_dout_tmp <= 'b0;
            max_IQ_ch5_dout_tmp <= 'b0;
            ref_phase_ch1_dout_tmp <= 'b0;
            ref_phase_ch2_dout_tmp <= 'b0;
            ref_phase_ch3_dout_tmp <= 'b0;
            ref_phase_ch4_dout_tmp <= 'b0;
            ref_phase_ch5_dout_tmp <= 'b0;
        end
        else begin
            max_IQ_ch1_dout_tmp <= max_IQ_ch1_dout;
            max_IQ_ch2_dout_tmp <= max_IQ_ch2_dout;
            max_IQ_ch3_dout_tmp <= max_IQ_ch3_dout;
            max_IQ_ch4_dout_tmp <= max_IQ_ch4_dout;
            max_IQ_ch5_dout_tmp <= max_IQ_ch5_dout;
            ref_phase_ch1_dout_tmp <= ref_phase_ch1_dout;
            ref_phase_ch2_dout_tmp <= ref_phase_ch2_dout;
            ref_phase_ch3_dout_tmp <= ref_phase_ch3_dout;
            ref_phase_ch4_dout_tmp <= ref_phase_ch4_dout;
            ref_phase_ch5_dout_tmp <= ref_phase_ch5_dout;
        end
    end

    always @(posedge bram_clk)
    begin
        if (bram_rst) begin
            max_bomen_dout_tmp <= 'b0;
            max_freq_dout_tmp <= 'b0;
            max_snr_dout_tmp <= 'b0;
            fft_result_bomen_before_tmp <= 'b0;
            fft_result_bomen_middle_tmp <= 'b0;
            fft_result_bomen_after_tmp <= 'b0;
            fft_result_freq_before_tmp <= 'b0;
            fft_result_freq_after_tmp <= 'b0;
        end
        else begin
            max_bomen_dout_tmp <= max_bomen_dout;
            max_freq_dout_tmp <= max_freq_dout;
            max_snr_dout_tmp <= max_snr_dout;
            fft_result_bomen_before_tmp <= fft_result_bomen_before;
            fft_result_bomen_middle_tmp <= fft_result_bomen_middle;
            fft_result_bomen_after_tmp <= fft_result_bomen_after;
            fft_result_freq_before_tmp <= fft_result_freq_before;
            fft_result_freq_after_tmp <= fft_result_freq_after;
        end
    end

    always @(posedge bram_clk)
    begin
        if (bram_rst)
            bram_rddata <= 'b0;
        else begin
            case (bram_addr)
                13'h0200 : bram_rddata <= {16'hAA55,zhen_cnt_tmp};
                13'h0204 : bram_rddata <= {14'h0000,detect_phase_state_tmp,7'h00,target_state_tmp,7'h00,CH_CHOOSE_tmp};
                13'h0208 : bram_rddata <= {6'h00,max_freq_dout_tmp,10'h000,max_bomen_dout_tmp};
                13'h020C : bram_rddata <= fft_result_bomen_before_tmp;
                13'h0210 : bram_rddata <= fft_result_bomen_middle_tmp;
                13'h0214 : bram_rddata <= fft_result_bomen_after_tmp;
                13'h0218 : bram_rddata <= fft_result_freq_before_tmp;
                13'h021C : bram_rddata <= fft_result_freq_after_tmp;
                13'h0220 :  begin
                                if (detect_phase_state_tmp == 2'b01)
                                    bram_rddata <= {ref_phase_ch1_dout_tmp,ref_phase_ch2_dout_tmp};
                                else
                                    bram_rddata <= {max_IQ_ch1_dout_tmp,max_IQ_ch2_dout_tmp};
                            end
                13'h0224 :  begin
                                if (detect_phase_state_tmp == 2'b01)
                                    bram_rddata <= {ref_phase_ch3_dout_tmp,ref_phase_ch4_dout_tmp};
                                else
                                    bram_rddata <= {max_IQ_ch3_dout_tmp,max_IQ_ch4_dout_tmp};
                            end
                13'h0228 :  begin
                                if (detect_phase_state_tmp == 2'b01)
                                    bram_rddata <= {ref_phase_ch5_dout_tmp,max_snr_dout_tmp};
                                else
                                    bram_rddata <= {max_IQ_ch5_dout_tmp,max_snr_dout_tmp};
                            end
                default : bram_rddata <= 'b0;
            endcase
        end
    end
     
	 
	always @(posedge sys_clk) begin
		if(rst == 1'b1) begin
			pc_tx_on_off					<= 1'b0			;
			 
		end
		else begin
			if(TF_power_reg_sys == 8'hff)
				pc_tx_on_off				<= 1'b1			;	
			else if(TF_power_reg_sys == 8'h00)
				pc_tx_on_off				<= 1'b0			;
			else
				pc_tx_on_off				<= pc_tx_on_off	;				
		end		
	end	
	always @(posedge sys_clk) begin
		if(rst == 1'b1) begin
			 
			just_receive					<= 1'b0			;
		end
		else begin
			if(detect_en_reg_sys == 8'hff)
				just_receive				<= 1'b1			;	
			else if(detect_en_reg_sys == 8'h00)
				just_receive				<= 1'b0			;
			else
				just_receive				<= just_receive	;				
		end		
	end	
	
	always @(posedge sys_clk) begin
		if(rst == 1'b1) begin
			pc_in_rst						<= 1'b0			;	 
		end
		else begin
			pc_in_rst						<= system_rst_reg_sys;	 
		end		
	end
	
    always @(posedge sys_clk)
    begin
        if (rst) begin
            result_download_length_dout <= 'b0;
            work_freq_dout <= 'b0;

        end
        else begin
            result_download_length_dout <= result_download_length_reg_sys;
            work_freq_dout <= work_freq_reg_sys;

        end
    end
	
	 
	always @(posedge sys_clk)
    begin
        if (rst)
            program_start				<= 1'b0				; 
        else begin	
			if(program_start_reg_sys == 16'hffff)	
				program_start			<= 1'b1				;
			else if(program_start_reg_sys == 16'h0000)	
				program_start			<= 1'b0				;
			else
				program_start			<= program_start	;
			
        end
    end
	always @(posedge sys_clk) begin
		if(rst == 1'b1) begin
			program_reset				<= 1'b0				;
		end
		else begin
			program_reset				<= program_reset_reg_sys;
		end		
	end
	
	 
	 
    always @(posedge sys_clk)
    begin
        if (rst) begin
            PRT_near_dout 				<= 16'd48		;	 
            frame_near_period_dout 		<= 32'd25087	;	 
            frame_near_pulse_dout		<= 16'd512		;	 
            TF_near_mod_delay_dout 		<= 16'd0		;	 
            TF_near_mod_width_dout 		<= 16'd9		;	 
            TF_near_pw_delay_dout 		<= 16'd0		;	 
            TF_near_pw_width_dout 		<= 16'd9		;	 
            TR_near_delay_dout 			<= 16'd0		;	 
            TR_near_width_dout 			<= 16'd38		;	 
            ADC_near_delay_dout 		<= 16'd0		;	 
            ADC_near_width_dout 		<= 16'd38		;	 
            phase_near_delay_dout 		<= 16'd0		;	 
            phase_near_width_dout 		<= 16'd38		;	 
			near_decim_factor_dout		<= 8'd0			;			

        end
        else begin
            PRT_near_dout <= PRT_near_reg_sys;
            frame_near_period_dout <= frame_near_period_reg_sys;
            frame_near_pulse_dout <= frame_near_pulse_reg_sys;
            TF_near_mod_delay_dout <= TF_near_mod_delay_reg_sys;           
			TF_near_mod_width_dout <= TF_near_mod_width_reg_sys;
            TF_near_pw_delay_dout <= TF_near_pw_delay_reg_sys;
            TF_near_pw_width_dout <= TF_near_pw_width_reg_sys;
            TR_near_delay_dout <= TR_near_delay_reg_sys;
            TR_near_width_dout <= TR_near_width_reg_sys;
            ADC_near_delay_dout <= ADC_near_delay_reg_sys;
            ADC_near_width_dout <= ADC_near_width_reg_sys;
            phase_near_delay_dout <= phase_near_delay_reg_sys;
            phase_near_width_dout <= phase_near_width_reg_sys;
			near_decim_factor_dout		<= near_decim_factor_reg_sys			;			
			
        end
    end
     
    always @(posedge sys_clk)
    begin
        if (rst) begin
            PRT_far_dout 				<= 16'd120		;	 
            frame_far_period_dout 		<= 32'd123903	;	 
            frame_far_pulse_dout 		<= 16'd1024		;	 
            TF_far_mod_delay_dout		<= 16'd0		;	 
            TF_far_mod_width_dout 		<= 16'd49		;	 
            TF_far_pw_delay_dout 		<= 16'd0		;	 
            TF_far_pw_width_dout 		<= 16'd49		;	 
            TR_far_delay_dout 			<= 16'd0		;	 
            TR_far_width_dout 			<= 16'd70		;	 
            ADC_far_delay_dout 			<= 16'd0		;	 
            ADC_far_width_dout 			<= 16'd70		;
            phase_far_delay_dout		<= 16'd0		;	 
            phase_far_width_dout 		<= 16'd70		;	 
			far_decim_factor_dout		<= 8'd1			;			

        end
        else begin
            PRT_far_dout <= PRT_far_reg_sys;
            frame_far_period_dout <= frame_far_period_reg_sys;
            frame_far_pulse_dout <= frame_far_pulse_reg_sys;
            TF_far_mod_delay_dout <= TF_far_mod_delay_reg_sys;
            TF_far_mod_width_dout <= TF_far_mod_width_reg_sys;
            TF_far_pw_delay_dout <= TF_far_pw_delay_reg_sys;
            TF_far_pw_width_dout <= TF_far_pw_width_reg_sys;
            TR_far_delay_dout <= TR_far_delay_reg_sys;
            TR_far_width_dout <= TR_far_width_reg_sys;
            ADC_far_delay_dout <= ADC_far_delay_reg_sys;
            ADC_far_width_dout <= ADC_far_width_reg_sys;
            phase_far_delay_dout <= phase_far_delay_reg_sys;
            phase_far_width_dout <= phase_far_width_reg_sys;		
			far_decim_factor_dout		<= far_decim_factor_reg_sys			;			
			
        end
    end


    always @(posedge sys_clk)
    begin
        if (rst) begin

            snr_door_dout <= 'b0;
            detect_freq_low_near_dout <= 'b0;
            detect_freq_high_near_dout <= 'b0;
            detect_freq_low_far_dout <= 'b0;
            detect_freq_high_far_dout <= 'b0;
            RF_on_delay_dout <= 'b0;
            RF_on_work_dout <= 'b0;
            uart_baud_rate_dout <= 'b0;
             
            mode_switch_distance_dout <= 'b0;
			subarray_select_mode	<= 8'h00	;
			detect_phase_state <= 2'b10		;
			use_PulseCompress	<= 8'hff	;	 
        end
        else begin

            snr_door_dout <= snr_door_reg_sys;
            detect_freq_low_near_dout <= detect_freq_low_near_reg_sys;
            detect_freq_high_near_dout <= detect_freq_high_near_reg_sys;
            detect_freq_low_far_dout <= detect_freq_low_far_reg_sys;
            detect_freq_high_far_dout <= detect_freq_high_far_reg_sys;
            RF_on_delay_dout <= RF_on_delay_reg_sys;
            RF_on_work_dout <= RF_on_work_reg_sys;
            uart_baud_rate_dout <= uart_baud_rate_reg_sys;
             
            mode_switch_distance_dout <= mode_switch_distance_reg_sys;
			subarray_select_mode	<= subarray_select_mode_reg_sys		;
			detect_phase_state <= detect_phase_state_tmp_sys;
			use_PulseCompress	<= use_PulseCompress_tmp_sys;
        end
    end


	always @(posedge sys_clk) begin
		if(rst == 1'b1) begin
			Setup_para_mode				<= 8'h11			;		 
		end
		else begin
			Setup_para_mode				<= Setup_para_mode_reg_sys[7:0]	;
		end		
	end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TF_power_reg <= 'b0;
        else begin
            if ((bram_addr == 13'h0004) && (bram_we[0] == 1'b1))
                TF_power_reg <= bram_wrdata[7:0];
            else
                TF_power_reg <= TF_power_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            detect_en_reg <= 'b0;
        else begin
            if ((bram_addr == 13'h0008) && (bram_we[0] == 1'b1))
                detect_en_reg <= bram_wrdata[7:0];
            else
                detect_en_reg <= detect_en_reg;
        end
    end
    
    reg		[7:0]				pc_rst_cnt					;
    
    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            system_rst_reg <= 'b0;
        else begin
            if ((bram_addr == 13'h000C) && (bram_we[0] == 1'b1) && (bram_wrdata[7:0] == 8'hff))
                system_rst_reg <= 1'b1;
            else begin
                if(pc_rst_cnt >= 8'd50)
					system_rst_reg <= 1'b0					;
				else
					system_rst_reg	<= system_rst_reg		;
				
			end
        end
    end

    always @(posedge bram_clk) begin
		if(rst_bram_sync[1] == 1'b1) begin
			pc_rst_cnt						<= 8'd0			;	 
		end
		else begin
			if(system_rst_reg == 1'b1)	
				pc_rst_cnt					<= pc_rst_cnt+ 1;
			else
				pc_rst_cnt					<= 8'd0			;
		end		
	end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            result_download_length_reg <= 'b0;
        else begin
            if ((bram_addr == 13'h0010) && (bram_we == 4'hF))
                result_download_length_reg <= bram_wrdata;
            else
                result_download_length_reg <= result_download_length_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            work_freq_reg <= 'b0;
        else begin
            if ((bram_addr == 13'h0014) && (bram_we[0] == 1'b1))
                work_freq_reg <= bram_wrdata[7:0];
            else
                work_freq_reg <= work_freq_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            PRT_near_reg <= 16'd48;    
        else begin
            if ((bram_addr == 13'h0018) && (bram_we[1:0] == 2'b11))
                PRT_near_reg <= bram_wrdata[15:0];
            else
                PRT_near_reg <= PRT_near_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            frame_near_period_reg <= 32'd25087;      
        else begin
            if ((bram_addr == 13'h001C) && (bram_we == 4'hF))
                frame_near_period_reg <= bram_wrdata;
            else
                frame_near_period_reg <= frame_near_period_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            frame_near_pulse_reg <= 16'd511;    
        else begin
            if ((bram_addr == 13'h0020) && (bram_we[1:0] == 2'b11))
                frame_near_pulse_reg <= bram_wrdata[15:0];
            else
                frame_near_pulse_reg <= frame_near_pulse_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TF_near_mod_delay_reg <= 16'd1;    
        else begin
            if ((bram_addr == 13'h0024) && (bram_we[1:0] == 2'b11))
                TF_near_mod_delay_reg <= bram_wrdata[15:0];
            else
                TF_near_mod_delay_reg <= TF_near_mod_delay_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TF_near_mod_width_reg <= 16'd9;    
        else begin
            if ((bram_addr == 13'h0028) && (bram_we[1:0] == 2'b11))
                TF_near_mod_width_reg <= bram_wrdata[15:0];
            else
                TF_near_mod_width_reg <= TF_near_mod_width_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TF_near_pw_delay_reg <= 16'd1;    
        else begin
            if ((bram_addr == 13'h002C) && (bram_we[1:0] == 2'b11))
                TF_near_pw_delay_reg <= bram_wrdata[15:0];
            else
                TF_near_pw_delay_reg <= TF_near_pw_delay_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TF_near_pw_width_reg <= 16'd9;    
        else begin
            if ((bram_addr == 13'h0030) && (bram_we[1:0] == 2'b11))
                TF_near_pw_width_reg <= bram_wrdata[15:0];
            else
                TF_near_pw_width_reg <= TF_near_pw_width_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TR_near_delay_reg <= 16'd9;    
        else begin
            if ((bram_addr == 13'h0034) && (bram_we[1:0] == 2'b11))
                TR_near_delay_reg <= bram_wrdata[15:0];
            else
                TR_near_delay_reg <= TR_near_delay_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TR_near_width_reg <= 16'd38;    
        else begin
            if ((bram_addr == 13'h0038) && (bram_we[1:0] == 2'b11))
                TR_near_width_reg <= bram_wrdata[15:0];
            else
                TR_near_width_reg <= TR_near_width_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            ADC_near_delay_reg <= 16'd9;    
        else begin
            if ((bram_addr == 13'h003C) && (bram_we[1:0] == 2'b11))
                ADC_near_delay_reg <= bram_wrdata[15:0];
            else
                ADC_near_delay_reg <= ADC_near_delay_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            ADC_near_width_reg <= 16'd38;    
        else begin
            if ((bram_addr == 13'h0040) && (bram_we[1:0] == 2'b11))
                ADC_near_width_reg <= bram_wrdata[15:0];
            else
                ADC_near_width_reg <= ADC_near_width_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            phase_near_delay_reg <= 16'd9;    
        else begin
            if ((bram_addr == 13'h0044) && (bram_we[1:0] == 2'b11))
                phase_near_delay_reg <= bram_wrdata[15:0];
            else
                phase_near_delay_reg <= phase_near_delay_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            phase_near_width_reg <= 16'd38;    
        else begin
            if ((bram_addr == 13'h0048) && (bram_we[1:0] == 2'b11))
                phase_near_width_reg <= bram_wrdata[15:0];
            else
                phase_near_width_reg <= phase_near_width_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            PRT_far_reg <= 16'd120;    
        else begin
            if ((bram_addr == 13'h004C) && (bram_we[1:0] == 2'b11))
                PRT_far_reg <= bram_wrdata[15:0];
            else
                PRT_far_reg <= PRT_far_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            frame_far_period_reg <= 32'd123903;      
        else begin
            if ((bram_addr == 13'h0050) && (bram_we == 4'hF))
                frame_far_period_reg <= bram_wrdata;
            else
                frame_far_period_reg <= frame_far_period_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            frame_far_pulse_reg <= 16'd1023;    
        else begin
            if ((bram_addr == 13'h0054) && (bram_we[1:0] == 2'b11))
                frame_far_pulse_reg <= bram_wrdata[15:0];
            else
                frame_far_pulse_reg <= frame_far_pulse_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TF_far_mod_delay_reg <= 16'd51;    
        else begin
            if ((bram_addr == 13'h0058) && (bram_we[1:0] == 2'b11))
                TF_far_mod_delay_reg <= bram_wrdata[15:0];
            else
                TF_far_mod_delay_reg <= TF_far_mod_delay_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TF_far_mod_width_reg <= 16'd12;    
        else begin
            if ((bram_addr == 13'h005C) && (bram_we[1:0] == 2'b11))
                TF_far_mod_width_reg <= bram_wrdata[15:0];
            else
                TF_far_mod_width_reg <= TF_far_mod_width_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TF_far_pw_delay_reg <= 16'd14;    
        else begin
            if ((bram_addr == 13'h0060) && (bram_we[1:0] == 2'b11))
                TF_far_pw_delay_reg <= bram_wrdata[15:0];
            else
                TF_far_pw_delay_reg <= TF_far_pw_delay_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TF_far_pw_width_reg <= 16'd44;    
        else begin
            if ((bram_addr == 13'h0064) && (bram_we[1:0] == 2'b11))
                TF_far_pw_width_reg <= bram_wrdata[15:0];
            else
                TF_far_pw_width_reg <= TF_far_pw_width_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TR_far_delay_reg <= 16'd66;    
        else begin
            if ((bram_addr == 13'h0068) && (bram_we[1:0] == 2'b11))
                TR_far_delay_reg <= bram_wrdata[15:0];
            else
                TR_far_delay_reg <= TR_far_delay_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            TR_far_width_reg <= 16'd108;    
        else begin
            if ((bram_addr == 13'h006C) && (bram_we[1:0] == 2'b11))
                TR_far_width_reg <= bram_wrdata[15:0];
            else
                TR_far_width_reg <= TR_far_width_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            ADC_far_delay_reg <= 16'd5;    
        else begin
            if ((bram_addr == 13'h0070) && (bram_we[1:0] == 2'b11))
                ADC_far_delay_reg <= bram_wrdata[15:0];
            else
                ADC_far_delay_reg <= ADC_far_delay_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            ADC_far_width_reg <= 16'd99;    
        else begin
            if ((bram_addr == 13'h0074) && (bram_we[1:0] == 2'b11))
                ADC_far_width_reg <= bram_wrdata[15:0];
            else
                ADC_far_width_reg <= ADC_far_width_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            phase_far_delay_reg <= 16'd49;    
        else begin
            if ((bram_addr == 13'h0078) && (bram_we[1:0] == 2'b11))
                phase_far_delay_reg <= bram_wrdata[15:0];
            else
                phase_far_delay_reg <= phase_far_delay_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            phase_far_width_reg <= 16'd70;    
        else begin
            if ((bram_addr == 13'h007C) && (bram_we[1:0] == 2'b11))
                phase_far_width_reg <= bram_wrdata[15:0];
            else
                phase_far_width_reg <= phase_far_width_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            snr_door_reg <= 16'd100;    
        else begin
            if ((bram_addr == 13'h0080) && (bram_we[1:0] == 2'b11))
                snr_door_reg <= bram_wrdata[15:0];
            else
                snr_door_reg <= snr_door_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            detect_freq_low_near_reg <= 16'd10;   
        else begin
            if ((bram_addr == 13'h0084) && (bram_we[1:0] == 2'b11))
                detect_freq_low_near_reg <= bram_wrdata[15:0];
            else
                detect_freq_low_near_reg <= detect_freq_low_near_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            detect_freq_high_near_reg <= 16'd200;    
        else begin
            if ((bram_addr == 13'h0088) && (bram_we[1:0] == 2'b11))
                detect_freq_high_near_reg <= bram_wrdata[15:0];
            else
                detect_freq_high_near_reg <= detect_freq_high_near_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            detect_freq_low_far_reg <= 16'd10;    
        else begin
            if ((bram_addr == 13'h008C) && (bram_we[1:0] == 2'b11))
                detect_freq_low_far_reg <= bram_wrdata[15:0];
            else
                detect_freq_low_far_reg <= detect_freq_low_far_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            detect_freq_high_far_reg <= 16'd400;    
        else begin
            if ((bram_addr == 13'h0090) && (bram_we[1:0] == 2'b11))
                detect_freq_high_far_reg <= bram_wrdata[15:0];
            else
                detect_freq_high_far_reg <= detect_freq_high_far_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            RF_on_delay_reg <= 16'd10;    
        else begin
            if ((bram_addr == 13'h0094) && (bram_we[1:0] == 2'b11))
                RF_on_delay_reg <= bram_wrdata[15:0];
            else
                RF_on_delay_reg <= RF_on_delay_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            RF_on_work_reg <= 16'd10;   
        else begin
            if ((bram_addr == 13'h0098) && (bram_we[1:0] == 2'b11))
                RF_on_work_reg <= bram_wrdata[15:0];
            else
                RF_on_work_reg <= RF_on_work_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            uart_baud_rate_reg <= 32'd100;   
        else begin
            if ((bram_addr == 13'h009C) && (bram_we[1:0] == 2'b11))
                uart_baud_rate_reg <= bram_wrdata[31:0];
            else
                uart_baud_rate_reg <= uart_baud_rate_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            radar_work_mode_reg <= 16'd0;   
        else begin
            if ((bram_addr == 13'h00A0) && (bram_we[1:0] == 2'b11))
                radar_work_mode_reg <= bram_wrdata[15:0];
            else
                radar_work_mode_reg <= radar_work_mode_reg;
        end
    end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            mode_switch_distance_reg <= 8'd10;    
        else begin
            if ((bram_addr == 13'h00A4) && (bram_we[1:0] == 2'b11))
                mode_switch_distance_reg <= bram_wrdata[7:0];
            else
                mode_switch_distance_reg <= mode_switch_distance_reg;
        end
    end
	 
    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            program_start_reg <= 16'h0000;    
        else begin
            if ((bram_addr == 13'h00A8) && (bram_we[1:0] == 2'b11))
                program_start_reg <= bram_wrdata[15:0];
            else
                program_start_reg <= program_start_reg;
        end
    end
    
    reg	[7:0]		prog_reset_cnt		;
    
	 
    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            program_reset_reg <= 1'b0;   
        else begin
            if ((bram_addr == 13'h00AC) && (bram_we[1:0] == 2'b11))
                program_reset_reg <= 1'b1				;
            else if(prog_reset_cnt >= 8'h50)
				program_reset_reg	<= 1'b0				;
			else
                program_reset_reg <= program_reset_reg	;
        end
    end

    always @(posedge bram_clk) begin
		if(rst_bram_sync[1] == 1'b1) begin
			prog_reset_cnt		<= 8'd0		;
		end
		else begin
			if(program_reset_reg == 1'b1) begin
				prog_reset_cnt	<= prog_reset_cnt + 8'd1;
			end
			else begin
				prog_reset_cnt	<= 8'd0		;
			end
		end
	end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1])
            Setup_para_mode_reg <= 16'h0011;    
        else begin
            if ((bram_addr == 13'h00B0) && (bram_we[1:0] == 2'b11))
                Setup_para_mode_reg <= bram_wrdata[15:0];
            else
                Setup_para_mode_reg <= Setup_para_mode_reg;
        end
    end


    always @(posedge sys_clk)
    begin
        if (rst) begin
            PINC1_near_dout             <= 32'd85899345;               
            f0_scale_near_dout          <= 32'hb3333333;             
            mu_scale_near_dout          <= 32'h28f5c3;             
            f0_scale2_near_dout         <= 32'h5599999a;             
            mu_scale2_near_dout         <= 32'ha3d7;           
            axi_chirp_width_near_dout   <= 32'd10;         
            axi_pulse_period_near_dout  <= 32'd49;          
            pulse_delay_dout            <= 32'd0;                   
            PINC1_far_dout              <= 32'd17179869;              
            f0_scale_far_dout           <= 32'hb3333333;             
            mu_scale_far_dout           <= 32'h83127;             
            f0_scale2_far_dout          <= 32'h5599999a;             
            mu_scale2_far_dout          <= 32'h20c5;           
            axi_chirp_width_far_dout    <= 32'd50;          
            axi_pulse_period_far_dout   <= 32'd121;         
            axi_fc_scale_near_dout      <= 32'h33333333;         
            axi_fc_scale_far_dout       <= 32'd3435973837;         
        end
        else begin
            PINC1_near_dout             <=  PINC1_near_reg_sys;                       
            f0_scale_near_dout          <=  f0_scale_near_reg_sys;                 
            mu_scale_near_dout          <=  mu_scale_near_reg_sys;                  
            f0_scale2_near_dout         <=  f0_scale2_near_reg_sys;                
            mu_scale2_near_dout         <=  mu_scale2_near_reg_sys;               
            axi_chirp_width_near_dout   <=  axi_chirp_width_near_reg_sys;         
            axi_pulse_period_near_dout  <=  axi_pulse_period_near_reg_sys;        
            pulse_delay_dout            <=  pulse_delay_reg_sys;                            
            PINC1_far_dout              <=  PINC1_far_reg_sys;                        
            f0_scale_far_dout           <=  f0_scale_far_reg_sys;                  
            mu_scale_far_dout           <=  mu_scale_far_reg_sys;                   
            f0_scale2_far_dout          <=  f0_scale2_far_reg_sys;                 
            mu_scale2_far_dout          <=  mu_scale2_far_reg_sys;                
            axi_chirp_width_far_dout    <=  axi_chirp_width_far_reg_sys;           
            axi_pulse_period_far_dout   <=  axi_pulse_period_far_reg_sys;           
            axi_fc_scale_near_dout      <= axi_fc_scale_near_reg_sys;         
            axi_fc_scale_far_dout       <= axi_fc_scale_far_reg_sys;         
        end
    end

    always @(posedge bram_clk) begin
    if (rst_bram_sync[1]) begin
        PINC1_near_reg             <= 32'd85899345;       
        f0_scale_near_reg          <= 32'hb3333333;  
        mu_scale_near_reg          <= 32'h28f5c3;     
        f0_scale2_near_reg         <= 32'h5599999a;  
        mu_scale2_near_reg         <= 32'ha3d7;       
        axi_chirp_width_near_reg   <= 32'd10;           
        axi_pulse_period_near_reg  <= 32'd49;          
        pulse_delay_reg            <= 32'd0;           
        PINC1_far_reg              <= 32'd17179869;    
        f0_scale_far_reg           <= 32'hb3333333;  
        mu_scale_far_reg           <= 32'h83127;      
        f0_scale2_far_reg          <= 32'h5599999a;  
        mu_scale2_far_reg          <= 32'h20c5;       
        axi_chirp_width_far_reg    <= 32'd50;          
        axi_pulse_period_far_reg   <= 32'd121;        
        axi_fc_scale_near_reg      <= 32'h33333333;        
        axi_fc_scale_far_reg       <= 32'd3435973837;        


    end
    else if(bram_we == 4'b1111) begin
        case(bram_addr)
        13'h00b4:begin
            PINC1_near_reg <= bram_wrdata;
        end
        13'h00b8:begin
            f0_scale_near_reg <= bram_wrdata;
        end
        13'h00bc:begin
            mu_scale_near_reg <= bram_wrdata;
        end
        13'h00c0:begin
            f0_scale2_near_reg <= bram_wrdata;
        end
        13'h00c4:begin
            mu_scale2_near_reg <= bram_wrdata;
        end
        13'h00c8:begin
            axi_chirp_width_near_reg <= bram_wrdata;
        end
        13'h00cc:begin
            axi_pulse_period_near_reg <= bram_wrdata;
        end
        13'h00d0:begin
            pulse_delay_reg <= bram_wrdata;
        end
        13'h00d4:begin
            PINC1_far_reg <= bram_wrdata;
        end
        13'h00d8:begin
            f0_scale_far_reg <= bram_wrdata;
        end
        13'h00dc:begin
            mu_scale_far_reg <= bram_wrdata;
        end
        13'h00e0:begin
            f0_scale2_far_reg <= bram_wrdata;
        end
        13'h00e4:begin
            mu_scale2_far_reg <= bram_wrdata;
        end
        13'h00e8:begin
            axi_chirp_width_far_reg <= bram_wrdata;
        end
        13'h00ec:begin
            axi_pulse_period_far_reg <= bram_wrdata;
        end
        13'h0100:begin
            axi_fc_scale_near_reg <= bram_wrdata;
        end
        13'h0104:begin
            axi_fc_scale_far_reg <= bram_wrdata;
        end
		
        default:begin
            PINC1_near_reg             <= PINC1_near_reg           ;      
            f0_scale_near_reg          <= f0_scale_near_reg        ;  
            mu_scale_near_reg          <= mu_scale_near_reg        ;  
            f0_scale2_near_reg         <= f0_scale2_near_reg       ;  
            mu_scale2_near_reg         <= mu_scale2_near_reg       ;  
            axi_chirp_width_near_reg   <= axi_chirp_width_near_reg ;  
            axi_pulse_period_near_reg  <= axi_pulse_period_near_reg;  
            pulse_delay_reg            <= pulse_delay_reg          ;  
            PINC1_far_reg              <= PINC1_far_reg            ;  
            f0_scale_far_reg           <= f0_scale_far_reg         ;  
            mu_scale_far_reg           <= mu_scale_far_reg         ;  
            f0_scale2_far_reg          <= f0_scale2_far_reg        ;  
            mu_scale2_far_reg          <= mu_scale2_far_reg        ;  
            axi_chirp_width_far_reg    <= axi_chirp_width_far_reg  ;  
            axi_pulse_period_far_reg   <= axi_pulse_period_far_reg ;
            axi_fc_scale_near_reg      <= axi_fc_scale_near_reg;        
            axi_fc_scale_far_reg       <= axi_fc_scale_far_reg;
			
        end
        endcase
    end   
    else begin
            PINC1_near_reg             <= PINC1_near_reg           ;      
            f0_scale_near_reg          <= f0_scale_near_reg        ;  
            mu_scale_near_reg          <= mu_scale_near_reg        ;  
            f0_scale2_near_reg         <= f0_scale2_near_reg       ;  
            mu_scale2_near_reg         <= mu_scale2_near_reg       ;  
            axi_chirp_width_near_reg   <= axi_chirp_width_near_reg ;  
            axi_pulse_period_near_reg  <= axi_pulse_period_near_reg;  
            pulse_delay_reg            <= pulse_delay_reg          ;  
            PINC1_far_reg              <= PINC1_far_reg            ;  
            f0_scale_far_reg           <= f0_scale_far_reg         ;  
            mu_scale_far_reg           <= mu_scale_far_reg         ;  
            f0_scale2_far_reg          <= f0_scale2_far_reg        ;  
            mu_scale2_far_reg          <= mu_scale2_far_reg        ;  
            axi_chirp_width_far_reg    <= axi_chirp_width_far_reg  ;  
            axi_pulse_period_far_reg   <= axi_pulse_period_far_reg ;
		    axi_fc_scale_near_reg      <= axi_fc_scale_near_reg;        
            axi_fc_scale_far_reg       <= axi_fc_scale_far_reg;
    end
end

    always @(posedge bram_clk)
    begin
        if (rst_bram_sync[1]) begin
            subarray_select_mode_reg 	<= 8'h00;    
			near_decim_factor_reg		<= 8'd0		;	
			far_decim_factor_reg	    <= 8'd1		;	
			detect_phase_state_tmp		<= 2'b10	;	 
			use_PulseCompress_tmp		<= 8'hff	;	 
		end
        else begin
			if(bram_we == 4'b1111) begin
				case(bram_addr)
					13'h00F0:begin
						subarray_select_mode_reg <= bram_wrdata[7:0];
					end
					13'h00f4:begin
						far_decim_factor_reg <= bram_wrdata[7:0];
					end
					13'h00f8:begin
						near_decim_factor_reg <= bram_wrdata[7:0];
					end
					13'h00fc:begin
						detect_phase_state_tmp <= bram_wrdata[1:0];
					end
					13'h0108:begin
						use_PulseCompress_tmp <= bram_wrdata[7:0];
					end
					
					 
						
					 
						 
					default : begin
						subarray_select_mode_reg 	<= subarray_select_mode_reg;
						near_decim_factor_reg		<= near_decim_factor_reg	;	
						far_decim_factor_reg	    <= far_decim_factor_reg		;
						detect_phase_state_tmp		<= detect_phase_state_tmp	;
						use_PulseCompress_tmp		<= use_PulseCompress_tmp;
					end
				endcase		
			end
			else begin
						subarray_select_mode_reg <= subarray_select_mode_reg;
						near_decim_factor_reg		<= near_decim_factor_reg	;	
						far_decim_factor_reg	    <= far_decim_factor_reg		;
						detect_phase_state_tmp		<= detect_phase_state_tmp	;
			end
        end
    end
    
    

	

    
endmodule

