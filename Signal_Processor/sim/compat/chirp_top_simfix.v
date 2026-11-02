`timescale 1ns / 1ps

(*KEEP_HIERARCHY = "YES"*)module chirp_top(
    input               m00_axis_aclk,
    input               clk_500M,
    input               m00_axis_aresetn,
    input   [31:0]      PINC1,              //第一级DDS的相位增量，k*312.5M*312.5M*2^32
    input   [31:0]      f0_scale,           //第一级相位偏移尺度因子，F_START / 312.5M * 2^32 四舍五入后取低32位
    input   [31:0]      mu_scale,            // 第一级相位偏移尺度因子= k /10G / 312.5M * 2^32;
    input   [31:0]      f0_scale2,           //第二级相位偏移尺度因子F_START /10G * 2^32 ;
    input   [31:0]      mu_scale2,          //第二级相位偏移尺度因子(0.5 * k /10G /10G * 2^32 
    input   [31:0]      fc_scale,          //
    input   [31:0]      axi_chirp_width,          // （脉宽*10G）/32，向上取整
    input   [31:0]      axi_pulse_period,          // （重复周期*10G）/32，四舍五入取整
    input   [31:0]      pulse_delay, 
    input               prt_ref,          // 参考脉冲
//    input               axi_chirp_gen_en,          // 开始产生脉冲
    input               rf_converter_tready,
    
    output                            mm_axis_tvalid,
    output [1023:0]    mm_axis_tdata,
    
//    output                            clk_400M,
    output                            m_axis_tvalid_converter,
    output    [255:0]                 m_axis_tdata_converter
    
    );


//    assign rf_data = (m_axis_tvalid_converter) ? m_axis_tdata_converter : 256'd0;
    // ========================================================
    // 固定系统参数（请勿修改）
    // ========================================================
    localparam integer C_DDS_CHNL_NUM      = 32;           // 通道数
    localparam integer C_DDS_PHASE_WIDTH   = 32;           // 相位宽度
    localparam integer C_S00_AXI_DATA_WIDTH = 32;
    localparam integer C_S00_AXI_ADDR_WIDTH = 11;


    // ========================================================
    // 信号声明
    // ========================================================
    reg   prt_ref_d1;                  
    reg   axi_chirp_gen_en;                  
    reg                             chirp_gen_gate;
    wire  [64*C_DDS_CHNL_NUM-1:0]    axi_phase_tdata;
    wire  [32*C_DDS_CHNL_NUM-1:0]    axi_offset_tdata;

    reg                             axi_update_flag;
    wire                            chirp_phase_tvalid;
    wire [C_DDS_PHASE_WIDTH*2*C_DDS_CHNL_NUM-1:0] chirp_phase_tdata;
    wire                            chirp_offset_tvalid;
    wire [C_DDS_PHASE_WIDTH*C_DDS_CHNL_NUM-1:0]   chirp_offset_tdata;
    wire [31:0]                     chirp_resetn;

    // 模块内用于计算的变量（全部在模块级别声明）

//    reg [63:0] prod_poff1, prod_poff2;
//    reg [31:0] poff1_int, poff2_int;
	reg [3:0]  start_cnt;
	reg [31:0] gen_cnt;
    
    wire [511:0] fifo_data_in;
    wire clk_625m;
    
    
//  clk_wiz_625 u_clk_625
//   (
//    // Clock out ports
//    .clk_out1(clk_400M),     // output clk_out1
//   // Clock in ports
//    .clk_in1(m00_axis_aclk));      // input clk_in1

genvar i;
    generate
        for(i=0; i<32; i=i+1) begin
            assign axi_phase_tdata[64*i +: 32] = PINC1;  // 低32位
            assign axi_phase_tdata[64*i+32 +: 32] = (f0_scale + i * mu_scale); // 高32位，自动截断
            assign axi_offset_tdata[32*i +: 32] = (i * f0_scale2 + i * i * mu_scale2);
            assign fifo_data_in[16*i +: 16] =  mm_axis_tdata[32*i+16 +: 16];

        end
    endgenerate

    reg [3:0]    prt_ref_shift;
    reg [15:0]   pulse_gen_cnt;
    reg [15:0]   pulse_gen_cnt_d1;
    always @(posedge m00_axis_aclk) begin
        if(!m00_axis_aresetn) begin
            prt_ref_shift <= 4'd0;
        end
        else begin
            prt_ref_shift <= {prt_ref_shift[3:0],prt_ref};
        end
    end
    
    
    //控制脉冲产生
    always @(posedge m00_axis_aclk) begin
        if(!m00_axis_aresetn) begin
            pulse_gen_cnt <= 16'd0;
            pulse_gen_cnt_d1 <= 16'd0;
        end
        else begin
            pulse_gen_cnt_d1 <= pulse_gen_cnt;
            if(prt_ref_shift == 4'b0001)
                pulse_gen_cnt <= 16'd0;
            else
                pulse_gen_cnt <= pulse_gen_cnt + 16'd1;
        end
    end


reg [15:0]   cw_gen_cnt;
reg          cw_flag;
    //控制连续波产生
    
    always @(posedge m00_axis_aclk) begin
        if(!m00_axis_aresetn) begin
            cw_flag <= 1'b0;
        end
        else begin
             if(prt_ref_shift == 4'b0001 && axi_chirp_width == 32'hFFFFFFFF)
                cw_flag <= 1'b1;
             else
                cw_flag <= cw_flag;
        end
    end
    
    always @(posedge m00_axis_aclk) begin
        if(!m00_axis_aresetn) begin
            cw_gen_cnt <= 16'd0;
        end
        else begin
            if(axi_chirp_width == 32'hFFFFFFFF && cw_flag)begin
                if(cw_gen_cnt <= 16'd2000)
                    cw_gen_cnt <= cw_gen_cnt + 16'd1;
                else
                    cw_gen_cnt <= cw_gen_cnt;
            end
            else begin
                    cw_gen_cnt <= 16'd0;
            end
        end
    end
// ila_chirp_prt ila_chirp_prt (
	// .clk(m00_axis_aclk), // input wire clk


	// .probe0(prt_ref), // input wire [0:0]  probe0  
	// .probe1(pulse_gen_cnt), // input wire [15:0]  probe1 
	// .probe2(pulse_gen_cnt_d1) // input wire [15:0]  probe2
// );
//    always @(posedge m00_axis_aclk) begin
//        if(!m00_axis_aresetn) begin
//            gen_cnt <= 32'd0;
//        end
//        else begin
//            if(axi_chirp_gen_en && gen_cnt < axi_pulse_period-32'd1)begin
//                gen_cnt <= gen_cnt + 32'd1;
//            end
//            else begin
//                gen_cnt <= 32'd0;
//            end    
//        end
//    end
    
    reg [31:0]  fc_scale_user;
    always @(posedge m00_axis_aclk) begin
        if(!m00_axis_aresetn) begin
            chirp_gen_gate <= 1'b0;
            axi_update_flag <= 1'b0;
            fc_scale_user <= 32'd0;
        end
        else begin
            if(axi_chirp_width == 32'hFFFFFFFF)begin
                fc_scale_user <= 32'd0;
                if(cw_gen_cnt >= 16'd1024 && cw_gen_cnt <= 16'd1025)begin
                    axi_update_flag <= 1'b1;
                    chirp_gen_gate <= 1'b0;
                end
                else if(cw_gen_cnt >= 16'd1025)begin
                    axi_update_flag <= 1'b0;
                    chirp_gen_gate <= 1'b1;
                end
                else begin
                    axi_update_flag <= 1'b0;
                    chirp_gen_gate <= 1'b0;
                end
            end
            else begin
                fc_scale_user <= fc_scale;
                if(pulse_gen_cnt >= pulse_delay + 32'd1 && pulse_gen_cnt <= pulse_delay + 32'd2)begin
                    axi_update_flag <= 1'b1;
                    chirp_gen_gate <= 1'b0;
                end
                else if(pulse_gen_cnt >= pulse_delay + 32'd6 && pulse_gen_cnt <= pulse_delay + 32'd7)begin
                    axi_update_flag <= 1'b0;
                    chirp_gen_gate <= 1'b1;
                end
                else begin
                    axi_update_flag <= 1'b0;
                    chirp_gen_gate <= 1'b0;
                end
            end
                
        end
    end

    // ========================================================
    // 模块实例化
    // ========================================================
    Chirp_Gen_Ctrl #(
        .C_DDS_CHNL_NUM     (C_DDS_CHNL_NUM),
        .C_DDS_PHASE_WIDTH  (C_DDS_PHASE_WIDTH)
    ) Chirp_Gen_Ctrl_Inst (
        .sys_clk            (m00_axis_aclk),
        .sys_rstn           (m00_axis_aresetn),
        .chirp_gen_gate     (chirp_gen_gate),
        .axi_resetn         (1'b1),
        .axi_update_flag    (axi_update_flag),
        .axi_chirp_width    (axi_chirp_width),
        .axi_chirp_gen_en   (1'b1),
        .axi_phase_tdata    (axi_phase_tdata),
        .axi_offset_tdata   (axi_offset_tdata),
        .chirp_phase_tvalid (chirp_phase_tvalid),
        .chirp_phase_tdata  (chirp_phase_tdata),
        .chirp_offset_tvalid (chirp_offset_tvalid),
        .chirp_offset_tdata  (chirp_offset_tdata),
        .chirp_resetn       (chirp_resetn)
    );

    ChirpGen_user #(
        .C_DDS_CHNL_NUM        (C_DDS_CHNL_NUM),
        .C_DDS_PHASE_WIDTH     (C_DDS_PHASE_WIDTH),
        .C_S00_AXI_DATA_WIDTH  (C_S00_AXI_DATA_WIDTH),
        .C_S00_AXI_ADDR_WIDTH  (C_S00_AXI_ADDR_WIDTH)
    ) ChirpGen_user_inst (
        .m00_axis_aclk         (m00_axis_aclk),
        .m00_axis_aresetn      (m00_axis_aresetn),
        .chirp_resetn          (chirp_resetn),
        .axi_out_sel           (1'b0),
        .axi_phase_tvalid      (chirp_phase_tvalid),
        .axi_phase_tdata       (chirp_phase_tdata),
        .axi_offset_tvalid     (chirp_offset_tvalid),
        .axi_offset_tdata      (chirp_offset_tdata),
        .fc_scale              (fc_scale_user),
        .mm_axis_tvalid        (mm_axis_tvalid),
        .mm_axis_tdata         (mm_axis_tdata)
    );



wire                m_axis_tvalid_fifo;
wire                m_axis_tready_fifo;
wire    [511:0]     m_axis_tdata_fifo;

// ila_200 your_instance_name (
	// .clk(m00_axis_aclk), // input wire clk


	// .probe0(mm_axis_tvalid), // input wire [0:0]  probe0  
	// .probe1(fifo_data_in) // input wire [511:0]  probe1
// );


wire                s_axis_tready_converter;

fifo_312_625 u_fifo_312_625 (
  .m_aclk               (clk_500M),                // input wire m_aclk
  .s_aclk               (m00_axis_aclk),                // input wire s_aclk
  .s_aresetn            (m00_axis_aresetn),          // input wire s_aresetn
  .s_axis_tvalid        (mm_axis_tvalid),  // input wire s_axis_tvalid
  .s_axis_tready        (),  // output wire s_axis_tready
  .s_axis_tdata         (fifo_data_in),    // input wire [511 : 0] s_axis_tdata
  .m_axis_tvalid        (m_axis_tvalid_fifo),  // output wire m_axis_tvalid
  .m_axis_tready        (s_axis_tready_converter),  // input wire m_axis_tready
  .m_axis_tdata         (m_axis_tdata_fifo)    // output wire [511 : 0] m_axis_tdata
);


//wire                m_axis_tvalid_converter;
//wire    [255:0]     m_axis_tdata_converter;

axis_dwidth_converter u_dwidth_converter (
  .aclk                 (clk_500M),                    // input wire aclk
  .aresetn              (m00_axis_aresetn),              // input wire aresetn
  .s_axis_tvalid        (m_axis_tvalid_fifo),  // input wire s_axis_tvalid
  .s_axis_tready        (s_axis_tready_converter),  // output wire s_axis_tready
  .s_axis_tdata         (m_axis_tdata_fifo),    // input wire [511 : 0] s_axis_tdata
  .m_axis_tvalid        (m_axis_tvalid_converter),  // output wire m_axis_tvalid
  .m_axis_tready        (1'b1),  // input wire m_axis_tready
  .m_axis_tdata         (m_axis_tdata_converter)    // output wire [255 : 0] m_axis_tdata
);

//genvar i;
//	generate
//	for(i=0; i<C_DDS_CHNL_NUM; i=i+1) begin
//		always @(posedge m00_axis_aclk) begin
//			// 配置每个通道的相位数据
//                // 第一级DDS的POFF：起始频率对应的相位字
//                prod_poff1 <= f0_scale + i * mu_scale;
//                poff1_int <= prod_poff1[31:0];
    
//                // 第二级DDS的POFF：起始相位对应的相位字
//                prod_poff2 <= i * f0_scale2 + i * i * mu_scale2;
//                poff2_int <= prod_poff2[31:0];
    
//                // 第一级DDS：高32位 = POFF1_i，低32位 = PINC1（固定）
//                axi_phase_tdata[64*i +: 32] <= PINC1;
//                axi_phase_tdata[64*i+32 +: 32] <= poff1_int;
    
//                // 第二级DDS的POFF
//                axi_offset_tdata[32*i +: 32] = poff2_int;
//		end
//	end
//	endgenerate

















endmodule
    
