`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

module protocol_485 #(
    parameter CLK_FREQ = 100_000_000     
)(
     
    input   wire                clk,             
    input   wire                rst,             
    
     
    output  reg     [7:0]       uart_tx_data,    
    output  reg                 uart_tx_valid,   
    input   wire                uart_tx_ready,   
    input   wire    [7:0]       uart_rx_data,    
    input   wire                uart_rx_valid,   
    input   wire                uart_rx_error,   
    
     
    input   wire    [7:0]       freq_setting,    
    input   wire                freq_valid,      
    output  wire                freq_busy,       
    
     
    output  reg     [7:0]       recv_freq,       
    output  reg                 recv_valid,      
    output  reg                 recv_error,      
    
     
    input   wire    [15:0]      config_reg,      
    output  reg     [15:0]      status_reg       
);

 
 
 
localparam          FRAME_HEADER_H = 8'hEB;      
localparam          FRAME_HEADER_L = 8'h90;      

 
 
 
localparam          STATE_IDLE       = 3'd0;     
localparam          STATE_RX_HEADER1 = 3'd1;     
localparam          STATE_RX_HEADER2 = 3'd2;     
localparam          STATE_RX_DATA    = 3'd3;     
localparam          STATE_TX_FRAME   = 3'd4;     

 
 
 
reg         [2:0]               rx_state;        
reg         [2:0]               rx_counter;      
reg         [7:0]               rx_buffer_0;     
reg         [7:0]               rx_buffer_1;     
reg         [7:0]               rx_buffer_2;     
reg         [7:0]               rx_buffer_3;     
reg         [7:0]               rx_buffer_4;     
reg         [7:0]               calc_chk;        

 
 
 
reg         [2:0]               tx_state;        
reg         [2:0]               tx_counter;      
reg         [7:0]               tx_buffer_0;     
reg         [7:0]               tx_buffer_1;     
reg         [7:0]               tx_buffer_2;     
reg         [7:0]               tx_buffer_3;     
reg         [7:0]               tx_buffer_4;     
reg                             tx_busy_reg;     

 
 
 
always @(posedge clk)
begin
    if (rst == 1'b1)
    begin
        rx_state     <= STATE_IDLE;      
        rx_counter   <= 3'd0;            
        recv_valid   <= 1'b0;            
        recv_error   <= 1'b0;            
        recv_freq    <= 8'd0;            
        rx_buffer_0  <= 8'd0;            
        rx_buffer_1  <= 8'd0;            
        rx_buffer_2  <= 8'd0;            
        rx_buffer_3  <= 8'd0;            
        rx_buffer_4  <= 8'd0;            
        calc_chk     <= 8'd0;            
    end
    else
    begin
        recv_valid <= 1'b0;     
        recv_error <= 1'b0;     
        
        if (uart_rx_error == 1'b1)
        begin
            rx_state <= STATE_IDLE;     
        end
        else
        begin
            case (rx_state)
                STATE_IDLE:
                begin
                    if ((uart_rx_valid == 1'b1) && (uart_rx_data == FRAME_HEADER_H))
                    begin
                        rx_state <= STATE_RX_HEADER1;     
                    end
                end
                
                STATE_RX_HEADER1:
                begin
                    if (uart_rx_valid == 1'b1)
                    begin
                        if (uart_rx_data == FRAME_HEADER_L)
                        begin
                            rx_state   <= STATE_RX_HEADER2;     
                            rx_counter <= 3'd0;                 
                        end
                        else
                        begin
                            rx_state <= STATE_IDLE;     
                        end
                    end
                end
                
                STATE_RX_HEADER2:
                begin
                    if (uart_rx_valid == 1'b1)
                    begin
                         
                        if (rx_counter == 3'd0)
                        begin
                            rx_buffer_0 <= uart_rx_data;     
                        end
                        else
                        begin
                            if (rx_counter == 3'd1)
                            begin
                                rx_buffer_1 <= uart_rx_data;     
                            end
                            else
                            begin
                                if (rx_counter == 3'd2)
                                begin
                                    rx_buffer_2 <= uart_rx_data;     
                                end
                                else
                                begin
                                    if (rx_counter == 3'd3)
                                    begin
                                        rx_buffer_3 <= uart_rx_data;     
                                    end
                                end
                            end
                        end
                        
                        rx_counter <= rx_counter + 3'd1;     
                        
                        if (rx_counter == 3'd3)
                        begin
                             
                             
                            calc_chk <= rx_buffer_0 ^ rx_buffer_1 ^ rx_buffer_2 ^ rx_buffer_3;
                            
                            if (calc_chk == rx_buffer_3)
                            begin
                                recv_freq  <= rx_buffer_2;     
                                recv_valid <= 1'b1;            
                            end
                            else
                            begin
                                recv_error <= 1'b1;     
                            end
                            
                            rx_state <= STATE_IDLE;     
                        end
                    end
                end
                
                default:
                begin
                    rx_state <= STATE_IDLE;     
                end
            endcase
        end
    end
end

 
 
 
always @(posedge clk)
begin
    if (rst == 1'b1)
    begin
        tx_state     <= STATE_IDLE;     
        tx_counter   <= 3'd0;           
        tx_busy_reg  <= 1'b0;           
        tx_buffer_0  <= 8'd0;           
        tx_buffer_1  <= 8'd0;           
        tx_buffer_2  <= 8'd0;           
        tx_buffer_3  <= 8'd0;           
        tx_buffer_4  <= 8'd0;           
    end
    else
    begin
         
        if (tx_state == STATE_IDLE)
        begin
            tx_busy_reg <= 1'b0;     
        end
        else
        begin
            tx_busy_reg <= 1'b1;     
        end
        
        case (tx_state)
            STATE_IDLE:
            begin
                if (freq_valid == 1'b1)
                begin
                     
                    tx_buffer_0 <= FRAME_HEADER_H;                              
                    tx_buffer_1 <= FRAME_HEADER_L;                              
                    tx_buffer_2 <= freq_setting;                                
                    tx_buffer_3 <= freq_setting;                                
                    tx_buffer_4 <= FRAME_HEADER_H ^ FRAME_HEADER_L ^ 
                                   freq_setting ^ freq_setting;                  
                    
                    tx_state   <= STATE_TX_FRAME;     
                    tx_counter <= 3'd0;               
                end
            end
            
            STATE_TX_FRAME:
            begin
                if ((uart_tx_ready == 1'b1) && (tx_counter < 3'd5))
                begin
                     
                    if (tx_counter == 3'd0)
                    begin
                        uart_tx_data <= tx_buffer_0;     
                    end
                    else
                    begin
                        if (tx_counter == 3'd1)
                        begin
                            uart_tx_data <= tx_buffer_1;     
                        end
                        else
                        begin
                            if (tx_counter == 3'd2)
                            begin
                                uart_tx_data <= tx_buffer_2;     
                            end
                            else
                            begin
                                if (tx_counter == 3'd3)
                                begin
                                    uart_tx_data <= tx_buffer_3;     
                                end
                                else
                                begin
                                    if (tx_counter == 3'd4)
                                    begin
                                        uart_tx_data <= tx_buffer_4;     
                                    end
                                end
                            end
                        end
                    end
                    
                    uart_tx_valid <= 1'b1;               
                    tx_counter    <= tx_counter + 3'd1;  
                end
                else
                begin
                    uart_tx_valid <= 1'b0;     
                end
                
                if (tx_counter == 3'd5)
                begin
                    tx_state   <= STATE_IDLE;     
                    tx_counter <= 3'd0;           
                end
            end
            
            default:
            begin
                tx_state <= STATE_IDLE;     
            end
        endcase
    end
end

 
 
 
assign freq_busy = tx_busy_reg;     

 
 
 
always @(posedge clk)
begin
    if (rst == 1'b1)
    begin
        status_reg <= 16'h0000;     
    end
    else
    begin
        status_reg <= {8'h00, 
                      tx_busy_reg, 
                      1'b0, 
                      rx_state[2:0], 
                      recv_valid, 
                      recv_error};     
    end
end

endmodule