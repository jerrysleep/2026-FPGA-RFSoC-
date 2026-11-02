`timescale 1ns/1ps
module tb_reset;
reg clk = 0;
reg arst = 1;
wire rst, rst_n;
integer fd, cycle;
Rst_Sync dut(.clk(clk), .arst(arst), .rst(rst), .rst_n(rst_n));
always #5 clk = ~clk;
initial begin
  fd = $fopen("reset.csv", "w");
  $fwrite(fd, "cycle,arst,rst,rst_n\n");
  for (cycle=0; cycle<10; cycle=cycle+1) begin
    if (cycle==2) arst=0;
    if (cycle==7) arst=1;
    @(negedge clk);
    $fwrite(fd, "%0d,%0d,%0d,%0d\n",cycle,arst,rst,rst_n);
    if (cycle==4 && (rst!==1'b0 || rst_n!==1'b1))
      $fatal(1,"RESET FAIL release");
    if (cycle==7 && (rst!==1'b1 || rst_n!==1'b0))
      $fatal(1,"RESET FAIL assert");
  end
  $fclose(fd);
  $display("RESET PASS");
  $finish;
end
endmodule
