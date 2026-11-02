`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


(*KEEP_HIERARCHY = "YES"*)module Processor_Ctrl(
	input							clk						,
	input							rst						,
	input							pc_tx_on_off			,		 
	input							just_receive			,		 
	input							program_start			,		 
	input		[15:0]				program_wait_time		,		 
	input		[15:0]				program_hold_time		,		 
	input							program_reset			,		 
		
	(* KEEP = "true" *) output		[3:0]				radar_mode				,		 
	(* KEEP = "true" *) output							tx_on_off				,		 
	(* KEEP = "true" *) output							receive_on				,		 
	
	input							serch_or_track			,		 
	input		[7:0]				current_range_gate		,		 
	input		[7:0]				switch_range_gate		,		 
	input		[7:0]				Setup_para_mode			,		 
	input		[7:0]				subarray_select_mode	,		 
	output		[1:0]               subarray_select		    ,		 
	
	input		[1:0]				detect_phase_state		,
	output	reg						start_gen_refsig		,		 
	output	reg						refsig_en				,		 
				
	(* KEEP = "true" *) output		[7:0]				current_para_mode		,		 
	output							far_or_near				,
	input							frame_ref				,		
	input		[15:0]				far_prt_period			,		 
	input		[31:0]				far_frame_period		,		 
	input		[15:0]				far_prt_num				,		 
	input		[15:0]				far_delay_tf_pm			,		 
	input		[15:0]				far_length_tf_pm		,		 
	input		[15:0]				far_delay_tf_pc			,		 
	input		[15:0]				far_length_tf_pc		,		 
	input		[15:0]				far_delay_tr_k			,		 
	input		[15:0]				far_length_tr_k			,		 
	input		[15:0]				far_delay_ADC			,		 
	input		[15:0]				far_length_ADC			,		 
	input		[15:0]				far_delay_PhaseRef		,		 
	input		[15:0]				far_length_PhaseRef		,		 
	input		[7:0]				far_decim_factor		,		 
				
	input		[15:0]				near_prt_period			,		 
	input		[31:0]				near_frame_period		,		 
	input		[15:0]				near_prt_num			,		 
	input		[15:0]				near_delay_tf_pm		,		 
	input		[15:0]				near_length_tf_pm		,		 
	input		[15:0]				near_delay_tf_pc		,		 
	input		[15:0]				near_length_tf_pc		,		 
	input		[15:0]				near_delay_tr_k			,		 
	input		[15:0]				near_length_tr_k		,		 
	input		[15:0]				near_delay_ADC			,		 
	input		[15:0]				near_length_ADC			,		 
	input		[15:0]				near_delay_PhaseRef		,		 
	input		[15:0]				near_length_PhaseRef	,		 
	input		[7:0]				near_decim_factor		,		 

    input       [31:0]              PINC1_near,               
    input       [31:0]              f0_scale_near,            
    input       [31:0]              mu_scale_near,             
    input       [31:0]              f0_scale2_near,            
    input       [31:0]              mu_scale2_near,           
    input       [31:0]              axi_chirp_width_near,           
    input       [31:0]              axi_pulse_period_near,           
    input       [31:0]              pulse_delay,                    
	input       [31:0]              PINC1_far,               
    input       [31:0]              f0_scale_far,            
    input       [31:0]              mu_scale_far,             
    input       [31:0]              f0_scale2_far,            
    input       [31:0]              mu_scale2_far,           
    input       [31:0]              axi_chirp_width_far,           
    input       [31:0]              axi_pulse_period_far,           
    input       [31:0]              axi_fc_scale_near,           
    input       [31:0]              axi_fc_scale_far,           

	(* KEEP = "true" *) output		[15:0]				prt_period				,		 
	(* KEEP = "true" *) output		[31:0]				frame_period			,		 
	(* KEEP = "true" *) output		[15:0]				prt_num					,		 
	(* KEEP = "true" *) output		[15:0]				upc_delay_tf_pm			,		 
	(* KEEP = "true" *) output		[15:0]				upc_length_tf_pm		,		 
	(* KEEP = "true" *) output		[15:0]				upc_delay_tf_pc			,		 
	(* KEEP = "true" *) output		[15:0]				upc_length_tf_pc		,		 
	(* KEEP = "true" *) output		[15:0]				upc_delay_tr_k			,		 
	(* KEEP = "true" *) output		[15:0]				upc_length_tr_k			,		 
	(* KEEP = "true" *) output		[15:0]				upc_delay_ADC			,		 
	(* KEEP = "true" *) output		[15:0]				upc_length_ADC			,		 
	(* KEEP = "true" *) output		[15:0]				upc_delay_PhaseRef		,		 
	(* KEEP = "true" *) output		[15:0]				upc_length_PhaseRef		,		 
						output		[3:0]				decim_factor			,		 
	
	(* KEEP = "true" *) output      [31:0]              upc_PINC1               ,               
    (* KEEP = "true" *) output      [31:0]              upc_f0_scale            ,            
    (* KEEP = "true" *) output      [31:0]              upc_mu_scale            ,             
    (* KEEP = "true" *) output      [31:0]              upc_f0_scale2           ,            
    (* KEEP = "true" *) output      [31:0]              upc_mu_scale2           ,           
    (* KEEP = "true" *) output      [31:0]              upc_axi_chirp_width     ,           
    (* KEEP = "true" *) output      [31:0]              upc_axi_pulse_period    ,           
    (* KEEP = "true" *) output      [31:0]              upc_pulse_delay         ,           
    (* KEEP = "true" *) output      [31:0]              upc_fc_scale                      
	
    );
	
	
	
		 
	 
	 
	
	always@(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
			start_gen_refsig				<= 1'b0			;
		end
		else begin
			if(frame_ref) 
				start_gen_refsig			<= 1'b1			;			 
			else
				start_gen_refsig			<= start_gen_refsig		;
		end
	end
	always@(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
			refsig_en						<= 1'b0			;
		end
		else begin
			if(detect_phase_state == 2'b01) 
				refsig_en					<= 1'b1			;
			else
				refsig_en					<= 1'b0			;
		end
	end
	
	
	Radar_Processor u_Radar_Processor(
	.clk							(	clk						),
	.rst							(	rst						),
	.pc_tx_on_off					(	pc_tx_on_off			),		 
	.just_receive					(	just_receive			),		 
	.program_start					(	program_start			),		 
	.program_wait_time				(	program_wait_time		),		 
	.program_hold_time				(	program_hold_time		),		 
	.program_reset					(	program_reset			),		 

	.radar_mode						(	radar_mode				),		 
	.tx_on_off						(	tx_on_off				),		 
	.receive_on						(	receive_on				)		 

    );
	
	Parameter_Ctrl u_Parameter_Ctrl(
	.clk							(	clk						),
	.rst							(	rst						),
	.serch_or_track					(	serch_or_track			),		 
	.current_range_gate				(	current_range_gate		),		 
	.switch_range_gate				(	switch_range_gate		),		 
	.Setup_para_mode				(	Setup_para_mode			),		 
	.current_para_mode				(	current_para_mode		),		 
	.far_or_near					(	far_or_near				),
	.subarray_select_mode			(	subarray_select_mode	)	,
	.subarray_select				(	subarray_select			)	,		 
	.frame_ref						(	frame_ref				)	,
	.far_prt_period					(	far_prt_period			),
    .far_frame_period	            (	far_frame_period	    ),
    .far_prt_num			        (	far_prt_num		        ),
	.far_delay_tf_pm				(	far_delay_tf_pm			),		 
	.far_length_tf_pm				(	far_length_tf_pm		),		 
	.far_delay_tf_pc				(	far_delay_tf_pc			),		 
	.far_length_tf_pc				(	far_length_tf_pc		),		 
	.far_delay_tr_k					(	far_delay_tr_k			),		 
	.far_length_tr_k				(	far_length_tr_k			),		 
	.far_delay_ADC					(	far_delay_ADC			),		 
	.far_length_ADC					(	far_length_ADC			),		 
	.far_delay_PhaseRef				(	far_delay_PhaseRef		),		 
	.far_length_PhaseRef			(	far_length_PhaseRef		),		 
	.far_decim_factor				(	far_decim_factor		),
	.near_prt_period				(	near_prt_period			),
    .near_frame_period              (	near_frame_period       ),
    .near_prt_num		            (	near_prt_num		    ),
	.near_delay_tf_pm				(	near_delay_tf_pm		),		 
	.near_length_tf_pm				(	near_length_tf_pm		),		 
	.near_delay_tf_pc				(	near_delay_tf_pc		),		 
	.near_length_tf_pc				(	near_length_tf_pc		),		 
	.near_delay_tr_k				(	near_delay_tr_k			),		 
	.near_length_tr_k				(	near_length_tr_k		),		 
	.near_delay_ADC					(	near_delay_ADC			),		 
	.near_length_ADC				(	near_length_ADC			),		 
	.near_delay_PhaseRef			(	near_delay_PhaseRef		),		 
	.near_length_PhaseRef			(	near_length_PhaseRef	),		 
	.near_decim_factor				(	near_decim_factor		),
	
	.PINC1_near                     (   PINC1_near              ),               
    .f0_scale_near                  (   f0_scale_near           ),            
    .mu_scale_near                  (   mu_scale_near           ),             
    .f0_scale2_near                 (   f0_scale2_near          ),            
    .mu_scale2_near                 (   mu_scale2_near          ),           
    .axi_chirp_width_near           (   axi_chirp_width_near    ),           
    .axi_pulse_period_near          (   axi_pulse_period_near   ),           
    .pulse_delay                    (   pulse_delay             ),                    
	.PINC1_far                      (   PINC1_far               ),               
    .f0_scale_far                   (   f0_scale_far            ),            
    .mu_scale_far                   (   mu_scale_far            ),             
    .f0_scale2_far                  (   f0_scale2_far           ),            
    .mu_scale2_far                  (   mu_scale2_far           ),           
    .axi_chirp_width_far            (   axi_chirp_width_far     ),           
    .axi_pulse_period_far           (   axi_pulse_period_far    ),           
    .axi_fc_scale_near              (   axi_fc_scale_near            ),           
    .axi_fc_scale_far               (   axi_fc_scale_far            ),           
	.prt_period						(	prt_period				),
    .frame_period                   (	frame_period           	),
	.decim_factor				    (	decim_factor		),
	
    .prt_num		                (	prt_num		        	),
	.upc_delay_tf_pm				(	upc_delay_tf_pm			),		 
	.upc_length_tf_pm				(	upc_length_tf_pm		),		 
	.upc_delay_tf_pc				(	upc_delay_tf_pc			),		 
	.upc_length_tf_pc				(	upc_length_tf_pc		),		 
	.upc_delay_tr_k					(	upc_delay_tr_k			),		 
	.upc_length_tr_k				(	upc_length_tr_k			),		 
	.upc_delay_ADC					(	upc_delay_ADC			),		 
	.upc_length_ADC					(	upc_length_ADC			),		 
	.upc_delay_PhaseRef				(	upc_delay_PhaseRef		),		 
	.upc_length_PhaseRef			(	upc_length_PhaseRef		),		 
	.upc_PINC1                      (   upc_PINC1               ),               
    .upc_f0_scale                   (   upc_f0_scale            ),            
    .upc_mu_scale                   (   upc_mu_scale            ),             
    .upc_f0_scale2                  (   upc_f0_scale2           ),            
    .upc_mu_scale2                  (   upc_mu_scale2           ),           
    .upc_axi_chirp_width            (   upc_axi_chirp_width     ),           
    .upc_axi_pulse_period           (   upc_axi_pulse_period    ),           
    .upc_pulse_delay                (   upc_pulse_delay         ),               
    .upc_fc_scale                   (   upc_fc_scale         )               
    );
	
	
endmodule
 