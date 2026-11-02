`timescale 1ns / 1ps

module tb_ch_pulse_compression_unit_old_ila_far;
  localparam integer CLK_PERIOD_NS = 4;
  localparam integer NFFT = 128;
  localparam integer FAR_POINTS = 60;
  localparam integer FAR_START_GAP = 363;

  reg clk = 1'b0;
  reg rst = 1'b1;
  reg en = 1'b0;
  reg start = 1'b0;
  reg far_or_near = 1'b1;
  reg far_or_near_out = 1'b1;
  reg [15:0] din_i = 16'd0;
  reg [15:0] din_q = 16'd0;
  reg din_valid = 1'b0;

  wire [15:0] dout_i;
  wire [15:0] dout_q;
  wire dout_valid;
  wire done;

  integer num_prt;
  integer start_valid_mode;
  integer fd_in;
  integer fd_dout;
  integer scan_code;
  integer prt_idx;
  integer sample_idx;
  integer consumed_points;
  integer wait_cycles;
  integer cycle_count = 0;
  integer dout_frame = 0;
  integer dout_sample = 0;
  real in_i_real;
  real in_q_real;
  reg [8*320:1] input_file;
  reg [8*320:1] out_dir;
  reg [8*320:1] dummy_line;

  always #(CLK_PERIOD_NS/2) clk = ~clk;

  ch_pulse_compression_unit_old_debug_sim dut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .start(start),
    .far_or_near(far_or_near),
    .far_or_near_out(far_or_near_out),
    .din_i(din_i),
    .din_q(din_q),
    .din_valid(din_valid),
    .dout_i(dout_i),
    .dout_q(dout_q),
    .dout_valid(dout_valid),
    .done(done)
  );

  initial begin
    num_prt = 33;
    start_valid_mode = 1;
    input_file = "D:/PROJ_Vivado/DAT/Pulse_Compress/ila_far_compare/ila_far_adc_decim_input_iq.csv";
    out_dir = "D:/PROJ_Vivado/DAT/Pulse_Compress/ila_far_compare/fpga_old_out";

    if ($value$plusargs("NPRT=%d", num_prt)) begin end
    if ($value$plusargs("START_VALID=%d", start_valid_mode)) begin end
    if ($value$plusargs("INPUT_FILE=%s", input_file)) begin end
    if ($value$plusargs("OUT_DIR=%s", out_dir)) begin end

    fd_in = $fopen(input_file, "r");
    if (fd_in == 0) begin
      $display("ERROR: cannot open input csv.");
      $finish;
    end
    scan_code = $fgets(dummy_line, fd_in);

    fd_dout = $fopen({out_dir, "/dout_out.csv"}, "w");
    if (fd_dout == 0) begin
      $display("ERROR: cannot open output csv.");
      $finish;
    end
    $fwrite(fd_dout, "cycle,frame,sample,I,Q,valid\n");

    repeat (80) @(posedge clk);
    rst <= 1'b0;
    en <= 1'b1;
    repeat (80) @(posedge clk);

    run_far_mode(fd_in, FAR_POINTS, FAR_START_GAP);

    repeat (8000) @(posedge clk);
    $display("OLD SIM DONE, num_prt=%0d", num_prt);
    $finish;
  end

  task run_far_mode;
    input integer fd;
    input integer valid_points;
    input integer start_gap;
    begin
      for (prt_idx = 0; prt_idx < num_prt; prt_idx = prt_idx + 1) begin
        @(negedge clk);
        start = 1'b1;
        if (start_valid_mode != 0) begin
          scan_code = $fscanf(fd, "%f,%f\n", in_i_real, in_q_real);
          din_i = $rtoi(in_i_real);
          din_q = $rtoi(in_q_real);
          din_valid = 1'b1;
        end else begin
          din_i = 16'd0;
          din_q = 16'd0;
          din_valid = 1'b0;
        end
        @(negedge clk);
        start = 1'b0;

        consumed_points = valid_points + (start_valid_mode != 0);
        for (sample_idx = (start_valid_mode != 0); sample_idx < consumed_points; sample_idx = sample_idx + 1) begin
          scan_code = $fscanf(fd, "%f,%f\n", in_i_real, in_q_real);
          @(negedge clk);
          din_i = $rtoi(in_i_real);
          din_q = $rtoi(in_q_real);
          din_valid = 1'b1;
        end

        for (sample_idx = consumed_points; sample_idx < NFFT; sample_idx = sample_idx + 1) begin
          scan_code = $fscanf(fd, "%f,%f\n", in_i_real, in_q_real);
        end

        @(negedge clk);
        din_i = 16'd0;
        din_q = 16'd0;
        din_valid = 1'b0;

        for (wait_cycles = valid_points + 2; wait_cycles < start_gap; wait_cycles = wait_cycles + 1) begin
          @(negedge clk);
        end
      end
    end
  endtask

  always @(posedge clk) begin
    cycle_count <= cycle_count + 1;
    if (dout_valid) begin
      $fwrite(fd_dout, "%0d,%0d,%0d,%0d,%0d,%0d\n",
        cycle_count, dout_frame, dout_sample, $signed(dout_i), $signed(dout_q), dout_valid);
      if (dout_sample == 60) begin
        dout_sample <= 0;
        dout_frame <= dout_frame + 1;
      end else begin
        dout_sample <= dout_sample + 1;
      end
    end
  end
endmodule
