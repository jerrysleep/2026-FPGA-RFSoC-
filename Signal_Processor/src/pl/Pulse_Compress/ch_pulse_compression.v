`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

module ch_pulse_compression (
    input   wire        clk,
    input   wire        rst,
    input   wire        en_in,

    input   wire        frame_start,
    input   wire        prt_ref,
    input   wire        far_or_near,

    input   wire [15:0] din_i,
    input   wire [15:0] din_q,

(* KEEP = "true" *)   	output  reg  [15:0] dout_i,
(* KEEP = "true" *)   	output  reg  [15:0] dout_q,
(* KEEP = "true" *)   	output  reg         dout_valid,
(* KEEP = "true" *)		output	reg			compress_ptr	,
(* KEEP = "true" *)   	output  reg	         frame_out,
(* KEEP = "true" *)   	output  reg         far_or_near_out
);

 
 
 
localparam NUM_UNITS = 3;
localparam FFT_SIZE = 128;
localparam FAR_POINTS = 60;
localparam NEAR_POINTS = 49;
localparam FAR_OUT_POINTS = 61;
localparam NEAR_OUT_POINTS = 49;


(* KEEP = "true" *)reg [15:0] 			prt_cnt;
(* KEEP = "true" *)reg        			frame_start_d1;
(* KEEP = "true" *)reg        			frame_start_rise;
(* KEEP = "true" *)reg 				far_or_near_latched;
(* KEEP = "true" *)reg [NUM_UNITS-1:0]	far_or_near_reg3	;	

(* KEEP = "true" *)reg [15:0] 			din_i_d1;
(* KEEP = "true" *)reg [15:0] 			din_q_d1;
(* KEEP = "true" *)reg [15:0] 			din_i_d2;
(* KEEP = "true" *)reg [15:0] 			din_q_d2;
(* KEEP = "true" *)reg         		din_valid_raw;
(* KEEP = "true" *)reg  [1:0]  		decim_cnt;
(* KEEP = "true" *)reg         		prt_ref_d1;
(* KEEP = "true" *)reg         		prt_ref_rise;

(* KEEP = "true" *)reg					en			;
 
 
 

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        en <= 1'b0;
    end
    else begin
        if(frame_start == 1'b1)  begin			 
            en <= en_in;
        end
        else begin
            en <= en;
        end
    end
end

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        frame_start_d1 <= 1'b0;
        frame_start_rise <= 1'b0;
    end
     
         
     
    else begin
        frame_start_d1 <= frame_start;
        if((frame_start == 1'b1) && (frame_start_d1 == 1'b0)) begin
            frame_start_rise <= 1'b1;
        end
        else begin
            frame_start_rise <= 1'b0;
        end
    end
end

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        prt_cnt <= 16'd0;
    end
     
         
     
    else begin
        if(frame_start_rise == 1'b1) begin
            prt_cnt <= 16'd0;
        end
        else if(prt_ref == 1'b1) begin
            prt_cnt <= prt_cnt + 16'd1;
        end
    end
end

 
 
 

	
always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        far_or_near_latched <= 1'b1;
    end
    else if(en == 1'b0) begin
        far_or_near_latched <= 1'b1;
    end
    else begin
        if(frame_start_rise == 1'b1) begin
            far_or_near_latched <= far_or_near;		 
        end
    end
end
 
 
     
         
     
     
         
     
     
		 
			 
		 
			 
     
 

 

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        frame_out <= 1'b0;
    end
    else if(en == 1'b0) begin
        frame_out <= 1'b0;
    end
    else begin
			if(far_or_near_out == 1'b1)
				frame_out <= frameref_buff_far;
			else
				frame_out	<= frameref_buff_near		;
    end
end

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        far_or_near_out <= 1'b1;
    end
    else if(en == 1'b0) begin
        far_or_near_out <= 1'b1;
    end
    else begin
			if(frame_out == 1'b1)
				far_or_near_out <= far_or_near_latched;
			else
				far_or_near_out	<= far_or_near_out		;
    end
end

 
 
 

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        din_i_d1 <= 16'd0;
        din_q_d1 <= 16'd0; 
		din_i_d2 <= 16'd0;
        din_q_d2 <= 16'd0;
    end
    else if(en == 1'b0) begin
        din_i_d1 <= 16'd0;
        din_q_d1 <= 16'd0;
        din_i_d2 <= 16'd0;
        din_q_d2 <= 16'd0;
    end
    else begin
        din_i_d1 <= din_i;
        din_q_d1 <= din_q;
        din_i_d2 <= din_i_d1;
        din_q_d2 <= din_q_d1;
    end
end

 
 
 

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        prt_ref_d1 <= 1'b0;
        prt_ref_rise <= 1'b0;
    end
     
         
     
    else begin
        prt_ref_d1 <= prt_ref;
        if((prt_ref == 1'b1 )&& (prt_ref_d1 == 1'b0)) begin
            prt_ref_rise <= 1'b1;
        end
        else begin
            prt_ref_rise <= 1'b0;
        end
    end
end

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        decim_cnt <= 2'd0;
        din_valid_raw <= 1'b0;
    end
    else if(en == 1'b0) begin
        decim_cnt <= 2'd0;
        din_valid_raw <= 1'b0;
    end
    else begin
        if(prt_ref_rise == 1'b1) begin
            din_valid_raw <= 1'b1;
            decim_cnt <= 2'd0;
        end
        else if(far_or_near_latched == 1'b1) begin
             
            if(decim_cnt == 2'd0) begin                
				decim_cnt <= decim_cnt + 2'd1;
                din_valid_raw <= 1'b1;
            end
            else begin
                decim_cnt <= 2'd0;
                din_valid_raw <= 1'b0;
            end
        end
        else begin
             
            decim_cnt <= 2'd0;
            din_valid_raw <= 1'b1;
        end
    end
end

 
 
 

	reg	[1:0]next_unit	;
	reg	unit0_start ;
	reg	unit1_start ;
	reg	unit2_start ;

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        next_unit 	<= 2'd0;
		unit0_start	<= 1'b0	;
		unit1_start <= 1'b0	;
		unit2_start <= 1'b0	;
    end
    else if(en == 1'b0) begin
        next_unit 	<= 2'd0;
		unit0_start	<= 1'b0	;
		unit1_start <= 1'b0	;
		unit2_start <= 1'b0	;
    end
    else begin
        if(prt_ref_rise == 1'b1) begin
			if(next_unit == 2'd2)
					next_unit	<= 2'd0			;
			else
				next_unit	<= next_unit + 1;
			case(next_unit)
				2'd0:begin
					unit0_start	<= 1'b1	;
					unit1_start <= 1'b0	;
					unit2_start <= 1'b0	;				
				end
				2'd1: begin
					unit0_start	<= 1'b0	;
					unit1_start <= 1'b1	;
					unit2_start <= 1'b0	;					
				end
				2'd2: begin
					unit0_start	<= 1'b0	;
					unit1_start <= 1'b0	;
					unit2_start <= 1'b1	;					
				end
				default: begin
					unit0_start	<= 1'b0	;
					unit1_start <= 1'b0	;
					unit2_start <= 1'b0	;					
				end
				
			endcase
			
        end
		else begin
			next_unit		<= next_unit	;
			unit0_start		<= 1'b0	;
			unit1_start 	<= 1'b0	;
			unit2_start 	<= 1'b0	;		
		end
    end
end


 
 
 
(* KEEP = "true" *) wire [15:0] unit0_dout_i, unit0_dout_q;
(* KEEP = "true" *) wire        unit0_dout_valid, unit0_done;
(* KEEP = "true" *) wire [15:0] unit1_dout_i, unit1_dout_q;
(* KEEP = "true" *) wire        unit1_dout_valid, unit1_done;
(* KEEP = "true" *) wire [15:0] unit2_dout_i, unit2_dout_q;
(* KEEP = "true" *) wire        unit2_dout_valid, unit2_done;

ch_pulse_compression_unit u_unit0 (
    .clk        		(clk),
    .rst        		(rst),
    .en         		(en),
    .start      		(unit0_start),
    .far_or_near		(far_or_near_latched),
	.far_or_near_out 	(far_or_near_out	),
    .din_i      		(din_i_d2),
    .din_q      		(din_q_d2),
    .din_valid  		(din_valid_raw),
    .dout_i     		(unit0_dout_i),
    .dout_q     		(unit0_dout_q),
    .dout_valid 		(unit0_dout_valid),
    .done       		(unit0_done)
);

ch_pulse_compression_unit u_unit1 (
    .clk        		(clk),
    .rst        		(rst),
    .en         		(en),
    .start      		(unit1_start),
    .far_or_near		(far_or_near_latched),
	.far_or_near_out 	(far_or_near_out	),	
    .din_i      		(din_i_d2),
    .din_q      		(din_q_d2),
    .din_valid  		(din_valid_raw),
    .dout_i     		(unit1_dout_i),
    .dout_q     		(unit1_dout_q),
    .dout_valid 		(unit1_dout_valid),
    .done       		(unit1_done)
);

ch_pulse_compression_unit u_unit2 (
    .clk        		(clk),
    .rst        		(rst),
    .en         		(en),
    .start      		(unit2_start),
    .far_or_near		(far_or_near_latched),
	.far_or_near_out 	(far_or_near_out	),
    .din_i      		(din_i_d2),
    .din_q      		(din_q_d2),
    .din_valid  		(din_valid_raw),
    .dout_i     		(unit2_dout_i),
    .dout_q     		(unit2_dout_q),
    .dout_valid 		(unit2_dout_valid),
    .done       		(unit2_done)
);

 
 
 

(* KEEP = "true" *)reg				unit0_dout_valid_d1;
(* KEEP = "true" *)reg				unit1_dout_valid_d1;
(* KEEP = "true" *)reg				unit2_dout_valid_d1;
	

always @(posedge clk or posedge rst) begin
	if(rst == 1'b1) begin
		unit0_dout_valid_d1					<= 1'b0		;
	    unit1_dout_valid_d1					<= 1'b0		;
	    unit2_dout_valid_d1					<= 1'b0		;
	end
	else begin
		unit0_dout_valid_d1					<= unit0_dout_valid		;
	    unit1_dout_valid_d1					<= unit1_dout_valid		;
	    unit2_dout_valid_d1					<= unit2_dout_valid		;	
	end
end

always@(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		compress_ptr						<= 1'b0			;
	end
	else begin
		if(((unit0_dout_valid== 1'b1)&&(unit0_dout_valid_d1== 1'b0)) ||((unit1_dout_valid== 1'b1)&&(unit1_dout_valid_d1== 1'b0)) ||((unit2_dout_valid== 1'b1)&&(unit2_dout_valid_d1== 1'b0)))
			compress_ptr					<= 1'b1			;
		else
			compress_ptr					<= 1'b0			;
	end
end



always@(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		dout_i								<= 16'd0		;
	    dout_q								<= 16'd0		;
	    dout_valid							<= 1'b0			;
	end
	else begin
		
		if(unit0_dout_valid == 1'b1) begin
			dout_i								<= unit0_dout_i		;
			dout_q								<= unit0_dout_q		;
			dout_valid							<= 1'b1			;	
		end
		else if(unit1_dout_valid == 1'b1) begin
			dout_i								<= unit1_dout_i		;
			dout_q								<= unit1_dout_q		;
			dout_valid							<= 1'b1			;			
		end
		else if(unit2_dout_valid == 1'b1) begin
			dout_i								<= unit2_dout_i		;
			dout_q								<= unit2_dout_q		;
			dout_valid							<= 1'b1			;			
		end
		else begin
			dout_i								<= 16'd0		;
			dout_q								<= 16'd0		;
			dout_valid							<= 1'b0			;			
		end
	end
end

	
FrameRef_delay_ctrl#(
	.DELAY_CYCLE					(	32'd919	)	               			 

    )FrameRef_delay_pC_FAR(
	.clk							(	clk					)	,
	.rst							(	rst					)	,
	.frameref_in					(	frame_start			)	,
	.frameref_out					(	frameref_buff_far	)
	);
	
FrameRef_delay_ctrl#(
	.DELAY_CYCLE					(	32'd860				)				 

    )FrameRef_delay_pC_NEAR(
	.clk							(	clk					)	,
	.rst							(	rst					)	,
	.frameref_in					(	frame_start			)	,
	.frameref_out					(	frameref_buff_near	)
	);


 
	 
		
		
	 
	 
		
		
	 
 

 
	 
		
		
	 
	 
		
		
	 
 


 
 
 
 

 

 
     
         
         
         
         
         
         
         
         
     
     
         
         
         
     
     
         
         
         
             
             
             
             
             
                 
             
         
         
			 
             
             
                 
                     
                         
                         
                         
                         
                         
                             
                             
                         
                     
                 
                 
                     
                         
                         
                         
                         
                         
                             
                             
                         
                     
                 
                 
                     
                         
                         
                         
                         
                         
                             
                             
                         
                     
                 
                 
                     
                 
             
         
     
 

endmodule