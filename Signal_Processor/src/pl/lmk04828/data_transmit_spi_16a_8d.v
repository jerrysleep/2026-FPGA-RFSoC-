`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


module data_transmit_spi_16a_8d(
     
    idle_flag,
    data_read_out1, 
    data_read_out2, 
    data_read_rdy, 
    spi_sclk,
    spi_sdio,
    spi_sden,
    direction_ctl,
     
    spi_sdo,
    clk,
    clk_50m,
    clk_1M_en,
    clk_1M_en_nege,

    reset,
    reg_addr,
    config_value,
    start_spi 
    );
	
	input              clk;
    input 	           clk_50m;		 
    input 	           clk_1M_en;	
    input 	           clk_1M_en_nege;

	input              reset;   
	input  [15:0]      reg_addr;
	input  [7:0]       config_value; 
	input              start_spi;
	
    input              spi_sdo;   
	inout              spi_sdio;  
    output             spi_sclk;  
    output             spi_sden;  
	
output  reg        idle_flag;  
output  reg [7:0] data_read_out1;
output  reg [7:0] data_read_out2;
output  reg        data_read_rdy;
    
	parameter      VCC = 1'b1;
	parameter      GND = 1'b0;
	parameter      IDLE = 2'b00,
				   WRITE = 2'b01,
				   READ  = 2'b10,
				   CLEAR = 2'b11;
	
reg             spi_mosi;   
wire            spi_miso1;
wire            spi_miso2;
reg             spi_csb;
reg             data_out_rdy;
reg             data_read_over;
reg [23:0]      data_to_send;
reg [7:0]      data_to_receive1;
reg [7:0]      data_to_receive2;
reg [1:0]       state;
reg [4:0]       cnt_index;
reg [4:0]       cnt_index_1;
	
output    reg             direction_ctl;  
reg             read_enable; 
	
	assign spi_sclk = spi_csb?1'b0:~clk;
 
	assign spi_sden = spi_csb;
	assign spi_sdio = direction_ctl ? spi_mosi : 1'bZ;
 
	assign spi_miso1 = spi_sdo;
	assign spi_miso2 = spi_sdio;
	always@(posedge clk_50m)
        begin
            if(reset)
                begin
                    data_to_receive1 <= {8{1'b0}};
                    data_to_receive2 <= {8{1'b0}};
                    data_out_rdy <= 0;
                end
            else begin
            if(clk_1M_en_nege)begin
                if(read_enable)
                    begin
                        data_to_receive1 <= {{data_to_receive1[6:0],spi_miso1}};
                        data_to_receive2 <= {{data_to_receive2[6:0],spi_miso2}};
                        data_out_rdy <= data_read_over;
                    end
                else 
				    begin
						data_to_receive1 <= data_to_receive1;
						data_to_receive2 <= data_to_receive2;
						data_out_rdy <= data_read_over;
					end
		  end else begin
				  data_to_receive1 <= data_to_receive1;
                  data_to_receive2 <= data_to_receive2;
                  data_out_rdy <= data_out_rdy;
		  end
        end
      end
	
	
	always@(posedge clk_50m)
	begin
	    if(reset)
		    begin
		        spi_csb  <= VCC;
				spi_mosi <= GND;
				data_read_over <= 0;
				data_to_send <= {24{1'b0}};
				idle_flag <= 0;
				cnt_index <= 0;
				cnt_index_1 <= 0;
				direction_ctl <= 1'b0;
				read_enable <= 1'b0;
				state <= IDLE;
		  end else begin
		  if(clk_1M_en)begin
			    case(state)
				IDLE:
				    begin
					    if(start_spi)
						    begin
							    idle_flag <= 0;
								data_to_send <= {reg_addr,config_value};
								if(reg_addr[15])          
								    state <= READ;
								else  
								    state <= WRITE;
							end
						else 
						    begin 
							    state <= IDLE;
							    idle_flag <= 1;
							    data_to_send <= data_to_send;
							end
					end
				WRITE:
				    begin
					    spi_csb <= GND;
					    direction_ctl <= 1'b1;
						spi_mosi <= data_to_send[23];
						data_to_send <= data_to_send << 1;
						cnt_index <= cnt_index + 1;
						if(cnt_index >= 5'd23)
						    state <= CLEAR;
						else
						    state <= WRITE;
					end
				READ:
				    begin
					    if(cnt_index >= 5'd16) 
						    begin
						        direction_ctl <= 1'b0;
						        read_enable <= 1'b1; 
								cnt_index_1 <= cnt_index_1 + 1;								
								if(cnt_index_1 >= 5'd7)
									begin
										state <= CLEAR;
										data_read_over <= 1; 
								    end
                                else
									state <= READ;
							end
					    else
						    begin    
							    spi_csb <= GND;
							    direction_ctl <= 1'b1;
								spi_mosi <= data_to_send[23];
								data_to_send <= data_to_send << 1;
								cnt_index <= cnt_index + 1;
								state <= READ;
							end
					end
				CLEAR:
				    begin
					    spi_csb <= VCC;
						spi_mosi <= GND;
						cnt_index <= 5'd0;
						cnt_index_1 <= 5'd0;
						data_read_over <= 0;
						data_to_send <= {24{1'b0}};	
						direction_ctl <= 1'b0;
						read_enable <= 1'b0;
						state <= IDLE;
					end
				endcase
				
			end else begin
		        spi_csb  <= spi_csb;
                spi_mosi <= spi_mosi;
                data_read_over <= data_read_over;
                data_to_send <= data_to_send;
                idle_flag <= idle_flag;
                cnt_index <= cnt_index;
                cnt_index_1 <= cnt_index_1;
                direction_ctl <= direction_ctl;
                read_enable <= read_enable;
                state <= state;
			end
			end
	end
	
	always@(posedge clk_50m)begin
		    if(reset)
                begin
                    data_read_out1 <= {8{1'b0}};
                    data_read_out2 <= {8{1'b0}};
					data_read_rdy <= 0;
                end
            else   begin
            if(clk_1M_en)begin
                    data_read_rdy <= data_out_rdy;
                    if(data_out_rdy)
                        begin
                            data_read_out1 <= data_to_receive1;
                            data_read_out2 <= data_to_receive2;
                        end
                    else 
                        begin
                            data_read_out1 <= data_read_out1;
                            data_read_out2 <= data_read_out2;
                        end
            end else begin
                data_read_out1 <=data_read_out1;
                data_read_out2 <= data_read_out2;
                data_read_rdy <= data_read_rdy;
            
            end
		end
	end
 
endmodule
