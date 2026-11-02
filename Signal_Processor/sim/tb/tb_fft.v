`timescale 1ns/1ps
module tb_fft;
  reg clk=0;
  always #5 clk=~clk;
  reg rst=1,p_b=0;
  wire rd_en,ps_int,max_dout_en;
  wire [15:0] rd_addr;
  reg [31:0] x=0;
  top_fft dut(
    .clk(clk),.rst(rst),.p_b_in(p_b),.fft_mode_in(8'h00),
    .use_PulseCompress(8'hff),.snr_door_in(16'd1),.protect_freq_in(16'd2),
    .detect_freq_low_near(16'd0),.detect_freq_high_near(16'd500),
    .detect_freq_low_far(16'd0),.detect_freq_high_far(16'd500),
    .ref_freq_in(10'd5),.ref_bomen_in(6'd0),
    .judge_num(4'd1),.judge_num_detect(4'd1),.All_WaveNum(6'd2),
    .buf_data_in_1(x),.buf_data_in_2(x+32'd1),.buf_data_in_3(x+32'd2),
    .buf_data_in_4(x+32'd3),.buf_data_in_5(x+32'd4),
    .ps_int(ps_int),.buf_data_rd_en(rd_en),.buf_data_rd_addr(rd_addr),
    .max_dout_en(max_dout_en));
  integer fd,i,reads=0,fft_valid=0;
  initial begin
    fd=$fopen("fft.csv","w");
    $fwrite(fd,"cycle,rst,p_b,rd_en,rd_addr,fft_config_valid,fft_data_valid,fft_output_valid,fft_output_hex,fft_bin,ps_int,max_dout_en\n");
    for(i=0;i<2200;i=i+1) begin
      @(negedge clk);
      if(i==5) rst=0;
      if(i==20) p_b=1;
      if(i==22) p_b=0;
      x=i%64;
      #1;
      if(rd_en) reads=reads+1;
      if(dut.u_fft_chal_ch1.fft_out_tvalid) fft_valid=fft_valid+1;
      if(i<40 || i%10==0 || dut.u_fft_chal_ch1.fft_out_tvalid || ps_int || max_dout_en)
        $fwrite(fd,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%08h,%0d,%0d,%0d\n",i,rst,p_b,rd_en,rd_addr,dut.config_tvalid,dut.u_fft_chal_ch1.fft_in_tvalid,dut.u_fft_chal_ch1.fft_out_tvalid,dut.u_fft_chal_ch1.fft_out_tdata,dut.u_fft_chal_ch1.fft_out_tuser[8:0],ps_int,max_dout_en);
    end
    $fclose(fd);
    if(reads<1 || fft_valid<1) $fatal(1,"FFT FAIL reads=%0d fft_valid=%0d",reads,fft_valid);
    $display("FFT PASS reads=%0d fft_valid=%0d",reads,fft_valid);
    $finish;
  end
endmodule
