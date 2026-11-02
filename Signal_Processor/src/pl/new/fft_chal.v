`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


module fft_chal
    (
        input                   clk,
        input                   rst,
        input                   fft_mode,
        input                   rd_en,
        input                   config_tvalid,
        input [15:0]            config_tdata,
        input [9:0]             ref_freq,
        input [15:0]            fft_deepth,
        input [31:0]            fft_data_in,
        input [15:0]            win_data,
        input                   IQ_ram_rd_en,
        input [8:0]             IQ_ram_rd_addr,
        output [31:0]           IQ_ram_rd_dout,
        output reg              win_rd_en,
        output reg [9:0]        win_rd_addr,
        output reg              detect_en,
        output reg              fft_data_en,
        output reg [9:0]        xk_index_dout,
        output reg              ref_IQ_dout_en,
        output reg [31:0]       ref_IQ_dout,
        output reg [51:0]       square_add_dout
    );
    
    wire fft_rstn;
    wire config_tready;
    reg rd_en_d,rd_en_d2,rd_en_d3;
    reg fifo_wr_en,fifo_rd_en;
    reg fifo_wr_en_d;
    reg [15:0] fifo_wr_cnt_d;
    wire [31:0] fifo_rd_out;
    reg [31:0] fifo_wr_dina;
    reg [15:0] fifo_wr_cnt,fifo_rd_cnt;
    reg [25:0] fft_data_re_sum,fft_data_im_sum;
    reg [15:0] fft_data_re_mean,fft_data_im_mean;
    reg [15:0] fft_data_re_before_win,fft_data_im_before_win;
    wire [31:0] fft_data_re_win,fft_data_im_win;
    reg fft_in_tvalid,fft_in_tlast;
    reg [31:0] fft_in_tdata;
    reg [15:0] fft_en_cnt;
    wire fft_in_tready;
    wire fft_out_tvalid,fft_out_tlast;
    reg fft_out_tvalid_d,fft_out_tvalid_d2,fft_out_tvalid_d3,fft_out_tvalid_d4;
    wire [31:0] fft_out_tdata;
    wire [23:0] fft_out_tuser;
    reg [15:0] fft_out_re,fft_out_im;
    reg [4:0] blk_exp;
    reg [9:0] fft_xk_index,fft_xk_index_d,fft_xk_index_d2,fft_xk_index_d3;
    wire [31:0] fft_out_re_square,fft_out_im_square;
    reg [0:0] fft_ram_wea;
    reg [8:0] fft_ram_addra;
    reg [31:0] fft_ram_dina;
    reg [51:0] square_add_dout_tmp;
    
     
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            rd_en_d <= 'b0;
            rd_en_d2 <= 'b0;
            rd_en_d3 <= 'b0;
        end
        else begin
            rd_en_d <= rd_en;
            rd_en_d2 <= rd_en_d;
            rd_en_d3 <= rd_en_d2;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            fifo_wr_en <= 'b0;
            fifo_wr_dina <= 'b0;
            fifo_wr_en_d <= 'b0;
            fifo_wr_cnt_d <= 'b0;
        end
        else begin
            fifo_wr_en <= rd_en_d3;
            fifo_wr_dina <= fft_data_in;
            fifo_wr_en_d <= fifo_wr_en;
            fifo_wr_cnt_d <= fifo_wr_cnt;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fifo_wr_cnt <= 'b0;
        else begin
            if (fifo_wr_en) 
                fifo_wr_cnt <= fifo_wr_cnt + 1'b1;
            else
                fifo_wr_cnt <= 'b0;       
        end
    end
    
     
     
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_data_re_sum <= 'b0;
        else begin
            if (fifo_wr_en) begin
                if (((fifo_wr_cnt[8:0] == 9'd0) && (!fft_mode)) || ((fifo_wr_cnt[9:0] == 10'd0) && (fft_mode)))
                    fft_data_re_sum <= {{10{fifo_wr_dina[15]}},fifo_wr_dina[15:0]};
                else
                    fft_data_re_sum <= fft_data_re_sum + {{10{fifo_wr_dina[15]}},fifo_wr_dina[15:0]};
            end
            else
                fft_data_re_sum <= 'b0;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_data_im_sum <= 'b0;
        else begin
            if (fifo_wr_en) begin
                if (((fifo_wr_cnt[8:0] == 9'd0) && (!fft_mode)) || ((fifo_wr_cnt[9:0] == 10'd0) && (fft_mode)))
                    fft_data_im_sum <= {{10{fifo_wr_dina[31]}},fifo_wr_dina[31:16]};
                else
                    fft_data_im_sum <= fft_data_im_sum + {{10{fifo_wr_dina[31]}},fifo_wr_dina[31:16]};
            end
            else
                fft_data_im_sum <= 'b0;
        end
    end
    
     
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_data_re_mean <= 'b0;
        else begin
            if ((fifo_wr_en_d) && (fifo_wr_cnt_d[8:0] == 9'd511) && (!fft_mode))
                fft_data_re_mean <= fft_data_re_sum[24:9];
            else if ((fifo_wr_en_d) && (fifo_wr_cnt_d[9:0] == 10'd1023) && (fft_mode))
                fft_data_re_mean <= fft_data_re_sum[25:10];
            else
                fft_data_re_mean <= fft_data_re_mean;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_data_im_mean <= 'b0;
        else begin
            if ((fifo_wr_en_d) && (fifo_wr_cnt_d[8:0] == 9'd511) && (!fft_mode))
                fft_data_im_mean <= fft_data_im_sum[24:9];
            else if ((fifo_wr_en_d) && (fifo_wr_cnt_d[9:0] == 10'd1023) && (fft_mode))
                fft_data_im_mean <= fft_data_im_sum[25:10];
            else
                fft_data_im_mean <= fft_data_im_mean;
        end
    end
    
     
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fifo_rd_en <= 'b0;
        else begin
            if (((fifo_wr_cnt == 16'd511) && (!fft_mode)) || ((fifo_wr_cnt == 16'd1023) && (fft_mode)))
                fifo_rd_en <= 1'b1;
            else if (fifo_rd_cnt == fft_deepth)
                fifo_rd_en <= 'b0;
            else
                fifo_rd_en <= fifo_rd_en;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fifo_rd_cnt <= 'b0;
        else begin
            if (fifo_rd_en)
                fifo_rd_cnt <= fifo_rd_cnt + 1'b1;
            else
                fifo_rd_cnt <= 'b0;
        end
    end
    
    fifo_adc_32x2048 u_fifo_adc_32x2048
    (
        .clk            (clk),               
        .srst           (rst),               
        .din            (fifo_wr_dina),      
        .wr_en          (fifo_wr_en),        
        .rd_en          (fifo_rd_en),        
        .dout           (fifo_rd_out),       
        .full           (),                  
        .empty          (),                  
        .wr_rst_busy    (),                  
        .rd_rst_busy    ()                   
    );
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_data_re_before_win <= 'b0;
        else
            fft_data_re_before_win <= fifo_rd_out[15:0] - fft_data_re_mean;
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_data_im_before_win <= 'b0;
        else
            fft_data_im_before_win <= fifo_rd_out[31:16] - fft_data_im_mean;
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            win_rd_en <= 'b0;
            win_rd_addr <= 'b0;
        end
        else begin
            win_rd_en <= fifo_rd_en;
            win_rd_addr <= fifo_rd_cnt[9:0];
        end
    end
    
     
    mult_16sx16us u_mult_16sx16us_re
    (
        .CLK    (clk),                       
        .A      (fft_data_re_before_win),    
        .B      (win_data),                  
        .P      (fft_data_re_win)            
    );
    
     
    mult_16sx16us u_mult_16sx16us_im
    (
        .CLK    (clk),                       
        .A      (fft_data_im_before_win),    
        .B      (win_data),                  
        .P      (fft_data_im_win)            
    );
    
     
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_in_tvalid <= 'b0;
        else begin
            if (((fifo_wr_cnt == 16'd516) && (!fft_mode)) || ((fifo_wr_cnt == 16'd1028) && (fft_mode)))
                fft_in_tvalid <= 1'b1;
            else if (fft_en_cnt == fft_deepth)
                fft_in_tvalid <= 'b0;
            else
                fft_in_tvalid <= fft_in_tvalid;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_en_cnt <= 'b0;
        else begin
            if (fft_in_tvalid)
                fft_en_cnt <= fft_en_cnt + 1'b1;
            else
                fft_en_cnt <= 'b0;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_in_tdata[15:0] <= 'b0;
        else
            fft_in_tdata[15:0] <= fft_data_re_win[31:16];
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_in_tdata[31:16] <= 'b0;
        else
            fft_in_tdata[31:16] <= fft_data_im_win[31:16];
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_in_tlast <= 'b0;
        else begin
            if (fft_en_cnt == (fft_deepth - 1'b1))
                fft_in_tlast <= 1'b1;
            else
                fft_in_tlast <= 1'b0;
        end
    end
    
    assign fft_rstn = ~rst;      
    
    fft_ip u_fft_ip
    (
        .aclk                           (clk),               
        .aresetn                        (fft_rstn),          
        .s_axis_config_tdata            (config_tdata),      
        .s_axis_config_tvalid           (config_tvalid),     
        .s_axis_config_tready           (config_tready),     
        .s_axis_data_tdata              (fft_in_tdata),      
        .s_axis_data_tvalid             (fft_in_tvalid),     
        .s_axis_data_tready             (fft_in_tready),     
        .s_axis_data_tlast              (fft_in_tlast),      
        .m_axis_data_tdata              (fft_out_tdata),     
        .m_axis_data_tuser              (fft_out_tuser),     
        .m_axis_data_tvalid             (fft_out_tvalid),    
        .m_axis_data_tready             (1'b1),              
        .m_axis_data_tlast              (fft_out_tlast),     
        .m_axis_status_tdata            (),      
        .m_axis_status_tvalid           (),      
        .m_axis_status_tready           (1'b1)  , 
        .event_frame_started            (),      
        .event_tlast_unexpected         (),      
        .event_tlast_missing            (),      
        .event_status_channel_halt      (),      
        .event_data_in_channel_halt     (),      
        .event_data_out_channel_halt    ()       
    );                                                                                             
                                                                                                   
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            fft_out_tvalid_d <= 'b0;
            fft_out_tvalid_d2 <= 'b0;
            fft_out_tvalid_d3 <= 'b0;
            fft_out_tvalid_d4 <= 'b0;
            fft_out_re <= 'b0;
            fft_out_im <= 'b0;
            fft_xk_index <= 'b0;
            fft_xk_index_d <= 'b0;
            fft_xk_index_d2 <= 'b0;
            fft_xk_index_d3 <= 'b0;
            blk_exp <= 'b0;
        end
        else begin
            fft_out_tvalid_d <= fft_out_tvalid;
            fft_out_tvalid_d2 <= fft_out_tvalid_d;
            fft_out_tvalid_d3 <= fft_out_tvalid_d2;
            fft_out_tvalid_d4 <= fft_out_tvalid_d3;
            fft_out_re <= fft_out_tdata[15:0];
            fft_out_im <= fft_out_tdata[31:16];
            fft_xk_index <= fft_out_tuser[9:0];
            fft_xk_index_d <= fft_xk_index;
            fft_xk_index_d2 <= fft_xk_index_d;
            fft_xk_index_d3 <= fft_xk_index_d2;
            blk_exp <= fft_out_tuser[20:16];
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            ref_IQ_dout_en <= 'b0;
            ref_IQ_dout <= 'b0;
        end
        else begin
            if ((fft_out_tvalid) && (fft_out_tuser[9:0] == ref_freq)) begin
                ref_IQ_dout_en <= 1'b1;
                ref_IQ_dout <= fft_out_tdata;
            end
            else begin
                ref_IQ_dout_en <= 'b0;
                ref_IQ_dout <= ref_IQ_dout;
            end
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            fft_ram_wea <= 'b0;
        else begin
            if (fft_out_tvalid) begin
                if (((!fft_mode) && (fft_out_tuser[9:0] <= 10'd255)) || ((fft_mode) && (fft_out_tuser[9:0] <= 10'd511)))
                    fft_ram_wea[0] <= 1'b1;
                else
                    fft_ram_wea <= 'b0;
            end
            else
                fft_ram_wea <= 'b0;
        end
    end
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            fft_ram_addra <= 'b0;
            fft_ram_dina <= 'b0;
        end
        else begin
            fft_ram_addra <= fft_out_tuser[8:0];
            fft_ram_dina <= fft_out_tdata;
        end
    end
    
    ram_32bx512 u_ram_32bx512
    (
        .clka       (clk),               
        .wea        (fft_ram_wea),       
        .addra      (fft_ram_addra),     
        .dina       (fft_ram_dina),      
        .clkb       (clk),               
        .enb        (IQ_ram_rd_en),      
        .addrb      (IQ_ram_rd_addr),    
        .doutb      (IQ_ram_rd_dout)     
    );
    
     
    mult_16sx16s u_mult_16sx16s_re
    (
        .CLK    (clk),                   
        .A      (fft_out_re),            
        .B      (fft_out_re),            
        .P      (fft_out_re_square)      
    );
    
    mult_16sx16s u_mult_16sx16s_im
    (
        .CLK    (clk),                   
        .A      (fft_out_im),            
        .B      (fft_out_im),            
        .P      (fft_out_im_square)      
    );    
    
     
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            detect_en <= 'b0;
        else begin
            if ((fft_out_tvalid) && (!fft_out_tvalid_d))
                detect_en <= 1'b1;
            else
                detect_en <= 1'b0;
        end
    end
    
    always @(posedge rst or posedge clk)
    begin
        if (rst)
            square_add_dout_tmp <= 'b0;
        else begin
            case (blk_exp)
                5'd0 : square_add_dout_tmp <= {20'h00000,fft_out_re_square} + {20'h00000,fft_out_im_square};
                5'd1 : square_add_dout_tmp <= {18'h00000,fft_out_re_square,2'h0} + {18'h00000,fft_out_im_square,2'h0};
                5'd2 : square_add_dout_tmp <= {16'h0000,fft_out_re_square,4'h0} + {16'h0000,fft_out_im_square,4'h0};
                5'd3 : square_add_dout_tmp <= {14'h0000,fft_out_re_square,6'h00} + {14'h0000,fft_out_im_square,6'h00};
                5'd4 : square_add_dout_tmp <= {12'h000,fft_out_re_square,8'h00} + {12'h000,fft_out_im_square,8'h00};
                5'd5 : square_add_dout_tmp <= {10'h000,fft_out_re_square,10'h000} + {10'h000,fft_out_im_square,10'h000};
                5'd6 : square_add_dout_tmp <= {8'h00,fft_out_re_square,12'h000} + {8'h00,fft_out_im_square,12'h000};
                5'd7 : square_add_dout_tmp <= {6'h00,fft_out_re_square,14'h000} + {6'h00,fft_out_im_square,14'h000};
                default : square_add_dout_tmp <= {4'h0,fft_out_re_square,16'h0000} + {4'h0,fft_out_im_square,16'h0000};
            endcase
        end
    end

     
    always @(posedge rst or posedge clk)
    begin
        if (rst) begin
            fft_data_en <= 'b0;
            xk_index_dout <= 'b0;
            square_add_dout <= 'b0;
        end
        else begin
            fft_data_en <= fft_out_tvalid_d4;
            xk_index_dout <= fft_xk_index_d3;
            square_add_dout <= square_add_dout_tmp;
        end
    end
    
    
endmodule
