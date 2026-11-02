`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
(*KEEP_HIERARCHY = "YES"*)module timing_cell(
input				clk,						 
input				rst,						 

input				pul_in,					 
input	[15:0]	delay_in,					 
input	[15:0]	width,					 
input				en,						 

output	reg	pul_out
 );

(*keep="true"*)reg	[15:0]	cnt_cycle_pul;			 
(*keep="true"*)reg	[15:0]	cnt_width;				 
(*keep="true"*)reg				valid;					 

 
always@(posedge clk or posedge rst)begin
	if(rst == 1'b1)begin
		valid	<= 1'b0;
	end
	else begin
		if(pul_in)										 
			valid	<= 1'b1;
		else if(cnt_cycle_pul == delay_in)			 
			valid	<= 1'b0;
		else
			valid	<= valid;
	end
end		

always@(posedge clk or posedge rst)begin
	if(rst == 1'b1)begin
		cnt_cycle_pul	<=	16'd0;
	end
	else begin
		if(pul_in)										 
			cnt_cycle_pul	<=	16'd0;
		else if(valid)begin							 
			if(cnt_cycle_pul == delay_in)				 
				cnt_cycle_pul	<=	16'd0;
			else
				cnt_cycle_pul	<=	cnt_cycle_pul + 16'd1;	
		end
		else
			cnt_cycle_pul	<=	16'd0;
	end
end

always@(posedge clk or posedge rst)begin
	if(rst == 1'b1)begin
		cnt_width	<=	16'd0;
	end
	else begin
		if(cnt_cycle_pul == delay_in)					 
			cnt_width	<=	16'd1;
		else if(cnt_width > 16'd0)begin
			if(cnt_width == width)					 
				cnt_width	<=	16'd0;  
			else
				cnt_width	<=	cnt_width + 16'd1;
		end
		else
			cnt_width	<=	cnt_width;
	end
end

always@(posedge clk or posedge rst)begin
	if(rst == 1'b1)begin
		pul_out	<=	1'b0;
	end
	else begin
		if((cnt_cycle_pul == delay_in) && en && valid)	 
			pul_out	<=	1'b1;
		else if(cnt_width == width)						 
			pul_out	<=	1'b0;
		else
			pul_out	<=	pul_out;
	end
end

endmodule
