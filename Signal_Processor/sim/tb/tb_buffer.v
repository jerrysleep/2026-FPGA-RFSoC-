`timescale 1ns/1ps
module tb_buffer;
  reg clk=0;
  always #5 clk=~clk;
  reg rst=1, frame_start=0, gate_buff=0, rd_en=0;
  reg [15:0] rd_addr=0;
  reg [15:0] sample=0;
  wire frame_ref_fft,dout_fft_en;
  wire [31:0] d1,d2,d3,d4,d5;
  wire [5:0] all_wave;
  Buffer_top dut(
    .clk(clk),.rst(rst),.timer_module_en(1'b1),
    .prt_num_per_frame(10'd1),.decim_factor(4'd0),
    .frame_start(frame_start),.gate_buff(gate_buff),
    .din_ch1_i(sample),.din_ch1_q(16'd101),
    .din_ch2_i(sample+16'd10),.din_ch2_q(16'd102),
    .din_ch3_i(sample+16'd20),.din_ch3_q(16'd103),
    .din_ch4_i(sample+16'd30),.din_ch4_q(16'd104),
    .din_ch5_i(sample+16'd40),.din_ch5_q(16'd105),
    .rd_addr(rd_addr),.rd_en(rd_en),
    .frame_ref_fft(frame_ref_fft),.dout_fft_en(dout_fft_en),
    .dout_fft_ch1(d1),.dout_fft_ch2(d2),.dout_fft_ch3(d3),
    .dout_fft_ch4(d4),.dout_fft_ch5(d5),.All_WaveNum(all_wave));
  integer fd,i,writes=0,valids=0,matched=0;
  initial begin
    fd=$fopen("buffer.csv","w");
    $fwrite(fd,"cycle,frame_start,gate_buff,wr_en,wr_addr,rd_en,rd_addr,frame_ref_fft,dout_fft_en,ch1_hex,ch2_hex,ch3_hex,ch4_hex,ch5_hex,all_wave\n");
    for(i=0;i<360;i=i+1) begin
      @(negedge clk);
      if(i==5) rst=0;
      if(i==10 || i==180) frame_start=1;
      if(i==12 || i==182) frame_start=0;
      if((i>=20 && i<90)||(i>=190 && i<260)) gate_buff=1;
      else gate_buff=0;
      if(i>=270 && i<320) begin rd_en=1;rd_addr=i-270; end
      else rd_en=0;
      sample=i;
      #1;
      if(dut.wr_en) writes=writes+1;
      if(dout_fft_en) valids=valids+1;
      if(dout_fft_en && d1[31:16]==16'd101 && d2[31:16]==16'd102 &&
         d3[31:16]==16'd103 && d4[31:16]==16'd104 && d5[31:16]==16'd105 &&
         d2[15:0]==d1[15:0]+16'd10 && d3[15:0]==d1[15:0]+16'd20 &&
         d4[15:0]==d1[15:0]+16'd30 && d5[15:0]==d1[15:0]+16'd40)
         matched=matched+1;
      if(i<35 || dut.wr_en || dout_fft_en || i%10==0)
        $fwrite(fd,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%08h,%08h,%08h,%08h,%08h,%0d\n",i,frame_start,gate_buff,dut.wr_en,dut.wr_addr,rd_en,rd_addr,frame_ref_fft,dout_fft_en,d1,d2,d3,d4,d5,all_wave);
    end
    $fclose(fd);
    if(writes<20 || valids<1 || matched<1) $fatal(1,"BUFFER FAIL writes=%0d valid=%0d match=%0d",writes,valids,matched);
    $display("BUFFER PASS writes=%0d valid_reads=%0d matched=%0d",writes,valids,matched);
    $finish;
  end
endmodule
