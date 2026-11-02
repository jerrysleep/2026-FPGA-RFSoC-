`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


module ChirpGen_user #(
    parameter	integer	C_DDS_CHNL_NUM			= 16,
	parameter	integer	C_DDS_PHASE_WIDTH		= 32,
    parameter	integer	C_S00_AXI_DATA_WIDTH	= 32,
    parameter	integer	C_S00_AXI_ADDR_WIDTH	= 9
)
(
    input													m00_axis_aclk,
    input													m00_axis_aresetn,
    input		[31:0]										chirp_resetn,
    input													axi_out_sel,
    input													axi_phase_tvalid,
    input		[C_DDS_PHASE_WIDTH*2*C_DDS_CHNL_NUM-1:0]	axi_phase_tdata,
    input													axi_offset_tvalid,
    input		[C_DDS_PHASE_WIDTH*C_DDS_CHNL_NUM-1:0]		axi_offset_tdata,
    input   [31:0]      fc_scale,
	 
	 
	 
	 
	output	reg												mm_axis_tvalid,
	output	reg	[C_DDS_CHNL_NUM*32-1:0]						mm_axis_tdata
);
	wire	[C_DDS_CHNL_NUM-1:0]			m_sin_axis_tvalid_r;
	wire	[C_DDS_CHNL_NUM*16-1:0]			m_sin_axis_tdata_r;
	wire	[C_DDS_CHNL_NUM-1:0]			m_cos_axis_tvalid_r;
	wire	[C_DDS_CHNL_NUM*16-1:0]			m_cos_axis_tdata_r;
	wire	[C_DDS_CHNL_NUM-1:0]			m_axis_tvalid_r;
	wire	[C_DDS_CHNL_NUM*32-1:0]			m_axis_tdata_r;
	genvar i;
	generate
	for(i = 0; i < C_DDS_CHNL_NUM; i = i + 1) begin
		ChirpGenUnit ChirpGenUnit_Inst
		(
			.clk					(m00_axis_aclk					),         
			.rstn					(m00_axis_aresetn & chirp_resetn[i]	),         
 
			.s00_axis_phase_tvalid	(axi_phase_tvalid				),         
			.s00_axis_phase_tdata	(axi_phase_tdata[C_DDS_PHASE_WIDTH*2*i+:C_DDS_PHASE_WIDTH*2]),         
			.s01_axis_offset_tvalid	(axi_offset_tvalid				),         
			.s01_axis_offset_tdata	(axi_offset_tdata[C_DDS_PHASE_WIDTH*i+:C_DDS_PHASE_WIDTH]	),         
			.fc_scale                (fc_scale),
			.m_sin_axis_tvalid		(m_sin_axis_tvalid_r[i]		),         
			.m_sin_axis_tdata		(m_sin_axis_tdata_r[16*i+:16]	),         
			.m_cos_axis_tvalid		(m_cos_axis_tvalid_r[i]			),         
			.m_cos_axis_tdata		(m_cos_axis_tdata_r[16*i+:16]	),         
			.m_axis_tvalid			(m_axis_tvalid_r[i]				),
			.m_axis_tdata			(m_axis_tdata_r[32*i+:32]		)
		);
	end
	endgenerate

 
 
 
 
 
 
 
 
 

	always @(posedge m00_axis_aclk) begin
		if(!m00_axis_aresetn) begin
			mm_axis_tvalid <= 0;
			mm_axis_tdata <= 0;
		end
		else begin
			mm_axis_tvalid <= &m_axis_tvalid_r;
			mm_axis_tdata <= m_axis_tdata_r;
		end
 
 
 
 
 
 
 
 
	end
	
endmodule
