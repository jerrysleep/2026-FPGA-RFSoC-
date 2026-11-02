`timescale 1ns/1ps
module tb_sysrst;
  reg clk=0,locked_in=0,pc_rst_in=0;
  always #5 clk=~clk;
  wire locked,sys_rst,sys_rst_n;
  Gen_Sys_Rst dut(.clk_in(clk),.locked_in(locked_in),.pc_rst_in(pc_rst_in),
                  .locked(locked),.sys_rst(sys_rst),.sys_rst_n(sys_rst_n));
  integer fd,i,released=0,reasserted=0;
  initial begin
    fd=$fopen("sysrst.csv","w");
    $fwrite(fd,"cycle,locked_in,locked,pc_rst_in,sys_rst,sys_rst_n\n");
    for(i=0;i<50140;i=i+1) begin
      @(negedge clk);
      if(i==5) locked_in=1;
      if(i==50080) pc_rst_in=1;
      if(i==50090) pc_rst_in=0;
      #1;
      if(i==0 || i==5 || i==10 || i%1000==0 || i>=50050)
        $fwrite(fd,"%0d,%0d,%0d,%0d,%0d,%0d\n",i,locked_in,locked,pc_rst_in,sys_rst,sys_rst_n);
      if(i>=50060 && i<50080 && sys_rst_n) released=1;
      if(i>=50085 && i<50100 && sys_rst && !sys_rst_n) reasserted=1;
    end
    $fclose(fd);
    if(!released || !reasserted) $fatal(1,"SYSRST FAIL release=%0d reassert=%0d",released,reasserted);
    $display("SYSRST PASS release=%0d reassert=%0d",released,reasserted);
    $finish;
  end
endmodule
