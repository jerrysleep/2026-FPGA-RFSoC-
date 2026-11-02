`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


(*KEEP_HIERARCHY = "YES"*)module Radar_Processor(
	(* KEEP = "true" *) input							clk					,
	(* KEEP = "true" *) input							rst					,
	(* KEEP = "true" *) input							pc_tx_on_off		,		 
	(* KEEP = "true" *) input							just_receive		,		 
	(* KEEP = "true" *) input							program_start		,		 
	(* KEEP = "true" *) input		[15:0]				program_wait_time	,		 
	(* KEEP = "true" *) input		[15:0]				program_hold_time	,		 
	(* KEEP = "true" *) input							program_reset		,		 
	(* KEEP = "true" *) 
	(* KEEP = "true" *) output	reg	[3:0]				radar_mode			,		 
	(* KEEP = "true" *) output							tx_on_off			,		 
	(* KEEP = "true" *) output	reg						receive_on					 

    );
	
	(* KEEP = "true" *) reg		[27:0]					prog_wait_cycle_cnt		;	 
	(* KEEP = "true" *) reg		[27:0]					prog_hold_cycle_cnt		;	 
	(* KEEP = "true" *) reg		[15:0]					prog_wait_second		;	 
	(* KEEP = "true" *) reg		[15:0]					prog_hold_second		;	 
	
	(* KEEP = "true" *) reg								prog_tx_on_off			;	 
	
	assign			tx_on_off = pc_tx_on_off || prog_tx_on_off	;		 
	
	parameter		IDLE		= 		4'b0001				;
	parameter		RECEIVE 	= 		4'b0010				;
	parameter		WORK		= 		4'b0100				;
	parameter		PROG		= 		4'b1000				;
	
	(* KEEP = "true" *) reg		[3:0]					state					;
	(* KEEP = "true" *) reg		[3:0]					next_state				;
	
	
	always @(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
			state						<= IDLE					;
		end		
		else begin		
			state						<= next_state			;
		end
	end
	
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			next_state					<= IDLE					;
		end
		else begin
			case(state) 
				IDLE: begin
					if(pc_tx_on_off== 1'b1) begin
						next_state		<= WORK					;
					end
					else if(just_receive == 1'b1) begin
						next_state		<= RECEIVE				;
					end
					else if(program_start == 1'b1) begin
						next_state		<= PROG					;
					end
					else begin
						next_state		<= IDLE					;
					end
				end
				RECEIVE: begin
					if(pc_tx_on_off== 1'b1) begin
						next_state		<= WORK					;
					end
					else if(program_start == 1'b1) begin
						next_state		<= PROG					;
					end
					else if(just_receive == 1'b0) begin
						next_state		<= IDLE					;
					end
					else begin
						next_state		<= RECEIVE				;
					end
				end
				WORK: begin
					if(pc_tx_on_off== 1'b0) begin
						next_state		<= IDLE					;
					end
					else begin
						 
							 
						 
							next_state	<=	WORK				; 
						 
					end
				end
				PROG: begin
					if(pc_tx_on_off == 1'b1) begin
						next_state		<= WORK				;
					end
					else begin
						if(program_start == 1'b0)	begin
							next_state	<= IDLE				;
						end
						else begin
							next_state	<= PROG				;
						end
					end	
				end
				default: begin
					next_state	<= IDLE					;
				end
				
			
			endcase
		end
	end
	
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			receive_on				<= 1'b0				;
			prog_tx_on_off			<= 1'b0				;
		end
		else begin
			case(state)
				IDLE: begin
					receive_on		<= 1'b0				;
					prog_tx_on_off	<= 1'b0				;
				end
				WORK: begin
					receive_on		<= 1'b1				;
					prog_tx_on_off	<= 1'b0				;
				end
				RECEIVE: begin
					receive_on		<= 1'b1				;
					prog_tx_on_off	<= 1'b0				;
				end
				PROG:begin
					if((prog_wait_second >= program_wait_time) && (program_hold_time <=program_hold_time )) begin
						prog_tx_on_off	<= 1'b1			;
						receive_on		<= 1'b1			;
					end
					else begin
						prog_tx_on_off	<= 1'b0			;
						receive_on		<= receive_on	;		 
					end					
				end				
			endcase
		end
	end
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			radar_mode				<= 4'd0				;
		end
		else begin
			radar_mode				<= state			;
		end
	end
	
	 
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			prog_wait_cycle_cnt		<= 28'd0			;
			prog_wait_second		<= 16'd0			;
		end
		else begin
			if (program_reset == 1'b1) begin
				prog_wait_cycle_cnt		<= 28'd0			;
				prog_wait_second		<= 16'd0			;				
			end
			else begin
				if(prog_wait_cycle_cnt >= 28'd99_999_999)	begin
					prog_wait_cycle_cnt	<= 28'd0		;
					prog_wait_second	<= prog_wait_second + 16'd1	;
				end
				else begin
					prog_wait_cycle_cnt	<= prog_wait_cycle_cnt + 28'd1	;
					prog_wait_second	<= prog_wait_second				;					
				end				
			end
		end
	end
	 
	always @(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
			prog_hold_cycle_cnt			<= 28'd0		;
			prog_hold_second			<= 16'd0		;
			
		end
		else begin
			if(prog_tx_on_off == 1'b1) begin
				if(prog_hold_cycle_cnt >= 28'd99_999_999) begin
					prog_hold_cycle_cnt	<= 28'd0		;
					prog_hold_second	<= prog_hold_second + 28'd1	;
				end
				else begin
					prog_hold_cycle_cnt	<= prog_hold_cycle_cnt + 28'd1	;
					prog_hold_second	<= prog_hold_second			;
				end
			end
			else begin
				prog_hold_cycle_cnt			<= 28'd0		;
				prog_hold_second			<= 16'd0		;
			
			end
			
		end
	end
	
	
	
endmodule
