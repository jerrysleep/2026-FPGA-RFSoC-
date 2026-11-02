`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
	`define 					REF_FFT_Point_Normal 		10'd73  			 
	`define						REF_FFT_Point_Ground 		10'd71				 


 
	`define						USE_UPC_LOCAL				1'b1				 
	`define						local_delay_tf_pm			16'd1				 
	`define						local_length_tf_pm			16'd49				 
	`define						local_delay_tf_pc			16'd1				 
	`define						local_length_tf_pc			16'd49				 
	`define						local_delay_tr_k			16'd49				 
	`define						local_length_tr_k			16'd225				 
	`define						local_delay_ADC				16'd45				 
	`define						local_length_ADC			16'd250				 
	`define						local_delay_PhaseRef		16'd0
	`define                     local_length_PhaseRef		16'd0
	`define						LOCAL_PRT_Period			16'd96				 
	`define						LOCAL_FRAME_Period			32'd282623			 
	`define						LOCAL_FRAME_Period_DEC16	32'd4521983			 
	`define						LOCAL_PRT_Num				16'd1024			 
	`define						DECIMATOR_PARA				8'd14				 
	
	`define						FR_DELAY_CYCLE_FAR			32'd2
	`define						FR_DELAY_CYCLE_NEAR			32'd2
	
 

 

 
     
	`define						ALL_STORE_BLOCK_NUM				3'd5		 
	
     
    `define                     DDR_ADDR_ONCE_ADD               29'd8                       
    
    `define                     FRAME_NUM_ONE_BLOCK             10'd800                 
    `define                     FRAME_NUM_ONE_BLOCK_ADD1        10'd801                 
    `define                     FRAME_NUM_ONE_BLOCK_SUB1        10'd799                 
    
    `define                     DDR_CYCLE_ONE_FRAME             13'd2305                  
    `define                     DDR_CYCLE_ONE_FRAME_ADD1        13'd2306                
    `define                     DDR_CYCLE_ONE_FRAME_ADD2        13'd2307                
    `define                     DDR_CYCLE_ONE_FRAME_SUB1        13'd2304                
    `define                     DDR_CYCLE_ONE_FRAME_SUB2        13'd2303                
    `define                     DDR_CYCLE_ONE_FRAME_SUB3        13'd2302                

    `define                     LAST_ADDR_ECHO_DATA             29'h00E1_18F8               
    `define                     LAST_ADDR_ECHO_DATA_ADD8        29'h00E1_1900               
    
    `define                     First_START_ADDR                29'h0000_0000           
    `define                     Second_START_ADDR               29'h0200_0000           
    `define                     Third_START_ADDR                29'h0400_0000           
    `define                     Fourth_START_ADDR               29'h0600_0000           
    `define                     Fifth_START_ADDR                29'h0800_0000           
    
    `define                     First_END_ADDR                  29'h00FF_FFF8           
    `define                     Second_END_ADDR                 29'h02FF_FFF8           
    `define                     Third_END_ADDR                  29'h04FF_FFF8           
    `define                     Fourth_END_ADDR                 29'h06FF_FFF8           
    `define                     Fifth_END_ADDR                  29'h08FF_FFF8           
    
    `define                     First_END_ADDR_ADD8             29'h0100_0000           
    `define                     Second_END_ADDR_ADD8            29'h0300_0000           
    `define                     Third_END_ADDR_ADD8             29'h0500_0000           
    `define                     Fourth_END_ADDR_ADD8            29'h0700_0000           
    `define                     Fifth_END_ADDR_ADD8             29'h0900_0000           
    
    `define                     One_Cycle_Start_Addr            29'h0000_0000           
    `define                     One_Cycle_end_Addr              29'h00FF_FFF8           
    `define                     One_Cycle_end_Addr_SUB8         29'h00FF_FFF0           
    `define                     One_Cycle_end_Addr_ADD8         29'h0100_0000           


		
    `define                     One_Cycle_Temp_Start_Addr       29'h00E1_1900                 		 
    `define                     One_Cycle_Temp_End_Addr         29'h00E1_31F8                 		 
    `define                     One_Cycle_Temp_End_Addr_Add8    29'h00E1_3200                 		 
		
	 
     
     
     
     
     
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 

	 
	 
	 
	 
	 
	
	 
    `define                     One_Cycle_INFO_Addr             29'h00FF_F370                 		 
    `define                     One_Cycle_INFO_Addr_ADD8        29'h00FF_F378                 		 
    `define                     One_Cycle_INFO_Addr_ADD16       29'h00FF_F380                 		 
	`define                     Dist_Vel_DiffPh_RAM_CNT         16'd6400                       		 
    `define                     Dist_Vel_DiffPh_RAM_CNT_SUB1    16'd6399                       		 
	 
	`define						Dist_Vel_RAM_ByteNum			14'd6400							 
	`define						Dist_Vel_RAM_ByteNum_SUB1		14'd6399							 
	`define						Dist_Vel_RAM_ByteNum_ADD1		14'd6401							 
	`define						Dist_Vel_OneFrame_ByteNum		4'd8								 
	`define						Dist_Vel_OneFrame_ByteNum_SUB1	4'd7								 

	`define						First_VelRAM_Start_ADDR			16'd0								 
	`define						Second_VelRAM_Start_ADDR		16'h2000							 
	`define						Third_VelRAM_Start_ADDR			16'h4000							 
	`define						Fourth_VelRAM_Start_ADDR		16'h6000							 
	`define						Fifth_VelRAM_Start_ADDR			16'h8000							 

	`define						First_VelRAM_End_ADDR			16'h18ff							 
	`define						Second_VelRAM_End_ADDR			16'h38ff							 
	`define						Third_VelRAM_End_ADDR			16'h58ff							 
	`define						Fourth_VelRAM_End_ADDR			16'h78ff							 
	`define						Fifth_VelRAM_End_ADDR			16'h98ff							 

 
 
 
 
 
 
 
 
 
 
	`define						VelRAM_200Frame_ADDR_TH1		16'd3128							 
	`define						VelRAM_200Frame_ADDR_TH2		16'd4720							 
	`define						VelRAM_800Frame_ADDR_ALL		16'd6400							 
	`define						VelRAM_800Frame_ADDR_ALL_SUB1	16'd6399							 
	`define						VelRAM_PackageNum_One_Block		8'd54								 
	`define						VelRAM_PackageNum_One_Block_SUB1	8'd53								 
	 
	 
	 
	 
	 

	`define						VelRAM_ByteNum_One_Package			8'd32								 
	`define						VelRAM_ByteNum_One_Package_SUB1		8'd31								 
	`define						FRAME_HEAD_LENGTH					8'd14						 
	`define						FRAME_HEAD_LENGTH_SUB1				8'd13						 
	`define						FRAME_HEAD_LENGTH_ADD1				8'd15						 
	`define						COMM_HEAD_LENGTH					8'd2						 


 

 

 
	`define						Volt_18V_Lower_Limit			8'd86						 
	`define						Volt_18V_Upper_Limit			8'd102					 

	`define						Volt_5V3_Lower_Limit			8'd0						 
	`define						Volt_5V3_Upper_Limit			8'hFF						 

	`define						Temp_TF_Lower_Limit				8'd0						 
	`define						Temp_TF_Upper_Limit				8'hFF						 
	
	`define						Temp_FPGA_Lower_Limit			8'd0						 
	`define						Temp_FPGA_Upper_Limit			8'hFF						 

	`define						RS422_2ms						32'd200_000					 
	`define						RS422_15ms						32'd1_500_000				 
















