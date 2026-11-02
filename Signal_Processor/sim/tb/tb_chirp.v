`timescale 1ns/1ps
module tb_chirp;
  reg clk=0,clk500=0;
  always #2 clk=~clk;
  always #1 clk500=~clk500;
  reg rstn=0,prt_ref=0;
  wire valid,conv_valid;
  wire [1023:0] data;
  wire [255:0] conv_data;
  chirp_top dut(
    .m00_axis_aclk(clk),.clk_500M(clk500),.m00_axis_aresetn(rstn),
    .PINC1(32'd0),.f0_scale(32'h19999999),.mu_scale(32'd0),
    .f0_scale2(32'd0),.mu_scale2(32'd0),.fc_scale(32'hcccccccd),
    .axi_chirp_width(32'd40),.axi_pulse_period(32'd97),.pulse_delay(32'd0),
    .prt_ref(prt_ref),.rf_converter_tready(1'b1),
    .mm_axis_tvalid(valid),.mm_axis_tdata(data),
    .m_axis_tvalid_converter(conv_valid),.m_axis_tdata_converter(conv_data));
  integer fd,i,hits=0,conv_hits=0,known=0;
  initial begin
    fd=$fopen("chirp.csv","w");
    $fwrite(fd,"cycle,prt_ref,mm_valid,mm_ch0_hex,mm_ch1_hex,converter_valid,converter_hex\n");
    for(i=0;i<1100;i=i+1) begin
      @(negedge clk);
      if(i==10) rstn=1;
      prt_ref=(i>=30 && (i-30)%97==0);
      #1;
      if(valid) hits=hits+1;
      if(conv_valid) conv_hits=conv_hits+1;
      if(valid && ^data[31:0]!==1'bx) known=known+1;
      if(i<40 || valid || conv_valid || i%20==0)
        $fwrite(fd,"%0d,%0d,%0d,%08h,%08h,%0d,%064h\n",i,prt_ref,valid,data[31:0],data[63:32],conv_valid,conv_data);
    end
    $fclose(fd);
    if(hits<1 || known<1) $fatal(1,"CHIRP FAIL mm=%0d known=%0d converter=%0d",hits,known,conv_hits);
    $display("CHIRP PASS mm=%0d known=%0d converter=%0d",hits,known,conv_hits);
    $finish;
  end
endmodule
