`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 

 


(*KEEP_HIERARCHY = "YES"*) module ping_pang_switch(
	input								clk						,		 
	input								rst						,		 
	
(*KEEP = "TRUE"*)	input								timer_module_en			,		 
(*KEEP = "TRUE"*)	input								frame_start_pose_edge	,		 
(*KEEP = "TRUE"*)	input								frame_start_neg_edge	,		 
 
(*KEEP = "TRUE"*)	input			[15:0]				din_i					,		 
(*KEEP = "TRUE"*)	input			[15:0]				din_q					,		 
 
(*KEEP = "TRUE"*)	input			[15:0]				wr_addr					,		 
(*KEEP = "TRUE"*)	input								wr_en					,		 
 
(*KEEP = "TRUE"*)	input			[15:0]				rd_addr					,		 
(*KEEP = "TRUE"*)	input								rd_en					,		 
(*KEEP = "TRUE"*)	output			[31:0]				dout					,		 
(*KEEP = "TRUE"*)	output	reg							dout_valid						 

    );

	
	
(*KEEP = "TRUE"*)	reg			[31:0]					din						;
(*KEEP = "TRUE"*)	reg			[15:0]					wr_addr_d1				;
(*KEEP = "TRUE"*)	reg			[15:0]					rd_addr_d1				;
 
(*KEEP = "TRUE"*)	reg									wr_ping					;
(*KEEP = "TRUE"*)	reg									wr_pang					;
(*KEEP = "TRUE"*)	reg									rd_ping					;
(*KEEP = "TRUE"*)	reg									rd_pang					;
(*KEEP = "TRUE"*)	reg									rd_ping_d1				;		 
(*KEEP = "TRUE"*)	reg									rd_pang_d1				;
(*KEEP = "TRUE"*)	reg									rd_ping_d2				;		 
(*KEEP = "TRUE"*)	reg									rd_pang_d2				;	
 
(*KEEP = "TRUE"*)	reg									wr_en_ping				;
(*KEEP = "TRUE"*)	reg									wr_en_pang				;
(*KEEP = "TRUE"*)	reg									rd_en_ping				;
(*KEEP = "TRUE"*)	reg									rd_en_pang				;

		
(*KEEP = "TRUE"*)	wire		[31:0]					dout_ping				;
(*KEEP = "TRUE"*)	wire		[31:0]					dout_pang				;
reg     [31:0]  din_d1;
reg     [31:0]  din_d2;
	
	
	 

	
	 
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			din					<= 32'd0						;
			din_d1               <= 32'd0                        ;
			din_d2               <= 32'd0                        ;
			wr_addr_d1			<= 16'd0						;
			rd_addr_d1			<= 16'd0						;			
		end
		else begin
			din					<= {din_q,din_i}				;
			din_d1               <=din                        ;
			din_d2               <= din_d1                        ;			
			wr_addr_d1			<= wr_addr						;
			rd_addr_d1			<= rd_addr						;			
		end
	end
	 
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			wr_ping				<= 1'b0							;
			wr_pang				<= 1'b1							;
			rd_ping				<= 1'b1							;
			rd_pang				<= 1'b0							;
		end
		else begin
			if(timer_module_en == 1'b1	)begin
				if(frame_start_pose_edge == 1'b1 ) begin					 
					wr_ping			<= ~wr_ping					;
					wr_pang			<= ~wr_pang					;
					rd_ping			<= ~rd_ping					;
					rd_pang			<= ~rd_pang					;
				end
				else begin
					wr_ping			<= wr_ping					;
					wr_pang			<= wr_pang					;
					rd_ping			<= rd_ping					;
					rd_pang			<= rd_pang					;				
				end
			end
			else begin
				wr_ping				<= 1'b0						;
				wr_pang				<= 1'b1						;
				rd_ping				<= 1'b1						;
				rd_pang				<= 1'b0						;			
			end
		end
	end
	
	 
	
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			wr_en_ping				<= 1'b0						;
		end
		else begin
			if(wr_ping== 1'b1)
				wr_en_ping			<= wr_en					;
			else
				wr_en_ping			<= 1'b0						;
		end
	end
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			wr_en_pang				<= 1'b0						;
		end
		else begin
			if(wr_pang== 1'b1)
				wr_en_pang			<= wr_en					;
			else
				wr_en_pang			<= 1'b0						;
		end
	end
	
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			rd_en_ping				<= 1'b0						;
		end
		else begin
			if(rd_ping== 1'b1)
				rd_en_ping			<= rd_en					;
			else
				rd_en_ping			<= 1'b0						;
		end
	end
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			rd_en_pang				<= 1'b0						;
		end
		else begin
			if(rd_pang== 1'b1)
				rd_en_pang			<= rd_en					;
			else
				rd_en_pang			<= 1'b0						;
		end
	end
 
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			rd_ping_d1				<= 1'b0						;
			rd_pang_d1				<= 1'b0						;
			rd_ping_d2				<= 1'b0						;	
			rd_pang_d2	            <= 1'b0						;
		end
		else begin
			rd_ping_d1				<= rd_ping					;
			rd_pang_d1				<= rd_pang					;
			rd_ping_d2				<= rd_ping_d1				;	
			rd_pang_d2	            <= rd_pang_d1				;			
		end
	end
	always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) begin
			dout_valid				<= 1'b0						;
		end
		else begin
			if( rd_en_ping || rd_en_pang) 
				dout_valid			<= 1'b1						;
			else
				dout_valid			<= 1'b0						;
		end
	end	
	assign	dout = (rd_ping_d2 == 1'b1) ? dout_ping :dout_pang 	;

buffer_ram ping_ram (
  .clka						(	clk					)			,     
  .wea						(	wr_en_ping			)			,     
  .addra					(	wr_addr_d1			)			,     
  .dina						(	din_d2					)			,     
  .clkb						(	clk					)			,     
  .enb						(	rd_en_ping			)			,     
  .addrb					(	rd_addr_d1			)			,  	  
  .doutb					(	dout_ping			)  				  
);	

buffer_ram pang_ram (
  .clka						(	clk					)			,     
  .wea						(	wr_en_pang			)			,     
  .addra					(	wr_addr_d1			)			,     
  .dina						(	din_d2					)			,     
  .clkb						(	clk					)			,     
  .enb						(	rd_en_pang			)			,     
  .addrb					(	rd_addr_d1			)			, 	  
  .doutb					(	dout_pang			)  				  
);

	

	
endmodule
