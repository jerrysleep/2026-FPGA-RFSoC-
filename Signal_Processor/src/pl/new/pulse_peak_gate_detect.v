`timescale 1ns / 1ps
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

module pulse_peak_gate_detect
    (
        input                   clk,
(* KEEP = "true" *)        input                   rst,
(* KEEP = "true" *)        input                   start_in,
(* KEEP = "true" *)        input                   fft_mode,
(* KEEP = "true" *)        input [5:0]             All_WaveNum,
(* KEEP = "true" *)        input                   rd_en,
(* KEEP = "true" *)        input [15:0]            rd_addr,
(* KEEP = "true" *)        input [31:0]            buf_data_in_1,
(* KEEP = "true" *)        input [31:0]            buf_data_in_2,
(* KEEP = "true" *)        input [31:0]            buf_data_in_3,
(* KEEP = "true" *)        input [31:0]            buf_data_in_4,
(* KEEP = "true" *)        input [31:0]            buf_data_in_5,
(* KEEP = "true" *)        output reg              pulse_peak_dout_en,
(* KEEP = "true" *)        output reg [5:0]        pulse_peak_bomen_dout,
 (* KEEP = "true" *)       output reg [47:0]       pulse_peak_energy_dout
    );

(* KEEP = "true" *)    reg                         rd_en_d1;
(* KEEP = "true" *)    reg                         rd_en_d2;
(* KEEP = "true" *)    reg                         rd_en_d3;
(* KEEP = "true" *)    reg                         square_valid_d1;
(* KEEP = "true" *)    reg                         square_valid_d2;
(* KEEP = "true" *)    reg                         square_valid_d3;
(* KEEP = "true" *)    reg [15:0]                  rd_addr_d1;
(* KEEP = "true" *)    reg [15:0]                  rd_addr_d2;
(* KEEP = "true" *)    reg [15:0]                  rd_addr_d3;
(* KEEP = "true" *)    reg [15:0]                  square_addr_d1;
(* KEEP = "true" *)    reg [15:0]                  square_addr_d2;
(* KEEP = "true" *)    reg [15:0]                  square_addr_d3;
(* KEEP = "true" *)    reg                         energy_valid;
(* KEEP = "true" *)    reg [15:0]                  energy_addr;
(* KEEP = "true" *)    reg [5:0]                   all_wave_num_latch;
(* KEEP = "true" *)    reg                         fft_mode_latch;

(* KEEP = "true" *)   reg signed [15:0]           ch1_i;
(* KEEP = "true" *)   reg signed [15:0]           ch1_q;
(* KEEP = "true" *)   reg signed [15:0]           ch2_i;
(* KEEP = "true" *)   reg signed [15:0]           ch2_q;
(* KEEP = "true" *)   reg signed [15:0]           ch3_i;
(* KEEP = "true" *)   reg signed [15:0]           ch3_q;
(* KEEP = "true" *)   reg signed [15:0]           ch4_i;
(* KEEP = "true" *)   reg signed [15:0]           ch4_q;
(* KEEP = "true" *)   reg signed [15:0]           ch5_i;
(* KEEP = "true" *)   reg signed [15:0]           ch5_q;

(* KEEP = "true" *)    wire [31:0]                 ch1_i_square;
(* KEEP = "true" *)    wire [31:0]                 ch1_q_square;
(* KEEP = "true" *)    wire [31:0]                 ch2_i_square;
(* KEEP = "true" *)    wire [31:0]                 ch2_q_square;
(* KEEP = "true" *)    wire [31:0]                 ch3_i_square;
(* KEEP = "true" *)    wire [31:0]                 ch3_q_square;
(* KEEP = "true" *)    wire [31:0]                 ch4_i_square;
(* KEEP = "true" *)    wire [31:0]                 ch4_q_square;
(* KEEP = "true" *)    wire [31:0]                 ch5_i_square;
(* KEEP = "true" *)    wire [31:0]                 ch5_q_square;

(* KEEP = "true" *)    reg [35:0]                  sample_energy;
(* KEEP = "true" *)    reg [47:0]                  gate_energy;
(* KEEP = "true" *)    wire [47:0]                 gate_energy_next;
(* KEEP = "true" *)    reg [47:0]                  max_gate_energy;
(* KEEP = "true" *)    reg [5:0]                   max_gate_index;
(* KEEP = "true" *)    reg [5:0]                   square_gate_index;
(* KEEP = "true" *)    reg [5:0]                   last_gate_index;
(* KEEP = "true" *)    reg                         square_gate_last;
(* KEEP = "true" *)    reg                         square_frame_last;
(* KEEP = "true" *)    reg                         frame_done;

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rd_en_d1                    <= 1'b0;
            rd_en_d2                    <= 1'b0;
            rd_en_d3                    <= 1'b0;
        end
        else begin
            rd_en_d1                    <= rd_en;
            rd_en_d2                    <= rd_en_d1;
            rd_en_d3                    <= rd_en_d2;
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            rd_addr_d1                  <= 16'd0;
            rd_addr_d2                  <= 16'd0;
            rd_addr_d3                  <= 16'd0;
        end
        else begin
            rd_addr_d1                  <= rd_addr;
            rd_addr_d2                  <= rd_addr_d1;
            rd_addr_d3                  <= rd_addr_d2;
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            all_wave_num_latch          <= 6'd0;
            fft_mode_latch              <= 1'b0;
        end
        else begin
            if(start_in == 1'b1) begin
                all_wave_num_latch      <= All_WaveNum;
                fft_mode_latch          <= fft_mode;
            end
            else begin
                all_wave_num_latch      <= all_wave_num_latch;
                fft_mode_latch          <= fft_mode_latch;
            end
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            ch1_i                       <= 16'sd0;
            ch1_q                       <= 16'sd0;
            ch2_i                       <= 16'sd0;
            ch2_q                       <= 16'sd0;
            ch3_i                       <= 16'sd0;
            ch3_q                       <= 16'sd0;
            ch4_i                       <= 16'sd0;
            ch4_q                       <= 16'sd0;
            ch5_i                       <= 16'sd0;
            ch5_q                       <= 16'sd0;
        end
        else begin
            ch1_i                       <= buf_data_in_1[15:0];
            ch1_q                       <= buf_data_in_1[31:16];
            ch2_i                       <= buf_data_in_2[15:0];
            ch2_q                       <= buf_data_in_2[31:16];
            ch3_i                       <= buf_data_in_3[15:0];
            ch3_q                       <= buf_data_in_3[31:16];
            ch4_i                       <= buf_data_in_4[15:0];
            ch4_q                       <= buf_data_in_4[31:16];
            ch5_i                       <= buf_data_in_5[15:0];
            ch5_q                       <= buf_data_in_5[31:16];
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            square_valid_d1             <= 1'b0;
            square_valid_d2             <= 1'b0;
            square_valid_d3             <= 1'b0;
            square_addr_d1              <= 16'd0;
            square_addr_d2              <= 16'd0;
            square_addr_d3              <= 16'd0;
        end
        else begin
            square_valid_d1             <= rd_en_d3;
            square_valid_d2             <= square_valid_d1;
            square_valid_d3             <= square_valid_d2;
            square_addr_d1              <= rd_addr_d3;
            square_addr_d2              <= square_addr_d1;
            square_addr_d3              <= square_addr_d2;
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            sample_energy               <= 36'd0;
        end
        else begin
            sample_energy               <= {4'h0,ch1_i_square} + {4'h0,ch1_q_square} +
                                           {4'h0,ch2_i_square} + {4'h0,ch2_q_square} +
                                           {4'h0,ch3_i_square} + {4'h0,ch3_q_square} +
                                           {4'h0,ch4_i_square} + {4'h0,ch4_q_square} +
                                           {4'h0,ch5_i_square} + {4'h0,ch5_q_square};
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            energy_valid                <= 1'b0;
            energy_addr                 <= 16'd0;
        end
        else begin
            energy_valid                <= square_valid_d3;
            energy_addr                 <= square_addr_d3;
        end
    end

     
     
    assign gate_energy_next = gate_energy + {12'h000,sample_energy};

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            square_gate_index           <= 6'd0;
        end
        else begin
            if(fft_mode_latch == 1'b1) begin
                square_gate_index       <= energy_addr[15:10];
            end
            else begin
                square_gate_index       <= energy_addr[14:9];
            end
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            last_gate_index             <= 6'd0;
        end
        else begin
            last_gate_index             <= all_wave_num_latch - 1'b1;
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            square_gate_last            <= 1'b0;
        end
        else begin
            if(fft_mode_latch == 1'b1) begin
                if((energy_valid == 1'b1) && (energy_addr[9:0] == 10'd1023)) begin
                    square_gate_last    <= 1'b1;
                end
                else begin
                    square_gate_last    <= 1'b0;
                end
            end
            else begin
                if((energy_valid == 1'b1) && (energy_addr[8:0] == 9'd511)) begin
                    square_gate_last    <= 1'b1;
                end
                else begin
                    square_gate_last    <= 1'b0;
                end
            end
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            square_frame_last           <= 1'b0;
        end
        else begin
            if(fft_mode_latch == 1'b1) begin
                if((energy_valid == 1'b1) && (energy_addr[9:0] == 10'd1023) &&
                   (energy_addr[15:10] == last_gate_index)) begin
                    square_frame_last   <= 1'b1;
                end
                else begin
                    square_frame_last   <= 1'b0;
                end
            end
            else begin
                if((energy_valid == 1'b1) && (energy_addr[8:0] == 9'd511) &&
                   (energy_addr[14:9] == last_gate_index)) begin
                    square_frame_last   <= 1'b1;
                end
                else begin
                    square_frame_last   <= 1'b0;
                end
            end
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            gate_energy                 <= 48'd0;
        end
        else begin
            if(start_in == 1'b1) begin
                gate_energy             <= 48'd0;
            end
            else begin
                if(energy_valid == 1'b1) begin
                    if(fft_mode_latch == 1'b1) begin
                        if(energy_addr[9:0] == 10'd1023) begin
                            gate_energy <= 48'd0;
                        end
                        else begin
                            gate_energy <= gate_energy_next;
                        end
                    end
                    else begin
                        if(energy_addr[8:0] == 9'd511) begin
                            gate_energy <= 48'd0;
                        end
                        else begin
                            gate_energy <= gate_energy_next;
                        end
                    end
                end
                else begin
                    gate_energy         <= gate_energy;
                end
            end
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            max_gate_energy             <= 48'd0;
            max_gate_index              <= 6'd0;
        end
        else begin
            if(start_in == 1'b1) begin
                max_gate_energy         <= 48'd0;
                max_gate_index          <= 6'd0;
            end
            else begin
                if(energy_valid == 1'b1) begin
                    if(fft_mode_latch == 1'b1) begin
                        if(energy_addr[9:0] == 10'd1023) begin
                            if(gate_energy_next >= max_gate_energy) begin
                                max_gate_energy <= gate_energy_next;
                                max_gate_index  <= energy_addr[15:10];
                            end
                            else begin
                                max_gate_energy <= max_gate_energy;
                                max_gate_index  <= max_gate_index;
                            end
                        end
                        else begin
                            max_gate_energy     <= max_gate_energy;
                            max_gate_index      <= max_gate_index;
                        end
                    end
                    else begin
                        if(energy_addr[8:0] == 9'd511) begin
                            if(gate_energy_next >= max_gate_energy) begin
                                max_gate_energy <= gate_energy_next;
                                max_gate_index  <= energy_addr[14:9];
                            end
                            else begin
                                max_gate_energy <= max_gate_energy;
                                max_gate_index  <= max_gate_index;
                            end
                        end
                        else begin
                            max_gate_energy     <= max_gate_energy;
                            max_gate_index      <= max_gate_index;
                        end
                    end
                end
                else begin
                    max_gate_energy     <= max_gate_energy;
                    max_gate_index      <= max_gate_index;
                end
            end
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            frame_done                  <= 1'b0;
        end
        else begin
            if(start_in == 1'b1) begin
                frame_done              <= 1'b0;
            end
            else begin
                if(square_frame_last == 1'b1) begin
                    frame_done          <= 1'b1;
                end
                else begin
                    frame_done          <= 1'b0;
                end
            end
        end
    end

     
    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            pulse_peak_dout_en          <= 1'b0;
            pulse_peak_bomen_dout       <= 6'd0;
            pulse_peak_energy_dout      <= 48'd0;
        end
        else begin
            if(frame_done == 1'b1) begin
                pulse_peak_dout_en      <= 1'b1;
                pulse_peak_bomen_dout   <= max_gate_index;
                pulse_peak_energy_dout  <= max_gate_energy;
            end
            else begin
                pulse_peak_dout_en      <= 1'b0;
                pulse_peak_bomen_dout   <= pulse_peak_bomen_dout;
                pulse_peak_energy_dout  <= pulse_peak_energy_dout;
            end
        end
    end

    mult_16sx16s u_mult_ch1_i
    (
        .CLK                        (clk),
        .A                          (ch1_i),
        .B                          (ch1_i),
        .P                          (ch1_i_square)
    );

    mult_16sx16s u_mult_ch1_q
    (
        .CLK                        (clk),
        .A                          (ch1_q),
        .B                          (ch1_q),
        .P                          (ch1_q_square)
    );

    mult_16sx16s u_mult_ch2_i
    (
        .CLK                        (clk),
        .A                          (ch2_i),
        .B                          (ch2_i),
        .P                          (ch2_i_square)
    );

    mult_16sx16s u_mult_ch2_q
    (
        .CLK                        (clk),
        .A                          (ch2_q),
        .B                          (ch2_q),
        .P                          (ch2_q_square)
    );

    mult_16sx16s u_mult_ch3_i
    (
        .CLK                        (clk),
        .A                          (ch3_i),
        .B                          (ch3_i),
        .P                          (ch3_i_square)
    );

    mult_16sx16s u_mult_ch3_q
    (
        .CLK                        (clk),
        .A                          (ch3_q),
        .B                          (ch3_q),
        .P                          (ch3_q_square)
    );

    mult_16sx16s u_mult_ch4_i
    (
        .CLK                        (clk),
        .A                          (ch4_i),
        .B                          (ch4_i),
        .P                          (ch4_i_square)
    );

    mult_16sx16s u_mult_ch4_q
    (
        .CLK                        (clk),
        .A                          (ch4_q),
        .B                          (ch4_q),
        .P                          (ch4_q_square)
    );

    mult_16sx16s u_mult_ch5_i
    (
        .CLK                        (clk),
        .A                          (ch5_i),
        .B                          (ch5_i),
        .P                          (ch5_i_square)
    );

    mult_16sx16s u_mult_ch5_q
    (
        .CLK                        (clk),
        .A                          (ch5_q),
        .B                          (ch5_q),
        .P                          (ch5_q_square)
    );

endmodule
