`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
(*KEEP_HIERARCHY = "YES"*)module timing_ref(
input										clk,					 
input										rst,					 
	
input						[15:0]		PRT,					 
input						[31:0]		FRAME_TIME,			 
input						[15:0]		PRT_NUM,				 

output		reg						frame_ref,			 
output		reg						prt_ref				 
    );

reg		[15:0]						cnt_cycle_prt;		 
reg		[31:0]						cnt_cycle_frame;	 

always@(posedge clk or posedge rst)begin
	if(rst == 1'b1)
		cnt_cycle_frame	<=	32'd0;
	else if(cnt_cycle_frame >= FRAME_TIME)
		cnt_cycle_frame	<=	32'd0;
	else
		cnt_cycle_frame	<=	cnt_cycle_frame + 32'd1;
end

always@(posedge clk or posedge rst)begin
	if(rst == 1'b1)
		frame_ref	<=	1'b0;
	else if((cnt_cycle_frame == 32'd0))				 
		frame_ref	<=	1'b1;
	else
		frame_ref	<=	1'b0;
end

 
always@(posedge clk or posedge rst)begin
	if(rst == 1'b1)
		cnt_cycle_prt			<=	16'd0;
	else	if((cnt_cycle_prt >= PRT) || (cnt_cycle_frame >= FRAME_TIME))
		cnt_cycle_prt			<=	16'd0;
	else
		cnt_cycle_prt			<=	cnt_cycle_prt + 16'd1;
end		

always@(posedge clk or posedge rst)begin
	if(rst == 1'b1)
		prt_ref					<=	1'b0;
	else if (cnt_cycle_prt == 16'd0)
		prt_ref					<=	1'b1;
	else
		prt_ref					<=	1'b0;
end	
			
endmodule
