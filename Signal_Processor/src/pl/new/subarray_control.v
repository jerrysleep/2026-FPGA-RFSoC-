`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
module subarray_control (
     
    input  wire        clk,                     
    input  wire        rst,                     

     
    input  wire [7:0]  subarray_select_mode,    
    input  wire        frame_start_ref,         
    input  wire        detect_refresh,          
    input  wire [15:0] detect_snr_in,           
    input  wire        detect_on_TH,            

     
    output reg         serch_or_track,          
    output reg         subarray_select          
);

     
    parameter TRACK_LOST_CNT = 10;               
    parameter TRACK_LOST_CNT_MINUS_1 = TRACK_LOST_CNT - 1;   

     
    localparam [1:0] SEARCH       = 2'b00;      
    localparam [1:0] TRACK_SUB1   = 2'b01;      
    localparam [1:0] TRACK_SUB2   = 2'b10;      

     
    reg [1:0]          state;                    
    reg                current_sub;              
    reg [2:0]          sub1_history;             
    reg [2:0]          sub2_history;             
    reg [15:0]         sub1_snr_last;            
    reg [15:0]         sub2_snr_last;            
    reg [3:0]          track_lost_cnt;           
    reg [1:0]          sub1_cnt;                 
    reg [1:0]          sub2_cnt;                 

     
    reg [7:0]          mode_reg_prev;            
    reg                mode_changed;             

     
    reg                detect_refresh_reg;       
    wire               detect_refresh_edge;      

     
    reg                frame_start_ref_reg;      
    wire               frame_start_edge;         

     
     
     
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            detect_refresh_reg <= 1'b0;
        end
        else begin
            detect_refresh_reg <= detect_refresh;
        end
    end
    assign detect_refresh_edge = (detect_refresh == 1'b1) && (detect_refresh_reg == 1'b0);

     
     
     
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            frame_start_ref_reg <= 1'b0;
        end
        else begin
            frame_start_ref_reg <= frame_start_ref;
        end
    end
    assign frame_start_edge = (frame_start_ref == 1'b1) && (frame_start_ref_reg == 1'b0);

     
     
     
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            mode_reg_prev <= 8'd0;
            mode_changed  <= 1'b0;
        end
        else begin
            mode_reg_prev <= subarray_select_mode;
            if (mode_reg_prev != subarray_select_mode) begin
                mode_changed <= 1'b1;
            end
            else begin
                mode_changed <= 1'b0;
            end
        end
    end

     
     
     
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
             
            state           <= SEARCH;
            current_sub     <= 1'b0;
            sub1_history    <= 3'd0;
            sub2_history    <= 3'd0;
            sub1_snr_last   <= 16'd0;
            sub2_snr_last   <= 16'd0;
            track_lost_cnt  <= 4'd0;
            sub1_cnt        <= 2'd0;
            sub2_cnt        <= 2'd0;
        end
        else begin
             
            if (mode_changed == 1'b1) begin
                state           <= SEARCH;
                current_sub     <= 1'b0;
                sub1_history    <= 3'd0;
                sub2_history    <= 3'd0;
                sub1_snr_last   <= 16'd0;
                sub2_snr_last   <= 16'd0;
                track_lost_cnt  <= 4'd0;
                sub1_cnt        <= 2'd0;
                sub2_cnt        <= 2'd0;
            end
            else begin
                 
                if (subarray_select_mode == 8'h00) begin
                     
                    current_sub <= 1'b0;
                    case (state)
                        SEARCH: begin
                            if (detect_refresh_edge == 1'b1) begin
                                 
                                sub1_history <= {sub1_history[1:0], detect_on_TH};
                                if (detect_on_TH == 1'b1) begin
                                    sub1_snr_last <= detect_snr_in;
                                end
                                else begin
                                     
                                end
                                sub1_cnt <= sub1_history[0] + sub1_history[1] + sub1_history[2];

                                if (sub1_cnt >= 2) begin
                                    state          <= TRACK_SUB1;
                                    track_lost_cnt <= 4'd0;
                                end
                                else begin
                                     
                                end
                            end
                            else begin
                                 
                            end
                        end

                        TRACK_SUB1: begin
                            if (detect_refresh_edge == 1'b1) begin
                                sub1_history <= {sub1_history[1:0], detect_on_TH};
                                if (detect_on_TH == 1'b1) begin
                                    sub1_snr_last <= detect_snr_in;
                                end
                                else begin
                                     
                                end
                                sub1_cnt <= sub1_history[0] + sub1_history[1] + sub1_history[2];

                                if (detect_on_TH == 1'b1) begin
                                    track_lost_cnt <= 4'd0;
                                end
                                else begin
                                    if (track_lost_cnt == TRACK_LOST_CNT_MINUS_1) begin
                                        state          <= SEARCH;
                                        track_lost_cnt <= 4'd0;
                                    end
                                    else begin
                                        track_lost_cnt <= track_lost_cnt + 1'b1;
                                    end
                                end
                            end
                            else begin
                                 
                            end
                        end

                        default: begin
                            state <= SEARCH;
                        end
                    endcase
                end
                 
                else if (subarray_select_mode == 8'h11) begin
                     
                    current_sub <= 1'b1;
                    case (state)
                        SEARCH: begin
                            if (detect_refresh_edge == 1'b1) begin
                                sub2_history <= {sub2_history[1:0], detect_on_TH};
                                if (detect_on_TH == 1'b1) begin
                                    sub2_snr_last <= detect_snr_in;
                                end
                                else begin
                                     
                                end
                                sub2_cnt <= sub2_history[0] + sub2_history[1] + sub2_history[2];

                                if (sub2_cnt >= 2) begin
                                    state          <= TRACK_SUB2;
                                    track_lost_cnt <= 4'd0;
                                end
                                else begin
                                     
                                end
                            end
                            else begin
                                 
                            end
                        end

                        TRACK_SUB2: begin
                            if (detect_refresh_edge == 1'b1) begin
                                sub2_history <= {sub2_history[1:0], detect_on_TH};
                                if (detect_on_TH == 1'b1) begin
                                    sub2_snr_last <= detect_snr_in;
                                end
                                else begin
                                     
                                end
                                sub2_cnt <= sub2_history[0] + sub2_history[1] + sub2_history[2];

                                if (detect_on_TH == 1'b1) begin
                                    track_lost_cnt <= 4'd0;
                                end
                                else begin
                                    if (track_lost_cnt == TRACK_LOST_CNT_MINUS_1) begin
                                        state          <= SEARCH;
                                        track_lost_cnt <= 4'd0;
                                    end
                                    else begin
                                        track_lost_cnt <= track_lost_cnt + 1'b1;
                                    end
                                end
                            end
                            else begin
                                 
                            end
                        end

                        default: begin
                            state <= SEARCH;
                        end
                    endcase
                end
                 
                else begin
                    case (state)
                        SEARCH: begin
                             
                            if (detect_refresh_edge == 1'b1) begin
                                 
                                if (current_sub == 1'b0) begin
                                     
                                    sub2_history <= {sub2_history[1:0], detect_on_TH};
                                    if (detect_on_TH == 1'b1) begin
                                        sub2_snr_last <= detect_snr_in;
                                    end
                                    else begin
                                         
                                    end
                                    sub2_cnt <= sub2_history[0] + sub2_history[1] + sub2_history[2];
                                end
                                else begin
                                     
                                    sub1_history <= {sub1_history[1:0], detect_on_TH};
                                    if (detect_on_TH == 1'b1) begin
                                        sub1_snr_last <= detect_snr_in;
                                    end
                                    else begin
                                         
                                    end
                                    sub1_cnt <= sub1_history[0] + sub1_history[1] + sub1_history[2];
                                end

                                 
                                if ((sub1_cnt >= 2) && (sub2_cnt < 2)) begin
                                    state          <= TRACK_SUB1;
                                    current_sub    <= 1'b0;
                                    track_lost_cnt <= 4'd0;
                                end
                                else if ((sub2_cnt >= 2) && (sub1_cnt < 2)) begin
                                    state          <= TRACK_SUB2;
                                    current_sub    <= 1'b1;
                                    track_lost_cnt <= 4'd0;
                                end
                                else if ((sub1_cnt >= 2) && (sub2_cnt >= 2)) begin
                                    if (sub1_snr_last >= sub2_snr_last) begin
                                        state          <= TRACK_SUB1;
                                        current_sub    <= 1'b0;
                                    end
                                    else begin
                                        state          <= TRACK_SUB2;
                                        current_sub    <= 1'b1;
                                    end
                                    track_lost_cnt <= 4'd0;
                                end
                                else begin
                                     
                                end
                            end
                            else begin
                                 
                            end

                             
                            if (frame_start_edge == 1'b1) begin
                                current_sub <= ~current_sub;
                            end
                            else begin
                                 
                            end
                        end

                        TRACK_SUB1: begin
                             
                            if (detect_refresh_edge == 1'b1) begin
                                 
                                sub1_history <= {sub1_history[1:0], detect_on_TH};
                                if (detect_on_TH == 1'b1) begin
                                    sub1_snr_last <= detect_snr_in;
                                end
                                else begin
                                     
                                end
                                sub1_cnt <= sub1_history[0] + sub1_history[1] + sub1_history[2];

                                if (detect_on_TH == 1'b1) begin
                                    track_lost_cnt <= 4'd0;
                                end
                                else begin
                                    if (track_lost_cnt == TRACK_LOST_CNT_MINUS_1) begin
                                        state          <= SEARCH;
                                        track_lost_cnt <= 4'd0;
                                    end
                                    else begin
                                        track_lost_cnt <= track_lost_cnt + 1'b1;
                                    end
                                end
                            end
                            else begin
                                 
                            end
                        end

                        TRACK_SUB2: begin
                            if (detect_refresh_edge == 1'b1) begin
                                sub2_history <= {sub2_history[1:0], detect_on_TH};
                                if (detect_on_TH == 1'b1) begin
                                    sub2_snr_last <= detect_snr_in;
                                end
                                else begin
                                     
                                end
                                sub2_cnt <= sub2_history[0] + sub2_history[1] + sub2_history[2];

                                if (detect_on_TH == 1'b1) begin
                                    track_lost_cnt <= 4'd0;
                                end
                                else begin
                                    if (track_lost_cnt == TRACK_LOST_CNT_MINUS_1) begin
                                        state          <= SEARCH;
                                        track_lost_cnt <= 4'd0;
                                    end
                                    else begin
                                        track_lost_cnt <= track_lost_cnt + 1'b1;
                                    end
                                end
                            end
                            else begin
                                 
                            end
                        end

                        default: begin
                            state <= SEARCH;
                        end
                    endcase
                end
            end
        end
    end

     
     
     
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            serch_or_track <= 1'b0;
        end
        else begin
             
            if (mode_changed == 1'b1) begin
                serch_or_track <= 1'b0;
            end
            else begin
                 
                if (subarray_select_mode == 8'h00) begin
                    if (state == TRACK_SUB1) begin
                        serch_or_track <= 1'b1;
                    end
                    else begin
                        serch_or_track <= 1'b0;
                    end
                end
                else if (subarray_select_mode == 8'h11) begin
                    if (state == TRACK_SUB2) begin
                        serch_or_track <= 1'b1;
                    end
                    else begin
                        serch_or_track <= 1'b0;
                    end
                end
                else begin
                    if (state == SEARCH) begin
                        serch_or_track <= 1'b0;
                    end
                    else begin
                        serch_or_track <= 1'b1;
                    end
                end
            end
        end
    end

     
     
     
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            subarray_select <= 1'b0;
        end
        else begin
             
            if (mode_changed == 1'b1) begin
                subarray_select <= 1'b0;
            end
            else begin
                if (subarray_select_mode == 8'h00) begin
                    subarray_select <= 1'b0;           
                end
                else if (subarray_select_mode == 8'h11) begin
                    subarray_select <= 1'b1;           
                end
                else begin
                     
                    subarray_select <= current_sub;
                end
            end
        end
    end

endmodule