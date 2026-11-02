`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

(*KEEP_HIERARCHY = "YES"*)module time_module (
     
    input  wire        clk,             
    input  wire        rst,             

     
    input  wire [7:0]  fk_rx_din,       
    input  wire        fk_rx_valid,     

     
    input  wire [7:0]  Status,          

     
(* KEEP = "true" *)    output reg  [7:0]  bram_addr,       
(* KEEP = "true" *)    output reg  [7:0]  bram_data,       
(* KEEP = "true" *)    output reg         bram_wr_en,      

     
    output reg         pulse_100us       
);

 
 
 
localparam  TIME_10MS_CNT    = 1_000_000;    
localparam  TIME_100MS_CNT   = 10_000_000;   
localparam  PULSE_100US_CNT  = 10_000;       

 
 
 
 
reg [19:0]  cnt_10ms;            
wire        tick_10ms;            
reg [23:0]  cnt_100ms;           
wire        tick_100ms;           

 
reg [7:0]   hour;                 
reg [7:0]   min;                  
reg [7:0]   sec;                  
reg [7:0]   ms;                   

 
(* KEEP = "true" *) reg [2:0]   rx_state;             
(* KEEP = "true" *) reg [2:0]   rx_cnt;               
(* KEEP = "true" *) reg [7:0]   rx_hour;              
(* KEEP = "true" *) reg [7:0]   rx_min;               
(* KEEP = "true" *) reg [7:0]   rx_sec;               
(* KEEP = "true" *) reg         rx_frame_done;         

 
(* KEEP = "true" *) reg [1:0]   wr_state;             
(* KEEP = "true" *) reg [2:0]   wr_addr_cnt;          
(* KEEP = "true" *) reg [23:0]  pulse_cnt;            
(* KEEP = "true" *) reg         pulse_active;         

 
(* KEEP = "true" *) reg [7:0]   status_reg;           

 
 
 
 
always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        cnt_10ms <= 20'd0;
    end else begin
        if (cnt_10ms == TIME_10MS_CNT - 1) begin
            cnt_10ms <= 20'd0;
        end else begin
            cnt_10ms <= cnt_10ms + 1'b1;
        end
    end
end

assign tick_10ms = (cnt_10ms == TIME_10MS_CNT - 1) ? 1'b1 : 1'b0;

 
always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        cnt_100ms <= 24'd0;
    end else begin
        if (cnt_100ms == TIME_100MS_CNT - 1) begin
            cnt_100ms <= 24'd0;
        end else begin
            cnt_100ms <= cnt_100ms + 1'b1;
        end
    end
end

assign tick_100ms = (cnt_100ms == TIME_100MS_CNT - 1) ? 1'b1 : 1'b0;

 
 
 
 
 
 
 
 
 
 
localparam RX_IDLE = 3'd0,
           RX_HOUR = 3'd1,
           RX_MIN  = 3'd2,
           RX_SEC  = 3'd3,
           RX_CHK  = 3'd4;

always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        rx_state     <= RX_IDLE;
        rx_cnt       <= 3'd0;
        rx_hour      <= 8'd0;
        rx_min       <= 8'd0;
        rx_sec       <= 8'd0;
        rx_frame_done <= 1'b0;
    end else begin
         
        rx_frame_done <= 1'b0;

        if (fk_rx_valid == 1'b1) begin
            case (rx_state)
                RX_IDLE: begin
                     
                    if (fk_rx_din == 8'hEA) begin
                        rx_state <= RX_HOUR;
                        rx_cnt   <= 3'd1;        
                    end else begin
                         
                        rx_state <= RX_IDLE;
                    end
                end

                RX_HOUR: begin
                    rx_hour <= fk_rx_din;         
                    rx_state <= RX_MIN;
                    rx_cnt   <= 3'd2;
                end

                RX_MIN: begin
                    rx_min <= fk_rx_din;          
                    rx_state <= RX_SEC;
                    rx_cnt   <= 3'd3;
                end

                RX_SEC: begin
                    rx_sec <= fk_rx_din;          
                    rx_state <= RX_CHK;
                    rx_cnt   <= 3'd4;
                end

                RX_CHK: begin
                     
                    rx_state <= RX_IDLE;
                    rx_frame_done <= 1'b1;        
                end

                default: rx_state <= RX_IDLE;
            endcase
        end else begin
             
             
        end
    end
end

 
 
 
 
 
 
 
 
 
always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        hour <= 8'd0;
        min  <= 8'd0;
        sec  <= 8'd0;
        ms   <= 8'd0;
    end else begin
         
        if (rx_frame_done == 1'b1) begin
            hour <= rx_hour;
            min  <= rx_min;
            sec  <= rx_sec;
             
        end else if (tick_10ms == 1'b1) begin
             
            if (ms == 8'd99) begin
                ms <= 8'd0;
                 
                if (sec == 8'd59) begin
                    sec <= 8'd0;
                    if (min == 8'd59) begin
                        min <= 8'd0;
                        if (hour == 8'd23) begin
                            hour <= 8'd0;
                        end else begin
                            hour <= hour + 1'b1;
                        end
                    end else begin
                        min <= min + 1'b1;
                    end
                end else begin
                    sec <= sec + 1'b1;
                end
            end else begin
                ms <= ms + 1'b1;
            end
        end else begin
             
            hour <= hour;
            min  <= min;
            sec  <= sec;
            ms   <= ms;
        end
    end
end

 
 
 
 
 
 
 
localparam WR_IDLE  = 2'd0,
           WR_WRITE = 2'd1,
           WR_PULSE = 2'd2;

always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        wr_state     <= WR_IDLE;
        wr_addr_cnt  <= 3'd0;
        pulse_cnt    <= 24'd0;
        pulse_active <= 1'b0;
        pulse_100us  <= 1'b0;
        bram_addr    <= 8'd0;
        bram_data    <= 8'd0;
        bram_wr_en   <= 1'b0;
        status_reg   <= 8'd0;
    end else begin
         
        status_reg <= Status;

        case (wr_state)
            WR_IDLE: begin
                 
                pulse_100us <= 1'b0;
                bram_wr_en  <= 1'b0;
                 
                if (tick_100ms == 1'b1) begin
                    wr_state    <= WR_WRITE;
                    wr_addr_cnt <= 3'd0;    
                end
            end

            WR_WRITE: begin
                 
                bram_wr_en <= 1'b1;         
                case (wr_addr_cnt)
                    3'd0: begin
                        bram_addr <= 8'd0;
                        bram_data <= 8'hEC;         
                    end
                    3'd1: begin
                        bram_addr <= 8'd1;
                        bram_data <= hour;
                    end
                    3'd2: begin
                        bram_addr <= 8'd2;
                        bram_data <= min;
                    end
                    3'd3: begin
                        bram_addr <= 8'd3;
                        bram_data <= sec;
                    end
                    3'd4: begin
                        bram_addr <= 8'd4;
                        bram_data <= ms;
                    end
                    3'd5: begin
                        bram_addr <= 8'd5;
                        bram_data <= status_reg;
                    end
                    default: begin
                        bram_addr <= 8'd0;
                        bram_data <= 8'd0;
                    end
                endcase

                 
                if (wr_addr_cnt == 3'd6) begin
                     
                    wr_state    <= WR_PULSE;
                    pulse_cnt   <= PULSE_100US_CNT - 1;  
                    pulse_active <= 1'b1;
                    bram_wr_en  <= 1'b0;        
                end else begin
                    wr_addr_cnt <= wr_addr_cnt + 1'b1;
                end
            end

            WR_PULSE: begin
                 
                if (pulse_active == 1'b1) begin
                    pulse_100us <= 1'b1;
                    if (pulse_cnt == 24'd0) begin
                        pulse_active <= 1'b0;
                        pulse_100us  <= 1'b0;
                        wr_state     <= WR_IDLE;    
                    end else begin
                        pulse_cnt <= pulse_cnt - 1'b1;
                    end
                end else begin
                     
                    wr_state <= WR_IDLE;
                end
            end

            default: wr_state <= WR_IDLE;
        endcase
    end
end


endmodule