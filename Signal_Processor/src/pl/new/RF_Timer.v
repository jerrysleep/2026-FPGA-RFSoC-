`timescale 1ns / 1ps
`include	"define.vh"
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
(*KEEP_HIERARCHY = "YES"*)module RF_Timer(
	input								clk					,		 
	input								rst					,		 
	input								tx_on_off			,		 
	input								receive_en			,		 
	input								decimate_16			,		 
	input								far_or_near			,		 


 
	input			[15:0]				upc_delay_tf_pm		,		 
	input			[15:0]				upc_length_tf_pm	,		 
	input			[15:0]				upc_delay_tf_pc		,		 
	input			[15:0]				upc_length_tf_pc	,		 
	input			[15:0]				upc_delay_tr_k		,		 
	input			[15:0]				upc_length_tr_k		,		 
	input			[15:0]				upc_delay_ADC		,		 
	input			[15:0]				upc_length_ADC		,		 
	input			[15:0]				upc_delay_PhaseRef	,		 
	input			[15:0]				upc_length_PhaseRef	,		 

	input			[15:0]				prt_period			,		 
	input			[31:0]				frame_period		,		 
	input			[15:0]				prt_num				,		 
	
	 
	(* KEEP = "true" *) output								TF_pm				,		 
	(* KEEP = "true" *) output								TF_pc				,		 
	(* KEEP = "true" *) output								TR_k				,		 
	(* KEEP = "true" *) output								PhaseRef_k			,		 

	(* KEEP = "true" *) output	reg							gate_buff_o			,		 
	(* KEEP = "true" *) output								frame_ref_buff		,		 
	(* KEEP = "true" *) output								prt_ref_buff		,
	(* KEEP = "true" *) output	reg							frame_ref			,		 
	(* KEEP = "true" *) output								TF_status,					 
	(* KEEP = "true" *) output	reg							prt_ref				,
					 
	(* KEEP = "true" *) output								prt_ref_b1			,
	(* KEEP = "true" *)	output								frame_ref_b1						
						
);

 

	(* KEEP = "true" *) wire								gate_buff			;
	

	(* KEEP = "true" *) reg			     [7:0]				frame_delay_para	;		 

 
	(* KEEP = "true" *) reg				[15:0]				delay_tf_pm			;		 
	(* KEEP = "true" *) reg				[15:0]				length_tf_pm		;		 
	(* KEEP = "true" *) reg				[15:0]				delay_tf_pc			;		 
	(* KEEP = "true" *) reg				[15:0]				length_tf_pc		;		 
	(* KEEP = "true" *) reg				[15:0]				delay_tr_k			;		 
	(* KEEP = "true" *) reg				[15:0]				length_tr_k			;		 
	(* KEEP = "true" *) reg				[15:0]				delay_ADC			;		 
	(* KEEP = "true" *) reg				[15:0]				length_ADC			;		 
	(* KEEP = "true" *) reg				[15:0]				delay_PhaseRef		;		 
	(* KEEP = "true" *) reg				[15:0]				length_PhaseRef		;		 
	
	(* KEEP = "true" *) reg				[7:0]				dec_cnt				;
	(* KEEP = "true" *) reg									gate_d1				;
	(* KEEP = "true" *) reg									gate_d2				;
	(* KEEP = "true" *) reg									decimate_16_frame	;		 
	
	 
	 
	 
	 
	 
	 
	 
	 

	 
	 
	 
	 
	 
	 
	 
	 
	
	 
	 
	 
 
    
    wire TR_k_tmp;

	assign	TF_status		 = tx_on_off						;
	assign	TR_k		     = ~TR_k_tmp						;

	 
	always @(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
					delay_tf_pm					<= 16'd1				;
					length_tf_pm				<= 16'd49				;
					delay_tf_pc					<= 16'd1				;
					length_tf_pc				<= 16'd49				;
                    delay_tr_k			    	<= 16'd84		    	;		      
                    length_tr_k			    	<= 16'd200		    	;             
                    delay_ADC			    	<= 16'd180		    	;		      
                    length_ADC			    	<= 16'd250		    	;	          
					frame_delay_para            <= 16'd0                ;
					delay_PhaseRef				<= 16'd0				;
					length_PhaseRef				<= 16'd0				;
		end
		else begin
			if(frame_ref) begin
				if(`USE_UPC_LOCAL == 1'b1) begin
					delay_tf_pm		 			<=	upc_delay_tf_pm			;
					length_tf_pm	 			<=	upc_length_tf_pm		;
					delay_tf_pc		 			<=	upc_delay_tf_pc			;
					length_tf_pc	 			<=	upc_length_tf_pc		;
					delay_tr_k		 			<=	upc_delay_tr_k			;
					length_tr_k		 			<=	upc_length_tr_k			;
					delay_ADC		 			<=	upc_delay_ADC			;
					length_ADC		 			<=	upc_length_ADC			;
					delay_PhaseRef				<=	upc_delay_PhaseRef		;
					length_PhaseRef				<=	upc_length_PhaseRef		;
					
				end	
				else begin
					delay_tf_pm		 			<=	`local_delay_tf_pm		;
					length_tf_pm	 			<=	`local_length_tf_pm		;
					delay_tf_pc		 			<=	`local_delay_tf_pc		;
					length_tf_pc	 			<=	`local_length_tf_pc		;
					delay_tr_k		 			<=	`local_delay_tr_k		;
					length_tr_k		 			<=	`local_length_tr_k		;
					delay_ADC		 			<=	`local_delay_ADC		;
					length_ADC		 			<=	`local_length_ADC		;
					delay_PhaseRef				<=	`local_delay_PhaseRef		;
					length_PhaseRef				<=	`local_length_PhaseRef		;					
					
				end
			
			end
			else begin
					delay_tf_pm					<= delay_tf_pm				;
					length_tf_pm				<= length_tf_pm				;
					delay_tf_pc					<= delay_tf_pc				;
					length_tf_pc				<= length_tf_pc				;
					delay_tr_k					<= delay_tr_k				;
					length_tr_k					<= length_tr_k				;
					delay_ADC					<= delay_ADC				;
					length_ADC					<= length_ADC				;
					frame_delay_para            <= delay_ADC                ;
					delay_PhaseRef				<= delay_PhaseRef			;
					length_PhaseRef				<= length_PhaseRef			;					
					
			end
		end
	end	
	 
		 
					 
					 
		 
		 
			 
				 
					 
					 
				 
				 
					 
					 
				 
			 
			 
					 
					 
			 
		 
	 
	
	 
		 
		
		 
		 
		
		 
	 
	
	 
		 
		
		 
		 
		
		 
	 
	
	
	
	
	 
	 
	always @(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
						gate_d1				<= 1'b0				;
						gate_d2				<= 1'b0				;
		end	
		else begin	
						gate_d1				<= gate_buff		;
						gate_d2				<= gate_d1			;
		end
	end
	
	always @(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
						dec_cnt				<= 8'd0				;
		end
		else begin
			if(decimate_16_frame == 1'b1 ) begin
				if((gate_d2 == 1'b1) &&(gate_d1 == 1'b0)) begin
					if(dec_cnt == `DECIMATOR_PARA) 
						dec_cnt				<= 8'd0				;
					else
						dec_cnt				<= dec_cnt + 8'd1	;
				end
				else begin
						dec_cnt				<= dec_cnt			;
				end
			end
			else begin 
						dec_cnt				<= 8'd0				;
			end
		end
	end
	 
	always @(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
						gate_buff_o			<= 1'b0				;
		end
		else begin
			if(dec_cnt == 8'd0) begin
						gate_buff_o			<= gate_buff		;
			end
			else begin
						gate_buff_o			<= 1'b0				;
			end
		end
	end


 

 


	always @(posedge clk or posedge rst) begin
		if(rst == 1'b1) begin
			frame_ref				<= 1'b0				;
			prt_ref					<= 1'b0				;
		end
		else begin
			frame_ref				<= frame_ref_b1				;
			prt_ref					<= prt_ref_b1				;
		end
	end


timing_ref							u_timing_ref (						 
	.clk							(	clk					)	, 
	.rst							(	rst					)	,
	.PRT							(	prt_period			)	,
	.FRAME_TIME						(	frame_period		)	,
	.PRT_NUM						(	prt_num				)	,
	.frame_ref						(	frame_ref_b1			)	,
	.prt_ref						(	prt_ref_b1				)
	);

timing_cell							timing_cell_TF_PM (				 
	.clk							(	clk					)	, 
	.rst							(	rst					)	, 
	.pul_in							(	prt_ref				)	,
	.en								(	tx_on_off			)	,						 
	.delay_in						(	delay_tf_pm			)	, 
	.width							(	length_tf_pm		)	, 
	.pul_out						(	TF_pm				)
	);
	 
timing_cell							timing_cell_TF_PC (				 
	.clk							(	clk					)	, 
	.rst							(	rst					)	, 
	.pul_in							(	prt_ref				)	,
	 .en							(	tx_on_off			)	,	 
	.delay_in						(	delay_tf_pc			)	, 
	.width							(	length_tf_pc		)	, 
	.pul_out						(	TF_pc				)
	);

timing_cell							timing_cell_RF_K (				 
	.clk							(	clk					)	, 
	.rst							(	rst					)	, 
	.pul_in							(	prt_ref				)	,
	.en								(	receive_en			)	,	  
	.delay_in						(	delay_tr_k			)	, 
	.width							(	length_tr_k			)	, 
	.pul_out						(	TR_k_tmp       		)
	);
	 
 
timing_cell							timing_cell_ADC (					 
	.clk							(	clk					)	, 
	.rst							(	rst					)	, 
	.pul_in							(	prt_ref				)	, 
	.en								(	receive_en			)	,
	.delay_in						(	delay_ADC			)	, 
	.width							(	length_ADC			)	, 
	.pul_out						(	gate_buff			)
	);
 
timing_cell							timing_cell_PhaseRef (					 
	.clk							(	clk					)	, 
	.rst							(	rst					)	, 
	.pul_in							(	prt_ref				)	, 
	.en								(	1'b1			)	,
	.delay_in						(	delay_PhaseRef		)	, 
	.width							(	length_PhaseRef		)	, 
	.pul_out						(	PhaseRef_k			)
	);
	
	wire							frameref_buff_far		;
	wire							frameref_buff_near		;

gate_buff_ctrl					frame_start_ctrl (							 
	.clk							(	clk					)	, 
	.rst							(	rst					)	, 
	.frame_ref						(	frame_ref			)	, 
	.frame_delay_para				(	frame_delay_para	)	,			 
	.frame_ref_buff					(	frame_ref_buff		)
	);
 
gate_buff_ctrl					prt_start_ctrl (							 
	.clk							(	clk					)	, 
	.rst							(	rst					)	, 
	.frame_ref						(	prt_ref			)	, 
	.frame_delay_para				(	frame_delay_para	)	,			 
	.frame_ref_buff					(	prt_ref_buff		)
	);

	
 
	 

     
	 
	 
	 
	 
	 
	
 
	 

     
	 
	 
	 
	 
	 

	 

	 
endmodule
