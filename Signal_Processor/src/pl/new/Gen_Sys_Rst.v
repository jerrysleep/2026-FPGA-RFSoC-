`timescale 1ns / 1ps

(* KEEP_HIERARCHY = "YES" *) module Gen_Sys_Rst(
    input  wire clk_in,
    input  wire locked_in,
    output reg  locked,
    input  wire pc_rst_in,
    output reg  sys_rst,
    output reg  sys_rst_n
);

    (* ASYNC_REG = "TRUE" *) reg [2:0] locked_sync = 3'b000;
    (* ASYNC_REG = "TRUE" *) reg [2:0] pc_rst_sync = 3'b000;
    reg [31:0] rst_cnt = 32'd0;

    initial begin
        locked    = 1'b0;
        sys_rst   = 1'b1;
        sys_rst_n = 1'b0;
    end

    always @(posedge clk_in) begin
        locked_sync <= {locked_sync[1:0], locked_in};
        pc_rst_sync <= {pc_rst_sync[1:0], pc_rst_in};
        locked      <= locked_sync[2];
    end

    always @(posedge clk_in) begin
        if (locked_sync[2] == 1'b0) begin
            rst_cnt   <= 32'd0;
            sys_rst   <= 1'b1;
            sys_rst_n <= 1'b0;
        end
        else if (pc_rst_sync[2]) begin
            rst_cnt   <= 32'd0;
            sys_rst   <= 1'b1;
            sys_rst_n <= 1'b0;
        end
        else if (rst_cnt > 32'd50000) begin
            rst_cnt   <= rst_cnt;
            sys_rst   <= 1'b0;
            sys_rst_n <= 1'b1;
        end
        else begin
            rst_cnt   <= rst_cnt + 32'd1;
            sys_rst   <= 1'b1;
            sys_rst_n <= 1'b0;
        end
    end

endmodule
