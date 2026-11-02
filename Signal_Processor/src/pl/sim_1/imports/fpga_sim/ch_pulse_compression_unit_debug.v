`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 

module ch_pulse_compression_unit_debug (
    input   wire        clk,
    input   wire        rst,
    input   wire        en,                      

    input   wire        start,                   
    input   wire        far_or_near,             
    input   wire        far_or_near_out,             
    input   wire [15:0] din_i,
    input   wire [15:0] din_q,
    input   wire        din_valid,               

(* KEEP = "true" *)    output  reg  [15:0] dout_i,
(* KEEP = "true" *)    output  reg  [15:0] dout_q,
(* KEEP = "true" *)    output  reg         dout_valid,
(* KEEP = "true" *)    output  reg         done,                    

    output  wire        dbg_input_fifo_wr_en,
    output  wire [31:0] dbg_input_fifo_din,
    output  wire        dbg_reading,
    output  wire [6:0]  dbg_rd_cnt,
    output  wire [31:0] dbg_input_fifo_dout,
    output  wire        dbg_fft_din_valid,
    output  wire        dbg_fft_saxis_tlast,
    output  wire [31:0] dbg_fft_dout,
    output  wire        dbg_fft_dout_valid,
    output  wire [15:0] dbg_fft_axis_data_tuser,
    output  wire [31:0] dbg_rom_dout,
    output  wire        dbg_mul_valid,
    output  wire [31:0] dbg_fft_dout_d1,
    output  wire [31:0] dbg_mul_dout,
    output  wire        dbg_mul_dout_valid,
    output  wire        dbg_ifft_saxis_tlast,
    output  wire [31:0] dbg_ifft_dout,
    output  wire        dbg_ifft_dout_valid,
    output  wire [15:0] dbg_ifft_axis_data_tuser,
    output  wire [7:0]  dbg_fft_m_axis_status_tdata,
    output  wire        dbg_fft_m_axis_status_tvalid,
    output  wire [7:0]  dbg_ifft_m_axis_status_tdata,
    output  wire        dbg_ifft_m_axis_status_tvalid,
    output  wire        dbg_fft_event_fft_overflow,
    output  wire        dbg_ifft_event_fft_overflow,
    output  wire        dbg_fft_event_status_channel_halt,
    output  wire        dbg_ifft_event_status_channel_halt
);

 
 
 
localparam FFT_SIZE = 128;
localparam FFT_SIZE_sub1 = FFT_SIZE -1;
localparam DATA_WIDTH = 16;
localparam FIFO_DEPTH = 128;
localparam FAR_POINTS = 60;
localparam NEAR_POINTS = 49;
localparam FAR_OUT_POINTS = 61;
localparam NEAR_OUT_POINTS = 48;

wire		[6:0]	points_num ;
wire		[6:0]	out_points_num ;
assign points_num = (far_or_near == 1'b1)? FAR_POINTS :NEAR_POINTS;
assign out_points_num = (far_or_near_out == 1'b1)? FAR_OUT_POINTS :NEAR_OUT_POINTS;
 
 
 
(* KEEP = "true" *)reg         input_fifo_wr_en;
(* KEEP = "true" *)reg  [31:0] input_fifo_din;
(* KEEP = "true" *)wire        input_fifo_rd_en;
(* KEEP = "true" *)wire [31:0] input_fifo_dout;
(* KEEP = "true" *)wire        input_fifo_empty;
(* KEEP = "true" *)wire        input_fifo_full;

 
 
 
 
 
 
 
 
 
 
 
 
 

(* KEEP = "true" *)reg					fifo_rst		;
(* KEEP = "true" *)reg					fft_rstn		;
(* KEEP = "true" *)reg					en_d1			;
(* KEEP = "true" *)reg		[7:0]		rst_cnt			;

always @(posedge clk or posedge rst) begin
	if(rst == 1'b1) begin
		en_d1			<= 1'b0		;
	end
	else begin
		en_d1			<= en		;
	end
end
always @(posedge clk or posedge rst) begin
	if(rst == 1'b1) begin
		rst_cnt			<= 8'd0		;
	end
	else begin
		if(fifo_rst== 1'b1)
			rst_cnt		<= rst_cnt+ 1;
		else
			rst_cnt		<= 8'd0		;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst == 1'b1) begin
		fifo_rst		<= 1'b1		;
		fft_rstn		<= 1'b0		;
	end
	else begin
		if((en_d1== 1'b1) &&(en == 1'b0)) begin
			fifo_rst	<= 1'b1		;
			fft_rstn	<= 1'b0		;
		end
		else if(rst_cnt >8'd50) begin
			fifo_rst	<= 1'b0		;
			fft_rstn	<= 1'b1		;
		end
		else begin
			fifo_rst	<= fifo_rst	;
			fft_rstn	<= fft_rstn	;
		end
	end
end


reg [6:0] rd_cnt;
reg       reading;
reg       fft_saxis_tlast;

PulseCompressfifo_32x256 Input_fifo (
  .clk				(	clk					),                   
  .srst				(	fifo_rst			),                 
  .din				(	input_fifo_din		),                   
  .wr_en			(	input_fifo_wr_en	),               
  .rd_en			(	reading				),               
  .dout				(	input_fifo_dout		),                 
  .full				(	input_fifo_full		),                 
  .empty			(	input_fifo_empty	),               
  .wr_rst_busy		( 						),   
  .rd_rst_busy		( 						)   
);
 
(* KEEP = "true" *)reg [6:0] write_cnt;
(* KEEP = "true" *)reg       write_done;

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        input_fifo_wr_en <= 1'b0;
        input_fifo_din    <= 32'd0;
        write_cnt         <= 7'd0;
    end
    else if(en == 1'b0) begin
        input_fifo_wr_en <= 1'b0;
        write_cnt        <= 7'd0;
    end
    else begin
        if(start == 1'b1) begin
            write_cnt  <= 7'd0;
                   if(din_valid == 1'b1 ) begin
						input_fifo_din <= {din_q, din_i};
						input_fifo_wr_en <= 1'b1;
						 
					end
					else begin
						input_fifo_din <= input_fifo_din;
						input_fifo_wr_en <= 1'b0;
						 
					end			
			
        end
        else if(write_done == 1'b0) begin
             
            if(write_cnt < FFT_SIZE_sub1) begin
                if( write_cnt < points_num) begin
                   if(din_valid == 1'b1 ) begin
						input_fifo_din <= {din_q, din_i};
						input_fifo_wr_en <= 1'b1;
						write_cnt <= write_cnt + 7'd1;
					end
					else begin
						input_fifo_din <= input_fifo_din;
						input_fifo_wr_en <= 1'b0;
						write_cnt <= write_cnt ;					
					end
                end
                else begin
                     
                    input_fifo_din <= 32'd0;
                    input_fifo_wr_en <= 1'b1;
                    write_cnt <= write_cnt + 7'd1;
                end
            end
			else begin
				input_fifo_wr_en <= 1'b0;
				
			end
        end
		else begin
			input_fifo_wr_en <= 1'b0;
		end
    end
end

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        write_done        <= 1'b1;
    end
    else if(en == 1'b0) begin
        write_done       <= 1'b1;
    end
    else begin
        
        if(start == 1'b1) begin
            write_done <= 1'b0;
        end
        else begin
			if(write_cnt  == FFT_SIZE_sub1) begin
                write_done <= 1'b1;
            end
			else 
				write_done	<= write_done	;   
        end
    end
end

 
 
 
(* KEEP = "true" *)reg  	       	fft_din_valid;
		
(* KEEP = "true" *)wire 	       	fft_dout_valid;
(* KEEP = "true" *)wire	[31:0]	fft_dout	;
(* KEEP = "true" *)reg 	[15:0] 	fft_dout_i;
(* KEEP = "true" *)reg 	[15:0] 	fft_dout_q;
(* KEEP = "true" *)wire 	       	fft_busy;
(* KEEP = "true" *)wire	[15:0]	fft_axis_data_tuser	;


 
assign input_fifo_rd_en = reading && (rd_cnt < FFT_SIZE) && (input_fifo_empty == 1'b0);

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        reading <= 1'b0;
        rd_cnt <= 7'd0;
		fft_saxis_tlast 	<= 1'b0		;
         

    end
    else if(en == 1'b0) begin
        reading <= 1'b0;
		rd_cnt <= 7'd0;
		fft_saxis_tlast 	<= 1'b0		;
         
    end
    else begin
		if (reading == 1'b0) begin
			fft_saxis_tlast 	<= 1'b0		;
			if((write_done == 1'b1) && (input_fifo_empty == 1'b0))
				reading		<= 1'b1	;
			else
				reading		<= 1'b0	;
		end
		else begin
			
			if(rd_cnt == FFT_SIZE_sub1) begin
				reading		<= 1'b0		;
				rd_cnt		<= 7'd0		;
				fft_saxis_tlast 	<= 1'b1		;
			end
			else begin
				reading		<= 1'b1	;
				rd_cnt			<= rd_cnt + 1;
				fft_saxis_tlast 	<= 1'b0		;
			end
		end

    end
end

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        fft_din_valid <= 1'b0;
    end
    else if(en == 1'b0) begin
        fft_din_valid <= 1'b0;
    end
    else begin
        fft_din_valid <=reading;        
    end
end

 
 
 
 

 
 
 
 

 
(* keep = "true" *) wire [7:0]  fft_m_axis_status_tdata;
(* MARK_DEBUG="true" *) wire        fft_m_axis_status_tvalid;
wire                            fft_m_axis_status_tready = 1'b1;
(* MARK_DEBUG="true" *)  wire        fft_event_fft_overflow;
(* MARK_DEBUG="true" *) wire        fft_event_status_channel_halt;

 
(* keep = "true" *) wire [7:0]  ifft_m_axis_status_tdata;
(* MARK_DEBUG="true" *) wire        ifft_m_axis_status_tvalid;
wire                            ifft_m_axis_status_tready = 1'b1;
(* MARK_DEBUG="true" *) wire        ifft_event_fft_overflow;

localparam [7:0]  FFT_SCALE_SCH_DEFAULT = 8'b01_10_10_11;
localparam [15:0] FFT_CONFIG_FWD        = {7'd0, FFT_SCALE_SCH_DEFAULT, 1'b1};
localparam [15:0] FFT_CONFIG_INV        = {7'd0, FFT_SCALE_SCH_DEFAULT, 1'b0};
(* MARK_DEBUG="true" *) wire        ifft_event_status_channel_halt;

xfft_128 u_fft (
  .aclk						(	clk							),                                                 
  .aresetn					(	fft_rstn					),                                           
  .s_axis_config_tdata		(	FFT_CONFIG_FWD						),                   
  .s_axis_config_tvalid		(	1'b1						),                 
  .s_axis_config_tready		( 								),                 
  .s_axis_data_tdata		(	input_fifo_dout				),                       
  .s_axis_data_tvalid		(	fft_din_valid				),                     
  .s_axis_data_tready		(								),                     
  .s_axis_data_tlast		(	fft_saxis_tlast				),                       
  .m_axis_data_tdata		(	fft_dout			),                       
  .m_axis_data_tuser		(	fft_axis_data_tuser			),                       
  .m_axis_data_tvalid		(	fft_dout_valid				),                     
  .m_axis_data_tready		(	1'b1						),                     
  .m_axis_data_tlast		( 								),                       

  .m_axis_status_tdata		(	fft_m_axis_status_tdata		),                   
  .m_axis_status_tvalid		(	fft_m_axis_status_tvalid	),                 
  .m_axis_status_tready		(	fft_m_axis_status_tready	),                 


  .event_frame_started		(								),                   
  .event_tlast_unexpected	(								),             
  .event_tlast_missing		(								),                   

  .event_fft_overflow		(	fft_event_fft_overflow		),                     

  .event_status_channel_halt(	fft_event_status_channel_halt),       
  .event_data_in_channel_halt(								),     
  .event_data_out_channel_halt(								)   
);

 
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
 
 
 
 
 

(* KEEP = "true" *)wire [31:0] rom_dout_far;
(* KEEP = "true" *)wire [31:0] rom_dout_near;
(* KEEP = "true" *)wire [31:0] rom_dout;
(* KEEP = "true" *)wire [15:0] coeff_i;
(* KEEP = "true" *)wire [15:0] coeff_q;


assign rom_dout = (far_or_near == 1'b1) ? rom_dout_far : rom_dout_near;
 
 

reg	[31:0]	fft_dout_d1;		 
reg			mul_valid		;
always @(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		fft_dout_d1			<= 32'd0		;
		mul_valid	<= 1'b0		;
	end
	else begin
		fft_dout_d1			<= fft_dout					;
		mul_valid	<= fft_dout_valid		;
	end
end


 
ROM_ff_far u_rom_far (
  .clka				(	clk			),     
  .addra			(	fft_axis_data_tuser[6:0]		),   
  .douta			(	rom_dout_far	)   
);
ROM_ff_near u_rom_near (
  .clka				(	clk			),     
  .addra			(	fft_axis_data_tuser[6:0]		),   
  .douta			(	rom_dout_near	)   
);
 
     
     
     
 
 
     
     
     
 


 
 
 

 

(* KEEP = "true" *)wire		[31:0]	mul_dout	;
(* KEEP = "true" *)wire				mul_dout_valid	;
complex_mult_16x16 your_instance_name (
  .aclk					(	clk				),                               
  .s_axis_a_tvalid		(	mul_valid		),         
  .s_axis_a_tdata		(	fft_dout_d1		),           
  .s_axis_b_tvalid		(	mul_valid		),         
  .s_axis_b_tdata		(	rom_dout		),           
  .m_axis_dout_tvalid	(	mul_dout_valid	),   
  .m_axis_dout_tdata	(	mul_dout		)     
);
 

 
 
 

(* KEEP = "true" *)wire 	       	ifft_dout_valid;
(* KEEP = "true" *)wire	[31:0]	ifft_dout	;
(* KEEP = "true" *)reg 	[15:0] 	ifft_dout_i;
(* KEEP = "true" *)reg 	[15:0] 	ifft_dout_q;
(* KEEP = "true" *)wire 	       	ifft_busy;
(* KEEP = "true" *)wire	[15:0]	ifft_axis_data_tuser	;
(* KEEP = "true" *)reg		[6:0]		ifft_last		;
(* KEEP = "true" *)reg				mul_last		;
always @(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		ifft_last		<= 7'd0		;	
		mul_last	    <= 1'b0		;
	end
	else begin
		ifft_last		<= {ifft_last[5:0], mul_last}	;
		if(fft_dout_valid && (fft_axis_data_tuser[6:0] == FFT_SIZE_sub1))
			mul_last	<= 1'b1		;
		else
			mul_last	<= 1'b0		;
	end
end

 
 
 
 
 
 
 
 
 
 
 
 
 
 

xfft_128 u_Ifft (
  .aclk						(	clk							),                                                 
  .aresetn					(	fft_rstn					),                                           
  .s_axis_config_tdata		(	FFT_CONFIG_INV						),                   
  .s_axis_config_tvalid		(	1'b1						),                 
  .s_axis_config_tready		( 								),                 
  .s_axis_data_tdata		(	mul_dout					),                       
  .s_axis_data_tvalid		(	mul_dout_valid				),                     
  .s_axis_data_tready		(								),                     
  .s_axis_data_tlast		(	ifft_last[6]				),                       
  .m_axis_data_tdata		(	ifft_dout					),                       
  .m_axis_data_tuser		(	ifft_axis_data_tuser		),                       
  .m_axis_data_tvalid		(	ifft_dout_valid				),                     
  .m_axis_data_tready		(	1'b1						),                     
  .m_axis_data_tlast		( 								),                       
 
  .m_axis_status_tdata		(	ifft_m_axis_status_tdata		),                   
  .m_axis_status_tvalid		(	ifft_m_axis_status_tvalid	),                 
  .m_axis_status_tready		(	ifft_m_axis_status_tready	),                 



  .event_frame_started		(								),                   
  .event_tlast_unexpected	(								),             
  .event_tlast_missing		(								),                   

  .event_fft_overflow		(	ifft_event_fft_overflow		),                     

  .event_status_channel_halt(ifft_event_status_channel_halt								),       
  .event_data_in_channel_halt(								),     
  .event_data_out_channel_halt(								)   
);

always@(posedge clk or posedge rst) begin
	if (rst == 1'b1) begin
		dout_i 					<= 16'd0		;
		dout_q 					<= 16'd0		;
		dout_valid				<= 1'b0		;
	end
	else begin
		if((ifft_dout_valid == 1'b1) && (ifft_axis_data_tuser[6:0] <out_points_num)) begin
			dout_i 					<= ifft_dout[15:0]		;
			dout_q 					<= ifft_dout[31:16]		;
			dout_valid				<= 1'b1					;			
		end
		else begin
			dout_i 					<= 16'd0				;
			dout_q 					<= 16'd0				;
			dout_valid				<= 1'b0					;			
		end		
	end
end

 
	 
	
	 
	 
	
	 
 

 
	 
	
	 
	 
	
	 
 


 

 
 
 
 
 
 
 
 

 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
   
   
   
   
   
   
   
   
   
   
 


 
 
 
 

 
     
         
         
         
         
         
         
         
     
     
         
         
         
         
     
     
         
         
         
         
             
             
         
         
             
             
             
             
             
                 
                 
             
         
     
 

 
     
         
         
         
         
         
         
         
     
     
         
         
         
         
     
     
         
         
         
         
             
             
         
         
             
             
             
             
             
                 
                 
             
         
     
 

 
assign dbg_input_fifo_wr_en = input_fifo_wr_en;
assign dbg_input_fifo_din = input_fifo_din;
assign dbg_reading = reading;
assign dbg_rd_cnt = rd_cnt;
assign dbg_input_fifo_dout = input_fifo_dout;
assign dbg_fft_din_valid = fft_din_valid;
assign dbg_fft_saxis_tlast = fft_saxis_tlast;
assign dbg_fft_dout = fft_dout;
assign dbg_fft_dout_valid = fft_dout_valid;
assign dbg_fft_axis_data_tuser = fft_axis_data_tuser;
assign dbg_rom_dout = rom_dout;
assign dbg_mul_valid = mul_valid;
assign dbg_fft_dout_d1 = fft_dout_d1;
assign dbg_mul_dout = mul_dout;
assign dbg_mul_dout_valid = mul_dout_valid;
assign dbg_ifft_saxis_tlast = ifft_last[6];
assign dbg_ifft_dout = ifft_dout;
assign dbg_ifft_dout_valid = ifft_dout_valid;
assign dbg_ifft_axis_data_tuser = ifft_axis_data_tuser;
assign dbg_fft_m_axis_status_tdata = fft_m_axis_status_tdata;
assign dbg_fft_m_axis_status_tvalid = fft_m_axis_status_tvalid;
assign dbg_ifft_m_axis_status_tdata = ifft_m_axis_status_tdata;
assign dbg_ifft_m_axis_status_tvalid = ifft_m_axis_status_tvalid;
assign dbg_fft_event_fft_overflow = fft_event_fft_overflow;
assign dbg_ifft_event_fft_overflow = ifft_event_fft_overflow;
assign dbg_fft_event_status_channel_halt = fft_event_status_channel_halt;
assign dbg_ifft_event_status_channel_halt = ifft_event_status_channel_halt;
endmodule


