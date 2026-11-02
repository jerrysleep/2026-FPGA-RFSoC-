`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


module dds_phase_mes #
(
	parameter	integer	PHASE_WIDTH = 32
)
(
	input   					clk,
	input   					rstn,
	input	[PHASE_WIDTH-1:0]   Phase_Increment,
	input						Phase_Increment_Valid,
	input	[PHASE_WIDTH-1:0]	Phase_Offset,
	input						Phase_Offset_Valid,
	output	[PHASE_WIDTH*2-1:0]	Phase_Out,
	output						Phase_Out_Valid
);

	reg	[PHASE_WIDTH-1:0]	Phase_Increment_d1;
	reg	[PHASE_WIDTH-1:0]	Phase_Increment_d2;
	reg	[PHASE_WIDTH*2-1:0]	Phase_OffInc;
	reg	[PHASE_WIDTH*2-1:0]	Phase_OffInc_d1;
	reg						Valid_d1;
	reg						Valid_d2;
 
	always @(posedge clk) begin
		if(rstn == 0) begin
			Phase_Increment_d1 <= 0;
		end
		else begin
			Phase_Increment_d1 <= Phase_Increment;
		end
	end

	always @(posedge clk) begin
		if(rstn == 0)
			Phase_Increment_d2 <= 0;
		else if(Phase_Increment_Valid)
			Phase_Increment_d2 <= Phase_Increment_d1;
		else
			Phase_Increment_d2 <= 0;
	end

	always @(posedge clk) begin
		if(rstn == 0)
			Phase_OffInc <= 0;
		else if(Phase_Increment_Valid && Phase_Offset_Valid)
			Phase_OffInc <= {Phase_Offset,Phase_Increment};
		else
			 Phase_OffInc <= 0;
	end
	
	always @(posedge clk) begin
		if(rstn == 0)
			Valid_d1 <= 0;
		else if(Phase_Increment_Valid && Phase_Offset_Valid)
			Valid_d1 <= 1;
		else
			 Valid_d1 <= 0;
	end

	always @(posedge clk) begin
		if(rstn == 0)
			Valid_d2 <= 0;
		else
			Valid_d2 <= Valid_d1;
	end
	
 
 
 
 
 
 
 
 
 
 
 
 
 
 
	
	always @(posedge clk) begin
	   if(rstn == 0)
	       Phase_OffInc_d1 <= 0;
	   else
	       Phase_OffInc_d1 <= Phase_OffInc;
	end
	
	assign Phase_Out = Phase_OffInc_d1;
	assign Phase_Out_Valid = Valid_d2;
 
	
endmodule
