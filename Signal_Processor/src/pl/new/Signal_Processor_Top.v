`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


module Signal_Processor_Top(
	input                   			clk_50m,
	 
				
	 
	input                   			glblclkp,
	input                   			glblclkn,
				
	input                   			sysref_p,
	input                   			sysref_n,
	 
	  
	 input wire              			adc0_clk_p,		
	 input wire              			adc0_clk_n,
				
	 input wire              			adc1_clk_p,
	 input wire              			adc1_clk_n,
	 input wire              			adc2_clk_p,		
	 input wire              			adc2_clk_n,
				
	 input wire              			adc3_clk_p,
	 input wire              			adc3_clk_n,
				
	 input wire              			dac0_clk_p,
	 input wire              			dac0_clk_n,
				
	 input wire              			sysref_in_p,
	 input wire              			sysref_in_n,
	
	 input wire 							vin0_01_p				,
	 input wire 							vin0_01_n				,
	 input wire 							vin0_23_p				,
	 input wire 							vin0_23_n				,
	 input wire 							vin1_01_p				,
	 input wire 							vin1_01_n				,
	 input wire 							vin1_23_p				,
	 input wire 							vin1_23_n				,
	 input wire 							vin2_01_p				,
	 input wire 							vin2_01_n				,
	 input wire 							vin2_23_p				,
	 input wire 							vin2_23_n				,
	 input wire 							vin3_01_p				,
	 input wire 							vin3_01_n				,
	 input wire 							vin3_23_p				,
	 input wire 							vin3_23_n				,
								
	 output wire							vout00_p				,
	 output wire							vout00_n				,
	 output wire							vout02_p				,
	 output wire							vout02_n				,
	 
 
	output                  			AGC_1DB_F,
	output                  			AGC_2DB_F,
	output                  			AGC_4DB_F,
	output                  			AGC_8DB_F,
	output                  			AGC_16DB_F,
	output        [1:0]         		CH_CHOOSE,			 
	 
	 
	 
	 
	 
	 
				
	output                  			uart_RF_re			,			 
	output                  			uart_RF_de			,
	output                  			uart_RF_tx,
	input                   			uart_RF_rx,
	 
	output                  			FK422_TX			,		 
	input                   			FK422_RX			,		 
	
	output                  			YC422_TX			,		 
	input                   			YC422_RX			,		 

	output								TF_pm				,		 
	output								TF_pc				,		 
	output								TR_k				,		 
				
	 
	output                  			si5341_csb,
	output                  			si5341_sdio,
	output                  			si5341_sclk,
	input                   			si5341_sdo,
	 
	output                  			LMK04828_SYNC,  
	output                  			LMK_dac_rst,  
	inout                   			LMK_dac_SDIO,  
	output                  			LMK_dac_CS,  
	output                  			LMK_dac_SCLK
	
    );
	wire                    		clk_50m_new         ;    
	wire                    		clk_50m_sys         ; 
	wire                    		clk_100m            ; 
	wire                    		locked              ;    
	wire                    		clk_spi_1M          ;    
			
			
			
	wire                    		lmk_cfg_finish      ;
	wire                    		lmk_cfg_LOCKED      ;
	
	
	 
	wire                        	glblclk_i       		;
	wire                        	glblclk_pll    		;
	wire                        	sysref          		;
	wire                        	clk_500M       		;
	wire                        	glblclk_locked		;
	wire                        	clk_pl_fbin     		;
	wire                        	clk_pl_fbout    		;
				
	wire							rf_clk_locked			;
	wire 							si5341_cfg_done			;
	
	wire							clk_200M				;
	wire							clk_250M				;
(*keep = "true"*)	wire							sys_rst						;
	wire							sys_rst_n					;
	wire											sys_rst_100m				;
	wire											sys_rst_n_100m			;
	 
 
    wire  							clk_adc0;
    wire  							adc_clk_locked;
    wire  							s_axi_aclk;
    wire  							s_axi_aresetn;
    wire 							irq;
    wire 							clk_dac0;
     
    wire 							m0_axis_aresetn;
    wire 							m0_axis_aclk;
					
    wire [15 : 0] 					m00_axis_tdata;
    wire 							m00_axis_tvalid;
    wire 							m00_axis_tready;
					
    wire [15 : 0] 					m01_axis_tdata;
    wire 							m01_axis_tvalid;
    wire 							m01_axis_tready;
								
    wire [15 : 0] 					m02_axis_tdata;
    wire 							m02_axis_tvalid;
    wire 							m02_axis_tready;
					
    wire [15 : 0] 					m03_axis_tdata;
    wire 							m03_axis_tvalid;
    wire 							m03_axis_tready;
								
    wire 							m1_axis_aresetn;
    wire 							m1_axis_aclk;
					
    wire [15 : 0] 					m10_axis_tdata;
    wire 							m10_axis_tvalid;
    wire 							m10_axis_tready;
					
    wire [15 : 0] 					m11_axis_tdata;
    wire 							m11_axis_tvalid;
    wire 							m11_axis_tready;
					
    wire [15 : 0] 					m12_axis_tdata;
    wire 							m12_axis_tvalid;
    wire 							m12_axis_tready;
					
    wire [15 : 0] 					m13_axis_tdata;
    wire 							m13_axis_tvalid;
    wire 							m13_axis_tready;
								
    wire 							m2_axis_aresetn;
    wire 							m2_axis_aclk;
					
    wire [15 : 0] 					m20_axis_tdata;
    wire 							m20_axis_tvalid;
    wire 							m20_axis_tready;
					
    wire [15 : 0] 					m21_axis_tdata;
    wire 							m21_axis_tvalid;
    wire 							m21_axis_tready;
					
    wire [15 : 0] 					m22_axis_tdata;
    wire 							m22_axis_tvalid;
    wire 							m22_axis_tready;
					
    wire [15 : 0]					m23_axis_tdata;
    wire 							m23_axis_tvalid;
    wire 							m23_axis_tready;
								
    wire 							m3_axis_aresetn;
    wire 							m3_axis_aclk;
					
    wire [15 : 0] 					m30_axis_tdata;
    wire 							m30_axis_tvalid;
    wire 							m30_axis_tready;
					
    wire [15 : 0]					m31_axis_tdata;
    wire 							m31_axis_tvalid;
    wire 							m31_axis_tready;
					
    wire [15 : 0] 					m32_axis_tdata;
    wire 							m32_axis_tvalid;
    wire 							m32_axis_tready;
					
    wire [15 : 0] 					m33_axis_tdata;
    wire 							m33_axis_tvalid;
    wire 							m33_axis_tready;
									
    wire 							s0_axis_aresetn;
    wire 							s0_axis_aclk;
					
    wire [255 : 0] 					s00_axis_tdata;
    wire 							s00_axis_tvalid;
    wire 							s00_axis_tready;
					
    wire [255 : 0] 					s02_axis_tdata;
    wire 							s02_axis_tvalid;
    wire 							s02_axis_tready;
	

	wire							pc_tx_on_off			;		 
	wire							just_receive			;		 
	wire							program_start			;		 
	wire		[15:0]				program_wait_time		;		 
	wire		[15:0]				program_hold_time		;		 
	wire							program_reset			;		 
	wire		[3:0]				radar_mode				;		 
	wire							tx_on_off				;		 
	wire							receive_on				;		 
	wire							serch_or_track			;		 
	wire		[7:0]				current_range_gate		;		 
	wire		[7:0]				switch_range_gate		;		 
	wire		[7:0]				Setup_para_mode			;		 
	wire		[7:0]				current_para_mode		;		 
	wire		[7:0]				subarray_select_mode	;		 
	
	wire        [31:0]              PINC1_near           ;               
    wire        [31:0]              f0_scale_near        ;            
    wire        [31:0]              mu_scale_near        ;             
    wire        [31:0]              f0_scale2_near       ;            
    wire        [31:0]              mu_scale2_near       ;           
    wire        [31:0]              axi_chirp_width_near ;           
    wire        [31:0]              axi_pulse_period_near;           
    wire        [31:0]              pulse_delay          ;                    
	wire        [31:0]              PINC1_far            ;               
    wire        [31:0]              f0_scale_far         ;            
    wire        [31:0]              mu_scale_far         ;             
    wire        [31:0]              f0_scale2_far        ;            
    wire        [31:0]              mu_scale2_far        ;           
    wire        [31:0]              axi_chirp_width_far  ;           
    wire        [31:0]              axi_pulse_period_far ;
    wire        [31:0]              axi_fc_scale_far         ;
    wire        [31:0]              axi_fc_scale_near         ;	
	
	
			
	wire		[15:0]				far_prt_period				;		 
	wire		[31:0]				far_frame_period			;		 
	wire		[15:0]				far_prt_num					;		 
	wire		[15:0]				far_delay_tf_pm			;		 
	wire		[15:0]				far_length_tf_pm		;		 
	wire		[15:0]				far_delay_tf_pc			;		 
	wire		[15:0]				far_length_tf_pc		;		 
	wire		[15:0]				far_delay_tr_k			;		 
	wire		[15:0]				far_length_tr_k			;		 
	wire		[15:0]				far_delay_ADC			;		 
	wire		[15:0]				far_length_ADC			;		 
	wire		[15:0]				far_delay_PhaseRef		;		 
	wire		[15:0]				far_length_PhaseRef		;		 
	wire		[7:0]				far_decim_factor		;		 

	wire		[15:0]				near_prt_period			;		 
	wire		[31:0]				near_frame_period		;		 
	wire		[15:0]				near_prt_num			;		 
	wire		[15:0]				near_delay_tf_pm		;		 
	wire		[15:0]				near_length_tf_pm		;		 
	wire		[15:0]				near_delay_tf_pc		;		 
	wire		[15:0]				near_length_tf_pc		;		 
	wire		[15:0]				near_delay_tr_k			;		 
	wire		[15:0]				near_length_tr_k		;		 
	wire		[15:0]				near_delay_ADC			;		 
	wire		[15:0]				near_length_ADC			;		 
	wire		[15:0]				near_delay_PhaseRef		;		 
	wire		[15:0]				near_length_PhaseRef	;		 
	wire		[7:0]				near_decim_factor		;		 
	
	wire		[15:0]				prt_period				;		 
	wire		[31:0]				frame_period			;		 
	wire		[15:0]				prt_num					;		 
	wire		[15:0]				upc_delay_tf_pm			;		 
	wire		[15:0]				upc_length_tf_pm		;		 
	wire		[15:0]				upc_delay_tf_pc			;		 
	wire		[15:0]				upc_length_tf_pc		;		 
	wire		[15:0]				upc_delay_tr_k			;		 
	wire		[15:0]				upc_length_tr_k			;		 
	wire		[15:0]				upc_delay_ADC			;		 
	wire		[15:0]				upc_length_ADC			;		 
	wire		[15:0]				upc_delay_PhaseRef		;		 
	wire		[15:0]				upc_length_PhaseRef		;	 
	wire		[3:0]				decim_factor			;
	wire		[3:0]				decim_factor_simple			;
	wire		[7:0]				use_PulseCompress		;	 
	
	wire      [31:0]              	upc_PINC1                 ;               
    wire      [31:0]              	upc_f0_scale              ;            
    wire      [31:0]              	upc_mu_scale              ;             
    wire      [31:0]              	upc_f0_scale2             ;            
    wire      [31:0]              	upc_mu_scale2             ;           
    wire      [31:0]              	upc_axi_chirp_width       ;           
    wire      [31:0]              	upc_axi_pulse_period      ;           
    wire      [31:0]              	upc_pulse_delay           ;          
    wire      [31:0]              	upc_fc_scale              ;         
	
	wire      [31:0]              	RefSig_PINC1                 ;               
    wire      [31:0]              	RefSig_f0_scale              ;            
    wire      [31:0]              	RefSig_mu_scale              ;             
    wire      [31:0]              	RefSig_f0_scale2             ;            
    wire      [31:0]              	RefSig_mu_scale2             ;           
    wire      [31:0]              	RefSig_axi_chirp_width       ;           
    wire      [31:0]              	RefSig_axi_pulse_period      ;           
    wire      [31:0]              	RefSig_pulse_delay           ;          
	wire		[31:0]				RefSig_fc_scale				;
	
	
	
    wire [31:0] result_download_length_dout;
    wire [7:0] work_freq_dout;
    wire [15:0] snr_door_dout;
    wire [15:0] RF_on_delay_dout,RF_on_work_dout;	

	 
	wire							receive_en				;		 
	wire							decimate_16				;		 
	wire							far_or_near				;		 


	 
	wire								pc_rst_in			;
	
	
	 

	wire								PhaseRef_k			;		 
	wire								gate_buff_o			;		 
(*keep = "true"*)	wire								frame_ref_ADC		;		 
	wire								prt_ref_ADC		;
	wire								frame_ref_TR		;		 
	wire								TF_status			;		 
	wire								prt_ref			    ;		 
	wire								prt_ref_b1			    ;		 
	wire								frame_ref_b1			;
 
	wire								frame_start				;		 
	wire								gate_buff				;		 
	wire			[15:0]				adc0_dat_i 				;		 
	wire			[15:0]				adc0_dat_q 				;		 
	wire			[15:0]				adc1_dat_i 				;		 
	wire			[15:0]				adc1_dat_q 				;		 
	wire			[15:0]				adc2_dat_i 				;		 
	wire			[15:0]				adc2_dat_q 				;		 
	wire			[15:0]				adc3_dat_i 				;		 
	wire			[15:0]				adc3_dat_q 				;		 
	wire			[15:0]				adc4_dat_i 				;		 
	wire			[15:0]				adc4_dat_q 				;		 
	                                 
	wire			[15:0]				rd_addr					;
	wire								rd_en					;
	wire								frame_ref_fft			;		 
	wire								dout_fft_en				;		 
	wire			[31:0]				dout_fft_ch1			;		 
	wire			[31:0]				dout_fft_ch2			;		 
	wire			[31:0]				dout_fft_ch3			;		 
	wire			[31:0]				dout_fft_ch4			;		 
	wire			[31:0]				dout_fft_ch5			;		 
	wire			[5:0]				All_WaveNum             ;

 
	
	wire			[7:0]				Radar_Status			;
	wire			[31:0]				baud_div				;
	(* KEEP = "true" *)wire			[15:0]              detect_freq_low_near_dout;
	(* KEEP = "true" *)wire			[15:0]              detect_freq_high_near_dout;  
	(* KEEP = "true" *)wire			[15:0]              detect_freq_low_far_dout; 
	(* KEEP = "true" *)wire			[15:0]              detect_freq_high_far_dout; 
	
	(* KEEP = "true" *)wire			[15:0]              max_bomen_dout_before;
	(* KEEP = "true" *)wire			[15:0]              max_bomen_dout_middle;
	(* KEEP = "true" *)wire			[15:0]              max_bomen_dout_after;
	(* KEEP = "true" *)wire			[15:0]              max_freq_dout_before;
	(* KEEP = "true" *)wire			[15:0]              max_freq_dout_middle;
	(* KEEP = "true" *)wire			[15:0]              max_freq_dout_after;
	(* KEEP = "true" *)wire			[15:0]              max_snr_dout_before;
	(* KEEP = "true" *)wire			[15:0]              max_snr_dout_middle;
	(* KEEP = "true" *)wire			[15:0]              max_snr_dout_after;
	(* KEEP = "true" *)wire			[15:0]              max_IQ_ch1_dout;
	(* KEEP = "true" *)wire			[15:0]              max_IQ_ch2_dout;
	(* KEEP = "true" *)wire			[15:0]              max_IQ_ch3_dout;
	(* KEEP = "true" *)wire			[15:0]              max_IQ_ch4_dout;
	(* KEEP = "true" *)wire			[15:0]              max_IQ_ch5_dout;
	(* KEEP = "true" *)wire			[15:0]              ref_phase_ch1_dout;
	(* KEEP = "true" *)wire			[15:0]              ref_phase_ch2_dout;
	(* KEEP = "true" *)wire			[15:0]              ref_phase_ch3_dout;
	(* KEEP = "true" *)wire			[15:0]              ref_phase_ch4_dout;
	(* KEEP = "true" *)wire			[15:0]              ref_phase_ch5_dout;
	(* KEEP = "true" *)wire                             max_dout_en;
	(* KEEP = "true" *)wire [5:0]                       max_bomen_dout;
	(* KEEP = "true" *)wire [9:0]                       max_freq_dout;
	(* KEEP = "true" *)wire [15:0]                      max_snr_dout;
	wire					fft_refresh		;	
	(* KEEP = "true" *)wire [31:0]                      fft_result_bomen_before;
	(* KEEP = "true" *)wire [31:0]                      fft_result_bomen_middle;
	(* KEEP = "true" *)wire [31:0]                      fft_result_bomen_after;
	(* KEEP = "true" *)wire [31:0]                      fft_result_freq_before;
	(* KEEP = "true" *)wire [31:0]                      fft_result_freq_after;
	
 
 

(* KEEP = "true" *)wire 	[12:0] 						pcPara_bram_addr	; 	 
(* KEEP = "true" *)    wire 								pcPara_bram_clk		;    
(* KEEP = "true" *)wire 								pcPara_bram_en		;     
(* KEEP = "true" *)    wire 								pcPara_bram_rst		;    
(* KEEP = "true" *)wire 	[3:0] 						pcPara_bram_we		;     
(* KEEP = "true" *)wire 	[31:0] 						pcPara_bram_wrdata	;       
(* KEEP = "true" *)wire 	[31:0] 						pcPara_bram_rddata	;  
    wire 	[15:0] 						gpio_in				;  
    wire 	[15:0] 						gpio_out			;  
	(* KEEP = "true" *) wire 								ps_int				;  	 
    (* KEEP = "true" *) wire 								target_state		;  	 
    (* KEEP = "true" *) wire 								target_state_out		;  	 
    (* KEEP = "true" *) wire 	[1:0]						detect_phase_state  ;  	 
    (* KEEP = "true" *) wire								start_gen_refsig	;	
	(* KEEP = "true" *) wire								refsig_en			;
	(* KEEP = "true" *) wire 	[15:0]						zhen_cnt			;  	 

	
(* KEEP = "true" *)    	wire 	[12:0] 						ToDT_bram_addr		; 	 
(* KEEP = "true" *)    	wire 								ToDT_bram_clk		;    
(* KEEP = "true" *)    	wire 								ToDT_bram_en		;     
(* KEEP = "true" *)    	wire 								ToDT_bram_rst		;    
(* KEEP = "true" *)    	wire 	[3:0] 						ToDT_bram_we		;     
(* KEEP = "true" *)    	wire 	[31:0] 						ToDT_bram_wrdata	;       
 

(* KEEP = "true" *)    	wire 	[12:0] 						ToFK_bram_addr		; 	 
(* KEEP = "true" *)    	wire 								ToFK_bram_clk		;    
(* KEEP = "true" *)    	wire 								ToFK_bram_en		;     
(* KEEP = "true" *)    	wire 								ToFK_bram_rst		;    
(* KEEP = "true" *)    	wire 	[3:0] 						ToFK_bram_we		;     
(* KEEP = "true" *)    	wire 	[31:0] 						ToFK_bram_wrdata	;       
 

(* KEEP = "true" *)    	wire 	[12:0] 						FromFK_bram_addr		; 	 
(* KEEP = "true" *)    	wire 								FromFK_bram_clk		;    
(* KEEP = "true" *)    	wire 								FromFK_bram_en		;     
(* KEEP = "true" *)    	wire 								FromFK_bram_rst		;    
(* KEEP = "true" *)    	wire 	[3:0] 						FromFK_bram_we		;     
(* KEEP = "true" *)    	wire 	[31:0] 						FromFK_bram_wrdata	;       
(* KEEP = "true" *)    	wire 	[31:0] 						FromFK_bram_rddata	;  
(* KEEP = "true" *)		wire				 Irq_FromFK;

 
wire        pc_tx_on_off_u5;
wire        just_receive_u5;
wire        pc_rst_in_u5;
wire        program_start_u5;
wire        program_reset_u5;
wire [1:0] detect_phase_state_u5;
wire [7:0] work_freq_dout_u5;
wire [7:0] Setup_para_mode_u5;
wire [7:0] subarray_select_mode_u5;
wire [7:0] use_PulseCompress_u5;
wire [7:0] switch_range_gate_u5;
wire [7:0] far_decim_factor_u5;
wire [7:0] near_decim_factor_u5;
wire [31:0] result_download_length_dout_u5;
wire [31:0] baud_div_u5;
wire [31:0] PINC1_near_u5;
wire [31:0] f0_scale_near_u5;
wire [31:0] mu_scale_near_u5;
wire [31:0] f0_scale2_near_u5;
wire [31:0] mu_scale2_near_u5;
wire [31:0] axi_chirp_width_near_u5;
wire [31:0] axi_pulse_period_near_u5;
wire [31:0] pulse_delay_u5;
wire [31:0] PINC1_far_u5;
wire [31:0] f0_scale_far_u5;
wire [31:0] mu_scale_far_u5;
wire [31:0] f0_scale2_far_u5;
wire [31:0] mu_scale2_far_u5;
wire [31:0] axi_chirp_width_far_u5;
wire [31:0] axi_pulse_period_far_u5;
wire [31:0] axi_fc_scale_far_u5;
wire [31:0] axi_fc_scale_near_u5;
wire [15:0] near_prt_period_u5;
wire [15:0] near_prt_num_u5;
wire [15:0] near_delay_tf_pm_u5;
wire [15:0] near_length_tf_pm_u5;
wire [15:0] near_delay_tf_pc_u5;
wire [15:0] near_length_tf_pc_u5;
wire [15:0] near_delay_tr_k_u5;
wire [15:0] near_length_tr_k_u5;
wire [15:0] near_delay_ADC_u5;
wire [15:0] near_length_ADC_u5;
wire [15:0] near_delay_PhaseRef_u5;
wire [15:0] near_length_PhaseRef_u5;
wire [15:0] far_prt_period_u5;
wire [15:0] far_prt_num_u5;
wire [15:0] far_delay_tf_pm_u5;
wire [15:0] far_length_tf_pm_u5;
wire [15:0] far_delay_tf_pc_u5;
wire [15:0] far_length_tf_pc_u5;
wire [15:0] far_delay_tr_k_u5;
wire [15:0] far_length_tr_k_u5;
wire [15:0] far_delay_ADC_u5;
wire [15:0] far_length_ADC_u5;
wire [15:0] far_delay_PhaseRef_u5;
wire [15:0] far_length_PhaseRef_u5;
wire [15:0] snr_door_dout_u5;
wire [15:0] detect_freq_low_near_dout_u5;
wire [15:0] detect_freq_high_near_dout_u5;
wire [15:0] detect_freq_low_far_dout_u5;
wire [15:0] detect_freq_high_far_dout_u5;
wire [15:0] RF_on_delay_dout_u5;
wire [15:0] RF_on_work_dout_u5;
wire [31:0] near_frame_period_u5;
wire [31:0] far_frame_period_u5;


 

     
    assign uart_RF_re = gpio_out[0];	
    assign uart_RF_de = gpio_out[1];wire pl_clk;


	assign AGC_1DB_F        =0;
	assign AGC_2DB_F        =0;
	assign AGC_4DB_F        =0;
	assign AGC_8DB_F        =0;
	assign AGC_16DB_F       =0;

 
    wire               					clk_400M;
    wire               					m_axis_tvalid_converter;	 
    wire   [255:0]     					m_axis_tdata_converter;
    wire   [255:0]     					rf_tdata_in;
    wire               					RefSig_tvalid_converter;	 
(* KEEP = "true" *)    wire   [255:0]     					RefSig_tdata_converter;
(* KEEP = "true" *)    wire   [255:0]     					RefSig_tdata_in;
	assign rf_tdata_in = (m_axis_tvalid_converter && tx_on_off ) ? m_axis_tdata_converter: 256'd0;
	assign RefSig_tdata_in = (RefSig_tvalid_converter && refsig_en && PhaseRef_k) ? RefSig_tdata_converter: 256'd0;
	assign Radar_Status = {current_para_mode[0],CH_CHOOSE[0],tx_on_off,receive_en,refsig_en,3'h0};
	assign target_state_out = (receive_en)? target_state : 1'b0;

 
	assign RefSig_PINC1						= 32'd0	;              
	assign RefSig_f0_scale                  = 32'hce6303cf;
	assign RefSig_mu_scale                  = 32'd0	;
	assign RefSig_f0_scale2                 = 32'h5673181e;
	assign RefSig_mu_scale2                 = 32'd0	;
	assign RefSig_axi_chirp_width           = 32'hffff_ffff	;		 
	assign RefSig_axi_pulse_period          = 32'd0	;
	assign RefSig_pulse_delay               = 32'd0	;
	assign RefSig_fc_scale					= 32'd0;				 
	
	
	
     

	
 
 
   BUFGCE #(
      .CE_TYPE              (   "SYNC"                  ),                
      .IS_CE_INVERTED       (   1'b0                    ),           
      .IS_I_INVERTED        (   1'b0                    ),            
      .SIM_DEVICE           (   "ULTRASCALE_PLUS"       )   
   )
   BUFGCE_inst (
      .O                    (   clk_50m_new             ),    
      .CE                   (   1'b1                    ),  
      .I                    (   clk_50m                 )     
   );

    clk_wiz_0 clk_wiz_0_inst
   (
     
    .clk_out1               (   clk_100m                ),      
    .clk_out2               (   clk_50m_sys             ),      
     
    .locked                 (   locked                  ),        
    
    .clk_in1                (   clk_50m_new             )       
);
 

    clk_spi_ge  clk_spi_ge_1MHz(
     .sys_rst_n             (   locked                  ), 
     .sys_clk               (   clk_50m_sys             ), 
     .clk_spi_out           (   clk_spi_1M              )  
           );
 
LMK04828_config  LMK04828_config_inst(
    .clk_1M                     (   clk_spi_1M                  ),  
    .sys_rst                    (   (~locked)                   ),  
    .clk_50m                    (   clk_50m_sys                 ),  
    .sleep_order                (   1'b0                        ),  
    .LMK_ADC_SCLK               (   LMK_dac_SCLK                ),  
    .LMK_ADC_SDIO               (   LMK_dac_SDIO                ),  
    .LMK_ADC_CS                 (   LMK_dac_CS                  ),  
    .lmk04828_rst               (   LMK_dac_rst                 ),  
    .LMK04828_SYNC              (   LMK04828_SYNC               ),
    .lmk_cfg_LOCKED             (   lmk_cfg_LOCKED              ),  
    .lmk_cfg_finish             (   lmk_cfg_finish              )   
    );
 

 

  IBUFDS i_glblclk_ibufds (
    .I                          (   glblclkp                    ),
    .IB                         (   glblclkn                    ),
    .O                          (   glblclk_i                   )
  );
  BUFG glbl_bufg_i
  (
    .O                          (   glblclk_pll                ),
    .I                          (   glblclk_i                   )
  );
   IBUFDS sysref_ibufds (
    .I                          (   sysref_p                    ),			 
    .IB                         (   sysref_n                    ),
    .O                          (   sysref                      )
  );
    BUFG glbl_bufg_inst_pl
  (
    .O                          (   clk_pl_fbin                 ),
    .I                          (   clk_pl_fbout                )
  );

 
cfg_si5341  cfg_si5341_INST(
    .clk_1M						(	clk_spi_1M					), 
    .sys_rst					(	~locked						), 
    .clk_50m					(	clk_50m_sys					), 
    .dac_sclk					(	si5341_sclk					), 
    .dac_sden					(	si5341_csb					), 
    .dac_sdio					(	si5341_sdio					), 
    .dac_sdo					(	si5341_sdo					), 
    .dac_reset					(	), 
		
    .dac_cfg_done				(	si5341_cfg_done				), 
    .direction_ctl				(	),							 
    .dac_read_out1				(	),							 
    .dac_read_out2				(	),							 
    .dac_spi_rdy				(	) 							 
);
 


PL_SYS_CLK PL_SYS_CLK_INST
   (
    .clkfb_in                   (   clk_pl_fbin                 ),  
     
    .clk_out1					(	clk_200M					),      
    .clk_out2					(	clk_250M					),      
    .clk_out3					(	clk_500M					),      
    .clkfb_out                  (   clk_pl_fbout                ),  
     
    .reset                      (   ~lmk_cfg_LOCKED             ),  
    .locked                     (   glblclk_locked            ),  
    
    .clk_in1                    (   glblclk_pll                )   
);

Gen_Sys_Rst U_SysRst_Ctrl(
	.clk_in						(	clk_250M					),	 
	.locked_in					(	glblclk_locked			),	 
	.locked						(	rf_clk_locked				),	 
	.pc_rst_in					(	pc_rst_in					),	 
	.sys_rst					(	sys_rst				),	 
	.sys_rst_n					(	sys_rst_n				)	 

    );

Rst_Sync U_rst_sync_100m(
    .clk                            (   clk_100m                ),
    .arst                           (   sys_rst                 ),
    .rst                            (   sys_rst_100m            ),
    .rst_n                          (   sys_rst_n_100m          )
);
 
	 
	 
	 

     
	   
 Processor_Ctrl U3_Processor_Ctrl(
	.clk								(	clk_250M				)	,	 
	.rst								(	sys_rst					)	,    
	.pc_tx_on_off						(	pc_tx_on_off			),		 
	.just_receive						(	just_receive			),		 
	.program_start						(program_start			),		 
	.program_wait_time					(program_wait_time		),		 
	.program_hold_time					(program_hold_time		),		 
	.program_reset						(program_reset			),		 
	.radar_mode							(radar_mode				),		 
	.tx_on_off							(	tx_on_off				),		 
	.receive_on							(	receive_en				),	 
	.serch_or_track						(serch_or_track			),		 
	.current_range_gate					(current_range_gate		),		 
	.switch_range_gate					(	switch_range_gate		),		 
	.Setup_para_mode					(Setup_para_mode		)	,	 
	.detect_phase_state					(	detect_phase_state		),		
	.start_gen_refsig					(	start_gen_refsig		),
	.refsig_en							(	refsig_en				),
	.current_para_mode					(current_para_mode		),		 
	.far_or_near						(	far_or_near			),
	.subarray_select_mode				(	subarray_select_mode	)	,
	.subarray_select					(	CH_CHOOSE			)	,		 
	.frame_ref							(		frame_ref_b1		),			 
	.far_prt_period						(	far_prt_period				),
    .far_frame_period                   (	far_frame_period           ),
    .far_prt_num		                (	far_prt_num		        ),
	.far_delay_tf_pm					(	far_delay_tf_pm		)	,	 
	.far_length_tf_pm					(	far_length_tf_pm		),		 
	.far_delay_tf_pc					(	far_delay_tf_pc		)	,	 
	.far_length_tf_pc					(	far_length_tf_pc		),		 
	.far_delay_tr_k						(	far_delay_tr_k			),		 
	.far_length_tr_k					(	far_length_tr_k		)	,	 
	.far_delay_ADC						(	far_delay_ADC			),		 
	.far_length_ADC						(	far_length_ADC			),		 
	.far_delay_PhaseRef					(	far_delay_PhaseRef		),		 
	.far_length_PhaseRef				(	far_length_PhaseRef	)	,	 
	.far_decim_factor					(	far_decim_factor		) ,

	.near_prt_period					(	near_prt_period				),
    .near_frame_period                  (	near_frame_period           ),
    .near_prt_num		                (	near_prt_num		        ),
	.near_delay_tf_pm					(	near_delay_tf_pm		),		 
	.near_length_tf_pm					(	near_length_tf_pm		),		 
	.near_delay_tf_pc					(	near_delay_tf_pc		),		 
	.near_length_tf_pc					(	near_length_tf_pc		),		 
	.near_delay_tr_k					(	near_delay_tr_k		)	,	 
	.near_length_tr_k					(	near_length_tr_k		),		 
	.near_delay_ADC						(	near_delay_ADC			),		 
	.near_length_ADC					(	near_length_ADC		)	,	 
	.near_delay_PhaseRef				(	near_delay_PhaseRef	)	,	 
	.near_length_PhaseRef				(	near_length_PhaseRef	),		 
	.near_decim_factor					(	near_decim_factor		) ,
	.PINC1_near                         (   PINC1_near              ),            
    .f0_scale_near                      (   f0_scale_near           ),            
    .mu_scale_near                      (   mu_scale_near           ),            
    .f0_scale2_near                     (   f0_scale2_near          ),            
    .mu_scale2_near                     (   mu_scale2_near          ),            
    .axi_chirp_width_near               (   axi_chirp_width_near    ),            
    .axi_pulse_period_near              (   axi_pulse_period_near   ),            
    .pulse_delay                        (   pulse_delay             ),            
	.PINC1_far                          (   PINC1_far               ),            
    .f0_scale_far                       (   f0_scale_far            ),            
    .mu_scale_far                       (   mu_scale_far            ),            
    .f0_scale2_far                      (   f0_scale2_far           ),            
    .mu_scale2_far                      (   mu_scale2_far           ),            
    .axi_fc_scale_near                  (   axi_fc_scale_near            ),           
    .axi_fc_scale_far                   (   axi_fc_scale_far            ),           

    .axi_chirp_width_far                (   axi_chirp_width_far     ),           
    .axi_pulse_period_far               (   axi_pulse_period_far    ),           
	.prt_period							(	prt_period				),
    .frame_period                       (	frame_period           ),
    .prt_num		                    (	prt_num		        ),
	.decim_factor						(	decim_factor_simple		) ,

	.upc_delay_tf_pm					(	upc_delay_tf_pm			),	 
	.upc_length_tf_pm					(	upc_length_tf_pm		),	 
	.upc_delay_tf_pc					(	upc_delay_tf_pc			),	 
	.upc_length_tf_pc					(	upc_length_tf_pc		),	 
	.upc_delay_tr_k						(	upc_delay_tr_k			),	 
	.upc_length_tr_k					(	upc_length_tr_k			),	 
	.upc_delay_ADC						(	upc_delay_ADC			),	 
	.upc_length_ADC						(	upc_length_ADC			),	 
	.upc_delay_PhaseRef					(	upc_delay_PhaseRef		),	 
	.upc_length_PhaseRef				(	upc_length_PhaseRef	    ),		 
	
	.upc_PINC1                          (   upc_PINC1               ),               
    .upc_f0_scale                       (   upc_f0_scale            ),            
    .upc_mu_scale                       (   upc_mu_scale            ),             
    .upc_f0_scale2                      (   upc_f0_scale2           ),            
    .upc_mu_scale2                      (   upc_mu_scale2           ),           
    .upc_axi_chirp_width                (   upc_axi_chirp_width     ),           
    .upc_axi_pulse_period               (   upc_axi_pulse_period    ),           
    .upc_pulse_delay                    (   upc_pulse_delay         ),              
    .upc_fc_scale                       (   upc_fc_scale         )               
	
								 															
    );                           
	                             
 RF_Timer U4_RF_Timer(           
	.clk						 		(	clk_250M				)	,		 
	.rst						 		(	sys_rst					)	,		 
	.tx_on_off					 		(	tx_on_off				),			 
	.receive_en							(	receive_en				),		 
	.decimate_16						(    decimate_16			)	,		 
	.far_or_near						(    far_or_near			)	,		 
	.upc_delay_tf_pm					(	upc_delay_tf_pm			)	,	 
	.upc_length_tf_pm					(	upc_length_tf_pm		),		 
	.upc_delay_tf_pc					(	upc_delay_tf_pc			)	,	 
	.upc_length_tf_pc					(	upc_length_tf_pc		),		 
	.upc_delay_tr_k						(	upc_delay_tr_k			),		 
	.upc_length_tr_k					(	upc_length_tr_k			)	,	 
	.upc_delay_ADC						(	upc_delay_ADC			),		 
	.upc_length_ADC						(	upc_length_ADC			),		 
	.upc_delay_PhaseRef					(	upc_delay_PhaseRef		),		 
	.upc_length_PhaseRef				(	upc_length_PhaseRef		)	,	 
	.prt_period							(	prt_period				),
    .frame_period                       (	frame_period           	),
    .prt_num		                    (	prt_num	    	        ),
	.TF_pm								(	TF_pm					),		 
	.TF_pc								(	TF_pc					),		 
	.TR_k								(	TR_k					),		 
	.PhaseRef_k							(   PhaseRef_k				),			 
	.gate_buff_o						(   gate_buff_o				)	,		 
	.frame_ref_buff						(   frame_ref_ADC			),			 
	.prt_ref_buff						(	prt_ref_ADC			),			 
	.frame_ref							(	frame_ref_TR			),			 
	.TF_status							(   TF_status				),			 
	.prt_ref							(   prt_ref					),			 
	.prt_ref_b1							(	prt_ref_b1				),	
	.frame_ref_b1					    (	frame_ref_b1            )
);	


    Analysis_RadarParameter U5_Analysis_RadarParameter
   (
    .sys_clk							(	clk_250M				) ,  		 
    .bram_clk							(	pcPara_bram_clk			) ,  		 
	.bram_rst							(	pcPara_bram_rst			) ,			 
    .rst								(	sys_rst						) ,  		 
    .bram_addr							(	pcPara_bram_addr		) ,  		 
    .bram_en							(	pcPara_bram_en			) ,  		 
    .bram_we							(	pcPara_bram_we			) ,  		 
    .bram_wrdata						(	pcPara_bram_wrdata		) ,  		 
    .bram_rddata						(	pcPara_bram_rddata		) ,  		 
	.pc_tx_on_off						(	pc_tx_on_off_u5			) ,  		 
    .just_receive						(	just_receive_u5			) ,  		 
    .detect_phase_state 				(	detect_phase_state_u5		) ,  		 
    .pc_in_rst							(	pc_rst_in_u5				) ,  		 
    .result_download_length_dout		(result_download_length_dout_u5) ,  		 
    .work_freq_dout						(work_freq_dout_u5				) ,  		 
    .PRT_near_dout						(	near_prt_period_u5			) ,  		 
    .frame_near_period_dout				(	near_frame_period_u5   	) ,  		 
    .frame_near_pulse_dout				(	near_prt_num_u5			) ,  		 
    .TF_near_mod_delay_dout				(	near_delay_tf_pm_u5		) ,  		 
    .TF_near_mod_width_dout				(	near_length_tf_pm_u5		) ,  		 
    .TF_near_pw_delay_dout				(	near_delay_tf_pc_u5		) ,  		 
    .TF_near_pw_width_dout				(	near_length_tf_pc_u5		) ,  		 
    .TR_near_delay_dout					(	near_delay_tr_k_u5			) ,  		 
    .TR_near_width_dout					(	near_length_tr_k_u5		) ,  		 
    .ADC_near_delay_dout				(	near_delay_ADC_u5			) ,  		 
    .ADC_near_width_dout				(	near_length_ADC_u5			) ,  		 
    .phase_near_delay_dout				(	near_delay_PhaseRef_u5		) ,  		 
    .phase_near_width_dout				(	near_length_PhaseRef_u5	) ,  		 
    .far_decim_factor_dout				(	far_decim_factor_u5		) ,
	.PRT_far_dout						(	far_prt_period_u5			) ,  		 
    .frame_far_period_dout				(	far_frame_period_u5		) ,  		 
    .frame_far_pulse_dout				(	far_prt_num_u5				) ,  		 
    .TF_far_mod_delay_dout				(	far_delay_tf_pm_u5			) ,  		 
    .TF_far_mod_width_dout				(	far_length_tf_pm_u5		) ,  		 
    .TF_far_pw_delay_dout				(	far_delay_tf_pc_u5			) ,  		 
    .TF_far_pw_width_dout				(	far_length_tf_pc_u5		) ,  		 
    .TR_far_delay_dout					(	far_delay_tr_k_u5			) ,  		 
    .TR_far_width_dout					(	far_length_tr_k_u5			) ,  		 
    .ADC_far_delay_dout					(	far_delay_ADC_u5			) ,  		 
    .ADC_far_width_dout					(	far_length_ADC_u5			) ,  		 
    .phase_far_delay_dout				(	far_delay_PhaseRef_u5		) ,  		 
    .phase_far_width_dout				(	far_length_PhaseRef_u5		) ,  		 
    .near_decim_factor_dout				(	near_decim_factor_u5		) ,
    .snr_door_dout						(	snr_door_dout_u5				) ,  		 
    .detect_freq_low_near_dout			(	detect_freq_low_near_dout_u5	) ,  		 
    .detect_freq_high_near_dout			(	detect_freq_high_near_dout_u5	) ,  		 
    .detect_freq_low_far_dout			(	detect_freq_low_far_dout_u5	) ,  		 
    .detect_freq_high_far_dout			(	detect_freq_high_far_dout_u5	) ,  		 
    .RF_on_delay_dout					(RF_on_delay_dout_u5			) ,  		 
    .RF_on_work_dout					(RF_on_work_dout_u5			) ,  		 
    .uart_baud_rate_dout				(	baud_div_u5				) ,  		 
    .mode_switch_distance_dout			(	switch_range_gate_u5		) ,  		 
	.program_start						(program_start_u5				) ,  		 
	.program_reset						(program_reset_u5				) ,  		 
	.Setup_para_mode					(Setup_para_mode_u5			) ,	 		 
	.subarray_select_mode				(	subarray_select_mode_u5	) ,			 
	.PINC1_near_dout                    (  PINC1_near_u5           ),               
    .f0_scale_near_dout                 (  f0_scale_near_u5        ),            
    .mu_scale_near_dout                 (  mu_scale_near_u5        ),             
    .f0_scale2_near_dout                (  f0_scale2_near_u5       ),            
    .mu_scale2_near_dout                (  mu_scale2_near_u5       ),           
    .axi_chirp_width_near_dout          (  axi_chirp_width_near_u5 ),           
    .axi_pulse_period_near_dout         (  axi_pulse_period_near_u5),           
    .pulse_delay_dout                   (  pulse_delay_u5          ),                    
	.PINC1_far_dout                     (  PINC1_far_u5            ),               
    .f0_scale_far_dout                  (  f0_scale_far_u5         ),            
    .mu_scale_far_dout                  (  mu_scale_far_u5         ),             
    .f0_scale2_far_dout                 (  f0_scale2_far_u5        ),            
    .mu_scale2_far_dout                 (  mu_scale2_far_u5        ),           
    .axi_chirp_width_far_dout           (  axi_chirp_width_far_u5  ),           
    .axi_pulse_period_far_dout          (  axi_pulse_period_far_u5 ),          
    .axi_fc_scale_far_dout              (  axi_fc_scale_far_u5),
    .axi_fc_scale_near_dout             (  axi_fc_scale_near_u5),

    .zhen_cnt                           ( zhen_cnt              ),                           
    .CH_CHOOSE                          ( CH_CHOOSE[0]          ),                           
	.use_PulseCompress					(	use_PulseCompress_u5	),		 
    .target_state                       (   target_state_out          ),                           
    .max_bomen_dout                     ( max_bomen_dout        ),
    .max_freq_dout                      ( max_freq_dout         ),
    .max_snr_dout                       ( max_snr_dout          ),
    .fft_result_bomen_before            ( fft_result_bomen_before),
    .fft_result_bomen_middle            ( fft_result_bomen_middle),
    .fft_result_bomen_after             ( fft_result_bomen_after),
    .fft_result_freq_before             ( fft_result_freq_before),
    .fft_result_freq_after              ( fft_result_freq_after ), 
    .max_bomen_dout_before              (max_bomen_dout_before  ),              
    .max_bomen_dout_middle              (max_bomen_dout_middle  ),              
    .max_bomen_dout_after               (max_bomen_dout_after   ),               
    .max_freq_dout_before               (max_freq_dout_before   ),               
    .max_freq_dout_middle               (max_freq_dout_middle   ),               
    .max_freq_dout_after                (max_freq_dout_after    ),                
    .max_snr_dout_before                (max_snr_dout_before    ),                
    .max_snr_dout_middle                (max_snr_dout_middle    ),                
    .max_snr_dout_after                 (max_snr_dout_after     ),                 
    .max_IQ_ch1_dout                    (max_IQ_ch1_dout        ),                    
    .max_IQ_ch2_dout                    (max_IQ_ch2_dout        ),                    
    .max_IQ_ch3_dout                    (max_IQ_ch3_dout        ),                    
    .max_IQ_ch4_dout                    (max_IQ_ch4_dout        ),                    
    .max_IQ_ch5_dout                    (max_IQ_ch5_dout        ),                    
    .ref_phase_ch1_dout                 (ref_phase_ch1_dout     ),                 
    .ref_phase_ch2_dout                 (ref_phase_ch2_dout     ),                 
    .ref_phase_ch3_dout                 (ref_phase_ch3_dout     ),                 
    .ref_phase_ch4_dout                 (ref_phase_ch4_dout     ),                 
    .ref_phase_ch5_dout                 (ref_phase_ch5_dout     )                  
    );
RadarParameter_OutputDelay U5_RadarParameter_OutputDelay (
    .clk                                (   clk_250M                ),
    .pc_tx_on_off_in                    (   pc_tx_on_off_u5 ),
    .pc_tx_on_off_out                   (   pc_tx_on_off ),
    .just_receive_in                    (   just_receive_u5 ),
    .just_receive_out                   (   just_receive ),
    .pc_rst_in_in                       (   pc_rst_in_u5 ),
    .pc_rst_in_out                      (   pc_rst_in ),
    .program_start_in                   (   program_start_u5 ),
    .program_start_out                  (   program_start ),
    .program_reset_in                   (   program_reset_u5 ),
    .program_reset_out                  (   program_reset ),
    .detect_phase_state_in              (   detect_phase_state_u5 ),
    .detect_phase_state_out             (   detect_phase_state ),
    .work_freq_dout_in                  (   work_freq_dout_u5 ),
    .work_freq_dout_out                 (   work_freq_dout ),
    .Setup_para_mode_in                 (   Setup_para_mode_u5 ),
    .Setup_para_mode_out                (   Setup_para_mode ),
    .subarray_select_mode_in            (   subarray_select_mode_u5 ),
    .subarray_select_mode_out           (   subarray_select_mode ),
    .use_PulseCompress_in               (   use_PulseCompress_u5 ),
    .use_PulseCompress_out              (   use_PulseCompress ),
    .switch_range_gate_in               (   switch_range_gate_u5 ),
    .switch_range_gate_out              (   switch_range_gate ),
    .far_decim_factor_in                (   far_decim_factor_u5 ),
    .far_decim_factor_out               (   far_decim_factor ),
    .near_decim_factor_in               (   near_decim_factor_u5 ),
    .near_decim_factor_out              (   near_decim_factor ),
    .result_download_length_dout_in     (   result_download_length_dout_u5 ),
    .result_download_length_dout_out    (   result_download_length_dout ),
    .baud_div_in                        (   baud_div_u5 ),
    .baud_div_out                       (   baud_div ),
    .PINC1_near_in                      (   PINC1_near_u5 ),
    .PINC1_near_out                     (   PINC1_near ),
    .f0_scale_near_in                   (   f0_scale_near_u5 ),
    .f0_scale_near_out                  (   f0_scale_near ),
    .mu_scale_near_in                   (   mu_scale_near_u5 ),
    .mu_scale_near_out                  (   mu_scale_near ),
    .f0_scale2_near_in                  (   f0_scale2_near_u5 ),
    .f0_scale2_near_out                 (   f0_scale2_near ),
    .mu_scale2_near_in                  (   mu_scale2_near_u5 ),
    .mu_scale2_near_out                 (   mu_scale2_near ),
    .axi_chirp_width_near_in            (   axi_chirp_width_near_u5 ),
    .axi_chirp_width_near_out           (   axi_chirp_width_near ),
    .axi_pulse_period_near_in           (   axi_pulse_period_near_u5 ),
    .axi_pulse_period_near_out          (   axi_pulse_period_near ),
    .pulse_delay_in                     (   pulse_delay_u5 ),
    .pulse_delay_out                    (   pulse_delay ),
    .PINC1_far_in                       (   PINC1_far_u5 ),
    .PINC1_far_out                      (   PINC1_far ),
    .f0_scale_far_in                    (   f0_scale_far_u5 ),
    .f0_scale_far_out                   (   f0_scale_far ),
    .mu_scale_far_in                    (   mu_scale_far_u5 ),
    .mu_scale_far_out                   (   mu_scale_far ),
    .f0_scale2_far_in                   (   f0_scale2_far_u5 ),
    .f0_scale2_far_out                  (   f0_scale2_far ),
    .mu_scale2_far_in                   (   mu_scale2_far_u5 ),
    .mu_scale2_far_out                  (   mu_scale2_far ),
    .axi_chirp_width_far_in             (   axi_chirp_width_far_u5 ),
    .axi_chirp_width_far_out            (   axi_chirp_width_far ),
    .axi_pulse_period_far_in            (   axi_pulse_period_far_u5 ),
    .axi_pulse_period_far_out           (   axi_pulse_period_far ),
    .axi_fc_scale_far_in                (   axi_fc_scale_far_u5 ),
    .axi_fc_scale_far_out               (   axi_fc_scale_far ),
    .axi_fc_scale_near_in               (   axi_fc_scale_near_u5 ),
    .axi_fc_scale_near_out              (   axi_fc_scale_near ),
    .near_prt_period_in                 (   near_prt_period_u5 ),
    .near_prt_period_out                (   near_prt_period ),
    .near_prt_num_in                    (   near_prt_num_u5 ),
    .near_prt_num_out                   (   near_prt_num ),
    .near_delay_tf_pm_in                (   near_delay_tf_pm_u5 ),
    .near_delay_tf_pm_out               (   near_delay_tf_pm ),
    .near_length_tf_pm_in               (   near_length_tf_pm_u5 ),
    .near_length_tf_pm_out              (   near_length_tf_pm ),
    .near_delay_tf_pc_in                (   near_delay_tf_pc_u5 ),
    .near_delay_tf_pc_out               (   near_delay_tf_pc ),
    .near_length_tf_pc_in               (   near_length_tf_pc_u5 ),
    .near_length_tf_pc_out              (   near_length_tf_pc ),
    .near_delay_tr_k_in                 (   near_delay_tr_k_u5 ),
    .near_delay_tr_k_out                (   near_delay_tr_k ),
    .near_length_tr_k_in                (   near_length_tr_k_u5 ),
    .near_length_tr_k_out               (   near_length_tr_k ),
    .near_delay_ADC_in                  (   near_delay_ADC_u5 ),
    .near_delay_ADC_out                 (   near_delay_ADC ),
    .near_length_ADC_in                 (   near_length_ADC_u5 ),
    .near_length_ADC_out                (   near_length_ADC ),
    .near_delay_PhaseRef_in             (   near_delay_PhaseRef_u5 ),
    .near_delay_PhaseRef_out            (   near_delay_PhaseRef ),
    .near_length_PhaseRef_in            (   near_length_PhaseRef_u5 ),
    .near_length_PhaseRef_out           (   near_length_PhaseRef ),
    .far_prt_period_in                  (   far_prt_period_u5 ),
    .far_prt_period_out                 (   far_prt_period ),
    .far_prt_num_in                     (   far_prt_num_u5 ),
    .far_prt_num_out                    (   far_prt_num ),
    .far_delay_tf_pm_in                 (   far_delay_tf_pm_u5 ),
    .far_delay_tf_pm_out                (   far_delay_tf_pm ),
    .far_length_tf_pm_in                (   far_length_tf_pm_u5 ),
    .far_length_tf_pm_out               (   far_length_tf_pm ),
    .far_delay_tf_pc_in                 (   far_delay_tf_pc_u5 ),
    .far_delay_tf_pc_out                (   far_delay_tf_pc ),
    .far_length_tf_pc_in                (   far_length_tf_pc_u5 ),
    .far_length_tf_pc_out               (   far_length_tf_pc ),
    .far_delay_tr_k_in                  (   far_delay_tr_k_u5 ),
    .far_delay_tr_k_out                 (   far_delay_tr_k ),
    .far_length_tr_k_in                 (   far_length_tr_k_u5 ),
    .far_length_tr_k_out                (   far_length_tr_k ),
    .far_delay_ADC_in                   (   far_delay_ADC_u5 ),
    .far_delay_ADC_out                  (   far_delay_ADC ),
    .far_length_ADC_in                  (   far_length_ADC_u5 ),
    .far_length_ADC_out                 (   far_length_ADC ),
    .far_delay_PhaseRef_in              (   far_delay_PhaseRef_u5           ),
    .far_delay_PhaseRef_out             (   far_delay_PhaseRef              ),
    .far_length_PhaseRef_in             (   far_length_PhaseRef_u5          ),
    .far_length_PhaseRef_out            (   far_length_PhaseRef             ),
    .snr_door_dout_in                   (   snr_door_dout_u5                ),
    .snr_door_dout_out                  (   snr_door_dout                   ),
    .detect_freq_low_near_dout_in       (   detect_freq_low_near_dout_u5    ),
    .detect_freq_low_near_dout_out      (   detect_freq_low_near_dout       ),
    .detect_freq_high_near_dout_in      (   detect_freq_high_near_dout_u5   ),
    .detect_freq_high_near_dout_out     (   detect_freq_high_near_dout      ),
    .detect_freq_low_far_dout_in        (   detect_freq_low_far_dout_u5      ),
    .detect_freq_low_far_dout_out       (   detect_freq_low_far_dout        ),
    .detect_freq_high_far_dout_in       (   detect_freq_high_far_dout_u5    ),
    .detect_freq_high_far_dout_out      (   detect_freq_high_far_dout       ),
    .RF_on_delay_dout_in                (   RF_on_delay_dout_u5             ),
    .RF_on_delay_dout_out               (   RF_on_delay_dout                ),
    .RF_on_work_dout_in                 (   RF_on_work_dout_u5              ),
    .RF_on_work_dout_out                (   RF_on_work_dout                 ),
    .near_frame_period_in               (   near_frame_period_u5            ),
    .near_frame_period_out              (   near_frame_period               ),
    .far_frame_period_in                (   far_frame_period_u5             ),
    .far_frame_period_out               (   far_frame_period                )
);
	
	
    chirp_top U6_Gen_chirp_Sig(
    .m00_axis_aclk                  	(	clk_250M),
    .clk_500M                         	(	clk_500M),
    .m00_axis_aresetn               	(	sys_rst_n),
    .PINC1                          	(	upc_PINC1),                     
    .f0_scale                       	(	upc_f0_scale),            
    .mu_scale                       	(	upc_mu_scale),             
    .f0_scale2                      	(	upc_f0_scale2),            
    .mu_scale2                      	(	upc_mu_scale2),           
    .axi_chirp_width                	(	upc_axi_chirp_width),           
    .axi_pulse_period               	(	upc_axi_pulse_period),           
    .prt_ref                        	(	prt_ref),           
    .pulse_delay                    	(	upc_pulse_delay),                 
    .fc_scale               	        (	upc_fc_scale),          
		
    .mm_axis_tvalid                 	(mm_axis_tvalid),
    .mm_axis_tdata                  	(mm_axis_tdata),
		
 
    .m_axis_tvalid_converter        	(	m_axis_tvalid_converter),
    .m_axis_tdata_converter         	(	m_axis_tdata_converter)
    );
  
	
    chirp_top U6_Gen_Ref_Sig(
    .m00_axis_aclk                  	(	clk_250M),
    .clk_500M                         	(	clk_500M),
    .m00_axis_aresetn               	(	sys_rst_n),
    .PINC1                          	(	RefSig_PINC1	),                     
    .f0_scale                       	(	RefSig_f0_scale),            
    .mu_scale                       	(	RefSig_mu_scale),             
    .f0_scale2                      	(	RefSig_f0_scale2),            
    .mu_scale2                      	(	RefSig_mu_scale2),           
    .axi_chirp_width                	(	RefSig_axi_chirp_width),           
    .axi_pulse_period               	(	RefSig_axi_pulse_period),           
    .prt_ref                        	(	refsig_en),           
    .pulse_delay                    	(	RefSig_pulse_delay),                 
    .fc_scale               	        (	RefSig_fc_scale),          
		
    .mm_axis_tvalid                 	( ),
    .mm_axis_tdata                  	( ),
		
 
    .m_axis_tvalid_converter        	(	RefSig_tvalid_converter),
    .m_axis_tdata_converter         	(	RefSig_tdata_converter)
    );
  

    
    usp_rf_data_converter_0 U7_rf_data_converter (
       .adc0_clk_p              (	adc0_clk_p				),             
      .adc0_clk_n               (	adc0_clk_n				),             
      .clk_adc0                 (	clk_adc0				),				                 
						
      .adc1_clk_p               (	adc1_clk_p				),             
      .adc1_clk_n               (	adc1_clk_n				),             
      .clk_adc1                 (	clk_adc1				),				                 
						
      .adc2_clk_p               (	adc2_clk_p				),             
      .adc2_clk_n               (	adc2_clk_n				),             
      .clk_adc2                 (	clk_adc2				),				                 
						
      .adc3_clk_p               (	adc3_clk_p				),             
      .adc3_clk_n               (	adc3_clk_n				),             
      .clk_adc3                 (	clk_adc3				),				                 
						
      .dac0_clk_p               (	dac0_clk_p				),             
      .dac0_clk_n               (	dac0_clk_n				),             
      .clk_dac0                 (	clk_dac0				),				                 
		
      .s_axi_aclk               (	clk_250M				),             
      .s_axi_aresetn            (	sys_rst_n				),       
      .s_axi_awaddr             (	18'd0					),         
      .s_axi_awvalid            (	1'b0					),       
      .s_axi_awready            (),       
      .s_axi_wdata              (	32'd0),           
      .s_axi_wstrb              (	4'd0),           
      .s_axi_wvalid             (	1'b0),         
      .s_axi_wready             (),         
      .s_axi_bresp              (),           
      .s_axi_bvalid             (),         
      .s_axi_bready             (1'd1),         
      .s_axi_araddr             (18'd0),         
      .s_axi_arvalid            (1'b0),       
      .s_axi_arready            (),       
      .s_axi_rdata              (),           
      .s_axi_rresp              (),           
      .s_axi_rvalid             (),         
      .s_axi_rready             (1'd1),         
      .irq                      (	irq),                           
      .sysref_in_p              (	sysref_in_p				),           
      .sysref_in_n              (	sysref_in_n				),           
		
      .vin0_01_p                (	vin0_01_p				),               
      .vin0_01_n                (	vin0_01_n				),               
      .vin0_23_p                (	vin0_23_p				),               
      .vin0_23_n                (	vin0_23_n				),               
						
      .vin1_01_p                (	vin1_01_p				),               
      .vin1_01_n                (	vin1_01_n				),               
      .vin1_23_p                (	vin1_23_p				),               
      .vin1_23_n                (	vin1_23_n				),               
						
      .vin2_01_p                (	vin2_01_p				),               
      .vin2_01_n                (	vin2_01_n				),               
      .vin2_23_p                (	vin2_23_p				),               
      .vin2_23_n                (	vin2_23_n				),               
						
      .vin3_01_p                (	vin3_01_p				),               
      .vin3_01_n                (	vin3_01_n				),               
      .vin3_23_p                (	vin3_23_p				),               
      .vin3_23_n                (	vin3_23_n				),               
    
      .vout00_p                 (	vout00_p				),                 
      .vout00_n                 (	vout00_n				),                 
      .vout02_p                 (	vout02_p				),                 
      .vout02_n                 (	vout02_n				),                 
		
      .m0_axis_aresetn          (	sys_rst_n				),   
      .m0_axis_aclk             (	clk_250M				),         
		
      .m00_axis_tdata           (	m00_axis_tdata			),     
      .m00_axis_tvalid          (	m00_axis_tvalid			),   
      .m00_axis_tready          (	1'b1					),              
		
      .m01_axis_tdata           (	m01_axis_tdata			),     
      .m01_axis_tvalid          (	m01_axis_tvalid			),   
      .m01_axis_tready          (	1'b1),   
		
      .m02_axis_tdata           (	m02_axis_tdata),     
      .m02_axis_tvalid          (	m02_axis_tvalid),   
      .m02_axis_tready          (	1'b1),   
		
      .m03_axis_tdata           (	m03_axis_tdata),     
      .m03_axis_tvalid          (	m03_axis_tvalid),   
      .m03_axis_tready          (	1'b1),   
		
      .m1_axis_aresetn          (	sys_rst_n),   
      .m1_axis_aclk             (	clk_250M),         
		
      .m10_axis_tdata           (	m10_axis_tdata),     
      .m10_axis_tvalid          (	m10_axis_tvalid),   
      .m10_axis_tready          (	1'b1),   
		
      .m11_axis_tdata           (	m11_axis_tdata),     
      .m11_axis_tvalid          (	m11_axis_tvalid),   
      .m11_axis_tready          (	1'b1),   
		
      .m12_axis_tdata           (	m12_axis_tdata),     
      .m12_axis_tvalid          (	m12_axis_tvalid),   
      .m12_axis_tready          (	1'b1),   
		
      .m13_axis_tdata           (	m13_axis_tdata),     
      .m13_axis_tvalid          (	m13_axis_tvalid),   
      .m13_axis_tready          (	1'b1),   
		
      .m2_axis_aresetn          (	sys_rst_n),   
      .m2_axis_aclk             (	clk_250M),         
		
      .m20_axis_tdata           (	m20_axis_tdata),     
      .m20_axis_tvalid          (	m20_axis_tvalid),   
      .m20_axis_tready          (	1'b1),   
		
      .m21_axis_tdata           (	m21_axis_tdata),     
      .m21_axis_tvalid          (	m21_axis_tvalid),   
      .m21_axis_tready          (	1'b1),   
		
      .m22_axis_tdata           (	m22_axis_tdata),     
      .m22_axis_tvalid          (	m22_axis_tvalid),   
      .m22_axis_tready          (	1'b1),   
		
      .m23_axis_tdata           (	m23_axis_tdata),     
      .m23_axis_tvalid          (	m23_axis_tvalid),   
      .m23_axis_tready          (	1'b1),   
		
      .m3_axis_aresetn          (	sys_rst_n),   
      .m3_axis_aclk             (	clk_250M),         
		
      .m30_axis_tdata           (	m30_axis_tdata),     
      .m30_axis_tvalid          (	m30_axis_tvalid),   
      .m30_axis_tready          (	1'b1),   
		
      .m31_axis_tdata           (	m31_axis_tdata),     
      .m31_axis_tvalid          (	m31_axis_tvalid),   
      .m31_axis_tready          (	1'b1),   
		
      .m32_axis_tdata           (	m32_axis_tdata),     
      .m32_axis_tvalid          (	m32_axis_tvalid),   
      .m32_axis_tready          (	1'b1),   
		
      .m33_axis_tdata           (	m33_axis_tdata),     
      .m33_axis_tvalid          (	m33_axis_tvalid),   
      .m33_axis_tready          (	1'b1),   
		
      .s0_axis_aresetn          (	sys_rst_n),   
      .s0_axis_aclk             (	clk_500M),         
		
      .s00_axis_tdata           (	RefSig_tdata_in),     
       
      .s00_axis_tvalid          (	1'b1),   
      .s00_axis_tready          (	s00_axis_tready),   
		
      .s02_axis_tdata           (	rf_tdata_in),     
      .s02_axis_tvalid          (	1'b1),   
      .s02_axis_tready          (	s02_axis_tready)   
);  

 

	wire	[15:0]		pulseCom_dout_ch1_i			;
	wire	[15:0]		pulseCom_dout_ch1_q			;
	wire	[15:0]		pulseCom_dout_ch2_i			;
	wire	[15:0]		pulseCom_dout_ch2_q			;
	wire	[15:0]		pulseCom_dout_ch3_i			;
	wire	[15:0]		pulseCom_dout_ch3_q			;
	wire	[15:0]		pulseCom_dout_ch4_i			;
	wire	[15:0]		pulseCom_dout_ch4_q			;
	wire	[15:0]		pulseCom_dout_ch5_i			;
	wire	[15:0]		pulseCom_dout_ch5_q			;
	wire				pulseCom_dout_valid			;

	wire	[15:0]		buff_din_ch1_i				;
	wire	[15:0]		buff_din_ch1_q				;
	wire	[15:0]		buff_din_ch2_i				;
	wire	[15:0]		buff_din_ch2_q				;
	wire	[15:0]		buff_din_ch3_i				;
	wire	[15:0]		buff_din_ch3_q				;
	wire	[15:0]		buff_din_ch4_i				;
	wire	[15:0]		buff_din_ch4_q				;
	wire	[15:0]		buff_din_ch5_i				;
	wire	[15:0]		buff_din_ch5_q				;






(*keep = "true"*)	wire				pulseCom_en					;
	wire				pulseCom_far_or_near		;
	wire				pulseCom_frame_ref			;
	assign pulseCom_en = (use_PulseCompress == 8'hff)? 	receive_en: 1'b0		;	 

	wire				frame_ref_buff	;
	wire				buff_wren		;
	assign	frame_ref_buff = (use_PulseCompress == 8'hff)? pulseCom_frame_ref : frame_ref_ADC;
	assign	buff_wren	= (use_PulseCompress == 8'hff)?pulseCom_dout_valid :gate_buff_o	;
	wire 	fft_far_or_near	;
	assign fft_far_or_near = (use_PulseCompress == 8'hff)?pulseCom_far_or_near : far_or_near;
	
	assign	buff_din_ch1_i	= (use_PulseCompress == 8'hff) ? pulseCom_dout_ch1_i : m32_axis_tdata	;
	assign	buff_din_ch1_q	= (use_PulseCompress == 8'hff) ? pulseCom_dout_ch1_q : m33_axis_tdata	;
	assign	buff_din_ch2_i	= (use_PulseCompress == 8'hff) ? pulseCom_dout_ch2_i : m30_axis_tdata	;
	assign	buff_din_ch2_q	= (use_PulseCompress == 8'hff) ? pulseCom_dout_ch2_q : m31_axis_tdata	;
	assign	buff_din_ch3_i	= (use_PulseCompress == 8'hff) ? pulseCom_dout_ch3_i : m22_axis_tdata	;
	assign	buff_din_ch3_q	= (use_PulseCompress == 8'hff) ? pulseCom_dout_ch3_q : m23_axis_tdata	;
	assign	buff_din_ch4_i	= (use_PulseCompress == 8'hff) ? pulseCom_dout_ch4_i : m20_axis_tdata	;
	assign	buff_din_ch4_q	= (use_PulseCompress == 8'hff) ? pulseCom_dout_ch4_q : m21_axis_tdata	;
	assign	buff_din_ch5_i	= (use_PulseCompress == 8'hff) ? pulseCom_dout_ch5_i : m12_axis_tdata	;
    assign	buff_din_ch5_q	= (use_PulseCompress == 8'hff) ? pulseCom_dout_ch5_q : m13_axis_tdata	;
	assign	decim_factor = (use_PulseCompress == 8'hff) ? 0: decim_factor_simple	;
	
top_5ch_pulse_compression U8_Pulse_Compression (
    .clk            				(	clk_250M			),
    .rst            				(	sys_rst				),
	.en								(	pulseCom_en			),
    .frame_start    				(	frame_ref_ADC		),
    .prt_ref        				(	prt_ref_ADC		),
    .far_or_near    				(	far_or_near			),
    .din_ch1_i      				(	m32_axis_tdata		),
    .din_ch1_q      				(	m33_axis_tdata		),
    .din_ch2_i      				(	m30_axis_tdata		),
    .din_ch2_q      				(	m31_axis_tdata		),
    .din_ch3_i      				(	m22_axis_tdata		),
    .din_ch3_q      				(	m23_axis_tdata		),
    .din_ch4_i      				(	m20_axis_tdata		),
    .din_ch4_q      				(	m21_axis_tdata		),
    .din_ch5_i      				(	m12_axis_tdata		),
    .din_ch5_q      				(	m13_axis_tdata		),
    .dout_ch1_i     				(	pulseCom_dout_ch1_i			),
    .dout_ch1_q     				(	pulseCom_dout_ch1_q			),
    .dout_ch2_i     				(	pulseCom_dout_ch2_i			),
    .dout_ch2_q     				(	pulseCom_dout_ch2_q			),
    .dout_ch3_i     				(	pulseCom_dout_ch3_i			),
    .dout_ch3_q     				(	pulseCom_dout_ch3_q			),
    .dout_ch4_i     				(	pulseCom_dout_ch4_i			),
    .dout_ch4_q     				(	pulseCom_dout_ch4_q			),
    .dout_ch5_i     				(	pulseCom_dout_ch5_i			),
    .dout_ch5_q     				(	pulseCom_dout_ch5_q			),
    .dout_valid     				(	pulseCom_dout_valid			),
    .frame_out      				(	pulseCom_frame_ref			),
    .far_or_near_out				(	pulseCom_far_or_near		)
);	
 
	


	Buffer_top U9_Buffer(
	.clk							(	clk_250M					),	 
	.rst							(	sys_rst						),	 
	.timer_module_en				(	receive_en					),	 
	.prt_num_per_frame				(	prt_num[9:0]				),	 
	.decim_factor					(	decim_factor				),	 
	.frame_start					(	frame_ref_buff				),	 
	.gate_buff						(	buff_wren					),	 
	.din_ch1_i						(	buff_din_ch1_i				),	 
	.din_ch1_q						(	buff_din_ch1_q				),	 
	.din_ch2_i						(	buff_din_ch2_i				),	 
	.din_ch2_q						(	buff_din_ch2_q				),	 
	.din_ch3_i						(	buff_din_ch3_i				),	 
	.din_ch3_q						(	buff_din_ch3_q				),	 
	.din_ch4_i						(	buff_din_ch4_i				),	 
	.din_ch4_q						(	buff_din_ch4_q				),	 
	.din_ch5_i						(	buff_din_ch5_i				),	 
	.din_ch5_q						(	buff_din_ch5_q				),	 
	
	.rd_addr						(	rd_addr						),	 
	.rd_en							(	rd_en						),	 
	.frame_ref_fft					(	frame_ref_fft				),	 
	.dout_fft_en					(dout_fft_en					),	 
	.dout_fft_ch1					(	dout_fft_ch1				),	 
	.dout_fft_ch2					(	dout_fft_ch2				),	 
	.dout_fft_ch3					(	dout_fft_ch3				),	 
	.dout_fft_ch4					(	dout_fft_ch4				),	 
	.dout_fft_ch5					(	dout_fft_ch5				),	 
	.All_WaveNum					(	All_WaveNum					)	 

    );
    
    wire [9:0] ref_freq_in;
    wire [5:0] ref_bomen_in;
    wire [3:0] judge_num;
    wire [3:0] judge_num_detect;
    
    vio_0 u_vio_0 
    (
        .clk            (clk_250M),
        .probe_out0     (ref_freq_in),
        .probe_out1     (ref_bomen_in),
        .probe_out2     (judge_num),
        .probe_out3     (judge_num_detect)
    );
    
    top_fft U10_top_fft
    (
        .clk                        (	clk_250M					)	,                                
        .rst                        (	sys_rst						)	,                                
        .p_b_in                     (	frame_ref_fft				),                             
        .snr_door_in                (	snr_door_dout				),                        
        .fft_mode_in                (	fft_far_or_near				),                        
        .protect_freq_in            (	16'd30						),                        
        .use_PulseCompress          (	use_PulseCompress			),                        
        .detect_freq_low_near    	(	detect_freq_low_near_dout	) ,  		 
        .detect_freq_high_near   	(	detect_freq_high_near_dout	) ,  		 
        .detect_freq_low_far    	(	detect_freq_low_far_dout	) ,  		 
        .detect_freq_high_far   	(	detect_freq_high_far_dout	) ,  		 
        .ref_freq_in                (10'd767),                        
        .ref_bomen_in               (6'd10),                       
        .judge_num                  (judge_num),                       
        .judge_num_detect           (judge_num_detect),                       
        .All_WaveNum                (	All_WaveNum					),                      
        .buf_data_in_1              (	dout_fft_ch1				),                      
        .buf_data_in_2              (	dout_fft_ch2				),                      
        .buf_data_in_3              (	dout_fft_ch3				),                      
        .buf_data_in_4              (	dout_fft_ch4				),                      
        .buf_data_in_5              (	dout_fft_ch5				),                      
        .buf_data_rd_en             (	rd_en						),                         
        .buf_data_rd_addr           (	rd_addr						),                       
        .target_state               (target_state),         		          
        .max_bomen_dout             ( max_bomen_dout        		),
        .max_freq_dout              ( max_freq_dout         		),
        .max_snr_dout               ( max_snr_dout          		),
		.max_dout_en				(	fft_refresh					),
        .fft_result_bomen_before    ( 	fft_result_bomen_before),
        .fft_result_bomen_middle    ( 	fft_result_bomen_middle),
        .fft_result_bomen_after     ( 	fft_result_bomen_after),
        .fft_result_freq_before     ( 	fft_result_freq_before),
        .fft_result_freq_after      ( 	fft_result_freq_after ),
        .ps_int                     (	ps_int),                            
        .zhen_cnt                   (	zhen_cnt),                           
        .max_bomen_dout_before      (	max_bomen_dout_before),              
        .max_bomen_dout_middle      (	max_bomen_dout_middle),              
        .max_bomen_dout_after       (	max_bomen_dout_after),               
        .max_freq_dout_before       (	max_freq_dout_before),               
        .max_freq_dout_middle       (	max_freq_dout_middle),               
        .max_freq_dout_after        (	max_freq_dout_after),                
        .max_snr_dout_before        (	max_snr_dout_before),                
        .max_snr_dout_middle        (	max_snr_dout_middle),                
        .max_snr_dout_after         (	max_snr_dout_after),                 
        .max_IQ_ch1_dout            (	max_IQ_ch1_dout),                    
        .max_IQ_ch2_dout            (	max_IQ_ch2_dout),                    
        .max_IQ_ch3_dout            (	max_IQ_ch3_dout),                    
        .max_IQ_ch4_dout            (	max_IQ_ch4_dout),                    
        .max_IQ_ch5_dout            (	max_IQ_ch5_dout),                    
        .ref_phase_ch1_dout         (	ref_phase_ch1_dout),                 
        .ref_phase_ch2_dout         (	ref_phase_ch2_dout),                 
        .ref_phase_ch3_dout         (	ref_phase_ch3_dout),                 
        .ref_phase_ch4_dout         (	ref_phase_ch4_dout),                 
        .ref_phase_ch5_dout         (	ref_phase_ch5_dout)                  
    );

	
 
 
 
 
 
 
 
 

 

	
	Serial_Comm #(
	.BAUD_RATE			(1_000_000)
	)U12_Serial_Rs422(
     
    .clk_100m				(	clk_100m		)	,            
    .rst					(	sys_rst_100m		)	,                 
    .rs422_rxd_fc			(	FK422_RX		)	,        
    .rs422_txd_fc			(	FK422_TX	)	,        
    .rs422_txd_radio		(	YC422_TX	)	,     
    .status_422     		(	status_422     	)	,      
	.Status					(	Radar_Status				),  
	.tx_clk_fc				(	ToFK_bram_clk			),
	.tx_clk_radio			(	ToDT_bram_clk			),	
	.tx_data_fc				(	ToFK_bram_wrdata[7:0]	),	 
	.tx_data_radio		    (	ToDT_bram_wrdata[7:0]	),   
	.tx_addr_fc				(	ToFK_bram_addr[10:2]	),
	.tx_addr_radio			(	ToDT_bram_addr[10:2]	),
	.tx_valid_fc			(	ToFK_bram_we[0]			),   
	.tx_valid_radio		    (	ToDT_bram_we[0]			),   
	.FromFK_bram_addr	    (	FromFK_bram_addr[9:2]	),
	.FromFK_bram_clk		(	FromFK_bram_clk			),
	.FromFK_bram_en		    (	FromFK_bram_en			),
	.FromFK_bram_rddata	    (	FromFK_bram_rddata		),
    .pulse_100us            (	Irq_FromFK				)	 
  	
    );

     
	 
	 
	 
	 
	 
	 
	 
	 
	 
     

     


  design_1_wrapper u_design_1_wrapper
   (
	.Irq_FromFK							(	Irq_FromFK					),
    .bram_addr_FromFK                   (	FromFK_bram_addr       	),
    .bram_addr_a                        (	pcPara_bram_addr       	),
    .bram_addr_toDT                     (	ToDT_bram_addr         	),
    .bram_addr_toFK                     (	ToFK_bram_addr         	),
    .bram_clk_FromFK                    (	FromFK_bram_clk        	),
    .bram_clk_a                         (	pcPara_bram_clk        	),
    .bram_clk_toDT                      (	ToDT_bram_clk          	),
    .bram_clk_toFK                      (	ToFK_bram_clk          	),
    .bram_en_FromFK                     (	FromFK_bram_en         	),
    .bram_en_a                          (	pcPara_bram_en         	),
    .bram_en_toDT                       (	ToDT_bram_en           	),
    .bram_en_toFK                       (	ToFK_bram_en           	),
    .bram_rddata_a                      (	pcPara_bram_rddata     	),
    .bram_rddata_fromFK                 (	FromFK_bram_rddata     ),
    .bram_rst_FromFK                    (	FromFK_bram_rst        ),
    .bram_rst_ToDT                      (	ToDT_bram_rst          ),
    .bram_rst_ToFK                      (	ToFK_bram_rst          ),
    .bram_rst_a                         (	pcPara_bram_rst        ),
    .bram_we_FromFK                     (	FromFK_bram_we         ),
    .bram_we_a                          (	pcPara_bram_we              ),
    .bram_we_toDT                       (	ToDT_bram_we           ),
    .bram_we_toFK                       (	ToFK_bram_we           ),
    .bram_wrdata_FromFK                 (	FromFK_bram_wrdata     ),
    .bram_wrdata_a                      (	pcPara_bram_wrdata          ),
    .bram_wrdata_toDT                   (	ToDT_bram_wrdata       ),
    .bram_wrdata_toFK                   (	ToFK_bram_wrdata       ),
    .gpio_in                            (	gpio_in                ),
    .gpio_out                           (	gpio_out               ),
    .ps_int                             (	ps_int                 ),
    .uart_RF_rx                         (	uart_RF_rx             ),
    .uart_RF_tx                         (	uart_RF_tx 	        )
	);
  

 	
     
	 
	 
	 
	 
	 
	 
	 
 
     
	 

	 
	 
	 
	 
	 
	 
	 
	 
 
 
 
 

     
         
           
           
           
         
         
            
            
            
                 
            
            
                 
            
         
     
    

    
    
     
     
     
     
     
     
     
     
     
    
 
 
   
   
   
   
   
   
   
   
   
   
 
	
	
	
	
	
	
endmodule





