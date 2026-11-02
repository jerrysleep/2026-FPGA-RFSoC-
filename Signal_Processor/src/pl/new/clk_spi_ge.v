`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


module clk_spi_ge(
    input               sys_rst_n       ,
    input               sys_clk         ,  
     
    output              clk_spi_out      
 
    );
  
    reg [7:0] cnt;
    reg clk_spi;
    always@(posedge sys_clk or negedge sys_rst_n) begin
       if(~sys_rst_n)begin
             cnt <= 8'd0;
             clk_spi <= 0;
       end else begin
           if(cnt == 8'd100) begin
                  cnt <= 8'd0;
                  clk_spi <= ~clk_spi;      
           end else begin
                  cnt <= cnt +1;
                  clk_spi <= clk_spi;
            end 
       end   
    end 
     
     BUFG BUFG_spi_clk  
      (
          .O(clk_spi_out),  
          .I(clk_spi)   
       ); 
       
        
 
 
 
 
 
 
 
  
 
 
 

endmodule
