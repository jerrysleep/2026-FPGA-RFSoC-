`timescale 1ns / 1ps

module tb_ch_pulse_compression_unit_debug;
  localparam integer CLK_PERIOD_NS = 4;
  localparam integer NFFT = 128;
  localparam integer FAR_POINTS = 60;
  localparam integer NEAR_POINTS = 49;
  localparam integer FAR_START_GAP = 363;
  localparam integer NEAR_START_GAP = 147;

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

  wire        dbg_input_fifo_wr_en;
  wire [31:0] dbg_input_fifo_din;
  wire        dbg_reading;
  wire [6:0]  dbg_rd_cnt;
  wire [31:0] dbg_input_fifo_dout;
  wire        dbg_fft_din_valid;
  wire        dbg_fft_saxis_tlast;
  wire [31:0] dbg_fft_dout;
  wire        dbg_fft_dout_valid;
  wire [15:0] dbg_fft_axis_data_tuser;
  wire [31:0] dbg_rom_dout;
  wire        dbg_mul_valid;
  wire [31:0] dbg_fft_dout_d1;
  wire [31:0] dbg_mul_dout;
  wire        dbg_mul_dout_valid;
  wire        dbg_ifft_saxis_tlast;
  wire [31:0] dbg_ifft_dout;
  wire        dbg_ifft_dout_valid;
  wire [15:0] dbg_ifft_axis_data_tuser;
  wire [7:0]  dbg_fft_m_axis_status_tdata;
  wire        dbg_fft_m_axis_status_tvalid;
  wire [7:0]  dbg_ifft_m_axis_status_tdata;
  wire        dbg_ifft_m_axis_status_tvalid;
  wire        dbg_fft_event_fft_overflow;
  wire        dbg_ifft_event_fft_overflow;
  wire        dbg_fft_event_status_channel_halt;
  wire        dbg_ifft_event_status_channel_halt;

  integer num_prt;
  integer start_valid_mode;
  integer log_stage_all;
  integer log_edge_frames;
  integer fd_far;
  integer fd_near;
  integer fd_fft;
  integer fd_mul;
  integer fd_ifft;
  integer fd_dout;
  integer fd_status;
  integer fd_fifo;
  integer scan_code;
  integer prt_idx;
  integer sample_idx;
  integer consumed_points;
  integer wait_cycles;
  integer cycle_count = 0;
  integer fft_frame = 0;
  integer fft_sample = 0;
  integer mul_frame = 0;
  integer mul_sample = 0;
  integer ifft_frame = 0;
  integer ifft_sample = 0;
  integer dout_frame = 0;
  integer dout_sample = 0;
  integer dout_label_mode = 1;
  integer dout_label_frame = 0;
  reg [7:0] dout_label_tuser = 8'd0;
  real in_i_real;
  real in_q_real;
  reg [8*320:1] far_file;
  reg [8*320:1] near_file;
  reg [8*320:1] out_dir;
  reg [8*320:1] dummy_line;

  always #(CLK_PERIOD_NS/2) clk = ~clk;

  function integer should_log_stage_frame;
    input integer frame_idx;
    begin
      if (log_stage_all != 0) begin
        should_log_stage_frame = 1;
      end else if (frame_idx < log_edge_frames) begin
        should_log_stage_frame = 1;
      end else if ((frame_idx >= (num_prt - log_edge_frames)) && (frame_idx < num_prt)) begin
        should_log_stage_frame = 1;
      end else if ((frame_idx >= num_prt) && (frame_idx < (num_prt + log_edge_frames))) begin
        should_log_stage_frame = 1;
      end else if (frame_idx >= ((2 * num_prt) - log_edge_frames)) begin
        should_log_stage_frame = 1;
      end else begin
        should_log_stage_frame = 0;
      end
    end
  endfunction

  ch_pulse_compression_unit_debug dut (
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
    .done(done),
    .dbg_input_fifo_wr_en(dbg_input_fifo_wr_en),
    .dbg_input_fifo_din(dbg_input_fifo_din),
    .dbg_reading(dbg_reading),
    .dbg_rd_cnt(dbg_rd_cnt),
    .dbg_input_fifo_dout(dbg_input_fifo_dout),
    .dbg_fft_din_valid(dbg_fft_din_valid),
    .dbg_fft_saxis_tlast(dbg_fft_saxis_tlast),
    .dbg_fft_dout(dbg_fft_dout),
    .dbg_fft_dout_valid(dbg_fft_dout_valid),
    .dbg_fft_axis_data_tuser(dbg_fft_axis_data_tuser),
    .dbg_rom_dout(dbg_rom_dout),
    .dbg_mul_valid(dbg_mul_valid),
    .dbg_fft_dout_d1(dbg_fft_dout_d1),
    .dbg_mul_dout(dbg_mul_dout),
    .dbg_mul_dout_valid(dbg_mul_dout_valid),
    .dbg_ifft_saxis_tlast(dbg_ifft_saxis_tlast),
    .dbg_ifft_dout(dbg_ifft_dout),
    .dbg_ifft_dout_valid(dbg_ifft_dout_valid),
    .dbg_ifft_axis_data_tuser(dbg_ifft_axis_data_tuser),
    .dbg_fft_m_axis_status_tdata(dbg_fft_m_axis_status_tdata),
    .dbg_fft_m_axis_status_tvalid(dbg_fft_m_axis_status_tvalid),
    .dbg_ifft_m_axis_status_tdata(dbg_ifft_m_axis_status_tdata),
    .dbg_ifft_m_axis_status_tvalid(dbg_ifft_m_axis_status_tvalid),
    .dbg_fft_event_fft_overflow(dbg_fft_event_fft_overflow),
    .dbg_ifft_event_fft_overflow(dbg_ifft_event_fft_overflow),
    .dbg_fft_event_status_channel_halt(dbg_fft_event_status_channel_halt),
    .dbg_ifft_event_status_channel_halt(dbg_ifft_event_status_channel_halt)
  );

  initial begin
    num_prt = 2048;
    start_valid_mode = 1;
    log_stage_all = 1;
    log_edge_frames = 16;
    far_file = "D:/PROJ_Vivado/DAT/Pulse_Compress/0606/matlab_stage1_files/pulsecompress_stage1_out/far_input_iq.csv";
    near_file = "D:/PROJ_Vivado/DAT/Pulse_Compress/0606/matlab_stage1_files/pulsecompress_stage1_out/near_input_iq.csv";
    out_dir = "D:/PROJ_Vivado/DAT/Pulse_Compress/0606/fpga_sim/out";

    if ($value$plusargs("NPRT=%d", num_prt)) begin end
    if ($value$plusargs("START_VALID=%d", start_valid_mode)) begin end
    if ($value$plusargs("LOG_STAGE_ALL=%d", log_stage_all)) begin end
    if ($value$plusargs("LOG_EDGE_FRAMES=%d", log_edge_frames)) begin end
    if ($value$plusargs("FAR_FILE=%s", far_file)) begin end
    if ($value$plusargs("NEAR_FILE=%s", near_file)) begin end
    if ($value$plusargs("OUT_DIR=%s", out_dir)) begin end

    fd_far = $fopen(far_file, "r");
    fd_near = $fopen(near_file, "r");
    if (fd_far == 0 || fd_near == 0) begin
      $display("ERROR: cannot open input csv.");
      $finish;
    end
    scan_code = $fgets(dummy_line, fd_far);
    scan_code = $fgets(dummy_line, fd_near);

    fd_fft = $fopen({out_dir, "/fft_out.csv"}, "w");
    fd_mul = $fopen({out_dir, "/mul_out.csv"}, "w");
    fd_ifft = $fopen({out_dir, "/ifft_out.csv"}, "w");
    fd_dout = $fopen({out_dir, "/dout_out.csv"}, "w");
    fd_status = $fopen({out_dir, "/status_out.csv"}, "w");
    fd_fifo = $fopen({out_dir, "/fifo_fft_in.csv"}, "w");
    if (fd_fft == 0 || fd_mul == 0 || fd_ifft == 0 || fd_dout == 0 || fd_status == 0 || fd_fifo == 0) begin
      $display("ERROR: cannot open output csv.");
      $finish;
    end

    $fwrite(fd_fft, "cycle,mode,frame,sample,tuser,I,Q,raw_hex,rom_I,rom_Q,rom_hex\n");
    $fwrite(fd_mul, "cycle,mode,frame,sample,I,Q,raw_hex,fft_d1_I,fft_d1_Q,coeff_I,coeff_Q\n");
    $fwrite(fd_ifft, "cycle,mode,frame,sample,tuser,I,Q,raw_hex,s_axis_tlast\n");
    $fwrite(fd_dout, "cycle,mode,frame,sample,I,Q,valid\n");
    $fwrite(fd_status, "cycle,fft_status_valid,fft_status,ifft_status_valid,ifft_status,fft_overflow,ifft_overflow,fft_halt,ifft_halt\n");
    $fwrite(fd_fifo, "cycle,mode,wr_en,rd_en,rd_cnt,fft_valid,fft_tlast,I,Q,raw_hex\n");

    repeat (80) @(posedge clk);
    rst <= 1'b0;
    en <= 1'b1;
    repeat (80) @(posedge clk);

    far_or_near <= 1'b1;
    far_or_near_out <= 1'b1;
    run_mode(fd_far, 1, FAR_POINTS, FAR_START_GAP);

    repeat (3000) @(posedge clk);

    far_or_near <= 1'b0;
    far_or_near_out <= 1'b0;
    run_mode(fd_near, 0, NEAR_POINTS, NEAR_START_GAP);

    repeat (8000) @(posedge clk);
    $display("SIM DONE, num_prt=%0d", num_prt);
    $finish;
  end

  task run_mode;
    input integer fd_in;
    input integer mode_value;
    input integer valid_points;
    input integer start_gap;
    begin
      for (prt_idx = 0; prt_idx < num_prt; prt_idx = prt_idx + 1) begin
        @(negedge clk);
        start = 1'b1;
        if (start_valid_mode != 0) begin
          scan_code = $fscanf(fd_in, "%f,%f\n", in_i_real, in_q_real);
          din_i = $rtoi(in_i_real);
          din_q = $rtoi(in_q_real);
          din_valid = 1'b1;
        end else begin
          din_valid = 1'b0;
          din_i = 16'd0;
          din_q = 16'd0;
        end
        @(negedge clk);
        start = 1'b0;

        consumed_points = valid_points + (start_valid_mode != 0);
        for (sample_idx = (start_valid_mode != 0); sample_idx < consumed_points; sample_idx = sample_idx + 1) begin
          scan_code = $fscanf(fd_in, "%f,%f\n", in_i_real, in_q_real);
          @(negedge clk);
          din_i = $rtoi(in_i_real);
          din_q = $rtoi(in_q_real);
          din_valid = 1'b1;
        end

        for (sample_idx = consumed_points; sample_idx < NFFT; sample_idx = sample_idx + 1) begin
          scan_code = $fscanf(fd_in, "%f,%f\n", in_i_real, in_q_real);
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

    if ((log_stage_all != 0) && (dbg_input_fifo_wr_en || dbg_reading || dbg_fft_din_valid)) begin
      $fwrite(fd_fifo, "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%08h\n",
        cycle_count, far_or_near, dbg_input_fifo_wr_en, dbg_reading, dbg_rd_cnt,
        dbg_fft_din_valid, dbg_fft_saxis_tlast,
        $signed(dbg_input_fifo_dout[15:0]), $signed(dbg_input_fifo_dout[31:16]), dbg_input_fifo_dout);
    end

    if (dbg_fft_dout_valid) begin
      if (should_log_stage_frame(fft_frame)) begin
        $fwrite(fd_fft, "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%08h,%0d,%0d,%08h\n",
          cycle_count, (fft_frame < num_prt), fft_frame, fft_sample, dbg_fft_axis_data_tuser,
          $signed(dbg_fft_dout[15:0]), $signed(dbg_fft_dout[31:16]), dbg_fft_dout,
          $signed(dbg_rom_dout[15:0]), $signed(dbg_rom_dout[31:16]), dbg_rom_dout);
      end
      if (fft_sample == NFFT - 1) begin
        fft_sample <= 0;
        fft_frame <= fft_frame + 1;
      end else begin
        fft_sample <= fft_sample + 1;
      end
    end

    if (dbg_mul_dout_valid) begin
      if (should_log_stage_frame(mul_frame)) begin
        $fwrite(fd_mul, "%0d,%0d,%0d,%0d,%0d,%0d,%08h,%0d,%0d,%0d,%0d\n",
          cycle_count, (mul_frame < num_prt), mul_frame, mul_sample,
          $signed(dbg_mul_dout[15:0]), $signed(dbg_mul_dout[31:16]), dbg_mul_dout,
          $signed(dbg_fft_dout_d1[15:0]), $signed(dbg_fft_dout_d1[31:16]),
          $signed(dbg_rom_dout[15:0]), $signed(dbg_rom_dout[31:16]));
      end
      if (mul_sample == NFFT - 1) begin
        mul_sample <= 0;
        mul_frame <= mul_frame + 1;
      end else begin
        mul_sample <= mul_sample + 1;
      end
    end

    if (dbg_ifft_dout_valid) begin
      if (should_log_stage_frame(ifft_frame)) begin
        $fwrite(fd_ifft, "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%08h,%0d\n",
          cycle_count, (ifft_frame < num_prt), ifft_frame, ifft_sample, dbg_ifft_axis_data_tuser,
          $signed(dbg_ifft_dout[15:0]), $signed(dbg_ifft_dout[31:16]), dbg_ifft_dout,
          dbg_ifft_saxis_tlast);
      end
      if (ifft_sample == NFFT - 1) begin
        ifft_sample <= 0;
        ifft_frame <= ifft_frame + 1;
      end else begin
        ifft_sample <= ifft_sample + 1;
      end
    end

    if (dbg_ifft_dout_valid && (dbg_ifft_axis_data_tuser[6:0] < (far_or_near_out ? 7'd61 : 7'd48))) begin
      dout_label_mode <= far_or_near_out;
      dout_label_frame <= ifft_frame;
      dout_label_tuser <= dbg_ifft_axis_data_tuser[7:0];
    end

    if (dout_valid) begin
      $fwrite(fd_dout, "%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",
        cycle_count, dout_label_mode, dout_label_frame, dout_label_tuser,
        $signed(dout_i), $signed(dout_q), dout_valid);
      if ((dout_frame < num_prt && dout_sample == 60) || (dout_frame >= num_prt && dout_sample == 47)) begin
        dout_sample <= 0;
        dout_frame <= dout_frame + 1;
      end else begin
        dout_sample <= dout_sample + 1;
      end
    end

    if (dbg_fft_m_axis_status_tvalid || dbg_ifft_m_axis_status_tvalid ||
        dbg_fft_event_fft_overflow || dbg_ifft_event_fft_overflow ||
        dbg_fft_event_status_channel_halt || dbg_ifft_event_status_channel_halt) begin
      $fwrite(fd_status, "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",
        cycle_count,
        dbg_fft_m_axis_status_tvalid, dbg_fft_m_axis_status_tdata,
        dbg_ifft_m_axis_status_tvalid, dbg_ifft_m_axis_status_tdata,
        dbg_fft_event_fft_overflow, dbg_ifft_event_fft_overflow,
        dbg_fft_event_status_channel_halt, dbg_ifft_event_status_channel_halt);
    end
  end
endmodule
