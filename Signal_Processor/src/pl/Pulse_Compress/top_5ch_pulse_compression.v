`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 

module top_5ch_pulse_compression (
    input   wire        clk,
 (* KEEP = "true" *)    input   wire        rst,
 (* KEEP = "true" *)    input   wire        en,

(* KEEP = "true" *)    input   wire        frame_start,
(* KEEP = "true" *)    input   wire        prt_ref,
(* KEEP = "true" *)    input   wire        far_or_near,

    input   wire [15:0] din_ch1_i, din_ch1_q,
    input   wire [15:0] din_ch2_i, din_ch2_q,
    input   wire [15:0] din_ch3_i, din_ch3_q,
    input   wire [15:0] din_ch4_i, din_ch4_q,
    input   wire [15:0] din_ch5_i, din_ch5_q,

(* KEEP = "true" *)    output  reg  [15:0] dout_ch1_i, dout_ch1_q,
(* KEEP = "true" *)    output  reg  [15:0] dout_ch2_i, dout_ch2_q,
(* KEEP = "true" *)    output  reg  [15:0] dout_ch3_i, dout_ch3_q,
(* KEEP = "true" *)    output  reg  [15:0] dout_ch4_i, dout_ch4_q,
(* KEEP = "true" *)    output  reg  [15:0] dout_ch5_i, dout_ch5_q,
(* KEEP = "true" *)    output  reg         dout_valid,
(* KEEP = "true" *)    output  reg         frame_out,
(* KEEP = "true" *)    output  reg         far_or_near_out
);

 
(* KEEP = "true" *) wire [15:0] ch1_dout_i, ch1_dout_q;
(* KEEP = "true" *) wire        ch1_dout_valid, ch1_frame_out, ch1_far_out;
(* KEEP = "true" *) wire [15:0] ch2_dout_i, ch2_dout_q;
(* KEEP = "true" *) wire        ch2_dout_valid, ch2_frame_out, ch2_far_out;
(* KEEP = "true" *) wire [15:0] ch3_dout_i, ch3_dout_q;
(* KEEP = "true" *) wire        ch3_dout_valid, ch3_frame_out, ch3_far_out;
(* KEEP = "true" *) wire [15:0] ch4_dout_i, ch4_dout_q;
(* KEEP = "true" *) wire        ch4_dout_valid, ch4_frame_out, ch4_far_out;
(* KEEP = "true" *) wire [15:0] ch5_dout_i, ch5_dout_q;
(* KEEP = "true" *) wire        ch5_dout_valid, ch5_frame_out, ch5_far_out;

 
always @(posedge clk or posedge rst) begin
    if(rst == 1'b1) begin
        dout_valid <= 1'b0;
        frame_out <= 1'b0;
        far_or_near_out <= 1'b1;
    end
    else if(en == 1'b0) begin
        dout_valid <= 1'b0;
        frame_out <= 1'b0;
        far_or_near_out <= 1'b1;
    end
    else begin
        dout_valid <= ch1_dout_valid;
        frame_out <= ch1_frame_out;
        far_or_near_out <= ch1_far_out;
    end
end

 
always @(posedge clk) begin
    dout_ch1_i <= ch1_dout_i;
    dout_ch1_q <= ch1_dout_q;
    dout_ch2_i <= ch2_dout_i;
    dout_ch2_q <= ch2_dout_q;
    dout_ch3_i <= ch3_dout_i;
    dout_ch3_q <= ch3_dout_q;
    dout_ch4_i <= ch4_dout_i;
    dout_ch4_q <= ch4_dout_q;
    dout_ch5_i <= ch5_dout_i;
    dout_ch5_q <= ch5_dout_q;
end

 
ch_pulse_compression u_ch1 (
    .clk        (clk),
    .rst        (rst),
    .en_in         (en),
    .frame_start(frame_start),
    .prt_ref    (prt_ref),
    .far_or_near(far_or_near),
    .din_i      (din_ch1_i),
    .din_q      (din_ch1_q),
    .dout_i     (ch1_dout_i),
    .dout_q     (ch1_dout_q),
    .dout_valid (ch1_dout_valid),
    .frame_out  (ch1_frame_out),
    .far_or_near_out(ch1_far_out)
);

 
ch_pulse_compression u_ch2 (
    .clk        (clk),
    .rst        (rst),
    .en_in         (en),
    .frame_start(frame_start),
    .prt_ref    (prt_ref),
    .far_or_near(far_or_near),
    .din_i      (din_ch2_i),
    .din_q      (din_ch2_q),
    .dout_i     (ch2_dout_i),
    .dout_q     (ch2_dout_q),
    .dout_valid (ch2_dout_valid),
    .frame_out  (ch2_frame_out),
    .far_or_near_out(ch2_far_out)
);

 
ch_pulse_compression u_ch3 (
    .clk        (clk),
    .rst        (rst),
    .en_in         (en),
    .frame_start(frame_start),
    .prt_ref    (prt_ref),
    .far_or_near(far_or_near),
    .din_i      (din_ch3_i),
    .din_q      (din_ch3_q),
    .dout_i     (ch3_dout_i),
    .dout_q     (ch3_dout_q),
    .dout_valid (ch3_dout_valid),
    .frame_out  (ch3_frame_out),
    .far_or_near_out(ch3_far_out)
);

 
ch_pulse_compression u_ch4 (
    .clk        (clk),
    .rst        (rst),
    .en_in         (en),
    .frame_start(frame_start),
    .prt_ref    (prt_ref),
    .far_or_near(far_or_near),
    .din_i      (din_ch4_i),
    .din_q      (din_ch4_q),
    .dout_i     (ch4_dout_i),
    .dout_q     (ch4_dout_q),
    .dout_valid (ch4_dout_valid),
    .frame_out  (ch4_frame_out),
    .far_or_near_out(ch4_far_out)
);

 
ch_pulse_compression u_ch5 (
    .clk        (clk),
    .rst        (rst),
    .en_in         (en),
    .frame_start(frame_start),
    .prt_ref    (prt_ref),
    .far_or_near(far_or_near),
    .din_i      (din_ch5_i),
    .din_q      (din_ch5_q),
    .dout_i     (ch5_dout_i),
    .dout_q     (ch5_dout_q),
    .dout_valid (ch5_dout_valid),
    .frame_out  (ch5_frame_out),
    .far_or_near_out(ch5_far_out)
);

endmodule