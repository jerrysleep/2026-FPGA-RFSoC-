`timescale 1ns / 1ps
`include	"define.vh"
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


(*KEEP_HIERARCHY = "YES"*)module Parameter_Ctrl(
	input									clk						,
	input									rst						,
	input									serch_or_track			,		 
	input				[7:0]				current_range_gate		,		 
	input				[7:0]				switch_range_gate		,		 
	(* KEEP = "true" *)	input				[7:0]				Setup_para_mode			,		 
	input		[7:0]						subarray_select_mode	,		 
	output	reg         [1:0]      			subarray_select		    ,		 
	output	reg			[7:0]				current_para_mode		,		 
	output	reg								far_or_near				,		 
	input									frame_ref				,
	input				[15:0]				far_prt_period			,		 
	input				[31:0]				far_frame_period		,		 
	input				[15:0]				far_prt_num				,		 
	input				[15:0]				far_delay_tf_pm			,		 
	input				[15:0]				far_length_tf_pm		,		 
	input				[15:0]				far_delay_tf_pc			,		 
	input				[15:0]				far_length_tf_pc		,		 
	input				[15:0]				far_delay_tr_k			,		 
	input				[15:0]				far_length_tr_k			,		 
	input				[15:0]				far_delay_ADC			,		 
	input				[15:0]				far_length_ADC			,		 
	input				[15:0]				far_delay_PhaseRef		,		 
	input				[15:0]				far_length_PhaseRef		,		 
	input				[7:0]				far_decim_factor		,		 

	input				[15:0]				near_prt_period			,		 
	input				[31:0]				near_frame_period		,		 
	input				[15:0]				near_prt_num			,		 
	input				[15:0]				near_delay_tf_pm		,		 
	input				[15:0]				near_length_tf_pm		,		 
	input				[15:0]				near_delay_tf_pc		,		 
	input				[15:0]				near_length_tf_pc		,		 
	input				[15:0]				near_delay_tr_k			,		 
	input				[15:0]				near_length_tr_k		,		 
	input				[15:0]				near_delay_ADC			,		 
	input				[15:0]				near_length_ADC			,		 
	input				[15:0]				near_delay_PhaseRef		,		 
	input				[15:0]				near_length_PhaseRef	,		 
	input				[7:0]				near_decim_factor		,		 
	
	input               [31:0]              PINC1_near,               
    input               [31:0]              f0_scale_near,            
    input               [31:0]              mu_scale_near,             
    input               [31:0]              f0_scale2_near,            
    input               [31:0]              mu_scale2_near,           
    input               [31:0]              axi_chirp_width_near,           
    input               [31:0]              axi_pulse_period_near,           
    input               [31:0]              pulse_delay,                    
	input               [31:0]              PINC1_far,               
    input               [31:0]              f0_scale_far,            
    input               [31:0]              mu_scale_far,             
    input               [31:0]              f0_scale2_far,            
    input               [31:0]              mu_scale2_far,           
    input               [31:0]              axi_chirp_width_far,           
    input               [31:0]              axi_pulse_period_far,           
    input               [31:0]              axi_fc_scale_near,           
    input               [31:0]              axi_fc_scale_far,           

	(* KEEP = "true" *)	output	reg			[15:0]				prt_period				,		 
	(* KEEP = "true" *)	output	reg			[31:0]				frame_period			,		 
	(* KEEP = "true" *)	output	reg			[15:0]				prt_num					,		 
	(* KEEP = "true" *)	output	reg			[15:0]				upc_delay_tf_pm			,		 
	(* KEEP = "true" *)	output	reg			[15:0]				upc_length_tf_pm		,		 
	(* KEEP = "true" *)	output	reg			[15:0]				upc_delay_tf_pc			,		 
	(* KEEP = "true" *)	output	reg			[15:0]				upc_length_tf_pc		,		 
	(* KEEP = "true" *)	output	reg			[15:0]				upc_delay_tr_k			,		 
	(* KEEP = "true" *)	output	reg			[15:0]				upc_length_tr_k			,		 
	(* KEEP = "true" *)	output	reg			[15:0]				upc_delay_ADC			,		 
	(* KEEP = "true" *)	output	reg			[15:0]				upc_length_ADC			,		 
	(* KEEP = "true" *)	output	reg			[15:0]				upc_delay_PhaseRef		,		 
	(* KEEP = "true" *)	output	reg			[15:0]				upc_length_PhaseRef		,		 
	(* KEEP = "true" *)	output	reg			[3:0]				decim_factor			,		 

    (* KEEP = "true" *) output reg  [31:0]      upc_PINC1,               
    (* KEEP = "true" *) output reg  [31:0]      upc_f0_scale,            
    (* KEEP = "true" *) output reg  [31:0]      upc_mu_scale,             
    (* KEEP = "true" *) output reg  [31:0]      upc_f0_scale2,            
    (* KEEP = "true" *) output reg  [31:0]      upc_mu_scale2,           
    (* KEEP = "true" *) output reg  [31:0]      upc_axi_chirp_width,           
    (* KEEP = "true" *) output reg  [31:0]      upc_axi_pulse_period,           
    (* KEEP = "true" *) output reg  [31:0]      upc_pulse_delay,                    
    (* KEEP = "true" *) output reg  [31:0]      upc_fc_scale

    );
	
	always@(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
			current_para_mode			<= 8'h11				;		 
		end
		else begin
			case(Setup_para_mode) 
				8'h00:	begin				 
					current_para_mode		<= 8'h00			;
				end
				8'h11: begin				 
					current_para_mode		<= 8'h11			;
				end
				8'h22: begin				 
					if(serch_or_track == 1'b1) begin
						if((current_para_mode == 8'h11) &&(current_range_gate <= switch_range_gate)) 	 
							current_para_mode	<= 8'h00		;
						else
							current_para_mode	<= 8'h11		;
					end
					else begin
						current_para_mode	<= 8'h11			;
					end
					
				end
				default: begin				 
					current_para_mode		<= 8'h11				;
				end
			endcase			
		end
	end
	
	
	always@(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
			subarray_select			<= 2'b00				;		 
		end
		else begin
			if(frame_ref)begin
				case(subarray_select_mode) 
					8'h00:	begin				 
						subarray_select		<= 2'b00			;
					end
					8'h11: begin				 
						subarray_select		<= 2'b11		;
					end
					8'hFF: begin				 
						subarray_select		<= ~subarray_select	;					
					end
					default: begin				 
						subarray_select		<= 2'b00				;
					end
				endcase	
			end
			else begin
				subarray_select			<= subarray_select	;
			end
		end
	end
	
	
	
	
	 
	
	always@(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			upc_delay_tf_pm				<= `local_delay_tf_pm		;
			upc_length_tf_pm			<= `local_length_tf_pm		;
			upc_delay_tf_pc				<= `local_delay_tf_pc		;
			upc_length_tf_pc			<= `local_length_tf_pc		;
			upc_delay_tr_k				<= `local_delay_tr_k		;
			upc_length_tr_k				<= `local_length_tr_k		;
			upc_delay_ADC				<= `local_delay_ADC		    ;
			upc_length_ADC				<= `local_length_ADC		;
			upc_delay_PhaseRef			<= `local_delay_PhaseRef	;
			upc_length_PhaseRef			<= `local_length_PhaseRef	;
			 
			 
			 
			 
			
   

		end
		else begin
			if(current_para_mode == 8'h11)begin
				upc_delay_tf_pm			<= far_delay_tf_pm			;
				upc_length_tf_pm		<= far_length_tf_pm			;
				upc_delay_tf_pc			<= far_delay_tf_pc			;
				upc_length_tf_pc		<= far_length_tf_pc			;
				upc_delay_tr_k			<= far_delay_tr_k			;
				upc_length_tr_k			<= far_length_tr_k			;
				upc_delay_ADC			<= far_delay_ADC			;
				upc_length_ADC			<= far_length_ADC			;
				upc_delay_PhaseRef		<= far_delay_PhaseRef		;
				upc_length_PhaseRef		<= far_length_PhaseRef		;
				 
				 
				 
				 


			end
			else if(current_para_mode == 8'h00) begin
				upc_delay_tf_pm			<= near_delay_tf_pm			;
				upc_length_tf_pm		<= near_length_tf_pm		;
				upc_delay_tf_pc			<= near_delay_tf_pc			;
				upc_length_tf_pc		<= near_length_tf_pc		;
				upc_delay_tr_k			<= near_delay_tr_k			;
				upc_length_tr_k			<= near_length_tr_k			;
				upc_delay_ADC			<= near_delay_ADC			;
				upc_length_ADC			<= near_length_ADC			;
				upc_delay_PhaseRef		<= near_delay_PhaseRef		;
				upc_length_PhaseRef		<= near_length_PhaseRef		;

				
         	
			end
			else begin
				upc_delay_tf_pm			<= upc_delay_tf_pm			;
				upc_length_tf_pm		<= upc_length_tf_pm			;
				upc_delay_tf_pc			<= upc_delay_tf_pc			;
				upc_length_tf_pc		<= upc_length_tf_pc			;
				upc_delay_tr_k			<= upc_delay_tr_k			;
				upc_length_tr_k			<= upc_length_tr_k			;
				upc_delay_ADC			<= upc_delay_ADC			;
				upc_length_ADC			<= upc_length_ADC			;
				upc_delay_PhaseRef		<= upc_delay_PhaseRef		;
				upc_length_PhaseRef		<= upc_length_PhaseRef		;		
       						
			end
		end		
	end
	
	
		
	always@(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			far_or_near					<= 1'b1		;
			prt_period		 			<= `LOCAL_PRT_Period		;
			prt_num			 			<= `LOCAL_PRT_Num			;
			frame_period				<= `LOCAL_FRAME_Period		;
			decim_factor				<= 4'd1						;
			
			upc_PINC1                   <= 32'd26843545;  
			upc_f0_scale                <= 32'd1610612736;
			upc_mu_scale                <= 32'd838861;    
			upc_f0_scale2               <= 32'd1795162112;
			upc_mu_scale2               <= 32'd13107;     
			upc_axi_chirp_width         <= 32'd40;        
			upc_axi_pulse_period        <= 32'd97;        
			upc_pulse_delay             <= 32'd0;        
			upc_fc_scale                <= 32'd3435973837;        

		end
		else begin
			if (frame_ref) begin
				if(current_para_mode == 8'h11)begin
					far_or_near				<= 1'b1		;
					prt_period		 		<= far_prt_period			;
					prt_num			 		<= far_prt_num				;
					frame_period			<= far_frame_period			;
					decim_factor			<= far_decim_factor[3:0]			;			

					upc_PINC1               <= PINC1_far;              
					upc_f0_scale            <= f0_scale_far;        
					upc_mu_scale            <= mu_scale_far;        
					upc_f0_scale2           <= f0_scale2_far;       
					upc_mu_scale2           <= mu_scale2_far;       
					upc_axi_chirp_width     <= axi_chirp_width_far; 
					upc_axi_pulse_period    <= axi_pulse_period_far;
					upc_pulse_delay         <= pulse_delay;
					upc_fc_scale            <= axi_fc_scale_far; 
				end
				else if(current_para_mode == 8'h00) begin
					far_or_near				<= 1'b0						;
					prt_period		 		<= near_prt_period			;
					prt_num			 		<= near_prt_num				;
					frame_period			<= near_frame_period		;		
					decim_factor			<= near_decim_factor[3:0]	;
					upc_PINC1               <= PINC1_near;              
					upc_f0_scale            <= f0_scale_near;        
					upc_mu_scale            <= mu_scale_near;        
					upc_f0_scale2           <= f0_scale2_near;       
					upc_mu_scale2           <= mu_scale2_near;       
					upc_axi_chirp_width     <= axi_chirp_width_near; 
					upc_axi_pulse_period    <= axi_pulse_period_near;
					upc_pulse_delay         <= pulse_delay;          	
					upc_fc_scale            <= axi_fc_scale_near; 
				end
				else begin
					far_or_near				<= far_or_near				;
					prt_period		 		<= prt_period				;
					prt_num			 		<= prt_num					;
					frame_period			<= frame_period				;
					decim_factor			<= decim_factor				;
					upc_PINC1               <= upc_PINC1;              
					upc_f0_scale            <= upc_f0_scale;        
					upc_mu_scale            <= upc_mu_scale;        
					upc_f0_scale2           <= upc_f0_scale2;       
					upc_mu_scale2           <= upc_mu_scale2;       
					upc_axi_chirp_width     <= upc_axi_chirp_width; 
					upc_axi_pulse_period    <= upc_axi_pulse_period;
					upc_pulse_delay         <= upc_pulse_delay;        
					upc_fc_scale            <= upc_fc_scale;   						
				end
			end
			else begin
					far_or_near				<= far_or_near				;
					prt_period		 		<= prt_period				;
					prt_num			 		<= prt_num					;
					frame_period			<= frame_period				;
					decim_factor			<= decim_factor				;
					upc_PINC1               <= upc_PINC1;              
					upc_f0_scale            <= upc_f0_scale;        
					upc_mu_scale            <= upc_mu_scale;        
					upc_f0_scale2           <= upc_f0_scale2;       
					upc_mu_scale2           <= upc_mu_scale2;       
					upc_axi_chirp_width     <= upc_axi_chirp_width; 
					upc_axi_pulse_period    <= upc_axi_pulse_period;
					upc_pulse_delay         <= upc_pulse_delay;  	
					upc_fc_scale            <= upc_fc_scale;   		
			
			end
		end		
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
endmodule
