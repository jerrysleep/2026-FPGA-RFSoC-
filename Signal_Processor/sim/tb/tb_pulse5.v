`timescale 1ns/1ps
module tb_pulse5;
  reg clk=0;
  always #5 clk=~clk;
  reg rst=1, frame_start=0, prt_ref=0;
  reg [15:0] v=0;
  wire [15:0] i1,q1,i2,q2,i3,q3,i4,q4,i5,q5;
  wire valid,frame_out,mode_out;
  top_5ch_pulse_compression dut(
    .clk(clk),.rst(rst),.en(1'b1),.frame_start(frame_start),.prt_ref(prt_ref),.far_or_near(1'b1),
    .din_ch1_i(v),.din_ch1_q(16'd0),
    .din_ch2_i(v+16'd10),.din_ch2_q(16'd0),
    .din_ch3_i(v+16'd20),.din_ch3_q(16'd0),
    .din_ch4_i(v+16'd30),.din_ch4_q(16'd0),
    .din_ch5_i(v+16'd40),.din_ch5_q(16'd0),
    .dout_ch1_i(i1),.dout_ch1_q(q1),.dout_ch2_i(i2),.dout_ch2_q(q2),
    .dout_ch3_i(i3),.dout_ch3_q(q3),.dout_ch4_i(i4),.dout_ch4_q(q4),
    .dout_ch5_i(i5),.dout_ch5_q(q5),
    .dout_valid(valid),.frame_out(frame_out),.far_or_near_out(mode_out));
  integer fd,k,hits=0,known_hits=0;
  initial begin
    fd=$fopen("pulse5.csv","w");
    $fwrite(fd,"cycle,frame_start,prt_ref,valid,frame_out,mode,i1,q1,i2,q2,i3,q3,i4,q4,i5,q5\n");
    for(k=0;k<6000;k=k+1) begin
      @(negedge clk);
      if(k==5) rst=0;
      frame_start=(k==80);
      prt_ref=(k>=100 && k<2500 && (k-100)%400==0);
      v=(k%400<60)?(k%400):16'd0;
      #1;
      if(valid) hits=hits+1;
      if(valid && ^{i1,q1,i2,q2,i3,q3,i4,q4,i5,q5}!==1'bx) known_hits=known_hits+1;
      if(k<110 || prt_ref || valid || k%100==0)
        $fwrite(fd,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",k,frame_start,prt_ref,valid,frame_out,mode_out,i1,q1,i2,q2,i3,q3,i4,q4,i5,q5);
    end
    $fclose(fd);
    if(hits<1 || known_hits<1) $fatal(1,"PULSE5 FAIL hits=%0d known=%0d",hits,known_hits);
    $display("PULSE5 PASS hits=%0d known=%0d",hits,known_hits);
    $finish;
  end
endmodule
