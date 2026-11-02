`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

module rs485_controller (
     
    input   wire                clk,             
    input   wire                rst,             
    
     
    input   wire                tx_enable,       
    input   wire                tx_active,       
    input   wire                rx_active,       
    input   wire    [7:0]       tx_data,         
    input   wire                tx_valid,        
    
     
    input   wire    [15:0]      idle_timeout,    
    input   wire    [15:0]      turn_delay,      
    
     
    output  reg                 dir_out,         
    output  reg     [15:0]      status_reg       
);

 
 
 
localparam          STATE_RX    = 1'b0;          
localparam          STATE_TX    = 1'b1;          

 
 
 
reg         [15:0]              idle_counter;    
reg         [15:0]              turn_counter;    
reg                             last_tx_valid;   

 
 
 
always @(posedge clk)
begin
    if (rst == 1'b1)
    begin
        dir_out        <= STATE_RX;          
        idle_counter   <= 16'd0;             
        turn_counter   <= 16'd0;             
        last_tx_valid  <= 1'b0;              
        status_reg     <= 16'h0000;          
    end
    else
    begin
        last_tx_valid <= tx_valid;     
        
        case (dir_out)
            STATE_RX:
            begin
                 
                if ((tx_enable == 1'b1) && (tx_active == 1'b1))
                begin
                     
                    dir_out      <= STATE_TX;          
                    turn_counter <= turn_delay;        
                    idle_counter <= 16'd0;             
                end
            end
            
            STATE_TX:
            begin
                 
                if (turn_counter > 16'd0)
                begin
                     
                    turn_counter <= turn_counter - 16'd1;     
                end
                else
                begin
                    if (tx_active == 1'b0)
                    begin
                         
                        idle_counter <= idle_counter + 16'd1;     
                        
                        if (idle_counter >= idle_timeout)
                        begin
                            dir_out      <= STATE_RX;     
                            idle_counter <= 16'd0;        
                        end
                    end
                    else
                    begin
                        idle_counter <= 16'd0;     
                    end
                end
            end
            
            default:
            begin
                dir_out <= STATE_RX;     
            end
        endcase
        
         
        status_reg <= {8'h00, 
                      idle_counter[7:0], 
                      dir_out, 
                      1'b0, 
                      6'h00};     
    end
end

endmodule