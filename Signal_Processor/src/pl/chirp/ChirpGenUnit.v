`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


module ChirpGenUnit #(
	parameter	DDS_PHASE_WIDTH = 32
)
(
	input							clk,
	input							rstn,
	input							s00_axis_phase_tvalid,
	
	input	[DDS_PHASE_WIDTH*2-1:0]	s00_axis_phase_tdata,
	input							s01_axis_offset_tvalid,
	input	[DDS_PHASE_WIDTH-1:0]	s01_axis_offset_tdata,
	input   [31:0]      fc_scale,
	
	output							m_sin_axis_tvalid,
	output	[15:0]					m_sin_axis_tdata,
	output							m_cos_axis_tvalid,
	output	[15:0]					m_cos_axis_tdata,
	output							m_axis_tvalid,
	output	[31:0]					m_axis_tdata
);

	wire							m00_axis_phase_tvalid;
	wire	[DDS_PHASE_WIDTH-1:0]	m00_axis_phase_tdata;
	wire	[DDS_PHASE_WIDTH-1:0]	m00_axis_phase_tdata_tmp;
	
	wire							m01_axis_phase_out_tvalid;
	wire	[DDS_PHASE_WIDTH*2-1:0]	m01_axis_phase_out_tdata_tmp;
	wire	[DDS_PHASE_WIDTH*2-1:0]	m01_axis_phase_out_tdata;
	
	wire							m02_axis_phase_tvalid;
	wire	[DDS_PHASE_WIDTH-1:0]	m02_axis_phase_tdata;
	
 
 
 
 
 
	
	wire							m05_axis_dout_tvalid;
	wire	[31:0]					m05_axis_dout_tdata;
    wire	[DDS_PHASE_WIDTH*2-1:0]	s00_axis_phase_tdata_tmp;
    wire	[DDS_PHASE_WIDTH-1:0]	s01_axis_offset_tdata_tmp;
    wire                            s00_axis_phase_tvalid_d2;
    wire                            s00_axis_phase_tvalid_d3;
    wire                            s00_axis_phase_tvalid_d4;
    wire                            s00_axis_phase_tvalid_d7;
    wire                            s00_axis_phase_tvalid_d13;
    

reg [15:0] shift;   
always @(posedge clk or negedge rstn) begin
    if (!rstn)
        shift <= 16'd0;
    else
        shift <= {shift[14:0], s00_axis_phase_tvalid};   
end
assign s00_axis_phase_tvalid_d2 = shift[1];   
assign s00_axis_phase_tvalid_d3 = shift[2];   
assign s00_axis_phase_tvalid_d7 = shift[6];   
assign s00_axis_phase_tvalid_d4 = shift[3];   
assign s00_axis_phase_tvalid_d13 = shift[12];   



assign s00_axis_phase_tdata_tmp = (s00_axis_phase_tvalid) ? s00_axis_phase_tdata : 64'd0;

	 
	dds_compiler_0 dds_compiler_0_Inst 
	(
		.aclk					(clk							),	 
	    .aresetn                (rstn                           ),   
		.s_axis_phase_tvalid	(rstn			),   
		.s_axis_phase_tdata	    (s00_axis_phase_tdata_tmp			),	 
		.m_axis_phase_tvalid	(m00_axis_phase_tvalid			),   
		.m_axis_phase_tdata		(m00_axis_phase_tdata			)	 
	);
	
	 
	
	assign m00_axis_phase_tdata_tmp = (s00_axis_phase_tvalid_d2) ? m00_axis_phase_tdata : 32'd0;
	assign s01_axis_offset_tdata_tmp = (s00_axis_phase_tvalid) ? s01_axis_offset_tdata : 32'd0;
	
	dds_phase_mes dds_phase_mes_Inst
	(
		.clk					(clk							),
		.rstn					(rstn							),
		.Phase_Increment		(m00_axis_phase_tdata_tmp		),
		.Phase_Increment_Valid	(1'b1			),
		.Phase_Offset			(s01_axis_offset_tdata			),
		.Phase_Offset_Valid		(1'b1			),
		.Phase_Out				(m01_axis_phase_out_tdata_tmp		),
		.Phase_Out_Valid		(m01_axis_phase_out_tvalid		)
	);

assign m01_axis_phase_out_tdata = (s00_axis_phase_tvalid_d4)?m01_axis_phase_out_tdata_tmp:64'd0;




reg [15:0] rstn_shift;   
wire    rstn_d1;
wire    rstn_d3;
wire    rstn_d5;
always @(posedge clk) begin
        rstn_shift <= {rstn_shift[14:0], rstn};   
end
assign rstn_d1 = rstn_shift[0];   
assign rstn_d3 = rstn_shift[2];   
assign rstn_d5 = rstn_shift[4];   


reg  [31:0]     fc_phase = 32'd0;
always @(posedge clk) begin
    if(!rstn && rstn_d1)
        fc_phase <= fc_phase + fc_scale;
    else
        fc_phase <= fc_phase;
end




	 
	dds_compiler_1 dds_compiler_1_Inst 
	(
		.aclk					(clk							),	 
		.aresetn                (rstn                          ),   
		.s_axis_phase_tvalid	(rstn && rstn_d5 && rstn_d3                    	),   
		.s_axis_phase_tdata	    ({(m01_axis_phase_out_tdata[63:32]+fc_phase),m01_axis_phase_out_tdata[31:0]}		),	 
		.m_axis_phase_tvalid	(m02_axis_phase_tvalid			),   
		.m_axis_phase_tdata		(m02_axis_phase_tdata			),	 
		.m_axis_data_tvalid     (m05_axis_dout_tvalid           ),   
		.m_axis_data_tdata      (m05_axis_dout_tdata            )    
	);
	
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
	
	 
	assign	m_cos_axis_tvalid = s00_axis_phase_tvalid_d13;
	assign	m_cos_axis_tdata = (s00_axis_phase_tvalid_d13)?{m05_axis_dout_tdata[13:0], 2'b00}:16'd0;
	assign	m_sin_axis_tvalid = s00_axis_phase_tvalid_d13;
	assign	m_sin_axis_tdata = (s00_axis_phase_tvalid_d13)?{m05_axis_dout_tdata[29:16], 2'b00}:16'd0;
	assign	m_axis_tvalid = s00_axis_phase_tvalid_d13;
	assign	m_axis_tdata = (s00_axis_phase_tvalid_d13)?{m05_axis_dout_tdata[29:16], 2'b00, m05_axis_dout_tdata[13:0], 2'b00}:32'd0;
	
endmodule
