`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


(*KEEP_HIERARCHY = "YES"*)module FrameRef_delay_ctrl # (
	parameter			DELAY_CYCLE		= 32'd100

    )(
	input					clk			,
	input					rst			,
	input					frameref_in	,
	output					frameref_out	
	);
	
	reg			[DELAY_CYCLE-1:0]			shift_reg			;
	
	
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			shift_reg			<= {DELAY_CYCLE{1'b0}};
		end
		else begin
			shift_reg 			<={shift_reg[DELAY_CYCLE-2:0],frameref_in};
		end
	end
	assign	frameref_out = shift_reg[DELAY_CYCLE-1];
	
endmodule
