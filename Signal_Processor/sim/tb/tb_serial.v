`timescale 1ns/1ps
module tb_serial;
  reg clk=0;
  always #5 clk=~clk;
  reg rst=1, tx_valid=0;
  reg [7:0] tx_data=0;
  reg [8:0] tx_addr=0;
  wire txd_fc, txd_radio;
  Serial_Comm dut(
    .clk_100m(clk),.rst(rst),.rs422_rxd_fc(1'b1),
    .rs422_txd_fc(txd_fc),.rs422_txd_radio(txd_radio),
    .Status(8'h55),.tx_clk_fc(clk),.tx_clk_radio(clk),
    .tx_data_fc(tx_data),.tx_data_radio(8'd0),
    .tx_valid_fc(tx_valid),.tx_valid_radio(1'b0),
    .tx_addr_fc(tx_addr),.tx_addr_radio(9'd0),
    .FromFK_bram_addr(8'd0),.FromFK_bram_clk(clk),.FromFK_bram_en(1'b0));
  integer fd,i,fall_count=0;
  reg last_txd=1;
  initial begin
    fd=$fopen("serial.csv","w");
    $fwrite(fd,"cycle,tx_valid,tx_addr,tx_data,txd_fc,txd_radio\n");
    for(i=0;i<6500;i=i+1) begin
      @(negedge clk);
      if(i==5) rst=0;
      if(i>=20 && i<24) begin tx_valid=1;tx_addr=i-20;tx_data=8'h41+i-20; end
      else tx_valid=0;
      #1;
      if(last_txd===1'b1 && txd_fc===1'b0) fall_count=fall_count+1;
      last_txd=txd_fc;
      if(i<35 || i%10==0 || (i>15 && i<5000 && txd_fc==0 && i%3==0))
        $fwrite(fd,"%0d,%0d,%0d,%0d,%0d,%0d\n",i,tx_valid,tx_addr,tx_data,txd_fc,txd_radio);
    end
    $fclose(fd);
    if(fall_count<2) $fatal(1,"SERIAL FAIL, falls=%0d",fall_count);
    $display("SERIAL PASS, falling edges=%0d",fall_count);
    $finish;
  end
endmodule
