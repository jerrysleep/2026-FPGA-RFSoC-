`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


(*KEEP_HIERARCHY = "YES"*)module Serial_Comm#(
parameter BAUD_RATE  = 1_000_000    

)(
     
    input   wire                clk_100m,            
    input   wire                rst,                 
    
     
    (* KEEP = "true" *) input   wire                rs422_rxd_fc,        
    (* KEEP = "true" *) output  wire                rs422_txd_fc,        
    (* KEEP = "true" *) output  wire                rs422_txd_radio,     
	 
    output  wire    [15:0]      status_422,           
	(* KEEP = "true" *) input  wire [7:0]  Status,          
	input					tx_clk_fc		,
	input					tx_clk_radio	,
	(* KEEP = "true" *) input        [7:0]              tx_data_fc		,     
	(* KEEP = "true" *) input        [7:0]              tx_data_radio	,  
	(* KEEP = "true" *) input                           tx_valid_fc		,    
	(* KEEP = "true" *) input                           tx_valid_radio	, 
	(* KEEP = "true" *) input			[8:0]			tx_addr_fc		,
	(* KEEP = "true" *) input			[8:0]			tx_addr_radio	,
	

	(* KEEP = "true" *)	input			[7:0] 			FromFK_bram_addr	,
	(* KEEP = "true" *)	input							FromFK_bram_clk		,
	(* KEEP = "true" *)	input							FromFK_bram_en		,
	(* KEEP = "true" *)	output	wire	[31:0]			FromFK_bram_rddata	,
     
    (* KEEP = "true" *) output          pulse_100us       

    );

    (* KEEP = "true" *) wire   [7:0]  bram_addr	;       
    (* KEEP = "true" *) wire   [7:0]  bram_data	;       
    (* KEEP = "true" *) wire          bram_wr_en;      
	


	(* KEEP = "true" *) wire                            uart_422_tx_ready_fc;    
	(* KEEP = "true" *) wire                            uart_422_tx_ready_radio; 
	(* KEEP = "true" *) wire                            uart_422_tx_busy_fc;     
	(* KEEP = "true" *) wire                            uart_422_tx_busy_radio;  
		
	(* KEEP = "true" *) wire        [7:0]               uart_422_rx_data;        
	(* KEEP = "true" *) wire                            uart_422_rx_valid;       
	(* KEEP = "true" *) wire                            uart_422_rx_error;       
	

	
 
uart_core_ram #(
    .CLK_FREQ   		(	100_000_000		),   
    .BAUD_RATE  		(	BAUD_RATE		),    
    .DATA_BITS  		(8),           	 
    .PARITY     		("NONE"),      	 
    .STOP_BITS  		(1),           	 
    .ADDR_THRESHOLD 	(3)            	 
) u_uart_422_tx_fc (	
    .clk         		(	clk_100m		),             
    .rst         		(	rst				),                  
    .baud_div    		(	100				),                   
    .config_reg 		(	4'd0			),	
    .wrfifo_clk			(	tx_clk_fc		),
	
    .tx_data     		(	tx_data_fc		),  
    .tx_valid    		(	tx_valid_fc		), 
	.tx_data_addr		(	tx_addr_fc	),
    .tx_ready    		(uart_422_tx_ready_fc), 
    .tx_busy     		(uart_422_tx_busy_fc),  
    
    .rx_data     (),                     
    .rx_valid    (),                     
    .rx_error    (),                     
    .rx_break    (),                     
    
    .status_reg  (),                     
    .error_count (error_count_422),      
    
    .rxd         		(	1'b1			),                 
    .txd         		(	rs422_txd_fc	)          
);

 
     
     
     
     
     
     
 
     
     
     

     
     

     
     
     
     
     

     
     
     
     

     
     

     
     
 


 
uart_core_ram #(
    .CLK_FREQ   		(100_000_000),   
    .BAUD_RATE  		(BAUD_RATE),    
    .DATA_BITS  		(8),             
    .PARITY     		("NONE"),        
    .STOP_BITS  		(1),             
    .ADDR_THRESHOLD 	(4)             
) u_uart_422_tx_radio (
    .clk         		(clk_100m),                 
    .rst         		(rst),                      
    .baud_div    		(100),                       
	.config_reg 		(4'd0),
    .wrfifo_clk			(	tx_clk_radio		),    
    .tx_data     		(	tx_data_radio	),   
    .tx_valid    		(	tx_valid_radio	),  
	.tx_data_addr		(	tx_addr_radio		),
    .tx_ready    		(uart_422_tx_ready_radio),  
    .tx_busy     		(uart_422_tx_busy_radio),   
    
    .rx_data     		(),                         
    .rx_valid    		(),                         
    .rx_error    		(),                         
    .rx_break    		(),                         
			
    .status_reg  		(),                         
    .error_count 		(),                         
			
    .rxd         		(1'b1),                     
    .txd         		(rs422_txd_radio)           
);

 
uart_core_fifo #(
    .CLK_FREQ   		(	100_000_000		),   
    .BAUD_RATE  		(	BAUD_RATE		),    
    .DATA_BITS  		(8),             
    .PARITY     		("NONE"),        
    .STOP_BITS  		(1),             
    .FIFO_DEPTH 		(8)              
) u_uart_422_rx (
    .clk         		(clk_100m),         
    .rst         		(	rst),              
    .baud_div    		(	100),               
    .wrfifo_clk			(	clk_100m		),			
    .tx_data     		(8'h00),            
    .tx_valid    		(1'b0),             
    .tx_ready    		(),                 
    .tx_busy     		(),                 
    
    .rx_data     		(uart_422_rx_data), 
    .rx_valid    		(uart_422_rx_valid), 
    .rx_error    		(uart_422_rx_error), 
    .rx_break    		(),                 
    
    .status_reg  		(status_422),       
    .error_count 		(),                 
			
    .rxd         		(	rs422_rxd_fc	),     
    .txd         		()                  
);

	
	time_module u_timer (
    .clk				(	clk_100m			),  
    .rst				(	rst					),  
    .fk_rx_din			(	uart_422_rx_data	),  
    .fk_rx_valid		(	uart_422_rx_valid	),  
    .Status				(	Status				),  
    .bram_addr			(	bram_addr			),  
    .bram_data			(	bram_data			),  
    .bram_wr_en			(	bram_wr_en			),  
    .pulse_100us  		(	pulse_100us  		)	 
); 
     

	
bram_422_32x256 Time_bram (
  .clka					(	clk_100m			),     
  .ena					(	1'b1				),       
  .wea					(	bram_wr_en			),       
  .addra				(	bram_addr			),   
  .dina					(	{24'd0,bram_data}	),     
  .clkb					(	FromFK_bram_clk		),     
  .enb					(	FromFK_bram_en		),       
  .addrb				(	FromFK_bram_addr	),   
  .doutb				(	FromFK_bram_rddata	)   
);                                             
	
endmodule
