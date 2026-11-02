`timescale 1ns / 1ps

module ch_pulse_compression_unit (
    input   wire        clk,
    input   wire        rst,
    input   wire        en,                     // 全局使能

    input   wire        start,                  // 本PRT启动脉冲（来自分配器）
    input   wire        far_or_near,            // 1:远距离, 0:近距离
    input   wire        far_or_near_out,            // 1:远距离, 0:近距离,输出较输入滞后3个PRT
    input   wire [15:0] din_i,
    input   wire [15:0] din_q,
    input   wire        din_valid,              // 输入采样有效（已做抽取）

     output  reg  [15:0] dout_i,
     output  reg  [15:0] dout_q,
     output  reg         dout_valid,
     output  reg         done                    // 本PRT输出完成脉冲
);

// =====================================================================
// 参数定义
// =====================================================================
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
// =====================================================================
// 输入FIFO控制（IP核：FIFO Generator，深度128，宽度32，同步时钟，首字跌落）
// =====================================================================
(* KEEP = "true" *)reg         input_fifo_wr_en;
(* KEEP = "true" *)reg  [31:0] input_fifo_din;
(* KEEP = "true" *)wire        input_fifo_rd_en;
(* KEEP = "true" *)wire [31:0] input_fifo_dout;
(* KEEP = "true" *)wire        input_fifo_empty;
(* KEEP = "true" *)wire        input_fifo_full;

// 用户需例化FIFO IP核，并连接以下信号
/*
fifo_generator_0 u_input_fifo (
    .clk(clk),
    .srst(rst),
    .din(input_fifo_din),
    .wr_en(input_fifo_wr_en),
    .rd_en(input_fifo_rd_en),
    .dout(input_fifo_dout),
    .full(input_fifo_full),
    .empty(input_fifo_empty)
);
*/

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


reg reading; // moved before first use for XSim declaration order
PulseCompressfifo_32x256 Input_fifo (
  .clk				(	clk					),                  // input wire clk
  .srst				(	fifo_rst			),                // input wire srst
  .din				(	input_fifo_din		),                  // input wire [31 : 0] din
  .wr_en			(	input_fifo_wr_en	),              // input wire wr_en
  .rd_en			(	reading				),              // input wire rd_en
  .dout				(	input_fifo_dout		),                // output wire [31 : 0] dout
  .full				(	input_fifo_full		),                // output wire full
  .empty			(	input_fifo_empty	),              // output wire empty
  .wr_rst_busy		( 						),  // output wire wr_rst_busy
  .rd_rst_busy		( 						)  // output wire rd_rst_busy
);
// 写入控制：每个PRT开始时清空计数，写入有效数据，之后自动补零
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
						// write_cnt <=  7'd1;
					end
					else begin
						input_fifo_din <= input_fifo_din;
						input_fifo_wr_en <= 1'b0;
						// write_cnt <= 7'd0;					
					end			
			
        end
        else if(write_done == 1'b0) begin
            // 写入数据：先写有效采样，后写零填充
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
                    // 自动补零
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

// =====================================================================
// FFT IP核（正向变换，流水线，128点，16位）
// =====================================================================
(* KEEP = "true" *)reg  	       	fft_din_valid;
		
(* KEEP = "true" *)wire 	       	fft_dout_valid;
(* KEEP = "true" *)wire	[31:0]	fft_dout	;
(* KEEP = "true" *)reg 	[15:0] 	fft_dout_i;
(* KEEP = "true" *)reg 	[15:0] 	fft_dout_q;
(* KEEP = "true" *)wire 	       	fft_busy;
(* KEEP = "true" *)wire	[15:0]	fft_axis_data_tuser	;


// 从输入FIFO读取数据送入FFT
reg [6:0] rd_cnt;

reg			fft_saxis_tlast		;		// FFT 模块的一帧的最后一个数据
assign input_fifo_rd_en = reading && (rd_cnt < FFT_SIZE) && (input_fifo_empty == 1'b0);

always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        reading <= 1'b0;
        rd_cnt <= 7'd0;
		fft_saxis_tlast 	<= 1'b0		;
        // fft_din_valid <= 1'b0;

    end
    else if(en == 1'b0) begin
        reading <= 1'b0;
		rd_cnt <= 7'd0;
		fft_saxis_tlast 	<= 1'b0		;
        // fft_din_valid <= 1'b0;
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


 wire [7:0]  fft_m_axis_status_tdata;
 wire        fft_m_axis_status_tvalid;
 wire        fft_m_axis_status_tready = 1'b1;
 wire        fft_event_status_channel_halt;

// (* keep = "true" *) wire [15:0] ifft_axis_data_tuser;
wire [7:0]  ifft_m_axis_status_tdata;
wire        ifft_m_axis_status_tvalid;
wire        ifft_m_axis_status_tready = 1'b1;
wire        ifft_event_fft_overflow;

localparam [7:0]  FFT_SCALE_SCH_FWD     = 8'b01_10_10_11;
localparam [7:0]  FFT_SCALE_SCH_INV     = 8'b00_00_00_00;
localparam [15:0] FFT_CONFIG_FWD        = {7'd0, FFT_SCALE_SCH_FWD, 1'b1};
localparam [15:0] FFT_CONFIG_INV        = {7'd0, FFT_SCALE_SCH_INV, 1'b0};
wire        ifft_event_status_channel_halt;

xfft_128 u_fft (
  .aclk						(	clk							),                                                // input wire aclk
  .aresetn					(	fft_rstn					),                                          // input wire aresetn
  .s_axis_config_tdata		(	FFT_CONFIG_FWD						),                  // input wire [15 : 0] s_axis_config_tdata
  .s_axis_config_tvalid		(	1'b1						),                // input wire s_axis_config_tvalid
  .s_axis_config_tready		( 								),                // output wire s_axis_config_tready
  .s_axis_data_tdata		(	input_fifo_dout				),                      // input wire [31 : 0] s_axis_data_tdata
  .s_axis_data_tvalid		(	fft_din_valid				),                    // input wire s_axis_data_tvalid
  .s_axis_data_tready		(								),                    // output wire s_axis_data_tready
  .s_axis_data_tlast		(	fft_saxis_tlast				),                      // input wire s_axis_data_tlast
  .m_axis_data_tdata		(	fft_dout			),                      // output wire [31 : 0] m_axis_data_tdata
  .m_axis_data_tuser		(	fft_axis_data_tuser			),                      // output wire [7 : 0] m_axis_data_tuser
  .m_axis_data_tvalid		(	fft_dout_valid				),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready		(	1'b1						),                    // input wire m_axis_data_tready
  .m_axis_data_tlast		( 								),                      // output wire m_axis_data_tlast

  .m_axis_status_tdata		(	fft_m_axis_status_tdata		),                  // output wire [7 : 0] m_axis_status_tdata
  .m_axis_status_tvalid		(	fft_m_axis_status_tvalid	),                // output wire m_axis_status_tvalid
  .m_axis_status_tready		(	fft_m_axis_status_tready	),                // input wire m_axis_status_tready


  .event_frame_started		(								),                  // output wire event_frame_started
  .event_tlast_unexpected	(								),            // output wire event_tlast_unexpected
  .event_tlast_missing		(								),                  // output wire event_tlast_missing

  .event_fft_overflow		(	fft_event_fft_overflow		),                    // output wire event_fft_overflow

  .event_status_channel_halt(	fft_event_status_channel_halt),      // output wire event_status_channel_halt
  .event_data_in_channel_halt(								),    // output wire event_data_in_channel_halt
  .event_data_out_channel_halt(								)  // output wire event_data_out_channel_halt
);


// =====================================================================
// 系数ROM（Block Memory Generator，128x32，只读）
// 根据far_or_near选择远/近距离系数
// =====================================================================

(* KEEP = "true" *)wire [31:0] rom_dout_far;
(* KEEP = "true" *)wire [31:0] rom_dout_near;
(* KEEP = "true" *)wire [31:0] rom_dout;
(* KEEP = "true" *)wire [15:0] coeff_i;
(* KEEP = "true" *)wire [15:0] coeff_q;


assign rom_dout = (far_or_near == 1'b1) ? rom_dout_far : rom_dout_near;
// assign coeff_i = rom_dout[15:0];
// assign coeff_q = rom_dout[31:16];

reg	[31:0]	fft_dout_d1;		// 延迟1个时钟周期，与ROM参数对齐
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


// 用户需例化两个ROM IP核，分别初始化远/近系数
ROM_ff_far u_rom_far (
  .clka				(	clk			),    // input wire clka
  .addra			(	fft_axis_data_tuser[6:0]		),  // input wire [6 : 0] addra 与输出索引同步
  .douta			(	rom_dout_far	)  // output wire [31 : 0] douta
);
ROM_ff_near u_rom_near (
  .clka				(	clk			),    // input wire clka
  .addra			(	fft_axis_data_tuser[6:0]		),  // input wire [6 : 0] addra
  .douta			(	rom_dout_near	)  // output wire [31 : 0] douta
);
// blk_mem_gen_0 u_rom_far (
    // .clka(clk),
    // .addra(rom_addr),
    // .douta(rom_dout_far)
// );
// blk_mem_gen_1 u_rom_near (
    // .clka(clk),
    // .addra(rom_addr),
    // .douta(rom_dout_near)
// );


// =====================================================================
// 复数乘法器（使用IP核，延迟1周期）
// =====================================================================

// 用户需例化复数乘法器IP核

(* KEEP = "true" *)wire		[31:0]	mul_dout	;
(* KEEP = "true" *)wire				mul_dout_valid	;
complex_mult_16x16 your_instance_name (
  .aclk					(	clk				),                              // input wire aclk
  .s_axis_a_tvalid		(	mul_valid		),        // input wire s_axis_a_tvalid
  .s_axis_a_tdata		(	fft_dout_d1		),          // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid		(	mul_valid		),        // input wire s_axis_b_tvalid
  .s_axis_b_tdata		(	rom_dout		),          // input wire [31 : 0] s_axis_b_tdata
  .m_axis_dout_tvalid	(	mul_dout_valid	),  // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata	(	mul_dout		)    // output wire [31 : 0] m_axis_dout_tdata
);
// // 暂时用寄存器直连（仿真用）

// =====================================================================
// IFFT IP核（反向变换，流水线，128点）
// =====================================================================

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

// 用户需例化IFFT IP核，配置为反向变换（fwd_inv=0）
/*
xifft_0 u_ifft (
    .aclk(clk),
    .aresetn(~rst),
    .s_axis_config_tdata(FFT_CONFIG_INV),
    .s_axis_config_tvalid(1'b1),
    .s_axis_data_tdata({mul_q, mul_i}),
    .s_axis_data_tvalid( ),
    .s_axis_data_tready(),
    .m_axis_data_tdata({ifft_dout_q, ifft_dout_i}),
    .m_axis_data_tvalid(ifft_dout_valid)
);
*/

xfft_128 u_Ifft (
  .aclk						(	clk							),                                                // input wire aclk
  .aresetn					(	fft_rstn					),                                          // input wire aresetn
  .s_axis_config_tdata		(	FFT_CONFIG_INV						),                  // input wire [15 : 0] s_axis_config_tdata
  .s_axis_config_tvalid		(	1'b1						),                // input wire s_axis_config_tvalid
  .s_axis_config_tready		( 								),                // output wire s_axis_config_tready
  .s_axis_data_tdata		(	mul_dout					),                      // input wire [31 : 0] s_axis_data_tdata
  .s_axis_data_tvalid		(	mul_dout_valid				),                    // input wire s_axis_data_tvalid
  .s_axis_data_tready		(								),                    // output wire s_axis_data_tready
  .s_axis_data_tlast		(	ifft_last[6]				),                      // input wire s_axis_data_tlast
  .m_axis_data_tdata		(	ifft_dout					),                      // output wire [31 : 0] m_axis_data_tdata
  .m_axis_data_tuser		(	ifft_axis_data_tuser		),                      // output wire [7 : 0] m_axis_data_tuser
  .m_axis_data_tvalid		(	ifft_dout_valid				),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready		(	1'b1						),                    // input wire m_axis_data_tready
  .m_axis_data_tlast		( 								),                      // output wire m_axis_data_tlast
 
  .m_axis_status_tdata		(	ifft_m_axis_status_tdata		),                  // output wire [7 : 0] m_axis_status_tdata
  .m_axis_status_tvalid		(	ifft_m_axis_status_tvalid	),                // output wire m_axis_status_tvalid
  .m_axis_status_tready		(	ifft_m_axis_status_tready	),                // input wire m_axis_status_tready



  .event_frame_started		(								),                  // output wire event_frame_started
  .event_tlast_unexpected	(								),            // output wire event_tlast_unexpected
  .event_tlast_missing		(								),                  // output wire event_tlast_missing

  .event_fft_overflow		(	ifft_event_fft_overflow		),                    // output wire event_fft_overflow

  .event_status_channel_halt(ifft_event_status_channel_halt								),      // output wire event_status_channel_halt
  .event_data_in_channel_halt(								),    // output wire event_data_in_channel_halt
  .event_data_out_channel_halt(								)  // output wire event_data_out_channel_halt
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

// always@(posedge clk or posedge rst) begin
	// if (rst == 1'b1) begin
	
	// end
	// else begin
	
	// end
// end

// always@(posedge clk or posedge rst) begin
	// if (rst == 1'b1) begin
	
	// end
	// else begin
	
	// end
// end


// 做完IFFT直接输出

// =====================================================================
// 输出FIFO（存储IFFT结果）
// =====================================================================
// wire        out_fifo_wr_en;
// wire [31:0] out_fifo_din;
// reg         out_fifo_rd_en;
// wire [31:0] out_fifo_dout;
// wire        out_fifo_empty;

// assign out_fifo_din = {ifft_dout_q, ifft_dout_i};
// assign out_fifo_wr_en = ifft_dout_valid;

// 用户需例化输出FIFO
/*
fifo_generator_1 u_out_fifo (
    .clk(clk),
    .srst(rst),
    .din(out_fifo_din),
    .wr_en(out_fifo_wr_en),
    .rd_en(out_fifo_rd_en),
    .dout(out_fifo_dout),
    .empty(out_fifo_empty)
);
*/
// PulseCompressfifo_32x256 Output_fifo (
  // .clk				(	clk					),                  // input wire clk
  // .srst				(	fifo_rst			),                // input wire srst
  // .din				(	ifft_dout			),                  // input wire [31 : 0] din
  // .wr_en			(	ifft_dout_valid		),              // input wire wr_en
  // .rd_en			(	out_fifo_rd_en		),              // input wire rd_en
  // .dout				(	out_fifo_dout		),                // output wire [31 : 0] dout
  // .full				(						),                // output wire full
  // .empty			(	out_fifo_empty		),              // output wire empty
  // .wr_rst_busy		( 						),  // output wire wr_rst_busy
  // .rd_rst_busy		( 						)  // output wire rd_rst_busy
// );


// // 输出读取控制：本模块输出数据（dout_i/q）供排序器读取
// reg [6:0] out_cnt;
// reg       out_active;
// reg       done_reg;

// always @(posedge clk or posedge rst) begin
    // if(rst == 1'b1) begin
        // out_active <= 1'b0;
        // out_cnt <= 7'd0;
        // out_fifo_rd_en <= 1'b0;
        // dout_i <= 16'd0;
        // dout_q <= 16'd0;
        // dout_valid <= 1'b0;
        // done_reg <= 1'b0;
    // end
    // else if(en == 1'b0) begin
        // out_active <= 1'b0;
        // out_fifo_rd_en <= 1'b0;
        // dout_valid <= 1'b0;
        // done_reg <= 1'b0;
    // end
    // else begin
        // out_fifo_rd_en <= 1'b0;
        // dout_valid <= 1'b0;
        // done_reg <= 1'b0;
        // if(out_active == 1'b0 && out_fifo_empty == 1'b0) begin
            // out_active <= 1'b1;
            // out_cnt <= 7'd0;
        // end
        // if(out_active == 1'b1) begin
            // out_fifo_rd_en <= 1'b1;
            // {dout_q, dout_i} <= out_fifo_dout;
            // dout_valid <= 1'b1;
            // out_cnt <= out_cnt + 7'd1;
            // if(out_cnt + 7'd1 == FFT_SIZE) begin
                // out_active <= 1'b0;
                // done_reg <= 1'b1;
            // end
        // end
    // end
// end

// always @(posedge clk or posedge rst) begin
    // if(rst == 1'b1) begin
        // out_active <= 1'b0;
        // out_cnt <= 7'd0;
        // out_fifo_rd_en <= 1'b0;
        // dout_i <= 16'd0;
        // dout_q <= 16'd0;
        // dout_valid <= 1'b0;
        // done_reg <= 1'b0;
    // end
    // else if(en == 1'b0) begin
        // out_active <= 1'b0;
        // out_fifo_rd_en <= 1'b0;
        // dout_valid <= 1'b0;
        // done_reg <= 1'b0;
    // end
    // else begin
        // out_fifo_rd_en <= 1'b0;
        // dout_valid <= 1'b0;
        // done_reg <= 1'b0;
        // if(out_active == 1'b0 && out_fifo_empty == 1'b0) begin
            // out_active <= 1'b1;
            // out_cnt <= 7'd0;
        // end
        // if(out_active == 1'b1) begin
            // out_fifo_rd_en <= 1'b1;
            // {dout_q, dout_i} <= out_fifo_dout;
            // dout_valid <= 1'b1;
            // out_cnt <= out_cnt + 7'd1;
            // if(out_cnt + 7'd1 == FFT_SIZE) begin
                // out_active <= 1'b0;
                // done_reg <= 1'b1;
            // end
        // end
    // end
// end

// assign done = done_reg;

endmodule
