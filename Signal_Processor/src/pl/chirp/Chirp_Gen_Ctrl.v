`timescale 1ns / 1ps

module Chirp_Gen_Ctrl #
(
	parameter	integer	C_DDS_CHNL_NUM = 32,
	parameter	integer	C_DDS_PHASE_WIDTH = 32
)
(
	input													sys_clk,
	input													sys_rstn,
	
	input													chirp_gen_gate,
	
	input													axi_resetn,
	input													axi_update_flag,
	input		[31:0]										axi_chirp_width,
	input													axi_chirp_gen_en,
	input		[64*C_DDS_CHNL_NUM-1:0]						axi_phase_tdata,
	input		[32*C_DDS_CHNL_NUM-1:0]						axi_offset_tdata,
	(*MAX_FANOUT = 32*)	output	reg												chirp_phase_tvalid,
						output	reg	[C_DDS_PHASE_WIDTH*2*C_DDS_CHNL_NUM-1:0]	chirp_phase_tdata,
	(*MAX_FANOUT = 32*)	output	reg												chirp_offset_tvalid,
						output	reg	[C_DDS_PHASE_WIDTH*C_DDS_CHNL_NUM-1:0]		chirp_offset_tdata,
						output	reg	[31:0]										chirp_resetn
);
 	reg 	[1:0]	loc_updata_flag;
 	reg 	[1:0]	loc_chirp_gen_en;
	always @(posedge sys_clk) begin
		if(!sys_rstn) begin
			loc_updata_flag <= 0;
			loc_chirp_gen_en <= 0;
		end
		else begin
			loc_updata_flag[0] <= axi_update_flag;
			loc_updata_flag[1] <= loc_updata_flag[0];
			loc_chirp_gen_en[0] <= axi_chirp_gen_en;
			loc_chirp_gen_en[1] <= loc_chirp_gen_en[0];
		end
	end
	
 
 
 
	reg		[1:0]	shift_update_flag;
	(*MAX_FANOUT = 32*)	reg				update_flag;
	
	always @(posedge sys_clk) begin
		if(!sys_rstn) begin
			shift_update_flag <= 0;
			update_flag <= 0;
		end
		else begin
			shift_update_flag <= {shift_update_flag[0], loc_updata_flag[1]};
			
			if(shift_update_flag == 2'b01)
				update_flag <= 1;
			else if(update_flag && !chirp_offset_tvalid && !chirp_phase_tvalid)
				update_flag <= 0;
			else
				update_flag <= update_flag;
		end
	end
	
	genvar i;
	generate
	for(i=0; i<C_DDS_CHNL_NUM; i=i+1) begin
		always @(posedge sys_clk) begin
			if(!sys_rstn) begin
				chirp_phase_tdata[C_DDS_PHASE_WIDTH*2*i+:C_DDS_PHASE_WIDTH*2] <= 0;
				chirp_offset_tdata[C_DDS_PHASE_WIDTH*i+:C_DDS_PHASE_WIDTH] <= 0;
			end
			else begin
				if(update_flag && !chirp_offset_tvalid && !chirp_phase_tvalid) begin
					chirp_phase_tdata[C_DDS_PHASE_WIDTH*2*i+:C_DDS_PHASE_WIDTH] <= axi_phase_tdata[64*i+:C_DDS_PHASE_WIDTH];
					chirp_phase_tdata[(C_DDS_PHASE_WIDTH*2*i+C_DDS_PHASE_WIDTH)+:C_DDS_PHASE_WIDTH] <= axi_phase_tdata[(64*i+32)+:C_DDS_PHASE_WIDTH];
					chirp_offset_tdata[C_DDS_PHASE_WIDTH*i+:C_DDS_PHASE_WIDTH] <= axi_offset_tdata[32*i+:C_DDS_PHASE_WIDTH];
				end
				else begin
					chirp_phase_tdata[C_DDS_PHASE_WIDTH*2*i+:C_DDS_PHASE_WIDTH] <= chirp_phase_tdata[C_DDS_PHASE_WIDTH*2*i+:C_DDS_PHASE_WIDTH];
					chirp_phase_tdata[(C_DDS_PHASE_WIDTH*2*i+C_DDS_PHASE_WIDTH)+:C_DDS_PHASE_WIDTH] <= chirp_phase_tdata[(C_DDS_PHASE_WIDTH*2*i+C_DDS_PHASE_WIDTH)+:C_DDS_PHASE_WIDTH];
					chirp_offset_tdata[C_DDS_PHASE_WIDTH*i+:C_DDS_PHASE_WIDTH] <= chirp_offset_tdata[C_DDS_PHASE_WIDTH*i+:C_DDS_PHASE_WIDTH];
				end
			end
		end
	end
	endgenerate
	
 
 
 
		reg				loc_chirp_gen_gate;
		reg		[1:0]	shift_chirp_gen_gate;
		reg				pos_chirp_gen_gate;
		reg		[31:0]	chirp_gen_cnt;
	
	 
	 
	always @(posedge sys_clk) begin
		loc_chirp_gen_gate <= chirp_gen_gate;
	end
	always @(posedge sys_clk) begin
		if(!sys_rstn)
			shift_chirp_gen_gate <= 0;
		else
			shift_chirp_gen_gate <= {shift_chirp_gen_gate[0], loc_chirp_gen_gate};
	end

	always @(posedge sys_clk) begin
		if(!sys_rstn)
			pos_chirp_gen_gate <= 0;
		else if(shift_chirp_gen_gate == 2'b01)
			pos_chirp_gen_gate <= 1;
		else
			pos_chirp_gen_gate <= 0;
	end

	 
	reg chirp_resetn_d1;
	always @(posedge sys_clk) begin
		if(!sys_rstn)
			chirp_resetn_d1 <= 1'b1;   
		else
			chirp_resetn_d1 <= chirp_resetn[0];   
	end
	wire reset_release = chirp_resetn[0] & ~chirp_resetn_d1;   

	always @(posedge sys_clk) begin
		if(!sys_rstn || !loc_chirp_gen_en[1]) begin
			chirp_offset_tvalid <= 0;
			chirp_phase_tvalid <= 0;
		end
		else if(reset_release) begin   
			chirp_offset_tvalid <= 1;
			chirp_phase_tvalid <= 1;
		end
		else if(chirp_gen_cnt >= axi_chirp_width - 1) begin
			chirp_offset_tvalid <= 0;
			chirp_phase_tvalid <= 0;
		end
		else begin
			chirp_offset_tvalid <= chirp_offset_tvalid;
			chirp_phase_tvalid <= chirp_phase_tvalid;
		end
	end
	
	always @(posedge sys_clk) begin
		if(!sys_rstn) begin
			chirp_gen_cnt <= 0;
		end
		else if(axi_chirp_width == 32'hFFFFFFFF) begin
			chirp_gen_cnt <= 0;
		end
		else if(chirp_phase_tvalid) begin
			if(chirp_gen_cnt >= axi_chirp_width - 1)
				chirp_gen_cnt <= 0;
			else
				chirp_gen_cnt <= chirp_gen_cnt + 1;
		end
		else
			chirp_gen_cnt <= 0;
	end
	
	 
	 


	 
	 
 
	
	
	 
	reg		[31:0]	chirp_rstn_cnt;
	
	always @(posedge sys_clk) begin
		if(!sys_rstn)
			chirp_resetn <= 32'hFFFFFFFF;
		else if(shift_chirp_gen_gate == 2'b01)
			chirp_resetn <= 0;
		else if(chirp_rstn_cnt >= 2)
			chirp_resetn <= 32'hFFFFFFFF;
		else
			chirp_resetn <= chirp_resetn;
	end
	
	always @(posedge sys_clk) begin
		if(!sys_rstn)
			chirp_rstn_cnt <= 0;
		else if(!chirp_resetn) begin
			if(chirp_rstn_cnt >= 2)
				chirp_rstn_cnt <= 0;
			else
				chirp_rstn_cnt <= chirp_rstn_cnt + 1;
		end
		else
			chirp_rstn_cnt <= 0;
	end
	
endmodule