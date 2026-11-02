`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


(*KEEP_HIERARCHY = "YES"*) module wr_ram_ctrl(
	input								clk						,		 
	input								rst						,		 
 
	input								frame_start_pose_edge	,		 
	input								frame_start_neg_edge	,
	input								gate_buff_in			,
	input		[9:0]					prt_num_per_frame		,		 
	output		reg						frame_ref_fft			,		 
	
 
	input								timer_module_en			,
	input			[3:0]				decim_factor			,		 
(*KEEP = "TRUE"*)	output				[15:0]			wr_addr					,
(*KEEP = "TRUE"*)	output		reg						wr_en					,
	output		reg	[5:0]				All_WaveNum

    );
	
(*KEEP = "TRUE"*)	reg					[3:0]			cnt						;		 
(*KEEP = "TRUE"*)	reg					[5:0]			wave_num				;		 
(*KEEP = "TRUE"*)	reg					[9:0]			prt_num					;
(*KEEP = "TRUE"*)	reg									gate_buff				;
(*KEEP = "TRUE"*)	reg									gate_buff_d1				;
	reg			[5:0]				All_WaveNum_reg		;
	reg				rd_ready					;
 

	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			cnt						<= 4'd0						;
		end
		else begin
			if(gate_buff == 1'b1) begin
				if(cnt == decim_factor)	
					cnt				<= 4'd0						;		 
				else
					cnt				<= cnt + 4'd1				;
			end	
			else begin
				cnt					<= 4'd0						;
			end
		end
	end
	
 
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			gate_buff					<= 1'b0						;
			gate_buff_d1				<= 1'b0					;
		end
		else begin
			gate_buff					<= gate_buff_in			;
			gate_buff_d1				<= gate_buff			;
		end
	end	
	
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			wr_en					<= 1'b0						;
		end
		else begin
			if((gate_buff == 1'b1) &&(cnt == 4'd0))					 
				wr_en				<= 1'b1						;
			else
				wr_en				<= 1'b0						;
		end
	end	
 
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			wave_num				<= 6'd0						;
		end
		else begin
			if(timer_module_en == 1'b1) begin
				if((frame_start_pose_edge == 1'b1) || (gate_buff == 1'b0)) begin					 
					wave_num		<= 6'd0						;
				end
				else begin
					if(wr_en == 1'b1)
						wave_num	<= wave_num + 6'd1			;		 
					else
						wave_num	<= wave_num					;
				end				
			end
			else begin
				wave_num				<= 6'd0					;
			end
		end
	end
	
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			prt_num					<= 10'd0					;
		end
		else begin
			if(timer_module_en == 1'b1) begin
				if(frame_start_pose_edge == 1'b1) begin					 
					prt_num			<= 10'd0					;
				end
				else begin
					if((gate_buff_d1 == 1'b1) && (gate_buff ==1'b0))  begin	 
						if(prt_num == prt_num_per_frame)
							prt_num		<= 10'd0					;
						else
					
							prt_num		<= prt_num + 10'd1			;		 
					end
					else
						prt_num		<= prt_num					;
					
					
				end
			end
			else begin
				prt_num				<= 10'd0					;
			end
		end
	end
	
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			All_WaveNum_reg					<= 6'd63					;
		end
		else begin
			if(timer_module_en == 1'b1) begin

					if((gate_buff == 1'b0) && (gate_buff_d1 ==1'b1))  begin	 
						All_WaveNum_reg		<= wave_num				;

					end
					else
						All_WaveNum_reg		<= All_WaveNum_reg					;
			end
			else begin
				All_WaveNum_reg				<= 6'd63					;
			end
		end
	end	
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			All_WaveNum					<= 6'd63					;
		end
		else begin
			if((rd_ready == 1'b1) && (frame_start_pose_edge ==1'b1))  begin	 
				All_WaveNum		<= All_WaveNum_reg				;

			end
			else begin
				All_WaveNum				<= All_WaveNum					;
			end
		end
	end	


assign wr_addr ={wave_num, prt_num};



always@(posedge clk or posedge rst) begin
	if(rst == 1'b1) begin
		rd_ready				<= 1'b0		;
	end
	else begin
		if(timer_module_en == 1'b1) begin
			if(prt_num == prt_num_per_frame)
				rd_ready		<= 1'b1		;
			else
				rd_ready		<= rd_ready	;
		end
		else
			rd_ready			<= 1'b0			;	
	end
end

always@(posedge clk or posedge rst) begin
	if(rst == 1'b1) begin
		frame_ref_fft				<= 1'b0		;
	end
	else begin
		if(rd_ready == 1'b1) begin
			frame_ref_fft			<= frame_start_pose_edge	;
		end
		else
			frame_ref_fft			<= 1'b0			;	
	end
end


endmodule
