`timescale 1ns/1ps
module tb_clock_startup;
  reg clk50=0, spi_fast=0, rst=1;
  always #10 clk50=~clk50;
  always #20 spi_fast=~spi_fast;
  wire spi_generated;
  clk_spi_ge gen(.sys_rst_n(~rst),.sys_clk(clk50),.clk_spi_out(spi_generated));
  wire lmk_sclk,lmk_cs,lmk_sync,lmk_rst,lmk_locked,lmk_done;
  tri lmk_sdio;
  LMK04828_config lmk(
    .clk_1M(spi_fast),.sys_rst(rst),.clk_50m(clk50),.sleep_order(1'b0),
    .LMK_ADC_SCLK(lmk_sclk),.LMK_ADC_SDIO(lmk_sdio),.LMK_ADC_CS(lmk_cs),
    .LMK04828_SYNC(lmk_sync),.lmk04828_rst(lmk_rst),
    .lmk_cfg_LOCKED(lmk_locked),.lmk_cfg_finish(lmk_done));
  wire si_sclk,si_cs,si_sdio,si_rst,si_done,si_dir,si_rdy;
  wire [7:0] si_read1,si_read2;
  cfg_si5341 si(
    .clk_1M(spi_fast),.sys_rst(rst),.clk_50m(clk50),
    .dac_sclk(si_sclk),.dac_sden(si_cs),.dac_sdio(si_sdio),.dac_sdo(1'b0),
    .dac_reset(si_rst),.dac_cfg_done(si_done),.direction_ctl(si_dir),
    .dac_read_out1(si_read1),.dac_read_out2(si_read2),.dac_spi_rdy(si_rdy));
  integer fd,i,gen_edges=0,lmk_starts=0,si_starts=0,lmk_active=0,si_active=0;
  reg last_gen=0;
  initial begin
    fd=$fopen("clock_startup.csv","w");
    $fwrite(fd,"cycle,rst,generated_spi,lmk_reset,lmk_wr_start,lmk_cs,lmk_sclk,lmk_locked,lmk_done,si_reset,si_wr_start,si_cs,si_sclk,si_done\n");
    for(i=0;i<30000;i=i+1) begin
      @(negedge clk50);
      if(i==5) rst=0;
      #1;
      if(spi_generated && !last_gen) gen_edges=gen_edges+1;
      last_gen=spi_generated;
      if(lmk.wr_start) lmk_starts=lmk_starts+1;
      if(si.wr_start) si_starts=si_starts+1;
      if(!lmk_cs) lmk_active=lmk_active+1;
      if(!si_cs) si_active=si_active+1;
      if(i<15 || i%100==0 || lmk.wr_start || si.wr_start)
        $fwrite(fd,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",
          i,rst,spi_generated,lmk_rst,lmk.wr_start,lmk_cs,lmk_sclk,lmk_locked,lmk_done,
          si_rst,si.wr_start,si_cs,si_sclk,si_done);
    end
    $fclose(fd);
    if(gen_edges<10 || lmk_starts<1 || si_starts<1 || lmk_active<1 || si_active<1)
      $fatal(1,"CLOCK FAIL gen=%0d lmk_start=%0d si_start=%0d lmk_active=%0d si_active=%0d",
        gen_edges,lmk_starts,si_starts,lmk_active,si_active);
    $display("CLOCK PASS gen=%0d lmk_start=%0d si_start=%0d lmk_active=%0d si_active=%0d",
      gen_edges,lmk_starts,si_starts,lmk_active,si_active);
    $finish;
  end
endmodule
