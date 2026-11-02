`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 


(*KEEP_HIERARCHY = "YES"*) module Buffer_top(
	input								clk						,		 
	input								rst						,		 
 
(*KEEP = "TRUE"*)   input								timer_module_en			,		 
	input		[9:0]					prt_num_per_frame		,		 
	input		[3:0]					decim_factor			,		 
 
	input								frame_start				,		 
	input								gate_buff				,		 
	
	
 
(*KEEP = "TRUE"*)	input			[15:0]				din_ch1_i				,		 
(*KEEP = "TRUE"*)	input			[15:0]				din_ch1_q				,		 
(*KEEP = "TRUE"*)	input			[15:0]				din_ch2_i				,		 
(*KEEP = "TRUE"*)	input			[15:0]				din_ch2_q				,		 
(*KEEP = "TRUE"*)	input			[15:0]				din_ch3_i				,		 
(*KEEP = "TRUE"*)	input			[15:0]				din_ch3_q				,		 
(*KEEP = "TRUE"*)	input			[15:0]				din_ch4_i				,		 
(*KEEP = "TRUE"*)	input			[15:0]				din_ch4_q				,		 
(*KEEP = "TRUE"*)	input			[15:0]				din_ch5_i				,		 
(*KEEP = "TRUE"*)	input			[15:0]				din_ch5_q				,		 


 
 
 
 
 
 
 
 
 
	input			[15:0]				rd_addr					,
	input								rd_en					,
 
(*KEEP = "TRUE"*)   output								frame_ref_fft			,		 
(*KEEP = "TRUE"*)   output								dout_fft_en				,		 
(*KEEP = "TRUE"*)   output			[31:0]				dout_fft_ch1			,		 
(*KEEP = "TRUE"*)   output			[31:0]				dout_fft_ch2			,		 
(*KEEP = "TRUE"*)   output			[31:0]				dout_fft_ch3			,		 
(*KEEP = "TRUE"*)   output			[31:0]				dout_fft_ch4			,		 
(*KEEP = "TRUE"*)   output			[31:0]				dout_fft_ch5			,		 
				
	output			[5:0]				All_WaveNum

    );
	
 
	wire			[15:0]				wr_addr					;
	wire								wr_en					;
	
 
 
 
 
 
 
 
 
 
 
 
 
 
	
	
	 
(*KEEP = "TRUE"*)	reg									frame_start_d1			;
(*KEEP = "TRUE"*)	reg									frame_start_d2			;
(*KEEP = "TRUE"*)	reg									frame_start_pose_edge	;		 
(*KEEP = "TRUE"*)	reg									frame_start_neg_edge	;		 


 
 
 
 
 
 
	
 
	
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			frame_start_d1				<= 1'b0					;
			frame_start_d2				<= 1'b0					;			
		end
		else begin
			frame_start_d1				<= frame_start			;
			frame_start_d2				<= frame_start_d1		;				
		end
	end
	reg		[9:0]					prt_num_per_frame_latch		;		 
	reg		[3:0]					decim_factor_latch			;		 
	
	always @(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
			prt_num_per_frame_latch				<= 10'd1023		;
			decim_factor_latch		            <= 4'd1			;
		end
		else begin
			if(frame_start) begin
				prt_num_per_frame_latch				<= prt_num_per_frame		;
				decim_factor_latch		            <= decim_factor			;
			end
			else begin
				prt_num_per_frame_latch				<= prt_num_per_frame_latch		;
				decim_factor_latch		            <= decim_factor_latch			;				
			end
		end
	end
	
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			frame_start_pose_edge		<= 1'b0					;
		end
		else begin
			if((frame_start_d2 == 1'b0) &&(frame_start_d1 == 1'b1))
				frame_start_pose_edge	<= 1'b1					;		
			else
				frame_start_pose_edge	<= 1'b0					;
		end
	end
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			frame_start_neg_edge		<= 1'b0					;
		end
		else begin
			if((frame_start_d2 == 1'b1) &&(frame_start_d1 == 1'b0))
				frame_start_neg_edge	<= 1'b1					;		
			else
				frame_start_neg_edge	<= 1'b0					;
		end
	end
	 
	 
	 
	 
	
 
 
	 
		 
			 
			 
			 
			 
		 
		 
			 
			 
			 
			 
		 
	 
	
	 
		 
			 
		 
		 
			 
				 
					 
				 
					 
				 
					 
				 
					 
			 
			 
				 
		 
	 
	
	 
		 
			 
		 
		 
			 
				 
					 
				 
					 
			 
			 
				 
		 
	 

	
	 
		 
			 
			 
		 
		 
			 
			 
		 
	 
 
	 
		 
			 
		 
		 
			 
				 
			 
				 
		 
	 

	 
	
 
wr_ram_ctrl wr_ram_ctrl(
	.clk						(	clk						)	,		 
	.rst						(	rst						)	,		 
	.frame_start_pose_edge		(	frame_start_pose_edge	)	,	 
	.frame_start_neg_edge		(	frame_start_neg_edge	)	,
	.decim_factor				(	decim_factor_latch			)	,
	.gate_buff_in					(	gate_buff				)	,
	.frame_ref_fft				(	frame_ref_fft			)	,
	.timer_module_en			(	timer_module_en			)	,
	.prt_num_per_frame			(	prt_num_per_frame_latch		)	,
	.wr_addr					(	wr_addr					)	,
	.wr_en						(   wr_en					)	,
	.All_WaveNum				(	All_WaveNum				)
    );
 
 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 


     
	
	
 
 ping_pang_switch ping_pang_switch_ch1(
	.clk						(	clk						)	,		 
	.rst						(	rst						)	,		 
	.timer_module_en			(	timer_module_en			)	,		 
	.frame_start_pose_edge		(	frame_start_pose_edge	)	,		 
	.frame_start_neg_edge		(	frame_start_neg_edge	)	,		 
	.din_i						(	din_ch1_i				)	,		 
	.din_q						(	din_ch1_q				)	,		 
	.wr_addr					(	wr_addr					)	,		 
	.wr_en						(	wr_en					)	,		 
	.rd_addr					(	rd_addr					)	,		 
	.rd_en						(	rd_en					)	,		 
	.dout						(	dout_fft_ch1			)	,		 
	.dout_valid					(	dout_fft_en				)			 

    );	
 ping_pang_switch ping_pang_switch_ch2(
	.clk						(	clk						)	,		 
	.rst						(	rst						)	,		 
	.timer_module_en			(	timer_module_en			)	,		 
	.frame_start_pose_edge		(	frame_start_pose_edge	)	,		 
	.frame_start_neg_edge		(	frame_start_neg_edge	)	,		 
	.din_i						(	din_ch2_i				)	,		 
	.din_q						(	din_ch2_q				)	,		 
	.wr_addr					(	wr_addr					)	,		 
	.wr_en						(	wr_en					)	,		 
	.rd_addr					(	rd_addr					)	,		 
	.rd_en						(	rd_en					)	,		 
	.dout						(	dout_fft_ch2			)	,		 
	.dout_valid					(					)			 
	
    );		
 ping_pang_switch ping_pang_switch_ch3(	
	.clk						(	clk						)	,		 
	.rst						(	rst						)	,		 
	.timer_module_en			(	timer_module_en			)	,		 
	.frame_start_pose_edge		(	frame_start_pose_edge	)	,		 
	.frame_start_neg_edge		(	frame_start_neg_edge	)	,		 
	.din_i						(	din_ch3_i				)	,		 
	.din_q						(	din_ch3_q				)	,		 
	.wr_addr					(	wr_addr					)	,		 
	.wr_en						(	wr_en					)	,		 
	.rd_addr					(	rd_addr					)	,		 
	.rd_en						(	rd_en					)	,		 
	.dout						(	dout_fft_ch3			)	,		 
	.dout_valid					(					)			 

    );	
 ping_pang_switch ping_pang_switch_ch4(	
	.clk						(	clk						)	,		 
	.rst						(	rst						)	,		 
	.timer_module_en			(	timer_module_en			)	,		 
	.frame_start_pose_edge		(	frame_start_pose_edge	)	,		 
	.frame_start_neg_edge		(	frame_start_neg_edge	)	,		 
	.din_i						(	din_ch4_i				)	,		 
	.din_q						(	din_ch4_q				)	,		 
	.wr_addr					(	wr_addr					)	,		 
	.wr_en						(	wr_en					)	,		 
	.rd_addr					(	rd_addr					)	,		 
	.rd_en						(	rd_en					)	,		 
	.dout						(	dout_fft_ch4			)	,		 
	.dout_valid					(					)			 

    );	
 ping_pang_switch ping_pang_switch_ch5(	
	.clk						(	clk						)	,		 
	.rst						(	rst						)	,		 
	.timer_module_en			(	timer_module_en			)	,		 
	.frame_start_pose_edge		(	frame_start_pose_edge	)	,		 
	.frame_start_neg_edge		(	frame_start_neg_edge	)	,		 
	.din_i						(	din_ch5_i				)	,		 
	.din_q						(	din_ch5_q				)	,		 
	.wr_addr					(	wr_addr					)	,		 
	.wr_en						(	wr_en					)	,		 
	.rd_addr					(	rd_addr					)	,		 
	.rd_en						(	rd_en					)	,		 
	.dout						(	dout_fft_ch5			)	,		 
	.dout_valid					(					)			 

    );	
	
endmodule
