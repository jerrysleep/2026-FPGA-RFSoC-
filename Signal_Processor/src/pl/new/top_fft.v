`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


module top_fft
    (
        input                   clk,
        input                   rst,
         input                   p_b_in,
         input [7:0]             fft_mode_in,
         input [7:0]             use_PulseCompress,
         input [15:0]            snr_door_in,
         input [15:0]            protect_freq_in,
         input [15:0]            detect_freq_low_near,
         input [15:0]            detect_freq_high_near,
         input [15:0]            detect_freq_low_far,
         input [15:0]            detect_freq_high_far,
        input [9:0]             ref_freq_in,
        input [5:0]             ref_bomen_in,
        input [3:0]             judge_num,
        input [3:0]             judge_num_detect,
         input [5:0]             All_WaveNum,
        input [31:0]            buf_data_in_1,
        input [31:0]            buf_data_in_2,
        input [31:0]            buf_data_in_3,
        input [31:0]            buf_data_in_4,
        input [31:0]            buf_data_in_5,
        output reg              ps_int,
        output reg              target_state,
        output reg              buf_data_rd_en,
        output reg [15:0]       buf_data_rd_addr,
        output reg [15:0]       max_bomen_dout_before,
        output reg [15:0]       max_bomen_dout_middle,
        output reg [15:0]       max_bomen_dout_after,
        output reg [15:0]       max_freq_dout_before,
        output reg [15:0]       max_freq_dout_middle,
        output reg [15:0]       max_freq_dout_after,
        output reg [15:0]       max_snr_dout_before,
        output reg [15:0]       max_snr_dout_middle,
        output reg [15:0]       max_snr_dout_after,
        output reg [15:0]       max_IQ_ch1_dout,
        output reg [15:0]       max_IQ_ch2_dout,
        output reg [15:0]       max_IQ_ch3_dout,
        output reg [15:0]       max_IQ_ch4_dout,
        output reg [15:0]       max_IQ_ch5_dout,
        output reg [15:0]       ref_phase_ch1_dout,
        output reg [15:0]       ref_phase_ch2_dout,
        output reg [15:0]       ref_phase_ch3_dout,
        output reg [15:0]       ref_phase_ch4_dout,
        output reg [15:0]       ref_phase_ch5_dout,
        output reg              max_dout_en,
        output reg [5:0]        max_bomen_dout,
        output reg [9:0]        max_freq_dout,
        output reg [15:0]       max_snr_dout,
        output reg [31:0]       fft_result_bomen_before,
        output reg [31:0]       fft_result_bomen_middle,
        output reg [31:0]       fft_result_bomen_after,
        output reg [31:0]       fft_result_freq_before,
        output reg [31:0]       fft_result_freq_after,
        output reg [15:0]       zhen_cnt
    );
    
    reg p_b_d,p_b_d2,p_b_d3;
    reg fft_mode;
    reg [5:0] All_WaveNum_d;
    reg [15:0] snr_door,snr_door_d;
    reg config_cnt_en;
    reg config_tvalid;
    reg [2:0] config_cnt;
    reg [15:0] config_tdata;
    reg [15:0] fft_deepth;
    reg [5:0] fft_max_bomen;
    reg [15:0] detect_freq_low_near_d,detect_freq_high_near_d,detect_freq_low_far_d,detect_freq_high_far_d;
    reg [9:0] detect_freq_low,detect_freq_high;
    reg [15:0] protect_freq;
    reg [9:0] ref_freq;
    reg [5:0] ref_bomen;
    reg rd_en;
    reg [15:0] rd_cnt;
    reg square_ram_rd_en;
    reg [8:0] square_ram_rd_addr;
    reg IQ_ram_rd_en;
    reg [8:0] IQ_ram_rd_addr;
    wire [31:0] IQ_ram_rd_dout_ch1,IQ_ram_rd_dout_ch2,IQ_ram_rd_dout_ch3,IQ_ram_rd_dout_ch4,IQ_ram_rd_dout_ch5;
    wire ref_IQ_dout_en;
    wire [31:0] ref_IQ_dout_ch1,ref_IQ_dout_ch2,ref_IQ_dout_ch3,ref_IQ_dout_ch4,ref_IQ_dout_ch5;
    wire detect_en;
    wire win_rd_en;
    wire [15:0] win_dout_512,win_dout_1024;
    wire [9:0] win_rd_addr;
    wire [15:0] fft_win_data;
    wire fft_data_en;
    reg [5:0] bomen_tmp;
    reg [31:0] snr_tmp;
    wire [9:0] xk_index_dout;
    reg [0:0] square_ram_wea;
    reg [8:0] square_ram_addra;
    reg [51:0] square_ram_din;
    reg [51:0] square_ch_add,square_ch_add_tmp;
    reg [60:0] square_sum,square_sub_tmp;
    wire [51:0] square_add_dout_ch1,square_add_dout_ch2,square_add_dout_ch3,square_add_dout_ch4,square_add_dout_ch5;
    reg fft_data_en_d,fft_data_en_d2;
    reg [9:0] xk_index_dout_d,xk_index_dout_d2;
    reg [9:0] max_freq_tmp;
    reg [51:0] max_square_tmp;
    reg sum_sub_en,sum_sub_en_d,sum_sub_en_d2,sum_sub_en_d3;
    reg [8:0] sum_sub_addr;
    reg [8:0] sum_sub_cnt;
    wire [51:0] sum_sub_dout;
    reg [9:0] protect_freq_low,protect_freq_high;
    reg div_tvalid;
    reg [55:0] divisor_tdata,dividend_tdata;
    wire divisor_tready,dividend_tready,div_dout_tvalid;
    reg div_dout_tvalid_d;
    wire [55:0] div_dout_tdata;
    reg [5:0] max_bomen;
    reg [9:0] max_freq;
    reg [31:0] max_snr;
    reg [15:0] max_IQ_phase_ch1,max_IQ_phase_ch2,max_IQ_phase_ch3,max_IQ_phase_ch4,max_IQ_phase_ch5;
    reg [15:0] ref_phase_ch1,ref_phase_ch2,ref_phase_ch3,ref_phase_ch4,ref_phase_ch5;
    wire arctan_rstn;
    reg arctan_tvalid,arctan_tvalid_cnt_en,arctan_state;
    reg [2:0] arctan_cnt;
    reg [31:0] arctan_tdata,arctan_tdata_tmp;
    wire arctan_dout_tvalid;
    reg [2:0] arctan_dout_tvalid_cnt;
    wire [15:0] arctan_dout_tdata;
    reg result_ram_wea_cnt_en;
    reg [3:0] result_ram_wea_cnt;
    reg [0:0] result_ram_wea;
    reg [6:0] result_ram_wr_addr;
    reg [31:0] result_ram_wr_din;
    reg max_phase_state,max_phase_state_d;
    reg result_ram_rd_en;
    reg [6:0] result_ram_rd_addr;
    wire [31:0] result_ram_rd_dout;
    reg result_dout_cnt_en;
    reg [3:0] result_dout_cnt;
    reg [3:0] judge_num_tmp;
    reg [3:0] judge_num_detect_tmp;
    reg [15:0] max_snr_reg1,max_snr_reg2,max_snr_reg3,max_snr_reg4,max_snr_reg5;
    reg [0:0] fft_result_wea;
    reg [14:0] fft_result_addra;
    reg [31:0] fft_result_dina;
    reg fft_result_rd_en;
    reg [14:0] fft_result_rd_addr;
    wire [31:0] fft_result_rd_dout;
    reg max_reg_cnt_en;
    reg [3:0] max_reg_cnt;
    reg [3:0] detect_num;
    (* KEEP = "true" *) wire                             pulse_peak_dout_en;
    (* KEEP = "true" *) wire [5:0]                       pulse_peak_bomen_dout;
    (* KEEP = "true" *) wire [47:0]                      pulse_peak_energy_dout;
    reg [0:0] bomen_result_wea;
    reg [5:0] bomen_result_wr_addr;
    reg [47:0] bomen_result_wr_din;
    reg [0:0] bomen_result_rd_en;
    reg [5:0] bomen_result_rd_addr;
    wire [47:0] bomen_result_rd_dout;
    reg [0:0] max_IQ_wea;
    reg [8:0] max_IQ_wr_addr;
    reg [15:0] max_IQ_wr_din;
    reg max_IQ_rd_en;
    reg [3:0] max_IQ_rd_cnt;
    reg [8:0] max_IQ_rd_addr;
    wire [15:0] max_IQ_rd_dout;
    
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            p_b_d <= 'b0;
            p_b_d2 <= 'b0;
            p_b_d3 <= 'b0;
        end
        else begin
            p_b_d <= p_b_in;
            p_b_d2 <= p_b_d;
            p_b_d3 <= p_b_d2;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            All_WaveNum_d <= 'b0;
            detect_freq_low_near_d <= 'b0;
            detect_freq_high_near_d <= 'b0;
            detect_freq_low_far_d <= 'b0;
            detect_freq_high_far_d <= 'b0;
            snr_door_d <= 'b0;
        end
        else begin
            All_WaveNum_d <= All_WaveNum - 1'b1;
            detect_freq_low_near_d <= detect_freq_low_near;
            detect_freq_high_near_d <= detect_freq_high_near;
            detect_freq_low_far_d <= detect_freq_low_far;
            detect_freq_high_far_d <= detect_freq_high_far;
            snr_door_d <= snr_door_in;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            fft_mode <= 'b0;
            protect_freq <= 'b0;
            snr_door <= 'b0;
            ref_freq <= 'b0;
            ref_bomen <= 'b0;
            judge_num_tmp <= 'b0;
            judge_num_detect_tmp <= 'b0;
        end
        else begin
            if ((p_b_d2) && (!p_b_d3)) begin
                fft_mode <= fft_mode_in[0];
                snr_door <= snr_door_d;
                protect_freq <= protect_freq_in;
                ref_freq <= ref_freq_in;
                ref_bomen <= ref_bomen_in;
                judge_num_tmp <= judge_num;
                judge_num_detect_tmp <= judge_num_detect;
            end
            else begin
                fft_mode <= fft_mode;
                snr_door <= snr_door;
                protect_freq <= protect_freq;
                ref_freq <= ref_freq;
                ref_bomen <= ref_bomen;
                judge_num_tmp <= judge_num_tmp;
                judge_num_detect_tmp <= judge_num_detect_tmp;
            end
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            fft_deepth <= 'b0;
            detect_freq_low <= 'b0;
            detect_freq_high <= 'b0;
            fft_max_bomen <= 'b0;
        end
        else begin
            if ((fft_mode == 1'b0) && (p_b_d2) && (!p_b_d3)) begin
                fft_max_bomen <= All_WaveNum_d;
                fft_deepth <= {1'b0,All_WaveNum_d,9'hFFF};
                detect_freq_low <= detect_freq_low_near_d[9:0];
                detect_freq_high <= detect_freq_high_near_d[9:0];
            end
            else if ((fft_mode == 1'b1) && (p_b_d2) && (!p_b_d3)) begin
                fft_max_bomen <= All_WaveNum_d;
                fft_deepth <= {All_WaveNum_d,10'hFFF};
                detect_freq_low <= detect_freq_low_far_d[9:0];
                detect_freq_high <= detect_freq_high_far_d[9:0];
            end
            else begin
                fft_max_bomen <= fft_max_bomen;
                fft_deepth <= fft_deepth;
                detect_freq_low <= detect_freq_low;
                detect_freq_high <= detect_freq_high;
            end
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            config_cnt_en <= 'b0;
        else begin
            if ((p_b_d2) && (!p_b_d3))
                config_cnt_en <= 1'b1;
            else if (config_cnt == 3'h6)
                config_cnt_en <= 1'b0;
            else
                config_cnt_en <= config_cnt_en;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            config_cnt <= 'b0;
        else begin
            if (config_cnt_en)
                config_cnt <= config_cnt + 1'b1;
            else
                config_cnt <= 'b0;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            config_tvalid <= 'b0;
            config_tdata <= 'b0;
        end
        else begin
            if ((config_cnt >= 3'd2) && (config_cnt <= 3'd3)) begin
                config_tvalid <= 1'b1;
                if (fft_mode == 1'b0)
                    config_tdata <= 16'h0109;        
                else
                    config_tdata <= 16'h010A;        
            end
            else begin
                config_tvalid <= 1'b0;
                config_tdata <= config_tdata;
            end
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            rd_en <= 'b0;
        else begin
            if (config_cnt == 3'd5)
                rd_en <= 1'b1;
            else if (rd_cnt == fft_deepth)
                rd_en <= 1'b0;
            else
                rd_en <= rd_en;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            rd_cnt <= 'b0;
        else begin
            if (rd_en)
                rd_cnt <= rd_cnt + 1'b1;
            else
                rd_cnt <= 'b0;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            buf_data_rd_en <= 'b0;
            buf_data_rd_addr <= 'b0;
        end
        else begin
            buf_data_rd_en <= rd_en;
            if (fft_mode == 1'b1) begin
                buf_data_rd_addr <= rd_cnt;
            end
            else begin
                buf_data_rd_addr <= {rd_cnt[14:9],1'b0,rd_cnt[8:0]};
            end
        end
    end
    
    pulse_peak_gate_detect u_pulse_peak_gate_detect
    (
        .clk                        (clk),
        .rst                        (rst),
        .start_in                   ((p_b_d2 == 1'b1) && (p_b_d3 == 1'b0)),
        .fft_mode                   (fft_mode_in[0]),
        .All_WaveNum                (All_WaveNum),
        .rd_en                      (rd_en),
        .rd_addr                    (rd_cnt),
        .buf_data_in_1              (buf_data_in_1),
        .buf_data_in_2              (buf_data_in_2),
        .buf_data_in_3              (buf_data_in_3),
        .buf_data_in_4              (buf_data_in_4),
        .buf_data_in_5              (buf_data_in_5),
        .pulse_peak_dout_en         (pulse_peak_dout_en),
        .pulse_peak_bomen_dout      (pulse_peak_bomen_dout),
        .pulse_peak_energy_dout     (pulse_peak_energy_dout)
    );
    
    fft_win_1024 u_fft_win_1024
    (
        .clka   (clk),               
        .ena    (win_rd_en),         
        .addra  (win_rd_addr),       
        .douta  (win_dout_1024)      
    );
    
    fft_win_512 u_fft_win_512
    (
        .clka   (clk),               
        .ena    (win_rd_en),         
        .addra  (win_rd_addr[8:0]),  
        .douta  (win_dout_512)       
    );
    
    assign fft_win_data = (fft_mode) ? win_dout_1024 : win_dout_512;
    
    fft_chal u_fft_chal_ch1
    (
        .clk                    (clk),                   
        .rst                    (rst),                   
        .fft_mode               (fft_mode),              
        .rd_en                  (rd_en),                 
        .config_tvalid          (config_tvalid),         
        .config_tdata           (config_tdata),          
        .ref_freq               (ref_freq),            
        .fft_deepth             (fft_deepth),            
        .fft_data_in            (buf_data_in_1),         
        .win_data               (fft_win_data),            
        .IQ_ram_rd_en           (IQ_ram_rd_en),    
        .IQ_ram_rd_addr         (IQ_ram_rd_addr),    
        .IQ_ram_rd_dout         (IQ_ram_rd_dout_ch1), 
        .win_rd_en              (win_rd_en),             
        .win_rd_addr            (win_rd_addr),           
        .detect_en              (detect_en),             
        .fft_data_en            (fft_data_en),             
        .xk_index_dout          (xk_index_dout),     
        .ref_IQ_dout_en         (ref_IQ_dout_en),     
        .ref_IQ_dout            (ref_IQ_dout_ch1),     
        .square_add_dout        (square_add_dout_ch1)    
    );
    
    fft_chal u_fft_chal_ch2
    (
        .clk                    (clk),                   
        .rst                    (rst),                   
        .fft_mode               (fft_mode),              
        .rd_en                  (rd_en),                 
        .config_tvalid          (config_tvalid),         
        .config_tdata           (config_tdata),  
        .ref_freq               (ref_freq),             
        .fft_deepth             (fft_deepth),            
        .fft_data_in            (buf_data_in_2),         
        .win_data               (fft_win_data),            
        .IQ_ram_rd_en           (IQ_ram_rd_en),    
        .IQ_ram_rd_addr         (IQ_ram_rd_addr),    
        .IQ_ram_rd_dout         (IQ_ram_rd_dout_ch2),  
        .win_rd_en              (),             
        .win_rd_addr            (),           
        .detect_en              (),             
        .fft_data_en            (),     
        .xk_index_dout          (),     
        .ref_IQ_dout_en         (),     
        .ref_IQ_dout            (ref_IQ_dout_ch2),     
        .square_add_dout        (square_add_dout_ch2)    
    );
    
    fft_chal u_fft_chal_ch3
    (
        .clk                    (clk),                   
        .rst                    (rst),                   
        .fft_mode               (fft_mode),              
        .rd_en                  (rd_en),                 
        .config_tvalid          (config_tvalid),         
        .config_tdata           (config_tdata),   
        .ref_freq               (ref_freq),      
        .fft_deepth             (fft_deepth),            
        .fft_data_in            (buf_data_in_3),         
        .win_data               (fft_win_data),            
        .IQ_ram_rd_en           (IQ_ram_rd_en),    
        .IQ_ram_rd_addr         (IQ_ram_rd_addr),    
        .IQ_ram_rd_dout         (IQ_ram_rd_dout_ch3),  
        .win_rd_en              (),             
        .win_rd_addr            (),           
        .detect_en              (),             
        .fft_data_en            (),     
        .xk_index_dout          (),    
        .ref_IQ_dout_en         (),     
        .ref_IQ_dout            (ref_IQ_dout_ch3),      
        .square_add_dout        (square_add_dout_ch3)    
    );
    
    fft_chal u_fft_chal_ch4
    (
        .clk                    (clk),                   
        .rst                    (rst),                   
        .fft_mode               (fft_mode),              
        .rd_en                  (rd_en),                 
        .config_tvalid          (config_tvalid),         
        .config_tdata           (config_tdata),          
        .ref_freq               (ref_freq),      
        .fft_deepth             (fft_deepth),            
        .fft_data_in            (buf_data_in_4),         
        .win_data               (fft_win_data),            
        .IQ_ram_rd_en           (IQ_ram_rd_en),    
        .IQ_ram_rd_addr         (IQ_ram_rd_addr),    
        .IQ_ram_rd_dout         (IQ_ram_rd_dout_ch4),  
        .win_rd_en              (),             
        .win_rd_addr            (),           
        .detect_en              (),             
        .fft_data_en            (),     
        .xk_index_dout          (),    
        .ref_IQ_dout_en         (),     
        .ref_IQ_dout            (ref_IQ_dout_ch4),      
        .square_add_dout        (square_add_dout_ch4)    
    );
    
    fft_chal u_fft_chal_ch5
    (
        .clk                    (clk),                   
        .rst                    (rst),                   
        .fft_mode               (fft_mode),              
        .rd_en                  (rd_en),                 
        .config_tvalid          (config_tvalid),         
        .config_tdata           (config_tdata),          
        .ref_freq               (ref_freq),      
        .fft_deepth             (fft_deepth),            
        .fft_data_in            (buf_data_in_5),         
        .win_data               (fft_win_data),            
        .IQ_ram_rd_en           (IQ_ram_rd_en),    
        .IQ_ram_rd_addr         (IQ_ram_rd_addr),    
        .IQ_ram_rd_dout         (IQ_ram_rd_dout_ch5),  
        .win_rd_en              (),             
        .win_rd_addr            (),           
        .detect_en              (),             
        .fft_data_en            (),     
        .xk_index_dout          (),     
        .ref_IQ_dout_en         (),     
        .ref_IQ_dout            (ref_IQ_dout_ch5),     
        .square_add_dout        (square_add_dout_ch5)    
    );
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            square_ch_add_tmp <= 'b0;
        else
            square_ch_add_tmp <= square_add_dout_ch1 + square_add_dout_ch2 + square_add_dout_ch3 + square_add_dout_ch4 + square_add_dout_ch5;
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            fft_data_en_d <= 'b0;
            fft_data_en_d2 <= 'b0;
            xk_index_dout_d <= 'b0;
            xk_index_dout_d2 <= 'b0;
            square_ch_add <= 'b0;
        end
        else begin
            fft_data_en_d <= fft_data_en;
            fft_data_en_d2 <= fft_data_en_d;
            xk_index_dout_d <= xk_index_dout;
            xk_index_dout_d2 <= xk_index_dout_d;
            square_ch_add <= square_ch_add_tmp;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            bomen_tmp <= 'b0;
        else begin
            if (detect_en) 
                bomen_tmp <= 'b0;
            else begin
                if (((!fft_mode) && (xk_index_dout_d2 == 10'd511)) || ((fft_mode) && (xk_index_dout_d2 == 10'd1023)))
                    bomen_tmp <= bomen_tmp + 1'b1;
                else
                    bomen_tmp <= bomen_tmp;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            square_ram_addra <= 'b0;
            square_ram_din <= 'b0;
        end
        else begin
            square_ram_addra <= xk_index_dout_d[8:0];
            square_ram_din <= square_ch_add_tmp;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            square_ram_wea <= 'b0;
        else begin
            if (fft_data_en_d) begin
                if (((!fft_mode) && (xk_index_dout_d >= 10'd1) && (xk_index_dout_d <= 10'd255)) || ((fft_mode) && (xk_index_dout_d >= 10'd1) && (xk_index_dout_d <= 10'd511)))
                    square_ram_wea[0] <= 1'b1;
                else
                    square_ram_wea[0] <= 'b0;
            end
            else
                square_ram_wea[0] <= 'b0;
        end
    end
    
    ram_52bx512 u_ram_52bx512
    (
        .clka       (clk),                   
        .wea        (square_ram_wea),        
        .addra      (square_ram_addra),      
        .dina       (square_ram_din),        
        .clkb       (clk),                   
        .enb        (sum_sub_en),            
        .addrb      (sum_sub_addr),          
        .doutb      (sum_sub_dout)           
    );
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_result_wea <= 'b0;
        else begin
            if (fft_data_en_d) begin
                if (((!fft_mode) && (xk_index_dout_d >= 10'd1) && (xk_index_dout_d <= 10'd255)) || ((fft_mode) && (xk_index_dout_d >= 10'd1) && (xk_index_dout_d <= 10'd511)))
                    fft_result_wea[0] <= 1'b1;
                else
                    fft_result_wea[0] <= 'b0;
            end
            else
                fft_result_wea[0] <= 'b0;
        end
    end
    
      
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            fft_result_addra <= 'b0;
            fft_result_dina <= 'b0;
        end
        else begin
            fft_result_addra <= {bomen_tmp,xk_index_dout_d[8:0]};
            if (square_ch_add_tmp[51:48] >= 4'd1)
                fft_result_dina <= 32'hFFFF_FFFF;
            else if (square_ch_add_tmp[51:16] == 36'd0)
                fft_result_dina <= 32'd1;
            else
                fft_result_dina <= square_ch_add_tmp[47:16];
        end
    end
    
    ram_64x512x32 u_ram_64x512x32
    (
        .clka       (clk),  
        .wea        (fft_result_wea),  
        .addra      (fft_result_addra),  
        .dina       (fft_result_dina),  
        .clkb       (clk),  
        .enb        (fft_result_rd_en),  
        .addrb      (fft_result_rd_addr),  
        .doutb      (fft_result_rd_dout)  
    );
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            protect_freq_low <= 'b0;
            protect_freq_high <= 'b0;
            sum_sub_en_d <= 'b0;
            sum_sub_en_d2 <= 'b0;
            sum_sub_en_d3 <= 'b0;
        end
        else begin
            protect_freq_low <= detect_freq_low + protect_freq[10:1];
            protect_freq_high <= detect_freq_high - protect_freq[10:1];
            sum_sub_en_d <= sum_sub_en;
            sum_sub_en_d2 <= sum_sub_en_d;
            sum_sub_en_d3 <= sum_sub_en_d2;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            square_sum <= 'b0;
        else begin
            if (xk_index_dout_d2 == 10'd1)
                square_sum <= 'b0;
            else if ((xk_index_dout_d2 >= detect_freq_low) && (xk_index_dout_d2 <= detect_freq_high))
                square_sum <= square_sum + {9'h000,square_ch_add};
            else
                square_sum <= square_sum;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            max_square_tmp <= 'b0;
            max_freq_tmp <= 'b0;
        end
        else begin
            if (xk_index_dout_d2 == 10'd1) begin
                max_square_tmp <= 'b0;
                max_freq_tmp <= 'b0;
            end
            else if ((xk_index_dout_d2 >= detect_freq_low) && (xk_index_dout_d2 <= detect_freq_high)) begin
                if (square_ch_add > max_square_tmp) begin
                    max_square_tmp <= square_ch_add;
                    max_freq_tmp <= xk_index_dout_d2;
                end
                else begin
                    max_square_tmp <= max_square_tmp;
                    max_freq_tmp <= max_freq_tmp;
                end
            end
            else begin
                max_square_tmp <= max_square_tmp;
                max_freq_tmp <= max_freq_tmp;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            IQ_ram_rd_en <= 'b0;
            IQ_ram_rd_addr <= 'b0;
        end
        else begin
            if (((!fft_mode) && (xk_index_dout_d2 == 10'd260)) || ((fft_mode) && (xk_index_dout_d2 == 10'd520))) begin
                IQ_ram_rd_en <= 1'b1;
                IQ_ram_rd_addr <= max_freq_tmp[8:0];
            end
            else begin
                IQ_ram_rd_en <= 'b0;
                IQ_ram_rd_addr <= 'b0;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            sum_sub_en <= 'b0;
        else begin
            if (((!fft_mode) && (xk_index_dout_d2 == 10'd260)) || ((fft_mode) && (xk_index_dout_d2 == 10'd520)))
                sum_sub_en <= 1'b1;
            else if (sum_sub_cnt == protect_freq[8:0])
                sum_sub_en <= 'b0;
            else
                sum_sub_en <= sum_sub_en;
        end
    end
    
     
	always @(posedge rst or posedge clk)
    begin
        if (rst)
			sum_sub_cnt <= 'b0;
		else begin
			if (sum_sub_en)
				sum_sub_cnt <= sum_sub_cnt + 1'b1;
			else
				sum_sub_cnt <= 'b0;
		end
	end
    
     
	always @(posedge rst or posedge clk)
    begin
        if (rst)
			sum_sub_addr <= 'b0;
		else begin
            if (((!fft_mode) && (xk_index_dout_d2 == 10'd260)) || ((fft_mode) && (xk_index_dout_d2 == 10'd520))) begin
                if (max_freq_tmp <= protect_freq_low)
                    sum_sub_addr <= detect_freq_low[8:0];
                else if (max_freq_tmp >= protect_freq_high)
                    sum_sub_addr <= detect_freq_high[8:0] - protect_freq[8:0];
                else
                    sum_sub_addr <= max_freq_tmp[8:0] - protect_freq[9:1];
            end
            else if (sum_sub_en)
                sum_sub_addr <= sum_sub_addr + 1'b1;
            else
                sum_sub_addr <= sum_sub_addr;
		end
	end
    
     
	always @(posedge rst or posedge clk)
    begin
        if (rst)
			square_sub_tmp <= 'b0;
		else begin
			if (((!fft_mode) && (xk_index_dout_d2 == 10'd260)) || ((fft_mode) && (xk_index_dout_d2 == 10'd520))) 
				square_sub_tmp <= square_sum;
			else if (sum_sub_en_d)
                square_sub_tmp <= square_sub_tmp - {9'h000,sum_sub_dout};
			else
				square_sub_tmp <= square_sub_tmp;
		end
	end
	
	 
	always @(posedge rst or posedge clk)
    begin
        if (rst) begin
			div_tvalid <= 'b0;
			dividend_tdata <= 'b0;
		end
		else begin
			if ((!sum_sub_en_d2) && (sum_sub_en_d3) && (divisor_tready) && (dividend_tready)) begin
                div_tvalid <= 1'b1;
                dividend_tdata <= {4'h0,max_square_tmp};
			end
			else begin
                div_tvalid <= 'b0;
                dividend_tdata <= 'b0;
			end
		end
	end
	
	always @(posedge rst or posedge clk)
    begin
        if (rst)
			divisor_tdata <= 56'h0F_FFFF_FFFF_FFFF;
		else begin
			if ((!sum_sub_en_d2) && (sum_sub_en_d3) && (divisor_tready) && (dividend_tready)) begin
                if (!fft_mode) begin
                    if (square_sub_tmp[60:8] == 53'd0)
                        divisor_tdata <= 56'h0F_FFFF_FFFF_FFFF;
                    else
                        divisor_tdata <= {3'h0,square_sub_tmp[60:8]};
                end
                else begin
                    if (square_sub_tmp[44:9] == 36'd0)
                        divisor_tdata <= 56'h0F_FFFF_FFFF_FFFF;
                    else
                        divisor_tdata <= {4'h0,square_sub_tmp[60:9]};
                end
			end
			else 
                divisor_tdata <= divisor_tdata;
		end
	end
	
    snr_div u_snr_div
    (
        .aclk                       (clk),               
        .s_axis_divisor_tvalid      (div_tvalid),        
        .s_axis_divisor_tready      (divisor_tready),    
        .s_axis_divisor_tdata       (divisor_tdata),     
        .s_axis_dividend_tvalid     (div_tvalid),        
        .s_axis_dividend_tready     (dividend_tready),   
        .s_axis_dividend_tdata      (dividend_tdata),    
        .m_axis_dout_tvalid         (div_dout_tvalid),   
        .m_axis_dout_tuser          (),                  
        .m_axis_dout_tdata          (div_dout_tdata)     
    );
    
     
	always @(posedge rst or posedge clk)
    begin
        if (rst)
            snr_tmp <= 'b0;
		else begin
			if (div_dout_tvalid) begin
                if (div_dout_tdata[51:32] >= 20'd1)
                    snr_tmp <= 32'hFFFF_FFFF;
                else
                    snr_tmp <= div_dout_tdata[31:0];
			end
			else
                snr_tmp <= snr_tmp;
        end
	end
	
	always @(posedge rst or posedge clk)
    begin
        if (rst)
            div_dout_tvalid_d <= 'b0;
		else
			div_dout_tvalid_d <= div_dout_tvalid;
	end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            max_bomen <= 'b0;
            max_freq <= 'b0;
            max_snr <= 'b0;
        end
        else begin
            if (detect_en) begin
                max_bomen <= 'b0;
                max_freq <= 'b0;
                max_snr <= 'b0;
            end
            else if ((use_PulseCompress == 8'hFF) && (!fft_data_en_d) && (fft_data_en_d2)) begin
                max_bomen <= pulse_peak_bomen_dout;
                max_freq <= bomen_result_rd_dout[41:32];
                max_snr <= bomen_result_rd_dout[31:0];
            end
            else if ((use_PulseCompress == 8'h00) && (div_dout_tvalid_d)) begin
                if (snr_tmp >= max_snr) begin
                    max_bomen <= bomen_tmp;
                    max_freq <= max_freq_tmp;
                    max_snr <= snr_tmp;
                end
                else begin
                    max_bomen <= max_bomen;
                    max_freq <= max_freq;
                    max_snr <= max_snr;
                end
            end
            else begin
                max_bomen <= max_bomen;
                max_freq <= max_freq;
                max_snr <= max_snr;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            bomen_result_wea <= 'b0;
            bomen_result_wr_addr <= 'b0;
            bomen_result_wr_din <= 'b0;
        end
        else begin
            if (div_dout_tvalid_d) begin
                bomen_result_wea[0] <= 1'b1;
                bomen_result_wr_addr <= bomen_tmp;
                bomen_result_wr_din <= {6'h00,max_freq_tmp,snr_tmp};
            end
            else begin
                bomen_result_wea <= 'b0;
                bomen_result_wr_addr <= 'b0;
                bomen_result_wr_din <= 'b0;
            end
        end
    end
    
    ram_48bx64 u_ram_48bx64
    (
        .clka           (clk),                       
        .wea            (bomen_result_wea),          
        .addra          (bomen_result_wr_addr),      
        .dina           (bomen_result_wr_din),       
        .clkb           (clk),                       
        .enb            (bomen_result_rd_en),        
        .addrb          (bomen_result_rd_addr),      
        .doutb          (bomen_result_rd_dout)       
    );
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            bomen_result_rd_en <= 'b0;
            bomen_result_rd_addr <= 'b0;
        end
        else begin
            if ((!fft_data_en) && (fft_data_en_d)) begin
                bomen_result_rd_en <= 1'b1;
                bomen_result_rd_addr <= pulse_peak_bomen_dout;
            end
            else begin
                bomen_result_rd_en <= 'b0;
                bomen_result_rd_addr <= 'b0;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            arctan_tvalid_cnt_en <= 'b0;
            arctan_state <= 'b0;
        end
        else begin
            if (div_dout_tvalid_d) begin
                arctan_tvalid_cnt_en <= 1'b1;
                arctan_state <= 1'b1;
            end
            else if (ref_IQ_dout_en) begin
                arctan_tvalid_cnt_en <= 1'b1;
                arctan_state <= 1'b0;
            end
            else if (arctan_cnt == 3'd7) begin
                arctan_tvalid_cnt_en <= 1'b0;
                arctan_state <= arctan_state;
            end
            else begin
                arctan_tvalid_cnt_en <= arctan_tvalid_cnt_en;
                arctan_state <= arctan_state;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            arctan_cnt <= 'b0;
        else begin
            if (arctan_tvalid_cnt_en)
                arctan_cnt <= arctan_cnt + 1'b1;
            else
                arctan_cnt <= 'b0;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            arctan_tvalid <= 'b0;
        else begin
            if ((arctan_cnt >= 3'd3) && (arctan_cnt <= 3'd7))
                arctan_tvalid <= 1'b1;
            else
                arctan_tvalid <= 'b0;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            arctan_tdata_tmp <= 32'h0001_0001;
        else begin
            case (arctan_cnt)
                3'd2 : begin
                           if (arctan_state)
                               arctan_tdata_tmp <= {IQ_ram_rd_dout_ch1[31],IQ_ram_rd_dout_ch1[31:17],IQ_ram_rd_dout_ch1[15],IQ_ram_rd_dout_ch1[15:1]};
                           else
                               arctan_tdata_tmp <= {ref_IQ_dout_ch1[31],ref_IQ_dout_ch1[31:17],ref_IQ_dout_ch1[15],ref_IQ_dout_ch1[15:1]};
                       end
                3'd3 : begin
                           if (arctan_state)
                               arctan_tdata_tmp <= {IQ_ram_rd_dout_ch2[31],IQ_ram_rd_dout_ch2[31:17],IQ_ram_rd_dout_ch2[15],IQ_ram_rd_dout_ch2[15:1]};
                           else
                               arctan_tdata_tmp <= {ref_IQ_dout_ch2[31],ref_IQ_dout_ch2[31:17],ref_IQ_dout_ch2[15],ref_IQ_dout_ch2[15:1]};
                       end
                3'd4 : begin
                           if (arctan_state)
                               arctan_tdata_tmp <= {IQ_ram_rd_dout_ch3[31],IQ_ram_rd_dout_ch3[31:17],IQ_ram_rd_dout_ch3[15],IQ_ram_rd_dout_ch3[15:1]};
                           else
                               arctan_tdata_tmp <= {ref_IQ_dout_ch3[31],ref_IQ_dout_ch3[31:17],ref_IQ_dout_ch3[15],ref_IQ_dout_ch3[15:1]};
                       end
                3'd5 : begin
                           if (arctan_state)
                               arctan_tdata_tmp <= {IQ_ram_rd_dout_ch4[31],IQ_ram_rd_dout_ch4[31:17],IQ_ram_rd_dout_ch4[15],IQ_ram_rd_dout_ch4[15:1]};
                           else
                               arctan_tdata_tmp <= {ref_IQ_dout_ch4[31],ref_IQ_dout_ch4[31:17],ref_IQ_dout_ch4[15],ref_IQ_dout_ch4[15:1]};
                       end
                3'd6 : begin
                           if (arctan_state)
                               arctan_tdata_tmp <= {IQ_ram_rd_dout_ch5[31],IQ_ram_rd_dout_ch5[31:17],IQ_ram_rd_dout_ch5[15],IQ_ram_rd_dout_ch5[15:1]};
                           else
                               arctan_tdata_tmp <= {ref_IQ_dout_ch5[31],ref_IQ_dout_ch5[31:17],ref_IQ_dout_ch5[15],ref_IQ_dout_ch5[15:1]};
                       end
                default : arctan_tdata_tmp <= 32'h0001_0001;
            endcase
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            arctan_tdata <= 'b0;
        else
            arctan_tdata <= arctan_tdata_tmp;
    end
    
    assign arctan_rstn = ~rst;
    
    arctan_ip u_arctan_ip
    (
        .aclk                       (clk),                   
        .aresetn                    (arctan_rstn),           
        .s_axis_cartesian_tvalid    (arctan_tvalid),         
        .s_axis_cartesian_tdata     (arctan_tdata),          
        .m_axis_dout_tvalid         (arctan_dout_tvalid),    
        .m_axis_dout_tdata          (arctan_dout_tdata)      
    );
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            arctan_dout_tvalid_cnt <= 'b0;
        else begin
           if (arctan_dout_tvalid)
                arctan_dout_tvalid_cnt <= arctan_dout_tvalid_cnt + 1'b1;
            else
                arctan_dout_tvalid_cnt <= 'b0;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            max_phase_state <= 'b0;
            max_phase_state_d <= 'b0;
        end
        else begin
            max_phase_state_d <= max_phase_state;
            if (detect_en)
                max_phase_state <= 'b0;
            else if ((div_dout_tvalid_d) && (snr_tmp >= max_snr))
                max_phase_state <= 1'b1;
            else if ((arctan_dout_tvalid) && (arctan_state) && (arctan_dout_tvalid_cnt == 3'd4))
                max_phase_state <= 1'b0;
            else 
                max_phase_state <= max_phase_state;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_IQ_phase_ch1 <= 'b0;
        else begin
            if (use_PulseCompress == 8'hFF) begin
                if (max_IQ_rd_cnt == 4'd1)
                    max_IQ_phase_ch1 <= max_IQ_rd_dout;
                else
                    max_IQ_phase_ch1 <= max_IQ_phase_ch1;
            end
            else begin
                if ((arctan_dout_tvalid) && (arctan_state) && (arctan_dout_tvalid_cnt == 3'd0) && (max_phase_state_d))
                    max_IQ_phase_ch1 <= arctan_dout_tdata;
                else
                    max_IQ_phase_ch1 <= max_IQ_phase_ch1;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_IQ_phase_ch2 <= 'b0;
        else begin
            if (use_PulseCompress == 8'hFF) begin
                if (max_IQ_rd_cnt == 4'd2)
                    max_IQ_phase_ch2 <= max_IQ_rd_dout;
                else
                    max_IQ_phase_ch2 <= max_IQ_phase_ch2;
            end
            else begin
                if ((arctan_dout_tvalid) && (arctan_state) && (arctan_dout_tvalid_cnt == 3'd1) && (max_phase_state_d))
                    max_IQ_phase_ch2 <= arctan_dout_tdata;
                else
                    max_IQ_phase_ch2 <= max_IQ_phase_ch2;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_IQ_phase_ch3 <= 'b0;
        else begin
            if (use_PulseCompress == 8'hFF) begin
                if (max_IQ_rd_cnt == 4'd3)
                    max_IQ_phase_ch3 <= max_IQ_rd_dout;
                else
                    max_IQ_phase_ch3 <= max_IQ_phase_ch3;
            end
            else begin
                if ((arctan_dout_tvalid) && (arctan_state) && (arctan_dout_tvalid_cnt == 3'd2) && (max_phase_state_d))
                    max_IQ_phase_ch3 <= arctan_dout_tdata;
                else
                    max_IQ_phase_ch3 <= max_IQ_phase_ch3;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_IQ_phase_ch4 <= 'b0;
        else begin
            if (use_PulseCompress == 8'hFF) begin
                if (max_IQ_rd_cnt == 4'd4)
                    max_IQ_phase_ch4 <= max_IQ_rd_dout;
                else
                    max_IQ_phase_ch4 <= max_IQ_phase_ch4;
            end
            else begin
                if ((arctan_dout_tvalid) && (arctan_state) && (arctan_dout_tvalid_cnt == 3'd3) && (max_phase_state_d))
                    max_IQ_phase_ch4 <= arctan_dout_tdata;
                else
                    max_IQ_phase_ch4 <= max_IQ_phase_ch4;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_IQ_phase_ch5 <= 'b0;
        else begin
            if (use_PulseCompress == 8'hFF) begin
                if (max_IQ_rd_cnt == 4'd5)
                    max_IQ_phase_ch5 <= max_IQ_rd_dout;
                else
                    max_IQ_phase_ch5 <= max_IQ_phase_ch5;
            end
            else begin
                if ((arctan_dout_tvalid) && (arctan_state) && (arctan_dout_tvalid_cnt == 3'd4) && (max_phase_state_d))
                    max_IQ_phase_ch5 <= arctan_dout_tdata;
                else
                    max_IQ_phase_ch5 <= max_IQ_phase_ch5;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            max_IQ_wea <= 'b0;
            max_IQ_wea <= 'b0;
        end
        else begin
            max_IQ_wea[0] <= arctan_dout_tvalid & arctan_state;
            max_IQ_wr_din <= arctan_dout_tdata;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) 
            max_IQ_wr_addr <= 'b0;
        else begin
            if ((p_b_d2) && (!p_b_d3))
                max_IQ_wr_addr <= 'b0;
            else if ((arctan_dout_tvalid) && (!max_IQ_wea[0]))
                max_IQ_wr_addr <= {bomen_tmp,3'b000};
            else if (max_IQ_wea[0])
                max_IQ_wr_addr <= max_IQ_wr_addr + 1'b1;
            else
                max_IQ_wr_addr <= max_IQ_wr_addr;
        end
    end
    
    ram_64x8x16b u_ram_64x8x16b
    (
        .clka           (clk),               
        .wea            (max_IQ_wea),        
        .addra          (max_IQ_wr_addr),    
        .dina           (max_IQ_wr_din),     
        .clkb           (clk),               
        .enb            (max_IQ_rd_en),      
        .addrb          (max_IQ_rd_addr),    
        .doutb          (max_IQ_rd_dout)     
    );
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_IQ_rd_en <= 'b0;
        else begin
            if ((!fft_data_en) && (fft_data_en_d))
                max_IQ_rd_en <= 1'b1;
            else if (max_IQ_rd_cnt == 4'd6)
                max_IQ_rd_en <= 'b0;
            else 
                max_IQ_rd_en <= max_IQ_rd_en;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_IQ_rd_cnt <= 'b0;
        else begin
            if (max_IQ_rd_en)
                max_IQ_rd_cnt <= max_IQ_rd_cnt + 1'b1;
            else
                max_IQ_rd_cnt <= 'b0;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_IQ_rd_addr <= 'b0;
        else begin
            if ((!fft_data_en) && (fft_data_en_d))
                max_IQ_rd_addr <= {pulse_peak_bomen_dout,3'b000};
            else if (max_IQ_rd_en)
                max_IQ_rd_addr <= max_IQ_rd_addr + 1'b1;
            else 
                max_IQ_rd_addr <= max_IQ_rd_addr;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            ref_phase_ch1 <= 'b0;
        else begin
            if ((arctan_dout_tvalid) && (!arctan_state) && (arctan_dout_tvalid_cnt == 3'd0) && (bomen_tmp == ref_bomen))
                ref_phase_ch1 <= arctan_dout_tdata;
            else
                ref_phase_ch1 <= ref_phase_ch1;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            ref_phase_ch2 <= 'b0;
        else begin
            if ((arctan_dout_tvalid) && (!arctan_state) && (arctan_dout_tvalid_cnt == 3'd1) && (bomen_tmp == ref_bomen))
                ref_phase_ch2 <= arctan_dout_tdata;
            else
                ref_phase_ch2 <= ref_phase_ch2;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            ref_phase_ch3 <= 'b0;
        else begin
            if ((arctan_dout_tvalid) && (!arctan_state) && (arctan_dout_tvalid_cnt == 3'd2) && (bomen_tmp == ref_bomen))
                ref_phase_ch3 <= arctan_dout_tdata;
            else
                ref_phase_ch3 <= ref_phase_ch3;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            ref_phase_ch4 <= 'b0;
        else begin
            if ((arctan_dout_tvalid) && (!arctan_state) && (arctan_dout_tvalid_cnt == 3'd3) && (bomen_tmp == ref_bomen))
                ref_phase_ch4 <= arctan_dout_tdata;
            else
                ref_phase_ch4 <= ref_phase_ch4;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            ref_phase_ch5 <= 'b0;
        else begin
            if ((arctan_dout_tvalid) && (!arctan_state) && (arctan_dout_tvalid_cnt == 3'd4) && (bomen_tmp == ref_bomen))
                ref_phase_ch5 <= arctan_dout_tdata;
            else
                ref_phase_ch5 <= ref_phase_ch5;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            result_ram_wea_cnt_en <= 'b0;
        else begin
            if ((arctan_dout_tvalid_cnt == 3'd4) && (arctan_state))
                result_ram_wea_cnt_en <= 1'b1;
            else if (result_ram_wea_cnt == 4'd10)
                result_ram_wea_cnt_en <= 'b0;
            else
                result_ram_wea_cnt_en <= result_ram_wea_cnt_en;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            result_ram_wea_cnt <= 'b0;
        else begin
            if (result_ram_wea_cnt_en)
                result_ram_wea_cnt <= result_ram_wea_cnt + 1'b1;
            else
                result_ram_wea_cnt <= 'b0;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            result_ram_wea <= 'b0;
        else begin
            if ((result_ram_wea_cnt >= 4'd1) && (result_ram_wea_cnt <= 4'd2))
                result_ram_wea[0] <= 1'b1;
            else
                result_ram_wea <= 'b0;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            result_ram_wr_addr <= 'b0;
        else begin
            if ((p_b_d2) && (!p_b_d3))
                result_ram_wr_addr <= 'b0;
            else if (result_ram_wea[0] == 1'b1)
                result_ram_wr_addr <= result_ram_wr_addr + 1'b1;
            else
                result_ram_wr_addr <= result_ram_wr_addr;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            result_ram_wr_din <= 'b0;
        else begin
            case (result_ram_wea_cnt)
                4'd1 : result_ram_wr_din <= {10'h000,bomen_tmp,6'h00,max_freq_tmp};
                4'd2 : result_ram_wr_din <= snr_tmp;
                default : result_ram_wr_din <= 'b0;
            endcase
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            result_dout_cnt_en <= 'b0;
        else begin
            if ((!fft_data_en) && (fft_data_en_d))
                result_dout_cnt_en <= 1'b1;
            else if (result_dout_cnt == 4'd12)
                result_dout_cnt_en <= 'b0;
            else
                result_dout_cnt_en <= result_dout_cnt_en;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            result_dout_cnt <= 'b0;
        else begin
            if (result_dout_cnt_en)
                result_dout_cnt <= result_dout_cnt + 1'b1;
            else
                result_dout_cnt <= 'b0;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_result_rd_en <= 'b0;
        else begin
            if ((result_dout_cnt >= 4'd1) && (result_dout_cnt <= 4'd5))
                fft_result_rd_en <= 1'b1;
            else
                fft_result_rd_en <= 'b0;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_result_rd_addr <= 'b0;
        else begin
            if (!fft_mode) begin
                case (max_bomen)
                    6'd0 : begin
                               case (result_dout_cnt)
                                   4'd1 : fft_result_rd_addr <= {7'h00,max_freq[7:0]};
                                   4'd2 : fft_result_rd_addr <= {7'h00,max_freq[7:0]};
                                   4'd3 : fft_result_rd_addr <= {7'h00,max_freq[7:0]};
                                   4'd4 : fft_result_rd_addr <= {7'h00,max_freq[7:0]} - 1'b1;
                                   4'd5 : fft_result_rd_addr <= {7'h00,max_freq[7:0]} + 1'b1;
                                   default : fft_result_rd_addr <= 'b0;
                               endcase
                           end
                    fft_max_bomen : begin
                               case (result_dout_cnt)
                                   4'd1 : fft_result_rd_addr <= {1'b0,fft_max_bomen,max_freq[7:0]};
                                   4'd2 : fft_result_rd_addr <= {1'b0,fft_max_bomen,max_freq[7:0]};
                                   4'd3 : fft_result_rd_addr <= {1'b0,fft_max_bomen,max_freq[7:0]};
                                   4'd4 : fft_result_rd_addr <= {1'b0,fft_max_bomen,max_freq[7:0]} - 1'b1;
                                   4'd5 : fft_result_rd_addr <= {1'b0,fft_max_bomen,max_freq[7:0]} + 1'b1;
                               endcase
                           end
                    default : begin
                               case (result_dout_cnt)
                                   4'd1 : fft_result_rd_addr <= {1'b0,max_bomen,max_freq[7:0]} - 15'd256;
                                   4'd2 : fft_result_rd_addr <= {1'b0,max_bomen,max_freq[7:0]};
                                   4'd3 : fft_result_rd_addr <= {1'b0,max_bomen,max_freq[7:0]} + 15'd256;
                                   4'd4 : fft_result_rd_addr <= {1'b0,max_bomen,max_freq[7:0]} - 1'b1;
                                   4'd5 : fft_result_rd_addr <= {1'b0,max_bomen,max_freq[7:0]} + 1'b1;
                               endcase
                           end
                endcase
            end
            else begin
                case (max_bomen)
                    6'd0 : begin
                               case (result_dout_cnt)
                                   4'd1 : fft_result_rd_addr <= {6'h00,max_freq[8:0]};
                                   4'd2 : fft_result_rd_addr <= {6'h00,max_freq[8:0]};
                                   4'd3 : fft_result_rd_addr <= {6'h00,max_freq[8:0]};
                                   4'd4 : fft_result_rd_addr <= {6'h00,max_freq[8:0]} - 1'b1;
                                   4'd5 : fft_result_rd_addr <= {6'h00,max_freq[8:0]} + 1'b1;
                                   default : fft_result_rd_addr <= 'b0;
                               endcase
                           end
                    fft_max_bomen : begin
                               case (result_dout_cnt)
                                   4'd1 : fft_result_rd_addr <= {fft_max_bomen,max_freq[8:0]};
                                   4'd2 : fft_result_rd_addr <= {fft_max_bomen,max_freq[8:0]};
                                   4'd3 : fft_result_rd_addr <= {fft_max_bomen,max_freq[8:0]};
                                   4'd4 : fft_result_rd_addr <= {fft_max_bomen,max_freq[8:0]} - 1'b1;
                                   4'd5 : fft_result_rd_addr <= {fft_max_bomen,max_freq[8:0]} + 1'b1;
                               endcase
                           end
                    default : begin
                               case (result_dout_cnt)
                                   4'd1 : fft_result_rd_addr <= {max_bomen,max_freq[8:0]} - 15'd512;
                                   4'd2 : fft_result_rd_addr <= {max_bomen,max_freq[8:0]};
                                   4'd3 : fft_result_rd_addr <= {max_bomen,max_freq[8:0]} + 15'd512;
                                   4'd4 : fft_result_rd_addr <= {max_bomen,max_freq[8:0]} - 1'b1;
                                   4'd5 : fft_result_rd_addr <= {max_bomen,max_freq[8:0]} + 1'b1;
                               endcase
                           end
                endcase
            end
        end
    end

     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_result_bomen_before <= 'b0;
        else begin
            if (result_dout_cnt == 4'd3)
                fft_result_bomen_before <= fft_result_rd_dout;
            else
                fft_result_bomen_before <= fft_result_bomen_before;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_result_bomen_middle <= 'b0;
        else begin
            if (result_dout_cnt == 4'd4)
                fft_result_bomen_middle <= fft_result_rd_dout;
            else
                fft_result_bomen_middle <= fft_result_bomen_middle;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_result_bomen_after <= 'b0;
        else begin
            if (result_dout_cnt == 4'd5)
                fft_result_bomen_after <= fft_result_rd_dout;
            else
                fft_result_bomen_after <= fft_result_bomen_after;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_result_freq_before <= 'b0;
        else begin
            if (result_dout_cnt == 4'd6)
                fft_result_freq_before <= fft_result_rd_dout;
            else
                fft_result_freq_before <= fft_result_freq_before;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_result_freq_after <= 'b0;
        else begin
            if (result_dout_cnt == 4'd7)
                fft_result_freq_after <= fft_result_rd_dout;
            else
                fft_result_freq_after <= fft_result_freq_after;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_dout_en <= 'b0;
        else begin
            if ((result_dout_cnt >= 4'd9) && (result_dout_cnt <= 4'd10))
                max_dout_en <= 1'b1;
            else
                max_dout_en <= 'b0;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            max_bomen_dout <= 'b0;
            max_freq_dout <= 'b0;
        end
        else begin
            if (result_dout_cnt == 4'd7) begin
                max_bomen_dout <= max_bomen;
                max_freq_dout <= max_freq;

            end
            else begin
                max_bomen_dout <= max_bomen_dout;
                max_freq_dout <= max_freq_dout;
            end
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_snr_dout <= 'b0;
        else begin
            if (result_dout_cnt == 4'd7) begin
                if (max_snr[31:16] >= 16'd1)
                    max_snr_dout <= 16'hFFFF;
                else
                    max_snr_dout <= max_snr[15:0];
            end
            else
                max_snr_dout <= max_snr_dout;
        end
    end
    
    ram_32bx2x64 u_ram_32bx2x64_result
    (
        .clka       (clk),                   
        .wea        (result_ram_wea),        
        .addra      (result_ram_wr_addr),    
        .dina       (result_ram_wr_din),     
        .clkb       (clk),                   
        .enb        (result_ram_rd_en),      
        .addrb      (result_ram_rd_addr),    
        .doutb      (result_ram_rd_dout)     
    );
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            result_ram_rd_en <= 'b0;
        else begin
            if ((result_dout_cnt >= 4'd1) && (result_dout_cnt <= 4'd6))
                result_ram_rd_en <= 1'b1;
            else
                result_ram_rd_en <= 'b0;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            result_ram_rd_addr <= 'b0;
        else begin
            case (max_bomen)
                6'd0 : begin
                           case (result_dout_cnt)
                               4'd1 : result_ram_rd_addr <= 7'd2;
                               4'd2 : result_ram_rd_addr <= 7'd3;
                               4'd3 : result_ram_rd_addr <= 7'd0;
                               4'd4 : result_ram_rd_addr <= 7'd1;
                               4'd5 : result_ram_rd_addr <= 7'd4;
                               4'd6 : result_ram_rd_addr <= 7'd5;
                               default : result_ram_rd_addr <= 'b0;
                           endcase
                       end
                fft_max_bomen : begin
                           case (result_dout_cnt)
                               4'd1 : result_ram_rd_addr <= {fft_max_bomen,1'b0} - 7'd4;
                               4'd2 : result_ram_rd_addr <= {fft_max_bomen,1'b0} - 7'd3;
                               4'd3 : result_ram_rd_addr <= {fft_max_bomen,1'b0};
                               4'd4 : result_ram_rd_addr <= {fft_max_bomen,1'b0} + 7'd1;
                               4'd5 : result_ram_rd_addr <= {fft_max_bomen,1'b0} - 7'd2;
                               4'd6 : result_ram_rd_addr <= {fft_max_bomen,1'b0} - 7'd1;
                               default : result_ram_rd_addr <= 'b0;
                           endcase
                       end
                default : begin
                           if (result_dout_cnt == 4'd1)
                               result_ram_rd_addr <= {max_bomen,1'b0} - 2'b10;
                           else
                               result_ram_rd_addr <= result_ram_rd_addr + 1'b1;
                       end
            endcase
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            max_bomen_dout_before <= 'b0;
            max_freq_dout_before <= 'b0;
        end
        else begin
            if (result_dout_cnt == 4'd3) begin
                max_bomen_dout_before <= result_ram_rd_dout[31:16];
                max_freq_dout_before <= result_ram_rd_dout[15:0];
            end
            else begin
                max_bomen_dout_before <= max_bomen_dout_before;
                max_freq_dout_before <= max_freq_dout_before;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_snr_dout_before <= 'b0;
        else begin
            if (result_dout_cnt == 4'd4) begin
                if (result_ram_rd_dout[31:16] >= 16'd1)
                    max_snr_dout_before <= 16'hFFFF;
                else
                    max_snr_dout_before <= result_ram_rd_dout[15:0];
            end
            else
                max_snr_dout_before <= max_snr_dout_before;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            max_bomen_dout_middle <= 'b0;
            max_freq_dout_middle <= 'b0;
        end
        else begin
            if (result_dout_cnt == 4'd5) begin
                max_bomen_dout_middle <= result_ram_rd_dout[31:16];
                max_freq_dout_middle <= result_ram_rd_dout[15:0];
            end
            else begin
                max_bomen_dout_middle <= max_bomen_dout_middle;
                max_freq_dout_middle <= max_freq_dout_middle;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_snr_dout_middle <= 'b0;
        else begin
            if (result_dout_cnt == 4'd6) begin
                if (result_ram_rd_dout[31:16] >= 16'd1)
                    max_snr_dout_middle <= 16'hFFFF;
                else
                    max_snr_dout_middle <= result_ram_rd_dout[15:0];
            end
            else
                max_snr_dout_middle <= max_snr_dout_middle;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            max_bomen_dout_after <= 'b0;
            max_freq_dout_after <= 'b0;
        end
        else begin
            if (result_dout_cnt == 4'd7) begin
                max_bomen_dout_after <= result_ram_rd_dout[31:16];
                max_freq_dout_after <= result_ram_rd_dout[15:0];
            end
            else begin
                max_bomen_dout_after <= max_bomen_dout_after;
                max_freq_dout_after <= max_freq_dout_after;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_snr_dout_after <= 'b0;
        else begin
            if (result_dout_cnt == 4'd8) begin
                if (result_ram_rd_dout[31:16] >= 16'd1)
                    max_snr_dout_after <= 16'hFFFF;
                else
                    max_snr_dout_after <= result_ram_rd_dout[15:0];
            end
            else
                max_snr_dout_after <= max_snr_dout_after;
        end
    end
    
     
	always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            max_IQ_ch1_dout <= 'b0;
            max_IQ_ch2_dout <= 'b0;
            max_IQ_ch3_dout <= 'b0;
            max_IQ_ch4_dout <= 'b0;
            max_IQ_ch5_dout <= 'b0;
		end
		else begin
			if (result_dout_cnt == 4'd8) begin
                max_IQ_ch1_dout <= max_IQ_phase_ch1;
                max_IQ_ch2_dout <= max_IQ_phase_ch2;
                max_IQ_ch3_dout <= max_IQ_phase_ch3;
                max_IQ_ch4_dout <= max_IQ_phase_ch4;
                max_IQ_ch5_dout <= max_IQ_phase_ch5;
			end
			else begin
                max_IQ_ch1_dout <= max_IQ_ch1_dout;
                max_IQ_ch2_dout <= max_IQ_ch2_dout;
                max_IQ_ch3_dout <= max_IQ_ch3_dout;
                max_IQ_ch4_dout <= max_IQ_ch4_dout;
                max_IQ_ch5_dout <= max_IQ_ch5_dout;
			end
        end
	end
	
	 
	always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            ref_phase_ch1_dout <= 'b0;
            ref_phase_ch2_dout <= 'b0;
            ref_phase_ch3_dout <= 'b0;
            ref_phase_ch4_dout <= 'b0;
            ref_phase_ch5_dout <= 'b0;
		end
		else begin
			if (result_dout_cnt == 4'd8) begin
                ref_phase_ch1_dout <= ref_phase_ch1;
                ref_phase_ch2_dout <= ref_phase_ch2;
                ref_phase_ch3_dout <= ref_phase_ch3;
                ref_phase_ch4_dout <= ref_phase_ch4;
                ref_phase_ch5_dout <= ref_phase_ch5;
			end
			else begin
                ref_phase_ch1_dout <= ref_phase_ch1_dout;
                ref_phase_ch2_dout <= ref_phase_ch2_dout;
                ref_phase_ch3_dout <= ref_phase_ch3_dout;
                ref_phase_ch4_dout <= ref_phase_ch4_dout;
                ref_phase_ch5_dout <= ref_phase_ch5_dout;
			end
        end
	end
	
	always @(posedge rst or posedge clk)
    begin
        if (rst)
            zhen_cnt <= 'b0;
		else begin
			if (result_dout_cnt == 4'd8)
                zhen_cnt <= zhen_cnt + 1'b1;
			else
                zhen_cnt <= zhen_cnt;
        end
	end
	
	always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            max_bomen_dout_middle <= 'b0;
            max_freq_dout_middle <= 'b0;
        end
        else begin
            if (result_dout_cnt == 4'd5) begin
                max_bomen_dout_middle <= result_ram_rd_dout[31:16];
                max_freq_dout_middle <= result_ram_rd_dout[15:0];
            end
            else begin
                max_bomen_dout_middle <= max_bomen_dout_middle;
                max_freq_dout_middle <= max_freq_dout_middle;
            end
        end
    end
	
	always @(posedge rst or posedge clk)
    begin
        if (rst)
            ps_int <= 'b0;
		else begin
			if ((result_dout_cnt >= 4'd2) && (result_dout_cnt <= 4'd11))
                ps_int <= 1'b1;
			else
                ps_int <= 'b0;
        end
	end
	
	 
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_snr_reg1 <= 'b0;
        else begin
            if (result_dout_cnt == 4'd6) begin
                if (result_ram_rd_dout[31:16] >= 16'd1)
                    max_snr_reg1 <= 16'hFFFF;
                else
                    max_snr_reg1 <= result_ram_rd_dout[15:0];
            end
            else
                max_snr_reg1 <= max_snr_reg1;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            max_snr_reg2 <= 'b0;
            max_snr_reg3 <= 'b0;
            max_snr_reg4 <= 'b0;
            max_snr_reg5 <= 'b0;
        end
        else begin
            if (result_dout_cnt == 4'd6) begin
                max_snr_reg2 <= max_snr_reg1;
                max_snr_reg3 <= max_snr_reg2;
                max_snr_reg4 <= max_snr_reg3;
                max_snr_reg5 <= max_snr_reg4;
            end
            else begin
                max_snr_reg2 <= max_snr_reg2;
                max_snr_reg3 <= max_snr_reg3;
                max_snr_reg4 <= max_snr_reg4;
                max_snr_reg5 <= max_snr_reg5;
            end
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_reg_cnt_en <= 'b0;
		else begin
			if (result_dout_cnt == 4'd7)
                max_reg_cnt_en <= 1'b1;
			else if (max_reg_cnt == 4'd10)    
                max_reg_cnt_en <= 1'b0;
            else
                max_reg_cnt_en <= max_reg_cnt_en;
        end
	end
	
	always @(posedge rst or posedge clk)
    begin
        if (rst)
            max_reg_cnt <= 'b0;
		else begin
			if (max_reg_cnt_en == 1'b1)
                max_reg_cnt <= max_reg_cnt + 1'b1;
            else
                max_reg_cnt <= 'b0;
        end
	end
	
	always @(posedge rst or posedge clk)
    begin
        if (rst)
            detect_num <= 'b0;
		else begin
			if (max_reg_cnt <= judge_num_tmp) begin
                case (max_reg_cnt)
                    4'd0 : detect_num <= 'b0;
                    4'd1 :  begin
                                if (max_snr_reg1 >= snr_door)
                                    detect_num <= detect_num + 1'b1;
                                else
                                    detect_num <= detect_num;
                            end
                    4'd2 :  begin
                                if (max_snr_reg2 >= snr_door)
                                    detect_num <= detect_num + 1'b1;
                                else
                                    detect_num <= detect_num;
                            end
                    4'd3 :  begin
                                if (max_snr_reg3 >= snr_door)
                                    detect_num <= detect_num + 1'b1;
                                else
                                    detect_num <= detect_num;
                            end
                    4'd4 :  begin
                                if (max_snr_reg4 >= snr_door)
                                    detect_num <= detect_num + 1'b1;
                                else
                                    detect_num <= detect_num;
                            end
                    4'd5 :  begin
                                if (max_snr_reg5 >= snr_door)
                                    detect_num <= detect_num + 1'b1;
                                else
                                    detect_num <= detect_num;
                            end
                    default : detect_num <= detect_num;
                endcase
            end
            else
                detect_num <= detect_num;
        end
	end
    
	
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            target_state <= 'b0;
		else begin
			if (max_reg_cnt == 4'd2)
                target_state <= 'b0;
			else if (max_reg_cnt == 4'd7) begin
                if (detect_num >= judge_num_detect_tmp)
                    target_state <= 1'b1;
                else
                    target_state <= 'b0;
			end
			else     
                target_state <= target_state;
        end
	end
	
endmodule
