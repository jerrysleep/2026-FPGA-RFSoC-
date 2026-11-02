`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


(*KEEP_HIERARCHY = "YES"*)module LMK04828_config(
    input        			clk_1M,
    input        			sys_rst,
    input        			clk_50m,
    input   				sleep_order,
	output  				LMK_ADC_SCLK,
	inout   				LMK_ADC_SDIO,
	output  				LMK_ADC_CS,
(* KEEP = "true" *)	output	reg				LMK04828_SYNC	,	
(* KEEP = "true" *)	output reg  			lmk04828_rst,
(* KEEP = "true" *)	output reg  			lmk_cfg_LOCKED,
(* KEEP = "true" *)	output reg  			lmk_cfg_finish
    );
 
 
 
wire        idle_flag;
wire [7:0]  data_read_out1;
wire [7:0]  data_read_out2;
wire [15:0] reg_addr;
wire [7:0]  config_value;
wire        start_spi;

wire        cfg_start_dac;
reg         cfg_start_dac1;
reg         cfg_start_dac2;
reg         set_start;
reg  [15:0] set_addr;
reg  [7:0]  set_data;
 
wire [15:0]  vio_config_addr;
wire [7:0]   vio_config_data;
wire         vio_start_spi;
wire         vio_select;


 

 
 

 
reg clk_1M_reg0,clk_1M_reg1;
reg clk_1M_en;
reg clk_1M_en_nege;
always@(posedge clk_50m)
begin
  clk_1M_reg0 <= clk_1M;
  clk_1M_reg1 <= clk_1M_reg0;
  
  clk_1M_en<=clk_1M_reg0&&(~clk_1M_reg1);
  clk_1M_en_nege<=clk_1M_reg1&&(~clk_1M_reg0);
end 

 
reg      sysref_on;
reg [31:0] cnt_time;
always@(posedge clk_50m or negedge lmk_cfg_LOCKED)begin
    if(~lmk_cfg_LOCKED)begin
        cnt_time<=16'd0;
        LMK04828_SYNC<=1'b0;
        sysref_on<=1'b0;
    end else begin
        if(cnt_time>=32'd50_000_00)begin 
            cnt_time<=cnt_time;
        end else begin
            cnt_time<=cnt_time+1;
        end
        LMK04828_SYNC<=(cnt_time>=32'd50_000_0)&&(cnt_time<=32'd50_040_0); 
        sysref_on<=(cnt_time>=32'd50_000_00); 
    end
end

 
wire [23 : 0] cfg_regs[133 : 0];
assign cfg_regs[0]      = {24'h000090};	 
assign cfg_regs[1]      = {24'h000000};  
assign cfg_regs[2]      = {24'h000200};	 
assign cfg_regs[3]      = {24'h000300}; 
assign cfg_regs[4]      = {24'h000400};  
assign cfg_regs[5]      = {24'h000500}; 
assign cfg_regs[6]      = {24'h000600}; 
assign cfg_regs[7]      = {24'h000C00}; 
assign cfg_regs[8]      = {24'h000D00};  
                          
assign cfg_regs[9]      = {24'h01000A};	 
assign cfg_regs[10]     = {24'h010100};	 
assign cfg_regs[11]     = {24'h010200};	 
assign cfg_regs[12]     = {24'h010300};	 
assign cfg_regs[13]     = {24'h010420};	 
assign cfg_regs[14]     = {24'h010500};   
assign cfg_regs[15]     = {24'h010600};	 
assign cfg_regs[16]     = {24'h010707};	 
                     
assign cfg_regs[17]     = {24'h01080A};	 
assign cfg_regs[18]     = {24'h010900};	 
assign cfg_regs[19]     = {24'h010A00};	 
assign cfg_regs[20]     = {24'h010B00};	 
assign cfg_regs[21]     = {24'h010C20};	 
assign cfg_regs[22]     = {24'h010D00};	 
assign cfg_regs[23]   	= {24'h010E00};	 
assign cfg_regs[24]   	= {24'h010F07};	 
                     
assign cfg_regs[25]   	= {24'h01100A};	 
assign cfg_regs[26]   	= {24'h011100};	 
assign cfg_regs[27]   	= {24'h011200};	 
assign cfg_regs[28]   	= {24'h011300};	 
assign cfg_regs[29]   	= {24'h011420};	 
assign cfg_regs[30]   	= {24'h011500};	 
assign cfg_regs[31]   	= {24'h011600}; 	 
assign cfg_regs[32]   	= {24'h011707};	 
                   
assign cfg_regs[33]   	= {24'h01180A};	 
assign cfg_regs[34]   	= {24'h011900};	 
assign cfg_regs[35]     = {24'h011A00};	 
assign cfg_regs[36]   	= {24'h011B00};	 
assign cfg_regs[37]   	= {24'h011C20};	 
assign cfg_regs[38]   	= {24'h011D00};	 
assign cfg_regs[39]   	= {24'h011E00};	 
assign cfg_regs[40]   	= {24'h011F07};	 
                   
assign cfg_regs[41]     = {24'h01200A};	 
assign cfg_regs[42]     = {24'h012100};   
assign cfg_regs[43]     = {24'h012200};	 
assign cfg_regs[44]     = {24'h012300};	 
assign cfg_regs[45]     = {24'h012420};	 
assign cfg_regs[46]     = {24'h012500};	 
assign cfg_regs[47]     = {24'h012601};	 
assign cfg_regs[48]     = {24'h012777};	 
                  
assign cfg_regs[49]     = {24'h01280A};	 
assign cfg_regs[50]     = {24'h012900};	 
assign cfg_regs[51]     = {24'h012A00};	 
assign cfg_regs[52]     = {24'h012B20};	 
assign cfg_regs[53]     = {24'h012C20};	 
assign cfg_regs[54]     = {24'h012D00};	 
assign cfg_regs[55]     = {24'h012E01};	 
assign cfg_regs[56]     = {24'h012F77};	 
                  
assign cfg_regs[57]     = {24'h01300A};	 
assign cfg_regs[58]     = {24'h013100};	 
assign cfg_regs[59]     = {24'h013200};	 
assign cfg_regs[60]     = {24'h013300};	 
assign cfg_regs[61]     = {24'h013420};                                                                                                                                                                    
assign cfg_regs[62]     = {24'h013500};	 
assign cfg_regs[63]     = {24'h013601};                                                                                                                                                                    
assign cfg_regs[64]     = {24'h013707};	 
                                                                                 
assign cfg_regs[65]     = {24'h013800};	 
assign cfg_regs[66]     = {24'h013900};	 
assign cfg_regs[67]     = {24'h013A01};	 
assign cfg_regs[68]     = {24'h013B00};	 
assign cfg_regs[69]     = {24'h013C00};	 
assign cfg_regs[70]     = {24'h013D08};	 
assign cfg_regs[71]     = {24'h013E03};	 
assign cfg_regs[72]     = {24'h013F00};	 
assign cfg_regs[73]     = {24'h014003};	 
assign cfg_regs[74]     = {24'h014100};                                                                                                                                                                    
assign cfg_regs[75]     = {24'h014200};	 

assign cfg_regs[76]     = {24'h014391};	 
assign cfg_regs[77]     = {24'h014311};	 
                                                                                                                     
assign cfg_regs[78]     = {24'h014480}; 
assign cfg_regs[79]     = {24'h01457F};                                                                                                                                                                    
assign cfg_regs[80]     = {24'h014610};  
assign cfg_regs[81]     = {24'h01471B};  
assign cfg_regs[82]     = {24'h014802};	 
assign cfg_regs[83]     = {24'h014902};	 
assign cfg_regs[84]     = {24'h014A00};	 
assign cfg_regs[85]     = {24'h014B16};	 
assign cfg_regs[86]     = {24'h014C00};	 
assign cfg_regs[87]     = {24'h014D00};	 
assign cfg_regs[88]     = {24'h014EC0};	 
assign cfg_regs[89]     = {24'h014F7F};	 
assign cfg_regs[90]     = {24'h015003};	 
assign cfg_regs[91]     = {24'h015102};	 
assign cfg_regs[92]     = {24'h015200};	 
assign cfg_regs[93]     = {24'h015300};	 
assign cfg_regs[94]     = {24'h015404};	 
assign cfg_regs[95]     = {24'h015500};	 
assign cfg_regs[96]     = {24'h015608};	 
assign cfg_regs[97]     = {24'h015700};	 
assign cfg_regs[98]     = {24'h015896};	 
assign cfg_regs[99]     = {24'h015900};	 
assign cfg_regs[100]    = {24'h015A08};	 
assign cfg_regs[101]    = {24'h015BD4};	 
assign cfg_regs[102]    = {24'h015C20};	 
assign cfg_regs[103]    = {24'h015D00};	 
assign cfg_regs[104]    = {24'h015E00};	 
assign cfg_regs[105]    = {24'h015F0B};	 
assign cfg_regs[106]    = {24'h016000};	 
assign cfg_regs[107]    = {24'h016104};	 
assign cfg_regs[108]    = {24'h016224};	 
assign cfg_regs[109]    = {24'h016300};	 
assign cfg_regs[110]    = {24'h016400};	 
assign cfg_regs[111]    = {24'h01650C};	 
assign cfg_regs[112]    = {24'h0171AA};	 
assign cfg_regs[113]    = {24'h017202};	 
assign cfg_regs[114]    = {24'h017C15};	 
assign cfg_regs[115]    = {24'h017D33};	 
assign cfg_regs[116]    = {24'h016600} ;                                                                                                                                                                   
assign cfg_regs[117]    = {24'h016700} ;                                                                                                                                                                   
assign cfg_regs[118]    = {24'h016832} ;  
assign cfg_regs[119]    = {24'h016959} ; 
assign cfg_regs[120]    = {24'h016A20} ;                                                                                                                                                                   
assign cfg_regs[121]    = {24'h016B00} ;                                                                                                                                                                   
assign cfg_regs[122]    = {24'h016C00} ;                                                                                                                                                                   
assign cfg_regs[123]    = {24'h016D00} ;                                                                                                                                                                   
assign cfg_regs[124]    = {24'h016E1B} ;                                                                                                                                                                   
assign cfg_regs[125]    = {24'h017300} ;	 
assign cfg_regs[126]    = {24'h018200} ;	 
assign cfg_regs[127]    = {24'h018300} ;	 
assign cfg_regs[128]    = {24'h018400} ;     
assign cfg_regs[129]    = {24'h018500} ;   
assign cfg_regs[130]    = {24'h018800} ;   
assign cfg_regs[131]    = {24'h018900} ;   
assign cfg_regs[132]    = {24'h018A00} ;   
assign cfg_regs[133]    = {24'h018B00} ;   


wire [23 : 0] cfg_regs_sysref_on[1 : 0];
assign cfg_regs_sysref_on[0]      = {24'h0144FF};	 
assign cfg_regs_sysref_on[1]      = {24'h013903};  

 
 
localparam REG_NUMA = 134; 
localparam REG_NUMB = 2; 

localparam DELAY_10MS = 10000; 
localparam DELAY_100MS = 100000; 

reg [7:0]  reg_cfg_valueA[REG_NUMA - 1:0];
reg [15:0]   reg_cfg_addrA[REG_NUMA - 1:0];

reg [7:0]   reg_cfg_valueB[REG_NUMB - 1:0];
reg [15:0]    reg_cfg_addrB[REG_NUMB - 1:0];
 
parameter     
   IDLE   = 5'd0,
   power_on     = 5'd1,
   TOGGLE_RESETB        = 5'd2,
   WAIT1                = 5'd3,
   Power_Up_PLL_CFG_S1     = 5'd4,
   Power_Up_PLL_CFG_S2     = 5'd5,
   WAIT2         = 5'd6,
   Power_Up_PLL_CFG_S3     = 5'd7,  
   
   RD_PLL_LOCKED        = 5'd8,
   RD_PLL_LOCKED_data_receive = 5'd9,
   RD_PLL_LOCKED_data_cherk   = 5'd10,
   sysref_on_ctrl= 5'd11,
   sysref_on_cfg= 5'd12,
   WAIT3         = 5'd13,
   cfg_done       = 5'd14;
   
(* fsm_safe_state = "reset_state" *)reg  [4:0]  cfg_state=5'b00000;  
reg   flag_reg_wr;
reg   flag_wr_done;
reg   wr_start;

reg   [15:0]  write_addr;
reg   [7:0]   write_data;
reg   [7:0]   read_data;
reg   [31:0] cnt;
 
reg    idle_flag_r0,idle_flag_r1;
reg    idle_flag_pose;
always@(negedge clk_1M )begin
    idle_flag_r0<=idle_flag;
    idle_flag_r1<=idle_flag_r0; 
    idle_flag_pose<= idle_flag_r0&&(~idle_flag_r1);
end

always@(posedge clk_50m or posedge sys_rst)begin
   if(sys_rst)begin
           write_addr <= {16{1'b0}};
           write_data <= {8{1'b0}};
           wr_start <= 0;
           lmk_cfg_finish <= 0;
           lmk_cfg_LOCKED <= 0;    
           cfg_state <= IDLE;
           lmk04828_rst <= 1;
           cnt  <= 0;
   end else begin
      if(clk_1M_en)begin
           case(cfg_state)
               IDLE:
                   begin
                       if(idle_flag_r1)begin
                           cfg_state <= power_on;
                       end else  begin
                            cfg_state <= IDLE;

                            lmk04828_rst <= 1;
                            lmk_cfg_finish <= 0;
                            lmk_cfg_LOCKED <= 0;                   
                            wr_start <= 0;
                            write_addr <= {16{1'b0}};
                            write_data <= {8{1'b0}};
                            cnt  <= 0;
                        end
                   end
              power_on:
                        begin
                           cfg_state <= WAIT1;
                           lmk04828_rst <= 0;
                        end
               WAIT1:
                        begin
                            if(cnt == 16'd5000)begin
                                    cnt <= 0;
                                    cfg_state <= Power_Up_PLL_CFG_S1;
                            end else begin
                                    cfg_state <= WAIT1;
                                    cnt <= cnt + 1;
                            end
                        end
               Power_Up_PLL_CFG_S1:
                   begin
                       if((idle_flag_r1&&(cnt==0))||idle_flag_pose) begin
                           if(cnt == REG_NUMA)begin 
                                   cfg_state <= WAIT2;
                                   cnt <= 0;
                            end else begin
                                   cfg_state <= Power_Up_PLL_CFG_S1;
                                   wr_start <= 1;
                                   write_addr <= cfg_regs[cnt][23:8];
                                   write_data <= cfg_regs[cnt][7:0];
                                   cnt <= cnt + 1;
                            end                
                       end else begin
                                   wr_start <= 0;
                                   cnt <= cnt;
                       end
                   end   
               WAIT2:
                       begin
                           if(cnt == DELAY_100MS)begin
                                   cfg_state <= RD_PLL_LOCKED;
                                   wr_start <= 0;
                                   write_addr <= {16{1'b0}};
                                   write_data <= {8{1'b0}};
                                   cnt <= 0;
                           end else begin
                                   cfg_state <= WAIT2;
                                   cnt <= cnt + 1;
                           end
                       end
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 RD_PLL_LOCKED:
                   begin
                           lmk_cfg_finish <= 0;
                           wr_start <= 1;
                           write_addr <= 16'h8183;
                           write_data <= 8'h00;
                           cfg_state <= RD_PLL_LOCKED_data_receive;
                   end
               RD_PLL_LOCKED_data_receive:
                       begin
                           wr_start <= 0;
                           write_addr <= 16'h8183;
                           write_data <= 8'h00;
                           if(dac_spi_rdy)begin
                                read_data  <= data_read_out2;
                                cfg_state <= RD_PLL_LOCKED_data_cherk;
                           end else begin
                                read_data  <= read_data;
                                cfg_state <= RD_PLL_LOCKED_data_receive;
                           end                    
                       end  
               RD_PLL_LOCKED_data_cherk:
                               begin
                                   cnt <= 0;
                                   wr_start <= 0;
                                   write_addr <= 16'h8183;
                                   write_data <= 8'h00;
                                   read_data  <= read_data;
                                   if(read_data[1])begin
                                        cfg_state <= sysref_on_ctrl;
                                   end else begin
                                        cfg_state <= RD_PLL_LOCKED;
                                   end                    
                               end   
  
                sysref_on_ctrl:
                               begin
                                   wr_start <= 0;
                                   write_addr <= {16{1'b0}};
                                   write_data <= {8{1'b0}};
                                   cnt  <= 0;
                                   lmk_cfg_LOCKED <= 1;
                                   if(sysref_on)begin
                                        cfg_state <= sysref_on_cfg;
                                   end else begin
                                        cfg_state <= sysref_on_ctrl;
                                   end                    
                               end      
  
                sysref_on_cfg:
                   begin
                       if((idle_flag_r1&&(cnt==0))||idle_flag_pose) begin
                           if(cnt == REG_NUMB)begin 
                                   cfg_state <= WAIT3;
                                   cnt <= 0;
                            end else begin
                                   cfg_state <= sysref_on_cfg;
                                   wr_start <= 1;
                                   write_addr <= cfg_regs_sysref_on[cnt][23:8];
                                   write_data <= cfg_regs_sysref_on[cnt][7:0];
                                   cnt <= cnt + 1;
                            end                
                       end else begin
                                   wr_start <= 0;
                                   cnt <= cnt;
                       end
                   end 
                   
                  WAIT3:
                       begin
                           if(cnt == DELAY_100MS)begin
                                   cfg_state <= cfg_done;
                                   wr_start <= 0;
                                   write_addr <= {16{1'b0}};
                                   write_data <= {8{1'b0}};
                                   cnt <= 0;
                           end else begin
                                   cfg_state <= WAIT3;
                                   cnt <= cnt + 1;
                           end
                       end
  
               cfg_done:
                   begin
                       wr_start <= 0;
                       write_addr <= {16{1'b0}};
                       write_data <= {8{1'b0}};
                       cnt  <= 0;
                       lmk_cfg_LOCKED <= 1;
                       lmk_cfg_finish <= 1;
                       cfg_state <= cfg_done;
                   end
 



 
               default:
                   begin
                       cfg_state <= IDLE;
                   end
           endcase
           end else begin
               write_addr <= write_addr;
               write_data <= write_data;
               wr_start <= wr_start;
               lmk_cfg_finish <= lmk_cfg_finish;
               lmk_cfg_LOCKED <= lmk_cfg_LOCKED;
               cfg_state <= cfg_state;
               lmk04828_rst <= lmk04828_rst;
               cnt  <= cnt;
           end
       end
end
 
 
 
 
 
   
 
 
 
 
 
 
 
 
 

     
 
 
 

assign start_spi      = wr_start;
assign reg_addr       = write_addr;
assign config_value   = write_data;
 
wire direction_ctl;
data_transmit_spi_16a_8d  data_transmit_spi_16a_8d_inst(
                   
                 .idle_flag(idle_flag),
                 .data_read_out1(data_read_out1), 
                 .data_read_out2(data_read_out2), 
                 .data_read_rdy(dac_spi_rdy), 
                 .spi_sclk(LMK_ADC_SCLK), 
                 .spi_sdio(LMK_ADC_SDIO), 
                 .spi_sden(LMK_ADC_CS), 
                 .direction_ctl(direction_ctl), 
                  
                 .clk(clk_1M),
                 .clk_50m(clk_50m),
                 .clk_1M_en(clk_1M_en),
                 .clk_1M_en_nege(clk_1M_en_nege),               
                 .spi_sdo(1'b0),
                 .reset(sys_rst),
                 .reg_addr(reg_addr),
                 .config_value(config_value),
                 .start_spi(start_spi) 
                 );               
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
endmodule