`timescale 1ns / 1ps

module Rst_Sync(
    input  wire clk,
    input  wire arst,
    output wire rst,
    output wire rst_n
);

    (* ASYNC_REG = "TRUE" *) reg [2:0] rst_pipe = 3'b111;

    always @(posedge clk or posedge arst) begin
        if (arst)
            rst_pipe <= 3'b111;
        else
            rst_pipe <= {rst_pipe[1:0], 1'b0};
    end

    assign rst   = rst_pipe[2];
    assign rst_n = ~rst_pipe[2];

endmodule
